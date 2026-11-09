# Optional record outlines

Adapt only what the task needs to the existing project format. Omit irrelevant fields; these outlines do not require separate files. Policy lives in the references, not the templates.

## Project instruction excerpt

Instruct the project to use the host-discovered `spec-driven-workflow` skill. Link local adaptations when present, requirement/decision sources, current work and applicable setup/run/build/test/lint commands under the [adoption guidance](../references/adoption.md). Preserve unrelated instructions and project-specific constraints. Resolve real locations before adoption.

## Specification

```markdown
# Capability or contract
Status / owner:
Intent, scope and exclusions:
Scenarios, inputs, outcomes, invariants and relevant failure/privacy/recovery behavior:
Acceptance criteria (stable identifiers) and prose verification plan:
Dependencies and decisions; blocking/deferred questions:
Research findings and resulting decisions (when relevant): what changed or was confirmed, supporting sources, applicability, tradeoffs and limitations.
Review findings (when relevant): resolutions and remaining effects on readiness.
Acceptance: not accepted, or approving human/date/scope/reference/exclusions.
```

## Work record

```markdown
# Task
Goal, milestone contribution, completion criteria and authoritative source links:
Allowed changes, exclusions and dependencies:
Acceptance and scoped implementation authorization (separate facts, with references):
Plan: order of work, ownership, consequential dependencies and required verification; migration or recovery considerations when relevant.
Research findings and resulting decisions (when relevant): what changed or was confirmed in the plan, with sources or owning-record links.
Evidence: relevant source state/commands/results/limits, linked to acceptance criteria; satisfied, failed or unverified criteria and not-run or blocked checks:
Completion: changed files, milestone progress, remaining issues and useful next action:
```

## Other records

| Record | Essential contents |
| --- | --- |
| Decision | Status, context, alternatives, decision/rationale, consequences, acceptance reference and any supersession link. Use for significant choices. |
| Roadmap | Project outcome; milestones with demonstrable criteria and dependencies; current/next work; observed progress and evidence. Keep later work coarse. |
| Work index | Current milestone; active/blocked items linked to owning records; next selected work and authorization state; grouped completed navigation. |
| Agent assignment | Use the [assignment checklist](../references/delegation.md#assignment). |
| Continuing-work handoff | Use the [handoff checklist](../references/delegation.md#handoffs). |
