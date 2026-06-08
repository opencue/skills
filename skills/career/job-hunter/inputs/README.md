# Inputs

Paste your data here before running any tool.

**These files are tracked templates, not git-ignored.** Do not commit your filled-in
data. Keep your real resume, contact details, and other personal data in a local copy
outside version control (or add an `inputs/.gitignore` of your own) so it never lands in a PR.

## Which file goes with which tool

| File | Fill in before running | What to put in it |
|---|---|---|
| `my-resume.md` | Most tools | Your full resume, plain text |
| `my-linkedin.md` | `npm run linkedin` | Your LinkedIn profile — headline, about, experience, skills |
| `job-description.md` | Most tools | The full job posting you're targeting |
| `job-search-criteria.md` | `npm run jobs` | Role titles, location, keywords, filters |
| `apply-linkedin-url.txt` | `npm run linkedin-scrape` | Your LinkedIn profile URL (advanced) |
| `search-outreach-target.md` | `npm run outreach` | Target company and contact details |
| `interview-context.md` | `npm run research` | Interviewer name, title, interview type |

## Tips

- Plain text is fine for resume and LinkedIn — don't worry about formatting
- For `job-description.md`, paste the complete posting including requirements
- One job description at a time — overwrite it for each new application
- Your resume in `my-resume.md` is your master resume — the tools tailor it per role
