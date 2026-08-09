---
name: network-baseline
description: >-
  Read-only home LAN network audit from Mac (gateway ping, DNS, key hosts).
  Use when the user says network audit or network baseline. Offer memorise to ops/networking.md.
---

# Network Baseline

Read-only probes — no router config changes.

## Execute

```bash
~/Developer/dotfiles/scripts/agent/network-baseline.sh
```

## After audit

Offer to **memorise** results into vault `ops/networking.md`.

## Reference

Existing baseline: vault `ops/networking.md`, `ops/network-baseline-2026-07.md`

## Runtimes

| Runtime | Invoke |
|---------|--------|
| All | "network audit" or `/network-baseline` |
