---
name: base44-weekly-report
description: Use when asked for a weekly Base44 task report with completed and carried-over counts by assignee.
category: forks
tags: [base44, task-reporting]
---

# Base44 weekly task report

> Adapted from the [Base44 CLI weekly-report template](https://github.com/NagyVikt/cli/blob/10a8d28ec6d7e3b3d20de1fb67c51e44d4bf672c/packages/cli/templates/backend-and-client/base44/agent-skills/weekly-report.md).

Use the selected Base44 project's Task records or a user-supplied export.
Do not write to the project or publish the report. If the project or data
source is ambiguous, resolve it before querying.

1. Use the requested reporting dates, or the last seven days in the
   project's timezone. State the dates and timezone.
2. Count tasks whose completion date falls within that window. Separately
   count tasks open at the end of the window as carried over. Include all
   pages of results and count each task once.
3. Group by the recorded assignee; show unassigned work separately. Present
   a short Markdown table and order completed task details newest first.

Example:

| Assignee | Completed | Carried over |
| --- | ---: | ---: |
| Anna | 3 | 1 |
| Unassigned | 0 | Unknown |

If completion timestamps or historical status are unavailable, mark the
affected count as unknown rather than zero. Omit task details not needed
for the report.
