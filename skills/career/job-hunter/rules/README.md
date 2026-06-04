# Rules Engine

`writing-rules.md` is loaded into every agent prompt before generating output.

These rules exist because AI-generated job content has tells — patterns that
signal to recruiters the writing wasn't done by a person. The rules eliminate
those tells before output is generated.

## How it works

Every agent file references these rules at the top of its prompt. The server
and Claude Code both inject the full contents of `writing-rules.md` into each
request automatically. You don't need to do anything — it's always on.

## Contributing a rule

The most valuable rules come from real job searches — things you noticed
that got a response or killed one.

Format for new rules:
```
- No "[phrase]" — [one line reason why it kills credibility]
```

Submit via pull request to `rules/writing-rules.md` or open an issue.
See [docs/CONTRIBUTING.md](../docs/CONTRIBUTING.md).

## What's in the rules

- Hard punctuation rules (no em dashes, no ellipses)
- Forbidden opening lines ("Hi", "I am writing to express...")
- Filler phrases to delete on sight (proven track record, results-driven, etc.)
- Bullet structure formula (action verb + what + result)
- Tone rules (specific beats vague, sound like a person)
- Email-specific rules
- Cover letter structure
- Resume bullet formula with examples
