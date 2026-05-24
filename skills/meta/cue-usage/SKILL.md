---
description: "When user asks about cue profiles, skills, MCPs, marketplace, or managing their agent setup, guide them through cue CLI commands"
tags: [meta, cue, profiles, skills, mcps]
category: meta
version: 1.0.0
requires_mcps: []
---

# cue — Agent Profile Manager

Use this skill when the user asks about managing profiles, skills, MCPs, or their agent configuration.

## Quick Reference

### Profile Management

```bash
cue list                        # list all profiles
cue current                     # show active profile
cue use <name>                  # activate a profile
cue init                        # interactive setup for current directory
cue auto-detect                 # suggest profile based on project type
cue tree <profile>              # visualize inheritance tree
cue diff <a> <b>                # compare two profiles
cue cost <profile>              # estimate token budget
```

### Skills

```bash
cue skills list                 # skills in active profile
cue skills available            # skills NOT in active profile
cue skills search <query>       # fuzzy search all skills
cue skills add-to-profile <id>  # add skill to active profile
cue skills remove-from-profile <id>  # remove skill
cue skills audit                # find unused skills
cue skills conflicts            # detect contradicting skills
cue skills lint <id>|--all      # quality check
cue skills test <id>|--all      # run skill tests
cue skills new <cat/name>       # scaffold a new skill
cue skills pin <id>             # pin to current version
cue skills changelog <id>       # show version history
```

### MCPs

```bash
cue mcps list                   # MCPs in active profile
cue mcps available              # MCPs NOT in active profile
cue mcps add <id>               # add MCP to active profile
cue mcps remove <id>            # remove MCP
cue mcps health                 # check MCP status
```

### Marketplace (Smithery + npx skills)

```bash
cue marketplace search <query>        # search MCPs + skills
cue marketplace search-mcps <query>   # search MCPs only (Smithery)
cue marketplace search-skills <query> # search skills only
cue marketplace install-mcp <id>      # install MCP via Smithery
cue marketplace install-skill <repo>  # install skill
cue marketplace list-mcps             # list connected MCPs
cue marketplace find-tools <query>    # search tools by intent
```

### Maintenance

```bash
cue doctor                      # detect drift/issues
cue doctor --fix                # auto-repair
cue update                      # git pull + sync
cue update --check              # preview updates
cue stats                       # usage analytics
cue snapshot                    # export current state
cue snapshot restore <file>     # restore from snapshot
```

### Discover (find hidden gem skills on GitHub)

```bash
cue discover search                     # scan GitHub for skill repos
cue discover search --profile marketing # find gems for a specific profile
cue discover search "mcp rust"          # targeted search
cue discover analyze --min-score 8      # Claude reads gems, determines best profile + MCPs + CLIs
cue discover install --dry-run          # preview what would be installed
cue discover install --min-score 8      # install top gems into profiles
cue discover install --notify           # install + notify repo owners via GitHub issue
cue discover mcps                       # find MCP servers to add
cue discover mcps --install             # auto-wire found MCPs into profile
cue discover --export                   # generate docs/discovered.md
cue discover list                       # show cached results
```

### Evolve (auto-learn from sessions)

```bash
cue evolve                      # scan sessions → detect gaps → propose changes
cue evolve --apply              # apply proposed changes (add/remove skills)
cue evolve --history            # show profile evolution log
```

### Profile Creation

```bash
cue skills new <category>/<name>      # scaffold a skill
cue packs create <name> --skills a,b  # create a skill pack
cue import <url|file|org/repo>        # import profile
cue export <profile> --output <path>  # export profile
cue lock <profile>                    # prevent modifications
cue unlock <profile>                  # allow modifications
```

### Inside Claude Code (slash commands)

```
/cue-skills              # browse/search/add/remove skills
/cue-mcps                # list/add/remove/health MCPs
/cue-reload              # rematerialize + restart
/cue-current             # show active profile
/cue-switch              # switch profile
```

## Creating a New Skill

1. Scaffold: `cue skills new review/my-checker`
2. Edit `resources/skills/skills/review/my-checker/SKILL.md`:

```markdown
---
description: "When user asks for X, do Y"
tags: [review, backend]
category: review
version: 1.0.0
requires_mcps: []
---

# My Checker

## When to use
Trigger when user asks for...

## Instructions
1. Step one
2. Step two

## Examples
User: "check this code"
Action: Run the review process
```

3. Add to profile: `cue skills add-to-profile review/my-checker`
4. Reload: `/cue-reload`

## Creating a Profile

```bash
cue create-profile my-project \
  --icon "🦊" \
  --description "My project work" \
  --skills review/code-review,meta/analyze
```

Or interactively: `cue init`

## Key Concepts

- **Profiles** inherit from `core` (shared baseline)
- **Skills** are SKILL.md files that teach the agent specific tasks
- **MCPs** are tool servers (local or remote via Smithery)
- **Packs** group related skills for reuse
- `.cue-profile` file pins a profile to a directory
- Changes require `/cue-reload` to take effect
