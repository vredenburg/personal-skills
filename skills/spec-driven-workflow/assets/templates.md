# Optional record outlines

Adapt only what the task needs to the existing project format. Omit irrelevant fields; these outlines do not require separate files. Policy lives in the references, not the templates.

## Project instruction excerpt

Include links to the accepted workflow, requirement/decision sources, current work and applicable setup/run/build/test/lint commands; record the actual adopted `spec-driven-workflow` version. Preserve unrelated instructions and project-specific constraints. Resolve real locations before adoption.

## Specification

```markdown
# Capability or contract
Status / owner:
Intent, scope and exclusions:
Scenarios, inputs, outcomes, invariants and relevant failure/privacy/recovery behavior:
Acceptance criteria (stable identifiers) and prose verification plan:
Dependencies and decisions; blocking/deferred questions:
Acceptance: not accepted, or approving human/date/scope/reference/exclusions.
```

## Work record

```markdown
# Task
Goal, milestone contribution, completion criteria and authoritative source links:
Allowed changes, exclusions and dependencies:
Acceptance and scoped implementation authorization (separate facts, with references):
Plan, ownership and required verification:
Evidence: relevant source state/commands/results/limits; not-run or blocked checks:
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
