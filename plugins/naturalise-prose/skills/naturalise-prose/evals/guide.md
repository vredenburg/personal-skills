# Behavioral evaluation

This suite contains editing tasks and assessment criteria for naturalise-prose. All passages, voice samples, notes, and reports are synthetic and self-contained. The files define cases and a protocol; they do not include a model runner or completed results.

Keep this directory inside the skill so the cases travel with its maintained source. These are evaluation materials, not references to load during ordinary prose editing.

## Files and coverage

[Case manifest and assessment criteria](cases.json) is for the run coordinator and reviewer. Each prompt file contains only the request and material that the editing model should receive.

| Prompt | Coverage |
| --- | --- |
| [01](prompts/01-voice-match.md) | Matching a separate voice sample without importing its content |
| [02](prompts/02-fiction-repetition.md) | Fictional perspective, dialogue, and purposeful repetition |
| [03](prompts/03-nonfiction-claims.md) | Claims, quotations, attribution, and evidential strength |
| [04](prompts/04-already-effective.md) | Recognizing prose that already works |
| [05](prompts/05-audience-expert.md) | Explanations for expert readers |
| [06](prompts/06-audience-novice.md) | Explanations for novice readers |
| [07](prompts/07-authorized-addition.md) | Adding a supplied fact when requested |
| [08](prompts/08-background-only.md) | Leaving background facts outside the revision |
| [09](prompts/09-long-continuity.md) | Continuity, denominators, qualifications, and pending decisions |
| [10](prompts/10-review-only.md) | Reviewing without rewriting |
| [11](prompts/11-at-the-landing.md) | Repairing awkward prose in a flowing first-person voice |
| [12](prompts/12-the-suitcase.md) | Distinct dialogue voices, reported speech, and physical beats |
| [13](prompts/13-last-shift.md) | A longer fiction scene with object continuity and mixed repetition |
| [14](prompts/14-sunday-opening.md) | A restrained voice sample and a largely effective fiction passage |

Use cases 02 and 11–14 as the primary fiction set. They cover both meaningful repair and proportionate intervention; the remaining cases provide broader regression coverage. Report fiction outcomes separately so that success on routine nonfiction does not obscure the skill's main use. These initial fiction cases mostly use understated literary voices and do not establish performance across every genre or style.

Cases 05 and 06 have identical source text and different audiences. Cases 07 and 08 have identical drafts and notes but different permission to use the note. Keep those materials identical when maintaining each pair.

The manifest uses schema_version and a cases array. Every case has a stable id, title, prompt_file relative to this directory, requirements, quality_targets, and acceptable_variations. Paired cases also share a pair_id.

## Run the cases

1. Select the cases and conditions before generating outputs, and freeze the inputs. Record the repository revision and any uncommitted changes, or content hashes of the actual skill, references, and case files. Record the model identifier, available generation settings, and shared harness instructions. Store run outputs in a separate run directory outside the skill.
2. Give the editing model the contents of one prompt file. Do not send its filename, the case manifest, this guide, the review conversation, or the assessment criteria.
3. For a skill condition, explicitly supply its frozen [SKILL.md](../SKILL.md), [editorial rubric](../references/editorial-rubric.md), and relevant mode-specific references. Fiction evaluations of the current version also need [fiction-editing.md](../references/fiction-editing.md). For the baseline, omit all skill guidance. When testing a revision, include the previous and revised skill as separate conditions alongside the baseline; supply only files belonging to each frozen version. Keep the request, source material, model, and other instructions the same. Use isolated contexts in which an installed skill cannot load implicitly. If that isolation cannot be established, report the run as a skill-only diagnostic rather than claiming a clean comparison.
4. Use a fresh context for every case, condition, and repetition. Three repetitions can reveal variation that a single pilot attempt cannot. Record the planned count: selected cases multiplied by conditions multiplied by repetitions. Preserve every raw response; do not repair responses or select only the best attempt. Record tool or service failures separately.
5. Give an independent reviewer the original prompt, that case's criteria, and the outputs under neutral labels in randomized order. Withhold the condition labels and our prior conclusions until grading is complete.

Supplying the skill and relevant references deliberately tests editorial behavior with the guidance available. It does not test automatic invocation or whether the model discovers the reference files. A previous-version versus revised-version comparison tests the effect of the change; a baseline comparison tests the value of the supplied skill guidance overall.

## Assess each output

First check the case's requirements. Mark each pass, fail, or uncertain, with evidence from the request, source, and output. Also check for unsupported additions, losses beyond the requested scope, or violations of the response format that the case list may not anticipate. An uncertain judgment stays unresolved until reviewed.

Then assess these three dimensions using the case's quality targets:

- Voice and audience fit.
- Clarity and continuity.
- Proportionate intervention.

Use 0 for an outcome that undermines the task or introduces a new problem, 1 for acceptable work with clear room for improvement, and 2 for a well-judged result. Use not applicable when a dimension does not apply. Leaving effective prose unchanged can earn 2; improvement is not measured by the amount changed or the number of words removed.

For fiction, ground these scores in the passage's recognizable voice, subtext, timing, imagery, and movement across sentences and paragraphs. Check whether an actual weakness was repaired as well as whether the story's information survived. Restraint alone does not establish success when a requested repair remains undone. Use the original passage as the comparison point for improvement and the supplied brief or preferences as the standard; do not impose a general preference for clipped, lyrical, or more explicit prose.

A case succeeds only when all requirements pass and every applicable quality dimension scores at least 1. Preserve failures in the report even when another dimension scores well. No preferred rewrite, vocabulary blacklist, or exact sentence shape defines success.

After grading individual outputs, compare each planned pair of conditions blindly. Use neutral output labels and record the preferred label, tie, or neither, with a short explanation. A requirement failure disqualifies an output from being judged successful; if both fail, record neither. Similar outputs across the audience pair are not automatically wrong if the wording serves both audiences. Preserve separate previous-versus-revised and baseline comparisons rather than combining them into one win count.

## Report and refine

For every attempt, retain the case id, condition, repetition, raw response, requirement judgments with evidence, quality scores, and paired preference. Keep the label-to-condition mapping separate during review. Report outcomes by case and show variation between repetitions, rather than hiding failures inside one average.

A useful report includes the actual source and revision around each consequential change, the reason it passed or failed, and unresolved reviewer disagreements. Keep automated checks narrow: numbers, quotations, headings, and labels can be checked mechanically, but those checks cannot establish preserved meaning or voice.

For taste calibration, record the author's blind preferences on a manageable subset separately from model judgments. Note the reasons for any disagreement. A model review alone does not establish that a revision better matches the author's preferences.

These bundled cases become development and regression cases once used to guide revisions. After changing the skill, rerun affected cases and check fresh passages that were not used to design the change. Add cases for demonstrated failures and keep the original requests stable when comparing skill versions.
