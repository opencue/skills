# Upstream provenance

- Project: [MadsLorentzen/ai-job-search](https://github.com/MadsLorentzen/ai-job-search)
- Imported revision: `9833a5dcb75dcbeefb053c09f77639356de834a3`
- Upstream branch: `master`
- Imported: 2026-09-02
- License: MIT; the original license is preserved at
  `assets/workspace-template/LICENSE`.

The bundled workspace is a source snapshot, not a live checkout. Its nested
Agent Skills entrypoints are stored as `SKILL.md.template` so cue's library
catalog does not mistake them for top-level library skills. The initializer
restores those filenames in the user's private workspace.
