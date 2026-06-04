---
name: ssh-copy
description: >-
  Use when the user wants to copy files over SSH: scp a file or directory, or
  rsync over ssh with resume, progress, and delete. Triggers: "scp", "copy to
  the server", "rsync to remote", "download from the server", "sync a folder".
tags: [ssh, scp, rsync, file-transfer]
category: ssh
triggers: ["scp", "copy to the server", "rsync to remote", "download from the server", "sync a folder", "rsync over ssh"]
allowed-tools: Bash(scp:*), Bash(rsync:*), Bash(ssh:*)
---

# SSH copy

Two tools move files over SSH. `scp` is fine for a one-off file. `rsync` wins for
directories and repeat syncs: it transfers only what changed, shows progress, and
resumes a broken transfer. This skill picks the right one and the flags that
matter.

## When to activate

- The user wants to push a file or folder to a server, or pull one down.
- The user wants to sync a directory and skip files that did not change.
- The user says "scp this", "copy to the box", "rsync to prod", or "download the logs".

## Steps

### One file with scp

```bash
scp ./report.pdf user@host:/var/www/           # upload
scp user@host:/var/log/app.log ./              # download
scp -P 2222 ./f user@host:~/                    # non-default port (capital -P)
```

### A directory with scp

```bash
scp -r ./dist user@host:/var/www/
```

### A directory with rsync (preferred for folders and repeats)

```bash
rsync -avz --progress ./dist/ user@host:/var/www/dist/
```

- `-a` preserves permissions, times, and symlinks.
- `-z` compresses in transit.
- `--progress` shows per-file progress.
- A trailing slash on the SOURCE (`./dist/`) copies the CONTENTS into the target. No trailing slash copies the directory itself. This is the most common rsync mistake.

### Resume a large or interrupted transfer

```bash
rsync -avz --partial --progress ./big.tar user@host:~/
```

`--partial` keeps the partial file so a re-run continues instead of restarting.

### Mirror a directory (delete extra files on the target)

```bash
rsync -avz --delete --dry-run ./site/ user@host:/var/www/site/   # preview first
rsync -avz --delete ./site/ user@host:/var/www/site/             # then for real
```

### rsync over a custom SSH port or key

```bash
rsync -avz -e "ssh -p 2222 -i ~/.ssh/id_ed25519_prod" ./dist/ user@host:~/dist/
```

## Prerequisites

- `scp`, `ssh` (OpenSSH client). apt: `sudo apt install -y openssh-client`.
- `rsync` on BOTH local and remote. apt: `sudo apt install -y rsync` · brew: preinstalled.

## Example

> User: "Push my built site to the server, but don't re-upload the 2GB of assets that haven't changed."

1. `rsync -avz --progress ./site/ deploy@web:/var/www/site/`. Only changed files transfer.
2. If the link drops mid-transfer, re-run the same command; rsync continues where it stopped.
3. To remove files on the server that you deleted locally, add `--delete` after a `--dry-run` check.

## Rules

- `scp` uses capital `-P` for port; `ssh` and `rsync -e "ssh -p"` use lowercase `-p`. Mixing them fails silently or errors.
- The rsync trailing-slash rule decides contents-into-target vs directory-into-target. Always `--dry-run` when unsure.
- `--delete` removes files on the target. Run `--dry-run` first, every time, so a wrong source path does not wipe the destination.
- For one small file, `scp` is simplest. For folders or anything you will repeat, use `rsync`.
