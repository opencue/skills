# Import a user's skills into cue with Claude Code

Paste the prompt below into a new Claude Code session opened at the root of the cue skills repository. Replace bracketed values only when needed.

```text
<context>
This repository is the cue skill library. I want to consolidate my reusable Claude Code and Codex skills here so cue can load them consistently for future users and profiles.
</context>

<sources>
- ~/.claude/skills
- ~/.codex/skills
- project-local .claude/skills and .codex/skills under [PROJECT_ROOTS]
- [SOURCE_DIRS]
</sources>

<target>
[CUE_SKILLS_REPO]/skills
Use `meta` only when a skill has no clearer domain category.
Target cue profile: [TARGET_PROFILE=all]
Activate for: [ACTIVATE_FOR=claude|codex|both]
</target>

<task>
Read AGENTS.md and README.md first. Inventory every source SKILL.md, excluding symlinks, generated runtime copies, caches, marketplace downloads, and exact duplicates. Compare content and purpose rather than filenames alone.

Import every non-conflicting user-authored skill as one stable `category/slug` directory. Copy its complete directory, including scripts, references, and assets. Preserve valid internal relative links. Normalize only repository-required metadata and portable paths.

If an existing skill has the same name or overlapping purpose, do not overwrite, delete, rename, or merge it. Record the collision for review and continue with independent imports.
</task>

<validation>
Run:
1. `python scripts/library_inventory.py --write`
2. `scripts/rebuild-catalog-local.sh`
3. `python scripts/library_inventory.py`
4. `cue lint-skill <path>` for each imported skill
5. `SOUL_SKILL_PROFILE=[TARGET_PROFILE] scripts/install-claude.sh` and/or `scripts/install-codex.sh` for the agents selected in [ACTIVATE_FOR]

Fix validation failures caused by this import. Do not expand scope into pre-existing warning cleanup. If activation reports a user-managed path collision, list it and stop for approval rather than moving or replacing it.
</validation>

<output_format>
Return a compact table with source path, destination ID, action (imported/skipped/collision), and validation result. Then list the exact verification commands, activation result, and unresolved collisions.
</output_format>

<stop_conditions>
Stop and ask before deleting files, replacing an existing skill, adding dependencies, changing profile membership, or resolving a semantic collision. Otherwise work autonomously until validation passes.
</stop_conditions>
```

🎯 Target: Claude Code, optimized for literal scope control, safe collision handling, and verified autonomous migration.
