---
name: memorise-vault
description: >-
  Create or update Obsidian vault markdown from conversation, mirror iCloud vault
  to vault-mirror, and git commit/push. Use when the user says "memorise",
  "memorise knowledge", or asks to persist knowledge to the Obsidian vault repo.
---

# Memorise in Vault

Persist conversation knowledge to the Obsidian vault, sync to the local mirror, and push to GitHub.

**Requires Agent mode** — this workflow writes files and runs git.

## Paths

| Role | Path |
|------|------|
| Source vault (write here first) | `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault` |
| Mirror repo | `~/Developer/vault-mirror` |
| Mirror script | `/usr/local/bin/obsidian-to-mirror.sh` |
| Agent scripts | `~/Developer/dotfiles/scripts/agent/` |

**Source of truth:** iCloud vault. Never edit only in `vault-mirror`.

## Workflow

```
- [ ] 1. Infer target path + content from conversation
- [ ] 2. Create/update .md in iCloud vault
- [ ] 3. Pre-commit unrelated mirror-repo changes (if dirty)
- [ ] 4. Run ~/Developer/dotfiles/scripts/agent/sync-vault.sh OR manual mirror+push
- [ ] 5. Report vault path, commit hash, push status
```

### Target folders

| Content | Folder |
|---------|--------|
| Infra, ops, network | `ops/` |
| Life/domain | `areas/` |
| Projects | `projects/` |
| Reference | `notes/` |

Match `ops/*.md` style: `Last updated: YYYY-MM-DD`, tables, `## Related` wikilinks.

### Mac vs Fedora

- **Mac:** full workflow (iCloud write + mirror + push)
- **Fedora:** cannot write iCloud; document intent and ask user to run on Mac, or SSH to Mac

## After content is written

```bash
~/Developer/dotfiles/scripts/agent/sync-vault.sh
```

## Do not

- Write only to `vault-mirror` and skip iCloud
- Commit secrets (.env, tokens)
- Force-push

## Runtimes

| Runtime | Invoke |
|---------|--------|
| Cursor | Say "memorise" |
| Antigravity | Say "memorise" |
| Codex | Reference memorise-vault skill |
| Claude Code | `/memorise-vault` or say "memorise"; `/reload-skills` after deploy |
