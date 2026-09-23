---
name: flow-analyzer
description: >-
  Run Flow Analyzer on a client UI/UX review folder (screencasts, screenshots, text).
  Use when the user says analyze review, flow analyzer, run flow-analyzer, snapshots,
  flow steps, or /flow-analyzer.
---

# Flow Analyzer

Local-first analyze / status / report / snapshots for an external client review directory.
Tooling lives in `~/Developer/personal-tools`; client media stays outside that repo.

## Execute

```bash
~/Developer/dotfiles/scripts/agent/flow-analyzer.sh <command> [review_dir] [flags...]
```

Taxnova (default for this workspace):

```bash
~/Developer/dotfiles/scripts/agent/flow-analyzer.sh analyze ~/Developer/taxnova
~/Developer/dotfiles/scripts/agent/flow-analyzer.sh status ~/Developer/taxnova
~/Developer/dotfiles/scripts/agent/flow-analyzer.sh report ~/Developer/taxnova
~/Developer/dotfiles/scripts/agent/flow-analyzer.sh snapshots ~/Developer/taxnova
```

If `review_dir` is omitted and `$PWD` looks like a review folder (`screencasts/`, `screenshots/`, or `text/`), the wrapper uses `$PWD`.

## Commands & flags

| Command | Purpose |
|---------|---------|
| `analyze` | Full local pipeline → `.flow-analyzer/` + `output/review.md` |
| `status` | Workspace state (`--json` optional) |
| `report` | Re-render `output/review.md` from artifacts |
| `snapshots` | Named flow-step stills from curated `flow-steps.yaml` |

Useful `analyze` flags: `--skip-vision`, `--skip-llm-findings`, `--interval N`, `--language auto`, `--include-temp`, `--json`.

### Snapshots

Requires `<review>/flow-steps.yaml` (or `text/flow-steps.yaml`, or `--map PATH`):

```yaml
version: 1
source: screencasts/part1.mov
steps:
  - id: onboarding-intent
    title: Intent choice
    section: onboarding
    t: "00:00:20"
    note: Optional curator note
```

Writes `output/flow-steps/<NN>-<id>.jpg` + `index.md` and `.flow-analyzer/snapshots/index.json`. Never writes into `screenshots/`.

## Hard rules

- **Never** copy client media into `~/Developer/personal-tools` (or any tool git repo).
- **Never** mutate `screencasts/`, `screenshots/`, or `text/` sources.
- Write only under `<review>/.flow-analyzer/` and `<review>/output/`.
- Keep **observations** (user speech / notes) distinct from **findings** (model hypotheses).

## Preflight

If analyze fails on missing deps:

- Ollama / stack: use skill `local-models-health` ("check ollama").
- Whisper: `whisper-cli` on PATH; model at `~/.local/share/voice-agent/models/ggml-small.bin` (override `FLOW_ANALYZER_WHISPER_MODEL`).
- personal-tools `.venv` / console script missing → bootstrap that repo, then retry.

## Runtimes

| Runtime | Invoke |
|---------|--------|
| All | "analyze review", "flow analyzer", "run flow-analyzer", "snapshots", "flow steps", or `/flow-analyzer` |
