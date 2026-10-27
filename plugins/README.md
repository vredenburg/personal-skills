# Plugin packaging

This catalog packages the existing skills as three independently selectable plugins for Codex and Claude Code:

| Plugin | Canonical skill |
| --- | --- |
| Specification-driven workflow | [spec-driven-workflow](../skills/spec-driven-workflow/SKILL.md) |
| Naturalise prose | [naturalise-prose](../skills/naturalise-prose/SKILL.md) |
| ASUS AniMe Matrix | [asus-anime-matrix](../skills/asus-anime-matrix/SKILL.md) |

For per-device installation and updates, use the [main README](../README.md#install-and-update).

The JSON files here are build inputs. The skill directories remain authoritative and can still be installed independently. Both hosts share one complete copy of each skill in the generated package; the build adds host-specific discovery metadata without rewriting skill files or using symlinks.

[marketplace.json](marketplace.json) owns catalog membership and names. Each `plugins/<name>/plugin.json` owns its version and description. The build derives Claude manifests and catalog entries from those inputs; [claude-marketplace-metadata.json](claude-marketplace-metadata.json) supplies only Claude’s required marketplace owner and its description. There is no second plugin list to maintain.

The optional [global instruction template](../instructions/codex-AGENTS.md) is included at `instructions/codex-AGENTS.md` in the distribution root, outside every plugin bundle. It requires separate installation. Packaging or installing the workflow plugin does not adopt the workflow in a project or change Project Hex's accepted policy.

## Build and check

From the repository root, using Git and Python 3.9 or newer:

```sh
python3 scripts/build_plugins.py
python3 scripts/build_plugins.py --check
```

The build replaces only the ignored `dist/personal-skills/` directory. It generates both catalogs and the Claude manifests, then copies existing tracked and non-ignored untracked files from each selected `skills/<name>/` directory, preserving file contents and permissions. Deleted files are excluded without requiring their deletion to be staged; each skill must still have a `SKILL.md`. The build also copies the optional `instructions/codex-AGENTS.md` template to the distribution root. Other instruction files, ignored local outputs and unrelated repository files are excluded. Symlinks are rejected. The check compares copied files with their sources and generated JSON with the expected metadata, rejecting missing, extra or changed files. If this output is already registered as a local marketplace, build in a scratch checkout when an installation must remain unchanged.

```text
dist/personal-skills/
├── .agents/plugins/marketplace.json       # Codex
├── .claude-plugin/marketplace.json        # Claude Code
├── instructions/codex-AGENTS.md           # Optional template; not installed
└── plugins/
    └── <name>/                           # One directory per plugin
        ├── plugin.json                   # Codex
        ├── .claude-plugin/plugin.json    # Claude Code
        └── skills/<name>/...             # Shared, complete skill
```

Codex uses the portable Agent Plugins format in [OpenAI’s packaging guide](https://developers.openai.com/plugins/build/plugins). Claude Code uses its [plugin manifest](https://code.claude.com/docs/en/plugins-reference) and [marketplace format](https://code.claude.com/docs/en/plugins/marketplace-reference). Both catalogs point to the same plugin directories relative to the generated marketplace root. No MCP server, connector, hook or automatic setup is included.

Claude loads `skills/<name>/SKILL.md`; it does not use `agents/openai.yaml` for invocation policy or icon presentation. That metadata and the icons remain in the complete skill copy for Codex. This packaging adds no Claude-specific model choices or runtime settings. The workflow skill already requires checking the destination host’s capabilities and restrictions.

## Installation remains separate

Building does not register a catalog, install or enable plugins, upload packages, or change harness settings. The source checkout contains authoring metadata; installation uses the generated `plugin-dist` branch through the [commands in the main README](../README.md#install-and-update). The ASUS plugin retains its [hardware and runtime prerequisites](../README.md#prerequisites-and-compatibility); packaging does not install them or run hardware commands.

## Distribution from GitHub

The [Distribute plugins workflow](../.github/workflows/distribute-plugins.yml) builds and checks packages after pushes to `master`. It can also be dispatched manually from `master`. Successful runs publish the generated catalogs and complete plugin directories to `plugin-dist` in the same repository. Editing or validating this setup locally publishes nothing.

The generated distribution has `.agents/plugins/marketplace.json`, `.claude-plugin/marketplace.json`, `plugins/<name>/` and the optional `instructions/codex-AGENTS.md` template at its root. Both hosts use the neutral `plugin-dist` branch name. It contains no active root `AGENTS.md` or `CLAUDE.md`, source workflow, build tooling or project history. Both catalogs point only into `plugins/`, so installing a plugin does not copy or activate the separate template. Author skills on `master`; do not edit the generated branch manually. The initial publication creates an independent history, later publications append commits, and identical packages produce no commit. Each publication commit identifies its source revision.

Runs are serialized, check out current `master`, and skip publication if `master` has advanced during the build. Pushes use normal fast-forward checks; they never force-push. Build or verification failures stop publication and leave the last distribution available. The job uses the repository's `GITHUB_TOKEN` with `contents: write`; repository settings and branch rules must permit it to create and update `plugin-dist`. No extra secret or dependency installation is required on the GitHub-hosted Ubuntu runner.

### Transition from the original branch

The first Codex-only publication is on `codex/plugin-dist`. The new `plugin-dist` branch was seeded at its tip, `4a4e73d50b3b2f6641afa0c249679d16ebbd5a51`, preserving distribution history. The updated workflow appends combined packages to `plugin-dist`; the original branch remains available at its existing revision.

The workflow only updates `plugin-dist`; it does not maintain the original branch as an alias. Git-backed Codex installation from `plugin-dist` has been verified. Other devices and Claude Code runtime installation have not been checked. The current per-device commands are maintained in the [main README](../README.md#install-and-update).

## Maintenance and validation limits

Edit skills under `skills/<name>/`, plugin metadata under `plugins/<name>/plugin.json`, and catalog membership in [marketplace.json](marketplace.json). Rebuild after changing any input. The portable manifests own versions for both hosts; use SemVer, including prerelease or build suffixes when appropriate. This packaging does not alter skill invocation policies or workflow acceptance.

Local build checks establish package completeness, source fidelity and deterministic Claude metadata, with basic manifest checks. They require a nonempty version string but do not perform full schema or SemVer validation. They do not establish host discovery, installation or agent behavior.

Both the original Codex distribution and the combined Codex/Claude packages passed GitHub-hosted publication. Local validation also covered the combined packages and the transition to `plugin-dist` against disposable Git remotes. See the [distribution runs](https://github.com/vredenburg/personal-skills/actions/workflows/distribute-plugins.yml) for current GitHub-hosted publication results. Claude Code is not available in the validation environment, so its authoritative `claude plugin validate` check and runtime discovery remain unverified. When available, validate the generated marketplace and each plugin directory separately before installation.

The generated Claude manifests omit optional `author` metadata because it is not declared in the source manifests. Claude documents this as a warning, which fails validation with `--strict`; it is not a loading error. Do not infer skill authorship from the marketplace owner or invent attribution to suppress the warning.

The [workflow review and pilot record](../../project-hex/docs/work/workflow-extraction-review/README.md) retains its existing limitations; isolation work remains parked. No host activation is part of packaging validation.

Existing skill license files are copied with their skills. The workflow's [unresolved attribution and standalone notice](../README.md#license) remain unresolved; no new license declaration is added.
