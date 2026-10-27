#!/usr/bin/env python3
"""Build or check Codex and Claude Code packages without activating either."""

import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "dist" / "personal-skills"
SCHEMA = "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json"


def source_file(relative):
    path = ROOT / relative
    if not path.resolve().is_relative_to(ROOT):
        raise ValueError(f"Source escapes the repository: {relative}")
    for part in (path, *path.parents):
        if part == ROOT:
            break
        if part.is_symlink():
            raise ValueError(f"Symlinks are not packaged: {relative}")
    return path.read_bytes(), path.stat().st_mode & 0o777


def package_files():
    catalog_file = "plugins/marketplace.json"
    catalog = json.loads(source_file(catalog_file)[0])
    expected = {".agents/plugins/marketplace.json": source_file(catalog_file)}
    claude_metadata = json.loads(source_file("plugins/claude-marketplace-metadata.json")[0])
    if not isinstance(claude_metadata.get("owner"), dict) or not isinstance(
        claude_metadata["owner"].get("name"), str
    ) or not claude_metadata["owner"]["name"].strip():
        raise ValueError("Claude marketplace metadata requires an owner name")
    if not isinstance(claude_metadata.get("description"), str) or not claude_metadata["description"].strip():
        raise ValueError("Claude marketplace metadata requires a description")
    claude_catalog = {
        "name": catalog["name"],
        "owner": claude_metadata["owner"],
        "description": claude_metadata["description"],
        "plugins": [],
    }
    names = set()
    for entry in catalog["plugins"]:
        name = entry["name"]
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name) or name in names:
            raise ValueError(f"Invalid or duplicate plugin name: {name}")
        names.add(name)
        prefix = f"plugins/{name}"
        if entry["source"] != {"source": "local", "path": f"./{prefix}"}:
            raise ValueError(f"Unexpected source for {name}")
        if entry["policy"]["installation"] != "AVAILABLE":
            raise ValueError(f"Plugin must remain optional: {name}")
        manifest_file = f"{prefix}/plugin.json"
        manifest = json.loads(source_file(manifest_file)[0])
        if manifest.get("$schema") != SCHEMA or manifest.get("name") != name:
            raise ValueError(f"Invalid portable manifest: {manifest_file}")
        version = manifest.get("version")
        if not isinstance(version, str) or not version.strip():
            raise ValueError(f"Expected a nonempty version string: {manifest_file}")
        expected[manifest_file] = source_file(manifest_file)
        description = manifest.get("description")
        if not isinstance(description, str) or not description.strip():
            raise ValueError(f"Expected a description: {manifest_file}")
        # Both hosts use this same skill tree; only discovery metadata differs.
        expected[f"{prefix}/.claude-plugin/plugin.json"] = json_file({
            "name": name,
            "version": version,
            "description": description,
        })
        claude_catalog["plugins"].append({
            "name": name,
            "source": f"./{prefix}",
            "description": description,
        })
        skill = f"skills/{name}/"
        listed = subprocess.check_output(
            ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z", "--", skill],
            cwd=ROOT,
        ).decode().split("\0")
        # Git also lists unstaged deletions; keep symlinks for explicit rejection.
        files = {
            path for path in listed
            if path and ((ROOT / path).exists() or (ROOT / path).is_symlink())
        }
        if f"{skill}SKILL.md" not in files:
            raise ValueError(f"Missing skill entry point: {name}")
        for relative in sorted(files):
            expected[f"{prefix}/{relative}"] = source_file(relative)
    if not names:
        raise ValueError("The catalog must contain at least one plugin")
    expected[".claude-plugin/marketplace.json"] = json_file(claude_catalog)
    return expected, names


def json_file(value):
    return (json.dumps(value, indent=2, ensure_ascii=False) + "\n").encode(), 0o644


def verify(directory, expected):
    if directory.is_symlink() or not directory.is_dir():
        raise ValueError(f"Missing build directory: {directory}")
    actual = set()
    for path in directory.rglob("*"):
        if path.is_symlink():
            raise ValueError(f"Unexpected symlink in build: {path}")
        if path.is_file():
            actual.add(path.relative_to(directory).as_posix())
    if actual != set(expected):
        raise ValueError("Build contents differ from sources; rebuild the packages")
    for relative, (content, mode) in expected.items():
        path = directory / relative
        if path.read_bytes() != content or path.stat().st_mode & 0o777 != mode:
            raise ValueError(f"Stale package file: {relative}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="check the existing build without writing files")
    args = parser.parse_args()
    for path in (OUTPUT.parent, OUTPUT):
        if path.is_symlink():
            raise ValueError(f"Build output must not be a symlink: {path}")
    expected, names = package_files()
    if args.check:
        verify(OUTPUT, expected)
        print(f"Verified {len(names)} plugins and {len(expected)} files in {OUTPUT}")
        return
    OUTPUT.parent.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="plugin-build-", dir=OUTPUT.parent) as temporary:
        staged = Path(temporary) / "personal-skills"
        for relative, (content, mode) in expected.items():
            target = staged / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(content)
            target.chmod(mode)
        verify(staged, expected)
        if OUTPUT.exists():
            shutil.rmtree(OUTPUT)
        staged.rename(OUTPUT)
    print(f"Built {len(names)} plugins and {len(expected)} files in {OUTPUT}")
    print("Nothing was registered, installed, enabled or uploaded.")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, KeyError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"Packaging failed: {error}") from error
