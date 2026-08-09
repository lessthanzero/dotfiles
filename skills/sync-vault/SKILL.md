---
name: sync-vault
description: >-
  Mirror iCloud Obsidian vault to vault-mirror and git push without authoring content.
  Use when the user says sync vault or push vault. For writing content use memorise-vault.
---

# Sync Vault

Mirror + push only. Does **not** create or edit vault markdown.

## Execute

```bash
~/Developer/dotfiles/scripts/agent/sync-vault.sh
```

## Requirements

- **Mac only** (iCloud vault path)
- `/usr/local/bin/obsidian-to-mirror.sh` must exist

## vs memorise-vault

| Skill | Writes content | Mirror | Push |
|-------|----------------|--------|------|
| memorise-vault | Yes | Yes | Yes |
| sync-vault | No | Yes | Yes |

## Runtimes

| Runtime | Invoke |
|---------|--------|
| All | "sync vault" or `/sync-vault` |
