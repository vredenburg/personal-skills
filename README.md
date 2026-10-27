# Personal agent skills

This repository holds the maintained source versions of my personal agent skills and global instruction templates. Each skill lives in `skills/<name>/` and can be installed and updated independently on each machine and agent harness. Instruction templates live in `instructions/`; they do not replace this repository's own `AGENTS.md` or active personal instructions.

For another device, go to [Install and update](#install-and-update).

The collection contains these skills:

- [naturalise-prose](skills/naturalise-prose/SKILL.md) removes formulaic prose while preserving meaning, evidence, voice, register, and deliberate style. It includes a [supporting editorial rubric](skills/naturalise-prose/references/editorial-rubric.md), [fiction editing guidance](skills/naturalise-prose/references/fiction-editing.md), and a [behavioral evaluation suite](skills/naturalise-prose/evals/guide.md).
- [asus-anime-matrix](skills/asus-anime-matrix/SKILL.md) creates, previews, validates, and optionally plays ASUS AniMe Matrix animations using verified model geometry. It includes reusable scripts, adaptive battery tooling, and a GA402 profile and LED mask. Generated animations and mascot packs are not included; adaptive playback requires a user-created pack.
- [spec-driven-workflow](skills/spec-driven-workflow/SKILL.md) provides a specification-driven workflow with bounded delegation, milestone direction, handoffs and proportionate verification. **Version 0.1.5 accepted by the owner on 2026-10-27. Installation and project adoption are separate decisions.**

## Global instruction template

The [Codex global instruction template](instructions/codex-AGENTS.md) is an optional companion: it provides personal defaults across projects and guidance on when to use the skill. The skill contains the detailed workflow and works independently. Their source directories are intentionally separate; the global instructions require their own explicit installation. Installing or updating the skill does not apply them.

The template's wording was accepted with version 0.1.5 on 2026-10-27; it is not installed or active. Updating this source does not change active global settings. Acceptance, installation and project adoption are separate decisions.

The extraction, review and pilot history remains in [Project Hex's review record](../project-hex/docs/work/workflow-extraction-review/README.md), linked through a sibling checkout. Isolation work is parked. Moving these sources does not change Hex's accepted workflow or resolve the recorded pilot limitations.

## Install and update

Run these commands in a terminal on each device with Git and the relevant CLI installed. No repository clone or local build is needed. The HTTPS URLs work with this public repository without GitHub SSH keys. Both hosts use the published `plugin-dist` branch.

The examples install `spec-driven-workflow`. To select another plugin, substitute `naturalise-prose` or `asus-anime-matrix` in the plugin commands. Register the marketplace once per host on each device; installing a plugin in Codex does not install it in Claude Code.

### Codex

Install once:

```sh
codex plugin marketplace add https://github.com/vredenburg/personal-skills.git --ref plugin-dist
codex plugin add spec-driven-workflow@personal-skills
```

Update later:

```sh
codex plugin marketplace upgrade personal-skills
codex plugin add spec-driven-workflow@personal-skills
```

The first update command refreshes the catalog; the second applies the selected plugin update. Check its version and enabled state:

```sh
codex plugin list --marketplace personal-skills --json
```

Start a new Codex chat or CLI session afterward. This Git-backed installation and skill discovery have been verified for `spec-driven-workflow`. See the [Codex CLI reference](https://learn.chatgpt.com/docs/cli/reference).

### Claude Code

Install once:

```sh
claude plugin marketplace add 'https://github.com/vredenburg/personal-skills.git#plugin-dist'
claude plugin install spec-driven-workflow@personal-skills --scope user
```

Update manually:

```sh
claude plugin marketplace update personal-skills
claude plugin update spec-driven-workflow@personal-skills --scope user
```

Check the installed version:

```sh
claude plugin list
```

Start a new session or run `/reload-plugins` inside Claude Code. Invoke the workflow with `/spec-driven-workflow:spec-driven-workflow`. See [Claude’s command reference](https://code.claude.com/docs/en/plugins/cli-reference).

For automatic updates, open `/plugin` → **Marketplaces** → **personal-skills** → **Enable auto-update** on each device. Custom marketplaces have this disabled by default. Updates are fetched after startup; use a new session or `/reload-plugins` to load them. See [Claude’s update guide](https://code.claude.com/docs/en/discover-plugins#keep-plugins-updated).

Claude packaging has passed local structural checks and GitHub publication, but its native validator and runtime installation have not yet been tested.

### Publishing updates

When changing a skill, bump the affected package version in `plugins/<name>/plugin.json` and push the source changes to `master`. After the [distribution workflow](https://github.com/vredenburg/personal-skills/actions/workflows/distribute-plugins.yml) succeeds, the update is available on `plugin-dist`. Each device then fetches it through the update commands above or Claude’s enabled auto-update. Do not edit the generated branch directly.

These installations keep the global instruction template separate and do not adopt the workflow in any project. See [plugin packaging](plugins/README.md) for build and maintenance details.

## Prerequisites and compatibility

Skills need a harness that loads `SKILL.md` and reads its relative supporting files. Model access and task tools depend on the harness. Installation requirements are listed under [Install and update](#install-and-update).

- **naturalise-prose:** Text files only, with no scripts, package dependencies, required connectors, credentials, or hardware requirements.
- **asus-anime-matrix:** See the skill's [runtime requirements](skills/asus-anime-matrix/SKILL.md#runtime-requirements) for Bash 4+, ImageMagick 7, GNU-compatible `realpath`, and playback dependencies. Only GA402 geometry is currently included; offline rendering can select that verified profile explicitly. Creating artwork does not start playback.

- **spec-driven-workflow:** Instructions, references and templates only; no scripts, package dependencies or required connectors.

| Harness | Compatibility |
| --- | --- |
| Codex | Skills use `SKILL.md`; all three include `agents/openai.yaml` metadata and matching icons, also used in their plugin listings. |
| Claude Code | Generated Claude marketplace and plugin manifests use the same `SKILL.md` sources. Package publication is verified; Claude validation and runtime discovery are pending. See [plugin packaging](plugins/README.md). |
| Other harnesses | Require support for `SKILL.md` and relative supporting files. Metadata, invocation policy, and discovery paths depend on the harness. |

## License

The existing naturalise-prose and asus-anime-matrix skills and their repository documentation are licensed under the [MIT License](LICENSE). Both skill directories include copies for standalone installations.

The workflow retains its source project's [selected MIT policy](../project-hex/docs/workflows/licensing-and-distribution.md#code-and-documentation). Copyright attribution and a standalone notice remain unresolved; this source transfer adds no license file or licensing decision.
