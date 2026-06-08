---
name: ssh-paste-image
description: >-
  Use when the user wants to paste a local clipboard image into Claude Code
  running over SSH, says "paste image over ssh", "can't paste images on the
  remote", "send screenshot to remote claude", or "/paste-image".
tags: [ssh, clipboard, image, remote, paste]
category: ssh
triggers: ["paste image over ssh", "can't paste images on the remote", "/paste-image", "send screenshot to remote claude", "paste clipboard image remote"]
allowed-tools: Bash(ccimg:*), Bash(go:*), Bash(systemctl:*), Bash(launchctl:*), Bash(scp:*), Read
---

# SSH paste-image

Claude Code can't paste a clipboard image when you run it over SSH: the clipboard
lives on your local machine, the agent runs on the remote host. This skill bridges
the gap. A tiny daemon on your local machine reads the clipboard and serves the
PNG; a client on the remote pulls it through the SSH connection and writes a temp
file the agent can `Read`. The daemon and client are vendored under `scripts/`
(Go source, MIT, from AlexZeitler/claude-ssh-image-skill).

## When to activate

- The user is in a Claude Code session on a remote SSH host and wants to share an image.
- The user says "paste image over ssh", "I can't paste a screenshot on the server", "/paste-image", or "send this image to the remote session".
- A task on the remote needs an image the user has on their local clipboard (a screenshot, a design, an error photo).

Do NOT use this for local sessions (paste works natively) or for copying image files that already exist on the remote (use `ssh-copy`).

## How it works

```
Local Machine                            Remote Server (SSH)
┌──────────────────────┐                 ┌──────────────────────────┐
│  Clipboard (PNG)     │                 │  Claude Code             │
│        │             │                 │        │                 │
│        ▼             │                 │        ▼                 │
│  ccimgd (Port 9998)  │◄────────────────│  ssh-paste-image skill   │
│  - wl-paste/xclip    │  SSH Reverse    │  - TCP request to ccimgd │
│  - returns base64    │  Tunnel         │  - receives base64 image │
│    image in response │  (Port 9998)    │  - saves a temp PNG      │
│                      │                 │  - Read → agent sees it  │
└──────────────────────┘                 └──────────────────────────┘
```

1. The skill runs `ccimg` on the remote, which opens a TCP request to `127.0.0.1:9998`.
2. That port is forwarded over the SSH reverse tunnel to the local `ccimgd`.
3. `ccimgd` reads the clipboard PNG (`wl-paste` on Wayland, `xclip` on X11, `pngpaste` on macOS) and returns base64 JSON.
4. `ccimg` decodes it, writes `/tmp/clipboard-<pid>.png`, and prints the path.
5. The skill uses `Read` on that path so the agent sees the image.

## Prerequisites

- **Build (anywhere with Go):** `go` 1.26+ for `bash scripts/build.sh`.
- **Local machine, Linux Wayland:** `wl-paste` from `wl-clipboard` (apt: `sudo apt install -y wl-clipboard`).
- **Local machine, Linux X11:** `xclip` (apt: `sudo apt install -y xclip`).
- **Local machine, macOS:** `pngpaste` (brew: `brew install pngpaste`).
- **Remote host:** Claude Code, plus the `ccimg` client binary (installed in step 3 below).

## Setup (one time)

### 1. Build the binaries

From this skill's directory (where this SKILL.md lives):

```bash
bash scripts/build.sh
```

This writes static binaries for linux/amd64, linux/arm64, darwin/amd64, darwin/arm64 into `scripts/daemon/` and `scripts/client/`.

### 2. Install the daemon on your LOCAL machine

Linux (systemd user service):

```bash
cp scripts/daemon/ccimgd-linux-amd64 ~/.local/bin/ccimgd   # or -linux-arm64
cp scripts/daemon/ccimgd.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now ccimgd
```

macOS (launchd agent):

```bash
cp scripts/daemon/ccimgd-darwin-arm64 /usr/local/bin/ccimgd   # or -darwin-amd64 on Intel
cp scripts/daemon/com.ccimgd.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.ccimgd.plist
```

### 3. Install the client on the REMOTE host

```bash
scp scripts/client/ccimg-linux-amd64 your-server:~/.local/bin/ccimg   # match the server arch
ssh your-server 'chmod +x ~/.local/bin/ccimg'
```

To skip the per-call permission prompt, add to the remote `~/.claude/settings.json`:

```json
{ "permissions": { "allow": ["Bash(ccimg)"] } }
```

### 4. Open the SSH reverse tunnel

Connect with port 9998 forwarded back to your local daemon:

```bash
ssh -R 9998:localhost:9998 your-server
```

Or make it permanent in `~/.ssh/config` (see the `ssh-tunnel` skill for the pattern):

```
Host your-server
    RemoteForward 9998 localhost:9998
```

## Usage

On the remote session, copy an image to your LOCAL clipboard, then run the client and read the file it prints:

```bash
ccimg
```

Then `Read` the printed path (for example `/tmp/clipboard-12345.png`). The agent now sees the image.

## Example

> User (in an SSH Claude Code session): "here's the broken layout, /paste-image"

1. Run `ccimg` with Bash. It prints `/tmp/clipboard-4821.png`.
2. `Read` `/tmp/clipboard-4821.png`.
3. The screenshot renders in the session and you can act on it.

If `ccimg` prints `Failed to connect to ccimgd`, the reverse tunnel is not up (reconnect with `-R 9998:localhost:9998`). If it prints `Clipboard is empty or does not contain an image`, copy an image first (a file copy is not an image).

## Rules

- The reverse tunnel (`-R 9998:localhost:9998`) is required. No tunnel, no image. This is the most common failure.
- `ccimgd` reads an IMAGE on the clipboard, not a file path. Copy the picture itself (screenshot tools do this).
- Port 9998 is chosen so it can run alongside sshimg.nvim (port 9999) on the same machine.
- The image crosses the existing SSH channel as base64. Nothing extra is exposed to the network.
- Rebuild and reinstall both binaries after editing the Go source; the daemon and client must agree on the protocol.

## Credits

Daemon and client vendored from [claude-ssh-image-skill](https://github.com/AlexZeitler/claude-ssh-image-skill) by Alexander Zeitler, MIT licensed. See `LICENSE`. The `build.sh` adds a linux/arm64 target; the Go sources are otherwise unchanged.
