# Personal agent skills

This repository holds the maintained source versions of my personal agent skills. Each skill lives in `skills/<name>/` and can be installed and updated independently on each machine and agent harness.

The collection contains only [naturalise-prose](skills/naturalise-prose/SKILL.md), which removes formulaic prose while preserving meaning, evidence, voice, register, and deliberate style. It includes `agents/openai.yaml`, a [supporting editorial rubric](skills/naturalise-prose/references/editorial-rubric.md), and [fiction editing guidance](skills/naturalise-prose/references/fiction-editing.md).

The skill also includes a [behavioral evaluation suite](skills/naturalise-prose/evals/guide.md) with editing tasks, assessment criteria, and a protocol for comparing revisions.

## Install and manage skills with an agent

Open this repository in an agent with filesystem access to the target machine, or give the agent the checkout path. Ask it to read [AGENTS.md](AGENTS.md) and manage the skills you choose. For example:

- **Install:** “Read AGENTS.md and install naturalise-prose for Codex.”
- **Update:** “Read AGENTS.md and update my naturalise-prose installation for Codex from this repository.”
- **Remove:** “Read AGENTS.md and remove naturalise-prose from Codex.”

Replace the skill and harness names as needed, and repeat on each machine where you want an installation. Cloning or updating the repository installs nothing; each installation and update is an explicit request.

Once installed in Codex, invoke the skill with `$naturalise-prose`.

## Prerequisites and compatibility

The skill contains only Markdown, YAML, and JSON, with no scripts, package dependencies, required connectors, credentials, or hardware requirements. It needs a harness that loads `SKILL.md` and reads its relative supporting files. Model access and document-editing tools depend on the harness and task. The optional manual commands below require a Unix shell, `rsync`, and `diff`.

| Harness | Compatibility |
| --- | --- |
| Codex | `agents/openai.yaml` supplies UI metadata and permits implicit invocation once installed. |
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
