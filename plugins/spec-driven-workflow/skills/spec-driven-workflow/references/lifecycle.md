# Lifecycle, records and evidence

## Direction and readiness

Frame work by the project outcome, current milestone where present, task goal, sources, allowed changes, exclusions and completion criteria. Revisit that connection when scope expands, discussion repeats or a consequential decision arises. A brief update in the existing record or conversation suffices.

A scope is **sufficiently specified** when its observable behavior, invariants, boundaries, acceptance criteria, consequential dependencies and verification are settled. Address relevant invalid actions, failure, privacy, access and recovery behavior. Resolve blocking questions; defer future choices that cannot change current commitments. Keep business rules independent of delivery mechanisms where the domain and accepted architecture permit.

Review specifications for contradictory requirements, missing observable outcomes, untestable acceptance criteria, unsupported assumptions and unnecessary scope. Resolve material findings or identify their effect on readiness. This can be self-review where independent review is not otherwise required; it adds no approval round.

A **proportionate plan** identifies the order of work, consequential dependencies and how completion will be verified, with migration or recovery considerations when relevant. Use enough detail to guide execution and expose material risks without prescribing routine implementation choices.

It is **ready for implementation** only when the relevant requirements and decisions are accepted, a proportionate plan exists and implementation is explicitly authorized. Waiting for acceptance or authorization is not a specification gap. Present the concrete decision needed; do not compensate by adding speculative design. Executable experiments need their own applicable bounded authorization and produce evidence, not design acceptance.

Add detail or abstractions only for a current requirement, concrete risk or near-term dependency. Leave ordinary internal choices to implementation, and record only consequential deferrals. Do not reopen settled decisions without new evidence or changed requirements.

Work through framing, necessary decisions, specification, review, planning, authorized execution and verification as needed. These are responsibilities, not separate mandatory documents or approval rounds. Reuse satisfied gates and existing records. Once completion criteria are met, report completion; propose relevant follow-up separately.

## Research for specifications and plans

Before settling a specification or plan, identify the concrete requirements, risks or decisions that need evidence, and research relevant practices in proportion to their uncertainty and consequences. Start with repository evidence, accepted decisions and existing conventions. Consult primary external sources when existing evidence is insufficient, potentially stale or missing relevant best practices, standards or technical guidance. Check applicability to the project's versions, constraints and intended use; distinguish source recommendations from project-specific inference.

Account for material findings in requirements, design choices, acceptance criteria or verification. In the owning specification, decision or work record, link the sources supporting consequential choices and explain their implications, tradeoffs, uncertainty and reasons for departing from relevant guidance. A list of links alone is insufficient. Keep product requirements distinct from implementation advice: research does not make a preferred technique mandatory or override accepted commitments. Propose consequential changes through the existing decision process.

Reuse research that remains applicable; revisit it when requirements change, evidence may be stale or a material question remains unresolved. Stop when the evidence is sufficient for the current decisions. If research is unavailable or inconclusive, record the limitation and any assumptions rather than presenting them as established practice. Treat the gap as blocking readiness only if it could materially change current commitments or acceptance criteria; otherwise proceed within the authorized scope. No separate research document or approval stage is required.

## Milestones and work navigation

For sustained work, maintain a compact roadmap of demonstrable milestone outcomes, completion criteria and dependencies. Identify current and next meaningful work; keep later milestones coarse. Report evidence-backed progress and blockers. Roadmap acceptance is direction, not permission to execute every item; task counts are not percentages of effort or release readiness. Propose changes to milestone outcomes or priorities for owner review; update observed progress within the authorized record-maintenance scope.

Use a directory for a coherent effort when related records benefit from it, and reuse it across chats, reviews and follow-up fixes. A separate objective, authorization or lifecycle may warrant separate tracking; a new chat alone does not.

Keep the main work index focused on the current milestone, active/blocked items and next selected work, linked to owning records. Group completed navigation by milestone or outcome, with a separate history index when needed. Preserve approvals and evidence at stable paths; improve navigation before moving directories. Physical reorganization needs applicable scope authorization and affected-link checks. No fixed directory hierarchy or archive schedule is required.

## Record ownership and amendments

Keep requirements in specifications, significant technical choices and rationale in decision records, and plans, authorization, observations and handoffs with their task. Indexes link to these sources rather than duplicating histories. Small work can use a brief plan and evidence in an existing record.

Use the project's status vocabulary. If absent: **Draft** is incomplete; **Proposed** awaits review; **Accepted** has explicit human approval; **Superseded** links to its replacement; **Rejected** retains its reason. Mark unresolved questions **Open**, with blocking/deferred scope. Track implementation and verification separately.

Preserve records establishing requirements, permissions or restrictions: approving human, date, scope/revision, available review reference and exclusions or withdrawals. Chat approval can be recorded without publishing the conversation. Relocation does not change its authority; historical checkout references do not establish current state. Keep agent policy concise, with its revisions in version history, while retaining specification and implementation approval records in their owning documents.

Preserve accepted commitments while proposing substantive changes to behavior, scope, privacy, recovery, architecture or policy. Editorial corrections follow project conventions. Resolve conflicting accepted sources through a human decision, not by silently choosing one. Missing execution evidence is a verification task, not a missing product decision.

## Verify and finish

Use the authorized plan and established checks appropriate to the affected criteria. Inspect only configuration/versions needed to choose or interpret them. Expected outcomes should be independent of the implementation; avoid tests that merely mirror it or add no value for editorial work.

Investigate failures and retain useful reproductions. Do not weaken checks or rerun until green. Once the required checks pass and relevant concerns are resolved, finish. Repeat or broaden verification only for a relevant change, stale evidence, failure or unresolved concern; a cosmetic command correction alone does not invalidate a successful result. Required integrated checks and independent parent verification still apply; [delegation](delegation.md#integration) defines those responsibilities.

Record enough source state, commands, results and limits to reproduce material findings, including versions when relevant. Distinguish passed, failed, not run and blocked. Documentation checks establish links, consistency and scope, not application runtime evidence. Scoped completion does not establish release readiness or satisfy separately defined asset-rights/publication requirements.

Connect completion evidence to the applicable acceptance criteria so it is clear which are satisfied, failed or remain unverified. Use links or a brief explanation in the owning record; a separate traceability matrix is not required. Passing checks establish only the criteria they actually cover.

Finish with changed files, actual checks, limitations, remaining decisions and the result's contribution to the milestone. Use the [handoff procedure](delegation.md#handoffs) when a successor would help; the final response may be the task's handoff.
