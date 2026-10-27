# Delegation and handoffs

## Choose useful parallel work

Delegate substantial independent research, review or separable edits when the time or quality benefit justifies coordination. Handle small or dependent steps directly. Choose concurrency by task independence, available slots, shared resources and the parent's integration capacity; account for existing agents and whether the limit includes the parent. Do not fill slots for their own sake. Reduce or serialize work when conflicts or review backlogs emerge. Independent review is useful where another perspective may catch material errors, not a mandatory pass for every task.

Only the parent delegates. Parallel edits need disjoint ownership and settled interfaces; the parent owns shared configuration and integration. Stop affected parallel edits and serialize when ownership or interface assumptions collide. Continue useful independent work while delegates run, but collect required results before claiming completion.

## Assignment

Use [model selection](model-selection.md), then give each agent:

- Goal, milestone contribution and completion criteria.
- Authoritative sources/statuses, applicable authorization and exclusions.
- Allowed paths and exclusive ownership or a read-only role; dependencies and interfaces.
- Expected output and checks; model/effort and rationale, with material fallback or uncertainty.
- The instruction not to delegate further or expand authority.

Fresh-context assignments must carry relevant decisions and source links; do not assume conversation access or copy irrelevant history. Delegates return referenced findings, changed files, actual checks, limitations and unresolved issues.

A read-only assignment describes authorized behavior, not an enforced read-only sandbox. Inspect the host's actual permissions when isolation matters; subagents may inherit the parent's permissions. Do not claim stronger enforcement than the runtime provides or change permissions without applicable authorization.

## Integration

The parent inspects artifacts and diffs, checks evidence against its source state, independently verifies material claims and runs required integrated checks. A delegate's success report is insufficient. Resolve discrepancies against authoritative sources; report unavailable checks as limitations. Repeat other commands only when changes, stale evidence or unresolved risk justify it.

## Handoffs

Prepare a concise handoff at a task boundary; the final response can suffice. Mark unfinished work accurately. Proactively suggest a successor when a distinct next objective, phase transition or difficult-to-follow context makes a new chat useful. Explain the reason, roadmap contribution, proposed scope and missing approvals. A grounded next objective may be proposed without presenting it as selected or authorized.

Do not suggest a successor routinely after small tasks, repeat a declined suggestion without new cause, invent work or use a handoff to avoid a current blocker. A suggestion does not suspend useful authorized work.

A continuing-work handoff carries the project outcome/milestone, next objective and completion criteria, authoritative sources/statuses, approvals and exclusions, checkout/branch/revision and uncommitted work, completed checks and remaining issues, settled decisions/consequential deferrals, and model/effort rationale. Link owning records rather than duplicating them.

Create or message a successor only with applicable explicit authorization, including advance authorization identifying its trigger, objective and scope. When authorized:

1. Check for an existing successor, including after an uncertain result. Do not create duplicates; messaging still needs authorization.
2. Finish writes and stop editing transferred files. Use a checkout containing required sources and uncommitted work; do not commit merely to enable transfer without commit permission.
3. Create the authorized successor with the scoped handoff and supported settings. Instruct it to inspect repository policy and current Git state before continuing.
4. Report confirmed creation separately from observed startup, including the chat's link or ID. Check supported status when available, but do not wait for work completion merely to finish the handoff. Report queued/unknown states accurately; check uncertain creation before retrying. If creation is unavailable, supply a copy-ready handoff without claiming a chat exists.

Use the host's subagent mechanism for delegated work and its user-chat mechanism for authorized successors; their permissions differ.
