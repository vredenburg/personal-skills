# Adopting or adapting the workflow

Inspect existing instructions, current changes and the project's requirements, decisions and work records. Establish whether the request covers a proposal, specified edits, personal installation or project adoption. Follow the [skill boundaries](../SKILL.md#boundaries-that-apply-throughout); acceptance of content alone does not authorize all these actions.

## Fit the existing project

Map responsibilities to current locations. Where none exist, these are possible homes, not mandatory scaffolding:

| Responsibility | Possible home |
| --- | --- |
| Stable instructions and source navigation | Root `AGENTS.md` |
| Behavior and boundary contracts | `specs/` |
| Significant technical choices and rationale | `docs/decisions/` |
| Project-specific development rules | `docs/workflows/development.md` |
| Roadmap, plans, authorization and evidence | Existing roadmap and `docs/work/` |
| Current milestone and active work; links to completed history | `docs/work/README.md` |

Keep one authoritative home per subject. Small projects may combine responsibilities in one document. Agree only the gaps needed for adoption: source locations, differences from existing policy, relevant architecture/rights/release boundaries, verification and how collaborators access the workflow. Unrelated future technical decisions need not block adoption.

Local workflow guidance contains project-specific prerequisites, explicit exceptions and links to authoritative sources. Reference the skill's generic procedures rather than paraphrasing them. Create a local workflow document only when those adaptations warrant one; prefer `docs/workflows/development.md` for a new location while respecting existing organization. Keep document conventions in the project's documentation guide and current decisions in their owning records.

Ensure repository instructions link to the actual setup, run, build, test and lint commands that apply, including necessary working directories or prerequisites. Reuse authoritative project documentation; mark unavailable or unverified commands honestly rather than inventing them. Documenting a command does not authorize installing dependencies or executing it outside the task's scope.

## Propose, apply and maintain

Keep a small adoption proposal focused on concrete file/policy changes, necessary local adaptations and the decision still needed. Link existing policy rather than repeating scope/status statements or adding a separate evaluation plan unless the task calls for one. Preserve accepted content until a substantive amendment is approved. Apply only the authorized scope, without requesting approval already given. Do not overwrite personal instructions or activate a skill merely to demonstrate a proposal.

Instruct the project to use the host-discovered skill. Do not introduce workflow-version baselines, per-reference pins or routine upgrade-approval procedures unless explicitly required by the project. Project requirements, authorizations and explicit local exceptions remain authoritative; surface substantive conflicts rather than silently changing them. Observed versions may belong in execution evidence when relevant; plugin release versioning and dependency pins are separate concerns.

If the skill is unavailable, disclose the gap and continue only work adequately covered by available repository guidance. Do not automatically create a duplicate local workflow, install the skill or add synchronization tooling.

Check links, status and scope consistency. Report what is proposed, accepted, installed or adopted from actual evidence. After an authorized instruction change, verify loading through the host when available; otherwise mark loading unverified.

Before wider adoption, validate a small representative sample through actual authorized runs: explicit use, implicit selection and an adjacent request that should not select the skill. Inspect actions and artifacts for scope adherence, unnecessary files or repeated approval requests; hypothetical review alone does not establish reliable behavior. Start with existing tools and retain observed failures as focused regression cases, without requiring a new evaluation framework.
