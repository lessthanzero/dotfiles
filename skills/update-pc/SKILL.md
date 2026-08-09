---
name: update-pc
description: >-
  Safely upgrade Fedora KDE/Plasma on pc (192.168.1.172) with coupled kf6+plasma
  packages. Use when the user says update pc, update linux, or update remote pc.
  Never run dnf upgrade -y kf6-* alone.
---

# Update PC (Fedora KDE)

Safely upgrade the Fedora workstation without breaking plasmalogin/KWin.

## Critical rule

**Never:** `dnf upgrade -y kf6-*` alone — breaks display (see vault `ops/fedora-kde-updates.md`).

## Execute

```bash
~/Developer/dotfiles/scripts/agent/update-pc.sh
```

Dry run on Fedora: `plasma-safe-upgrade --dry-run`

## Host behaviour

| Where you run | Action |
|---------------|--------|
| Mac | SSH to `pc` (fallback `pc-remote`) → `plasma-safe-upgrade` |
| Fedora (hostname fedora) | Local `plasma-safe-upgrade` |

## Post-check

- `verify-plasma-versions.sh` must pass
- Reboot if kernel changed
- If black screen: SSH + vault recovery playbook in `ops/fedora-kde-updates.md`

## Runtimes

| Runtime | Invoke |
|---------|--------|
| Cursor / Antigravity / Codex | "update pc" |
| Claude Code | `/update-pc` |
