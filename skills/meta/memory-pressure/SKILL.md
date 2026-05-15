---
name: memory-pressure
description: "Use when user says 'free RAM', 'memory is full', 'compact memory', 'swap out', 'reclaim memory', 'use more swap', 'my box is slow', 'high memory usage', or shows a screenshot of mem at >85%. Push idle pages from app.slice into zstd-compressed zram (cost ~1 GB zram per ~3-4 GB RAM freed). NOT for OOM crashes — use diagnose for those."
---

# Memory pressure — push idle pages to zram

The user's box is tuned for aggressive zstd-zram swap (see memory note `project-memory-tuning`). When RAM crosses ~85% used, you can free real RAM by forcing the kernel to reclaim idle anonymous pages into zram. zstd compression ~3-4× → 4 GB reclaimed costs ~1.2 GB zram.

## The tool

`~/.local/bin/swap-out [GiB] [scope]`

- Default: `swap-out` → 5 GiB from `app.slice` (claude, codex, next-server, rust-analyzer, etc.)
- Scopes: `app` (app.slice only), `user` (whole user@.service), `session` (session.slice / desktop bits)
- No sudo needed — user owns the cgroup `memory.reclaim` file.

The tool writes to `memory.reclaim` via the cgroup v2 interface. The kernel pages out *only what it considers idle*; active pages stay resident. If insufficient idle pages exist the kernel returns "partial" — safe, no thrashing, no OOM risk.

## Auto-pressure timer

`swap-out-pressure.timer` runs every 10 min and only fires `swap-out` when:
- MemAvailable < 6 GiB (real pressure), AND
- zram DATA < 60% of DISKSIZE (room to absorb more), AND
- swap is not already on `/swapfile` (would mean zram is saturated)

Check status: `systemctl --user status swap-out-pressure.timer`
Logs: `journalctl --user -t swap-out-pressure`

## Decision tree

```
User: "memory is high / slow box"
  │
  ├─ Check: free -h (Available column)
  │           zramctl    (DATA / DISKSIZE ratio)
  │           swapon --show  (any data on /swapfile/?)
  │
  ├─ If Available < 5 GiB AND zram has headroom (DATA < 60%):
  │       run: swap-out 4
  │       (expect 3-4 GiB RAM freed, ~1.2 GiB zram cost)
  │
  ├─ If zram already >80% full:
  │       zram saturating. Don't reclaim — kernel will fall to disk swap.
  │       Instead: identify and close heavy idle processes.
  │
  └─ If disk swap (/swapfile*) is in use:
        zram is full. swap-out won't help here.
        Real fix: kill idle agent sessions or reduce concurrent load.
```

## Don't

- Don't run `swap-out` reactively after every command — the auto timer handles steady-state pressure.
- Don't bump it past 8 GiB in one shot; kernel may stall briefly while reclaiming large batches.
- Don't touch `vm.swappiness` or `memory.high` to "force" more swap — already set to 100. Use `memory.reclaim` instead.
- Don't suggest killing claude/codex sessions as the FIRST option. Reclaim is cheaper. Only suggest closing sessions if zram is already saturated.

## Related

- Memory note: `project-memory-tuning` — full tuning record (sysctl, zram, slice caps, wrappers, claude-mem patches).
- `gbrain-janitor.timer` — kills orphaned `bun gbrain serve` procs (PPID=1 or systemd-user).
- `nextdev` — caps Next.js dev V8 heap to prevent slow leaks.
