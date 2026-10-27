# Personal agent skills

This repository holds the maintained source versions of my personal agent skills and global instruction templates. Each skill lives in `skills/<name>/` and can be installed and updated independently on each machine and agent harness. Instruction templates live in `instructions/`; they do not replace this repository's own `AGENTS.md` or active personal instructions.

The collection contains these skills:

- [naturalise-prose](skills/naturalise-prose/SKILL.md) removes formulaic prose while preserving meaning, evidence, voice, register, and deliberate style. It includes a [supporting editorial rubric](skills/naturalise-prose/references/editorial-rubric.md), [fiction editing guidance](skills/naturalise-prose/references/fiction-editing.md), and a [behavioral evaluation suite](skills/naturalise-prose/evals/guide.md).
- [asus-anime-matrix](skills/asus-anime-matrix/SKILL.md) creates, previews, validates, and optionally plays ASUS AniMe Matrix animations using verified model geometry. It includes reusable scripts, adaptive battery tooling, and a GA402 profile and LED mask. Generated animations and mascot packs are not included; adaptive playback requires a user-created pack.

- [spec-driven-workflow](skills/spec-driven-workflow/SKILL.md) provides a specification-driven workflow with bounded delegation, milestone direction, handoffs and proportionate verification. **Version 0.1.5 accepted by the owner on 2026-10-27; not installed or adopted in any project.**

## Global instruction template

The [Codex global instruction template](instructions/codex-AGENTS.md) is an optional companion: it provides personal defaults across projects and guidance on when to use the skill. The skill contains the detailed workflow and works independently. Their source directories are intentionally separate; the global instructions require their own explicit installation. Installing or updating the skill does not apply them.

The template's wording was accepted with version 0.1.5 on 2026-10-27; it is not installed or active. Updating this source does not change active global settings. Acceptance, installation and project adoption are separate decisions.

The extraction, review and pilot history remains in [Project Hex's review record](../project-hex/docs/work/workflow-extraction-review/README.md), linked through a sibling checkout. Isolation work is parked. Moving these sources does not change Hex's accepted workflow or resolve the recorded pilot limitations.

## Install and manage skills with an agent

Open this repository in an agent with filesystem access to the target machine, or give the agent the checkout path. Ask it to read [AGENTS.md](AGENTS.md) and manage the skills you choose. For example:

- **Install:** “Read AGENTS.md and install naturalise-prose for Codex.”
- **Update:** “Read AGENTS.md and update my naturalise-prose installation for Codex from this repository.”
- **Remove:** “Read AGENTS.md and remove naturalise-prose from Codex.”

Replace the skill and harness names as needed, and repeat on each machine where you want an installation. Cloning or updating the repository installs nothing; each installation and update is an explicit request.

Once installed in Codex, invoke the selected skill with `$naturalise-prose` or `$asus-anime-matrix`.

## Prerequisites and compatibility

Skills need a harness that loads `SKILL.md` and reads its relative supporting files. Model access and task tools depend on the harness. The optional manual commands below require a Unix shell, `rsync`, and `diff`.

- **naturalise-prose:** Text files only, with no scripts, package dependencies, required connectors, credentials, or hardware requirements.
- **asus-anime-matrix:** Bash and ImageMagick 7 (`magick`) for rendering and validation; Python 3 (standard library only) for the adaptive controller. Live playback additionally requires compatible ASUS AniMe Matrix hardware, `asusctl` with its daemon, and systemd user services. Adaptive mode reads Linux power-supply information. Only GA402 geometry is currently included; offline rendering can select that verified profile explicitly. Creating artwork does not start playback.

- **spec-driven-workflow:** Instructions, references and templates only; no scripts, package dependencies or required connectors.

| Harness | Compatibility |
| --- | --- |
| Codex | Skills use `SKILL.md`; the existing naturalise-prose and asus-anime-matrix skills also provide `agents/openai.yaml` metadata. The workflow skill has no UI metadata file. |
| Other harnesses | Require support for `SKILL.md` and relative supporting files. Metadata, invocation policy, and discovery paths depend on the harness. |

## Manual installation and updating

<details>
<summary>Shell commands for managing a selected skill</summary>

### Install

Keep the checkout in a regular project directory, outside skill discovery directories. Copy the skills you want into each selected harness's skill directory; separate copies let you choose when each installation receives updates.

The example below uses a Codex-specific destination. Codex also supports shared `.agents/skills` locations; a private destination keeps harness selections independent. See the [official skill documentation](https://learn.chatgpt.com/docs/build-skills) for discovery details.

From the repository root, set the following paths in your shell. For another compatible harness, replace `skill_root` with its own skill directory.

```sh
skill_repo="$(pwd)"
skill_name="naturalise-prose"
skill_root="${CODEX_HOME:-$HOME/.codex}/skills"
skill_src="$skill_repo/skills/$skill_name"
skill_dst="$skill_root/$skill_name"
```

To install the complete skill folder, run:

```sh
(
  set -eu
  test -f "$skill_src/SKILL.md"
  test ! -e "$skill_dst"
  test ! -L "$skill_dst"
  mkdir -p "$skill_dst"
  rsync -a "$skill_src/" "$skill_dst/"
  diff -r "$skill_src" "$skill_dst"
)
```

If the destination already exists, use the update procedure. Confirm discovery afterward and restart Codex if needed. Invoke with `$naturalise-prose` in Codex; its policy also allows automatic selection for matching requests.

### Update

Update the repository checkout to the version you want to use, then set the paths above for the installation you want to update. Back up any installed edits you want to keep outside skill discovery directories.

Preview the update:

```sh
(
  set -eu
  test -f "$skill_src/SKILL.md"
  test -d "$skill_dst"
  test ! -L "$skill_dst"
  rsync -ac --delete --dry-run --itemize-changes "$skill_src/" "$skill_dst/"
)
```

After reviewing the preview, apply it to that skill alone:

```sh
(
  set -eu
  test -f "$skill_src/SKILL.md"
  test -d "$skill_dst"
  test ! -L "$skill_dst"
  rsync -ac --delete "$skill_src/" "$skill_dst/"
  diff -r "$skill_src" "$skill_dst"
)
```

`--delete` removes obsolete files inside the selected skill directory, so `skill_dst` must point to one skill. Checksums detect changes even when sizes and timestamps match.

To uninstall a skill from a harness, remove its installed copy and refresh the harness.

</details>

## License

The existing naturalise-prose and asus-anime-matrix skills and their repository documentation are licensed under the [MIT License](LICENSE). Both skill directories include copies for standalone installations.

The workflow retains its source project's [selected MIT policy](../project-hex/docs/workflows/licensing-and-distribution.md#code-and-documentation). Copyright attribution and a standalone notice remain unresolved; this source transfer adds no license file or licensing decision.
