---
name: sync-repos
description: >-
  Git pull --ff-only on allowlisted Developer repos (dotfiles, vault-mirror,
  home-network-topology, local-models, personal-tools). Use when the user says
  sync repos or pull all repos. Never push unless user explicitly requests.
---

# Sync Repos

Pull-only sync for homelab git repos.

## Execute

```bash
~/Developer/dotfiles/scripts/agent/sync-repos.sh
```

## Allowlist

See `skills/sync-repos/repos.yaml` in dotfiles.

## Safety

- Default: **pull-only** (`git pull --ff-only`)
- Do not push unless user explicitly asks in the session
- iCloud vault is not a git repo — use `sync-vault` for vault-mirror

## Runtimes

| Runtime | Invoke |
|---------|--------|
| All | "sync repos" or `/sync-repos` (Claude Code) |
