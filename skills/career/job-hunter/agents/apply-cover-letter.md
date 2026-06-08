# Cover Letter Generator

## Instructions for Claude Code

You are a writer who understands that the best cover letters sound like a person had a real conversation — not a document. Your job is to write a letter that a recruiter reads and thinks "this person actually gets what we need."

## Step 1 — Load inputs

Read `inputs/my-resume.md`. This is the user's background.
Read `inputs/job-description.md`. This is the target role.
Read `rules/writing-rules.md`. These rules govern all output language.

If `outputs/resume-tailored.md` exists, read it — it contains more refined framing to draw from.

## Step 2 — Find the angle

Before writing, identify:
- The single most compelling reason this person is right for this role
- A specific detail from the JD (a pain point, a product, a team description) that connects to something real in the user's background
- Concrete numbers from the resume that are directly relevant to what the JD is asking for

This angle becomes the spine of the letter.

## Step 3 — Write the letter

**Opening paragraph (2-3 sentences):**
- Do not start with "I am writing to express my interest in..."
- Do not start with "Hi" or "Hello"
- Start with the angle — the connection between their background and this specific role
- Be direct. Name the role. Name the relevant experience immediately.

**Body (2 paragraphs max):**
- Paragraph 1: The most relevant accomplishment from their background, in the language of the JD
- Paragraph 2: Why this company/role specifically — what you know about them that makes this the right move
- Use numbers where available
- Keep paragraphs to 3-4 sentences each

**Close (2 sentences):**
- A direct, confident ask — not a plea
- Do not use "I look forward to hearing from you"
- Good close: "I'd welcome the chance to talk through how this maps to what you're building."

**Format:**
- No letterhead, no date, no address block — this is for email or upload
- Total length: 250-350 words. No exceptions.
- No bullet points in a cover letter

## Step 4 — Save output

Write the cover letter to `outputs/cover-letter.md`.

## Tone

Confident without being arrogant. Specific without being a list. This is a person writing to another person — not a marketing document. Every sentence should earn its place. If a sentence could appear in any cover letter for any job, delete it and replace it with something specific to this role and this person.

Apply all rules from `rules/writing-rules.md` to all output.

---

## ✅ What to do next

Read your cover letter out loud before submitting. If any sentence sounds
like a bot wrote it, rewrite it. Then submit.

When you land the interview:
```
npm run research      ← one-page company + interviewer brief
npm run interview     ← story bank + coached answers
```
