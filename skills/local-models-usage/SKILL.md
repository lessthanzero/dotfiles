---
name: local-models-usage
description: >-
  Report local-models content-free token/cost usage and attempt/admission metrics.
  Use when the user says model usage, local models usage, token usage,
  local-models metrics, or /local-models-usage.
---

# Local Models Usage

Content-free telemetry from the local-models ledger (no prompt/response text).

## Execute

```bash
# Token / cost report (default)
~/Developer/dotfiles/scripts/agent/local-models-usage.sh usage --days 7

# Attempt / quality / admission metrics
~/Developer/dotfiles/scripts/agent/local-models-usage.sh metrics --days 30
```

Defaults when the user does not specify a window: `usage --days 7`.

When the user mentions Taxnova or Flow Analyzer, filter:

```bash
~/Developer/dotfiles/scripts/agent/local-models-usage.sh usage --days 7 --project flow-analyzer
~/Developer/dotfiles/scripts/agent/local-models-usage.sh metrics --days 30 --project flow-analyzer
```

Other useful flags: `--today`, `-v` / `--verbose` (usage), `--import-legacy` (metrics).

## Hard rules

- **Report only** by default — do not run `--prune` unless the user explicitly asks to prune metrics.
- Never dump or reconstruct prompt/response content; telemetry is content-free.
- Summarize the printed report for the user (totals, by-project, by-model); do not invent numbers.

## Related

- Stack reachability: skill `local-models-health` ("check ollama").

## Runtimes

| Runtime | Invoke |
|---------|--------|
| All | "model usage", "local models usage", "token usage", "local-models metrics", or `/local-models-usage` |
