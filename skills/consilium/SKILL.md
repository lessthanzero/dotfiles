---
name: consilium
description: >-
  Convene local + cloud model peers (Ollama, Antigravity/agy, Codex, optional
  Cursor agent) for a consolidated second opinion. Use when the user says
  consilium, peer review, multi-model opinion, council, ask the peers, or
  /consilium.
---

# Consilium

CLI-agnostic multi-peer opinion panel. Works from Cursor, Claude Code, Codex,
Antigravity, or a plain shell — same wrapper.

## Execute

```bash
# Prompt as args
~/Developer/dotfiles/scripts/agent/consilium.sh "Should I refinance X?"

# Prompt on stdin
echo "Question…" | ~/Developer/dotfiles/scripts/agent/consilium.sh

# Context file + question
~/Developer/dotfiles/scripts/agent/consilium.sh --context ./brief.md "Opine on option 3"

# Subset / extras
~/Developer/dotfiles/scripts/agent/consilium.sh --peers qwen,agy,codex "…"
~/Developer/dotfiles/scripts/agent/consilium.sh --with-cursor "…"   # also call `agent -p --mode ask`
~/Developer/dotfiles/scripts/agent/consilium.sh --out ./peer.json "…"
```

Default peers (parallel): **qwen** (Ollama `qwen2.5:7b`), **agy** (`gemini-3.8-flash-medium`), **codex** (Codex CLI). Cursor is opt-in (`--with-cursor`) — slower and billed separately.

## Agent workflow

1. Build a tight CONTEXT + QUESTION (facts labelled; no invented rates/fees).
2. Run the wrapper; wait for JSON + printed peer blocks.
3. **You** (host agent) synthesize: table of verdicts, agreements, disagreements, merged recommendation, must-verify. Do not rubber-stamp the loudest peer.
4. Discount peers that invent numbers or contradict labelled FACTS; say so.

## Output contract (each peer)

Peers are asked for:

1. `VERDICT`
2. `KEY_POINTS` (max 4)
3. `RISKS_OR_GAPS` (max 4)
4. `MUST_VERIFY` (max 3)
5. `ONE_SENTENCE`

Wrapper writes JSON (`ok` / `error` / `content` / latency per peer) and prints the same.

## Hard rules

- Advisory only — peers do not edit files or run side effects.
- Prefer pounds / concrete checks over vibes.
- Missing peer → continue; mark panel **INCOMPLETE** if fewer than 2 succeed.
- Do not claim a personalised soft-quote APR unless the user or a lookup provided it.
- Stack down? Use skill `local-models-health` for Ollama; `agy` / `codex` / `agent` must be on PATH and signed in.

## Runtimes

| Runtime | Invoke |
|---------|--------|
| All | "consilium", "peer review", "ask the peers", "multi-model opinion", `/consilium` |
