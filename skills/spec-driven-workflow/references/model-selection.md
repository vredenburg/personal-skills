# Model and reasoning selection

For each assignment, choose model and effort together from uncertainty, interacting constraints and difficulty of detecting mistakes before choosing whether to inherit conversation context. Honor explicit user choices and preserve useful context. Stronger capability may be justified immediately; a smaller-model failure is not a prerequisite. More reasoning on a smaller model is not assumed equivalent to a stronger model.

## Starting point and adjustment

Use current model-specific guidance and live host support. Retain explicit user choices that apply to the target agent and settings required by the host. Otherwise start from the selected model's documented default effort supported by the host, then adjust for the assignment and observed results. A configured parent default alone does not require subagents to use the same model and effort. Do not assume the same effort label represents equivalent behavior across models.

For mechanical, readily checked work, consider a lighter available model. Use a capable general coding model for ordinary implementation and review; favor stronger reasoning capability for ambiguity or interacting contracts whose errors are hard to detect. These are selection criteria, not a mandatory escalation ladder or benchmark claims.

Adjust effort for unresolved reasoning errors, difficult edge cases, latency and verification cost. Record the task-based reason for a departure from the starting setting. Do not replace explicit user settings merely to match generic recommendations. Reassess after meaningful model or host changes rather than preserving an untested table of fixed pairs.

## Apply and disclose

Record the actual selected model and effort with a brief task-specific reason once per assignment, including when retaining the parent’s settings. If the inherited pair cannot be verified, disclose that uncertainty. Distinguish recommendation from applied settings when they differ or application is unverified. Prompt wording does not configure runtime settings. Use permitted tool parameters and disclose fallback; do not install or reconfigure a host just to match a recommendation.

Inspect live tool restrictions. In the authoring environment, full-conversation subagents inherit settings; overrides require fresh context. Weigh the cost of supplying fresh context against the assignment’s capability needs before selecting inheritance. Using the same pair remains appropriate when justified by that assessment. Successor model overrides require an explicit user model choice, otherwise the configured default applies. Recheck these constraints at the destination; a workflow rubric cannot override them.

Every pair retains the same authorization and verification obligations. [Official Codex guidance](https://learn.chatgpt.com/docs/learn/best-practices) provides current starting recommendations; local task evidence determines whether an adjustment helps.
