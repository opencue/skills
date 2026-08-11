# Import a user's skills into cue with Codex

Paste the prompt below into a new Codex session opened at the root of the cue skills repository. Replace bracketed values only when needed.

```text
Import my reusable coding-agent skills into this cue skills repository.

Sources to inspect:
- ~/.codex/skills
- ~/.claude/skills
- project-local .codex/skills and .claude/skills directories under [PROJECT_ROOTS]
- any additional paths in [SOURCE_DIRS]

Target: [CUE_SKILLS_REPO]/skills
Default category when no domain is evident: meta
Target cue profile: [TARGET_PROFILE=all]
Activate for: [ACTIVATE_FOR=codex|claude|both]

Requirements:
1. Read this repository's AGENTS.md and README.md before changing files.
2. Inventory source SKILL.md files. Ignore symlinks, caches, generated runtime copies, marketplace caches, and exact duplicates.
3. Compare by content and purpose, not filename alone. Never overwrite an existing skill silently.
4. For each new skill, choose one stable `category/slug` ID, copy its complete directory (SKILL.md, scripts, references, and assets), and make internal relative links continue to work.
5. Normalize only what the repository requires: valid frontmatter, unique name or explicit collision report, trigger-oriented description, portable relative paths, and category matching the destination folder.
6. Do not delete, rename, or merge an existing skill without stopping and reporting the collision.
7. Run `python scripts/library_inventory.py --write`, rebuild the catalog with `scripts/rebuild-catalog-local.sh`, then run `python scripts/library_inventory.py` and `cue lint-skill` on every imported skill.
8. Activate the selected profile with `SOUL_SKILL_PROFILE=[TARGET_PROFILE] scripts/install-codex.sh` and/or `SOUL_SKILL_PROFILE=[TARGET_PROFILE] scripts/install-claude.sh`. If activation reports a user-managed path collision, do not move or replace it; list the path and stop for approval.
9. Finish with a table: source, destination ID, action (imported/skipped/collision), validation result. Include the exact commands run and activation result.

Done when all non-conflicting user-authored skills are copied, catalogs and README metadata are refreshed, validation passes, cue activation succeeds for the selected agents, and unresolved collisions are listed without destructive changes.
```

🎯 Target: Codex, optimized for autonomous repository inspection, conservative imports, and command-backed completion.
