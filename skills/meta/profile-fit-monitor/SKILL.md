---
name: profile-fit-monitor
description: "Notices when the active cue profile is a poor fit for the current work and suggests switching. Use when user says \"wrong profile\", \"switch profile\", \"this profile doesn't fit\", \"better profile for this\", or proactively when reaching for skills/tools that aren't loaded (e.g. backend work in a frontend profile)."
---

# Profile Fit Monitor

Track how well the active profile matches what the user is actually doing. If you notice any of:

- You're doing work outside the profile's domain (e.g. backend work in a frontend profile, design work in a backend profile).
- None of the loaded skills are relevant to what the user is asking.
- You keep needing tools or skills that aren't in this profile.

Then **after completing the user's immediate request**, surface the mismatch with a one-line suggestion:

> 💡 This session has been mostly [backend / infra / docs / …] work — your current profile is **{active-profile}**.
> A better fit might be **[suggested]**. Switch with: `/cue switch [name]` or `echo [name] > .cue-profile`

## Rules

- Only suggest once per session — don't nag.
- Never interrupt urgent or in-flight work to suggest a switch; wait for a natural break.
- If the user has explicitly pinned the profile (`.cue-profile` present, or recently ran `/cue switch`), assume they meant it and stay quiet unless the mismatch is extreme.
- Match the suggested profile to the work category — don't suggest randomly. If unsure, just describe the mismatch without picking a target.
