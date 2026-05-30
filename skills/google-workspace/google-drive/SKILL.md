---
name: google-drive
description: >-
  Use when user says "upload to Drive", "create a doc", "share file",
  "search Drive", "create spreadsheet", "make a presentation", "list my files",
  "move file", "create folder", "calendar event", "schedule meeting",
  "Google Drive", "Google Docs", "Google Sheets", or "Google Slides".
  Manages files, docs, sheets, slides, and calendar via google-drive-mcp
  and gws CLI.
tags: [google, drive, docs, sheets, slides, calendar, workspace]
category: google-workspace
version: 1.0.0
requires_mcps: [google-drive-mcp]
allowed-tools: Bash(gws:*), mcp__google-drive-mcp__*
---

# Google Drive Operations

Manage Google Drive files, Docs, Sheets, Slides, and Calendar through the
google-drive-mcp server and the `gws` CLI.

## When to activate

- User wants to search, upload, create, move, rename, or delete Drive files
- User wants to create or edit Google Docs, Sheets, or Slides
- User wants to share files or manage permissions
- User wants to create or manage calendar events
- User mentions "Google Drive", "Google Docs", "Sheets", "Slides", or "Calendar"

## Two tools available

1. **google-drive-mcp** — MCP server with full CRUD for Drive/Docs/Sheets/Slides/Calendar
2. **gws CLI** — Google Workspace CLI for admin and batch operations

## Step 1 — Identify the operation type

| User intent | Tool | Action |
|---|---|---|
| Search files | MCP | `search` with query or `rawQuery=true` for Drive API syntax |
| List folder | MCP | `listFolder` with optional `folderId` |
| Create text file | MCP | `createTextFile` (.txt or .md) |
| Upload local file | MCP | `uploadFile` with `localPath` |
| Create Google Doc | MCP | `createGoogleDoc` with name + content |
| Create spreadsheet | MCP | `createGoogleSheet` with name + data |
| Create presentation | MCP | `createGoogleSlides` with slides array |
| Share a file | MCP | `shareFile` or `addPermission` |
| Calendar event | MCP | `createCalendarEvent` with summary + start + end |
| Batch operations | CLI | `gws drive`, `gws docs`, `gws sheets` |

## Step 2 — Execute with the right tool

### MCP operations (preferred for single-file actions)

Search:
```
search(query: "quarterly report", pageSize: 10)
search(query: "mimeType='application/vnd.google-apps.spreadsheet'", rawQuery: true)
```

Create a document:
```
createGoogleDoc(name: "Meeting Notes", content: "# Meeting Notes\n\n...")
```

Create a spreadsheet:
```
createGoogleSheet(name: "Budget", headers: ["Item", "Amount", "Category"])
```

Share a file:
```
shareFile(fileId: "abc123", emailAddress: "user@example.com", role: "writer")
```

Calendar:
```
createCalendarEvent(summary: "Team Standup", start: {dateTime: "2024-01-15T09:00:00Z"}, end: {dateTime: "2024-01-15T09:30:00Z"})
```

### gws CLI (for admin/batch operations)

```bash
# List files
gws drive list

# Upload a file
gws drive upload ./report.pdf

# Download a file
gws drive download <file-id>

# Share a file
gws drive share <file-id> --email user@example.com --role writer
```

## Step 3 — Verify and report

After any operation:
1. Confirm the action completed (check returned file ID or status)
2. Report the file URL if created/uploaded: `https://drive.google.com/file/d/<id>`
3. For shared files, confirm the permission was applied

## Rules

- Always confirm before destructive operations (delete, overwrite)
- When sharing, confirm email and permission level with the user first
- For large uploads, warn about potential timeout (use `--api-timeout` flag)
- Default search to 10 results unless user asks for more
- Use `rawQuery=true` for advanced Drive API queries (date filters, MIME types)
- For calendar events, always include timezone context

## Prerequisites

- **gws CLI**: `npm install -g @googleworkspace/cli`
- **OAuth credentials**: Place `gcp-oauth.keys.json` at `~/.config/google-drive-mcp/`
- **First-time auth**: Run `npx @piotr-agier/google-drive-mcp auth` to complete OAuth flow
- **Required Google APIs**: Drive, Docs, Sheets, Slides, Calendar (enable in GCP Console)
