---
name: homelab-health
description: >-
  Read-only health check for Fedora pc, Tailscale, plasmalogin, and SSH reachability.
  Use when the user says homelab health, check pc, or is fedora up.
---

# Homelab Health

Read-only checks — safe to run anytime.

## Execute

```bash
~/Developer/dotfiles/scripts/agent/homelab-health.sh
```

## Checks

- Tailscale status
- SSH `pc` (LAN) and `pc-remote` (Tailscale)
- `verify-plasma-versions.sh` + plasmalogin on pc

## Reference

Vault: `ops/homelab-links.md`

## Runtimes

| Runtime | Invoke |
|---------|--------|
| All | "homelab health" or `/homelab-health` |
