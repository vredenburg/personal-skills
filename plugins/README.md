# Plugin packaging

This catalog packages the existing skills as three independently selectable plugins:

| Plugin | Canonical skill |
| --- | --- |
| Specification-driven workflow | [spec-driven-workflow](../skills/spec-driven-workflow/SKILL.md) |
| Naturalise prose | [naturalise-prose](../skills/naturalise-prose/SKILL.md) |
| ASUS AniMe Matrix | [asus-anime-matrix](../skills/asus-anime-matrix/SKILL.md) |

The JSON files here are build inputs. The skill directories remain authoritative and can still be installed independently. The build copies their files into complete plugin directories; it does not use symlinks or references back to this checkout.

The optional [global instruction template](../instructions/codex-AGENTS.md) is excluded from every plugin. It requires separate installation. Packaging or installing the workflow plugin does not adopt the workflow in a project or change Project Hex's accepted policy.

## Build and check

From the repository root, using Git and Python 3.9 or newer:

```sh
python3 scripts/build_plugins.py
python3 scripts/build_plugins.py --check
```

The build replaces only the ignored `dist/personal-skills/` directory. It copies existing tracked and non-ignored untracked files from each selected `skills/<name>/` directory, preserving file contents and permissions. Deleted files are excluded without requiring their deletion to be staged; each skill must still have a `SKILL.md`. Ignored local outputs, global instructions and unrelated repository files are excluded. Symlinks are rejected. The check compares every packaged file with its current source and rejects missing, extra or changed files.

```text
dist/personal-skills/
├── .agents/plugins/marketplace.json
└── plugins/
    ├── spec-driven-workflow/
    │   ├── plugin.json
    │   └── skills/spec-driven-workflow/...
    ├── naturalise-prose/
    │   ├── plugin.json
    │   └── skills/naturalise-prose/...
    └── asus-anime-matrix/
        ├── plugin.json
        └── skills/asus-anime-matrix/...
```

The packages use the portable Agent Plugins manifest format described in [OpenAI's packaging guide](https://developers.openai.com/plugins/build/plugins). The catalog uses local paths relative to the generated marketplace root, with each plugin available for individual selection. No MCP server, connector, hook or automatic setup is included.

## Installation remains separate

Building does not register the catalog, install or enable plugins, upload packages, or change harness settings. The source catalog stays at `plugins/marketplace.json`, outside active discovery locations. The generated catalog is inside ignored build output; do not register the source checkout as a marketplace because its plugin directories contain metadata only.

For a later authorized installation, use `dist/personal-skills/` as the local marketplace root and select the desired plugins through the target host's supported flow. Check that host's format support first. Registering a remote copy of this repository alone is not supported by this layout: the generated packages must be built and made available on that machine. Publication and remote distribution remain separate work.

Choose either the standalone skill or the plugin containing it for a given harness to avoid duplicate discovery. Existing standalone installations are not migrated by the build. The ASUS plugin retains its [hardware and runtime prerequisites](../README.md#prerequisites-and-compatibility); packaging does not install them or run hardware commands.

## Maintenance and validation limits

Edit skills under `skills/<name>/`, plugin metadata under `plugins/<name>/plugin.json`, and catalog membership in [marketplace.json](marketplace.json). Rebuild after changing any input. The manifests own package versions; use SemVer, including prerelease or build suffixes when appropriate. This packaging does not alter skill invocation policies or workflow acceptance.

Local build checks establish package completeness and source fidelity, with basic manifest checks. They require a nonempty version string but do not perform full schema or SemVer validation. They do not establish host discovery, installation or agent behavior. The [workflow review and pilot record](../../project-hex/docs/work/workflow-extraction-review/README.md) retains its existing limitations; isolation work remains parked. No host activation is part of packaging validation.

Existing skill license files are copied with their skills. The workflow's [unresolved attribution and standalone notice](../README.md#license) remain unresolved; no new license declaration is added.
