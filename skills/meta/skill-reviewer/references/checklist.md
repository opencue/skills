# Skill Quality Checklist

Complete checklist from Anthropic's official best practices + community patterns.
Use this as a pass/fail gate before shipping any skill.

## Core quality (must pass all)

- [ ] Description is specific and includes key terms
- [ ] Description includes both WHAT the skill does and WHEN to use it
- [ ] Description is written in 3rd person (no "I" or "you")
- [ ] Description is under 1024 characters
- [ ] Description is slightly "pushy" — Claude undertriggers by default
- [ ] SKILL.md body is under 500 lines
- [ ] Additional details are in separate reference files (if needed)
- [ ] No time-sensitive information (or in "old patterns" section)
- [ ] Consistent terminology throughout (pick one term, use it everywhere)
- [ ] Examples are concrete, not abstract
- [ ] File references are one level deep from SKILL.md
- [ ] Progressive disclosure used appropriately
- [ ] Workflows have clear numbered steps
- [ ] "What this skill does NOT do" section present (prevents false triggers)

## Description checklist (the #1 activation lever)

- [ ] Contains capability statement (WHAT)
- [ ] Contains "Use when..." trigger conditions (WHEN)
- [ ] Includes 5+ specific trigger keywords from real user requests
- [ ] Mentions file types/formats if applicable (.xlsx, .pdf, etc.)
- [ ] No vague terms ("helps with", "does stuff", "processes data")
- [ ] Tested mentally: "would a user typing X cause Claude to pick this?"
- [ ] Slightly pushy: "Make sure to use this skill whenever..."

## Frontmatter (spec compliance R001-R008)

- [ ] `name`: present, max 64 chars, lowercase+hyphens only
- [ ] `name`: no "anthropic" or "claude" reserved words
- [ ] `description`: present, non-empty, max 1024 chars
- [ ] `description`: no XML tags
- [ ] `description`: contains trigger phrase ("when user says X")
- [ ] `tags`: present with relevant categories
- [ ] `category`: present
- [ ] `allowed-tools`: lists tools the skill shells out to
- [ ] `requires_mcps`: lists MCP servers needed (empty array if none)

## Body structure

- [ ] Starts with 1-2 sentence summary (what + why)
- [ ] "When to activate" section with bullet triggers
- [ ] Steps use imperative form ("Run X", not "You could try X")
- [ ] Steps include actual bash commands with expected output
- [ ] Rules section explains WHY (not just "MUST" / "NEVER")
- [ ] No deeply nested references (A → B → C)
- [ ] Long reference files (>100 lines) have table of contents

## Examples (activation multiplier: 50% → 72-90%)

- [ ] At least one input/output example present
- [ ] Examples use realistic user language (not abstract)
- [ ] Examples include context (file paths, personal details, casual speech)
- [ ] Examples show different phrasings of same intent
- [ ] Examples section is longer than rules section (Anthropic recommendation)

## Code and scripts

- [ ] Scripts solve problems rather than punt to Claude
- [ ] Error handling is explicit and helpful (not just `throw`)
- [ ] No "voodoo constants" — all values justified with comments
- [ ] Required packages listed in instructions
- [ ] Scripts have clear documentation
- [ ] No Windows-style paths (all forward slashes)
- [ ] Validation/verification steps for critical operations
- [ ] Feedback loops included for quality-critical tasks

## Testing (before shipping)

- [ ] At least 3 eval scenarios created (should-trigger + should-not-trigger)
- [ ] Tested with realistic user prompts (not "process data")
- [ ] Verified skill activates on intended triggers
- [ ] Verified skill does NOT activate on adjacent queries
- [ ] Run `cue lint-skill` — passes R001-R008

## Progressive disclosure patterns

### When to split into reference files:

- SKILL.md approaching 500 lines → split
- Multiple domains/frameworks → one file per domain
- Large API reference → separate reference.md
- Many examples → separate examples.md

### File organization:

```
skill-name/
├── SKILL.md              # Entry point (<500 lines)
├── references/           # Loaded on-demand
│   ├── api.md
│   └── patterns.md
├── examples/             # Input/output pairs
│   └── examples.md
└── scripts/              # Executable helpers
    └── validate.py
```

## Activation debugging

If a skill isn't triggering:

1. **Check description** — does it contain the exact words the user types?
2. **Check competition** — is another skill's description a better match?
3. **Check complexity** — simple one-step tasks may not trigger skills at all
4. **Check token budget** — total descriptions across all skills share 15,000 chars
5. **Add "Use when..." explicitly** — the single highest-impact fix
6. **Add examples** — boosts activation from 50% to 72-90%
7. **Make description pushier** — "Make sure to use this whenever..."

## Anti-patterns (instant fail)

- [ ] ❌ Description says "Helps with documents" (too vague)
- [ ] ❌ Description uses 1st/2nd person ("I can help you")
- [ ] ❌ Body says "consider doing X" (not actionable)
- [ ] ❌ Offers 5+ tool options without a default ("use pypdf or pdfplumber or...")
- [ ] ❌ References go 3 levels deep (SKILL → file → file → actual info)
- [ ] ❌ Contains time-sensitive info ("before August 2025, use...")
- [ ] ❌ >500 lines without progressive disclosure
- [ ] ❌ No examples for a skill that produces output
- [ ] ❌ Shells out to CLIs not declared in `allowed-tools`
