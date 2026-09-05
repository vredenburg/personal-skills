# Repository guidance

- Treat `skills/<name>/` as the authoritative source for each skill. Make lasting changes here rather than in installed copies.
- Keep each skill self-contained. Store its supporting files inside its directory and use relative references within the skill. Preserve its name and invocation policy unless the requested change requires otherwise.
- Keep the collection under the ordinary `skills/` directory, outside automatically discovered skill directories. Do not register or symlink the whole collection as a harness search path.
- Adding or editing a skill must not install or enable it, update installed copies, or change active harness configuration. Handle installation only when requested, selecting individual skills for the intended machine and harness.
- Keep changes small and scoped to the request. Add installation automation, machine profiles, or additional skills only when requested.
- Keep the README focused on human-facing collection information, prerequisites, installation, updating, and usage. Put repository maintenance instructions here and skill-specific workflows in the relevant skill. Keep documentation portable and focused on ongoing use.
- Check changed skill metadata and local references. When copying a skill, include all supporting files and verify the complete copy against its source. Report pre-existing issues separately instead of silently changing the skill.
- Do not commit, push, publish, or add a license without an explicit request.

## Managing requested installations

- Resolve the named skills under `skills/` and confirm the target harness's compatibility and discovery path from its configuration or documentation. Use a harness-specific destination to preserve independent selection.
- Install complete copies of the selected skill directories, including supporting files. Keep the checkout outside discovery directories and leave source files unchanged during installation.
- If a destination already exists, compare it with the source. Treat an identical copy as already installed. Preserve differing installed files in a backup outside discovery directories before replacing them. Synchronize only the selected skill directory, including removal of obsolete files.
- After installation or updating, verify the copied files and local references. Report the destination and whether harness discovery was verified; mention any required refresh or restart.
- For removal, delete only the selected installed copy. Keep the repository's source skill and other installations intact.
