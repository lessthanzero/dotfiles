---
name: local-models-health
description: >-
  Check Ollama and local-models stack on Fedora pc via health.sh or API probe.
  Use when the user says check ollama or local models health.
---

# Local Models Health

Check Ollama / local-models on Fedora pc.

## Execute

```bash
~/Developer/dotfiles/scripts/agent/local-models-health.sh
```

## Behaviour

| Host | Action |
|------|--------|
| Mac | SSH to `pc` → `~/Developer/local-models/scripts/health.sh` |
| Fedora | Run health.sh locally or curl Ollama API |

## Reference

Vault: `ops/linux-local-tasks.md`

## Runtimes

| Runtime | Invoke |
|---------|--------|
| All | "check ollama" or `/local-models-health` |
