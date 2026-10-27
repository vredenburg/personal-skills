# Personal agent skills

This repository holds the maintained source versions of my personal agent skills and global instruction templates. Each skill lives in `skills/<name>/` and can be installed and updated independently on each machine and agent harness. Instruction templates live in `instructions/`; they do not replace this repository's own `AGENTS.md` or active personal instructions.

For another device, go to [Install and update](#install-and-update).

The collection contains these skills:

- [naturalise-prose](skills/naturalise-prose/SKILL.md) removes formulaic prose while preserving meaning, evidence, voice, register, and deliberate style. It includes a [supporting editorial rubric](skills/naturalise-prose/references/editorial-rubric.md), [fiction editing guidance](skills/naturalise-prose/references/fiction-editing.md), and a [behavioral evaluation suite](skills/naturalise-prose/evals/guide.md).
- [asus-anime-matrix](skills/asus-anime-matrix/SKILL.md) creates, previews, validates, and optionally plays ASUS AniMe Matrix animations using verified model geometry. It includes reusable scripts, adaptive battery tooling, and a GA402 profile and LED mask. Generated animations and mascot packs are not included; adaptive playback requires a user-created pack.
- [spec-driven-workflow](skills/spec-driven-workflow/SKILL.md) provides a specification-driven workflow with bounded delegation, milestone direction, handoffs and proportionate verification.

## Global instruction template

The [Codex global instruction template](instructions/codex-AGENTS.md) is an optional companion: it provides personal defaults across projects and guidance on when to use the skill. The skill contains the detailed workflow and works independently. Install the template separately by merging the relevant guidance into your personal Codex instructions. Installing or updating the skill does not apply it. The `codex-` filename prefix identifies the intended host; this file is a template for Codex personal instructions, not a Claude Code configuration file.

The distribution build includes the template at `instructions/codex-AGENTS.md`, alongside the marketplace and outside all plugin bundles. It is available as the [distribution copy](https://github.com/vredenburg/personal-skills/blob/plugin-dist/instructions/codex-AGENTS.md). Downloading or updating the marketplace does not apply it as global instructions.

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

The spec-driven-workflow skill does not yet include a standalone license notice; its copyright attribution remains unresolved.
