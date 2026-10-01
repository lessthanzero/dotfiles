#!/usr/bin/env bash
# Consilium — parallel local + cloud peer opinions (CLI-agnostic).
# Usage: consilium.sh [--context FILE] [--peers LIST] [--with-cursor] [--out PATH] [PROMPT...]
#        echo PROMPT | consilium.sh …
set -euo pipefail

DOTFILES="${HOME}/Developer/dotfiles"
LM="${HOME}/Developer/local-models"
PT="${HOME}/Developer/personal-tools"
OUT=""
CONTEXT_FILE=""
PEERS="qwen,agy,codex"
WITH_CURSOR=0
MAX_CONTEXT_CHARS=16000
ALLOW_LARGE_CONTEXT=0
PROMPT_ARGS=()

usage() {
  cat <<'EOF'
Usage: consilium.sh [options] [prompt...]
       echo prompt | consilium.sh [options]

Options:
  --context FILE           Extra context prepended to the prompt
  --max-context-chars NUM  Safety character cap for context (default: 16000, ~4k tokens)
  --allow-large-context    Bypass safety cap and send full unbudgeted context
  --peers LIST             Comma list: qwen,agy,codex,cursor (default: qwen,agy,codex)
  --with-cursor            Append cursor peer (agent -p --mode ask)
  --out PATH               Write JSON results (default: /tmp/consilium-<ts>.json)
  -h, --help               Show help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --context) CONTEXT_FILE="${2:-}"; shift 2 ;;
    --max-context-chars) MAX_CONTEXT_CHARS="${2:-16000}"; shift 2 ;;
    --allow-large-context) ALLOW_LARGE_CONTEXT=1; shift ;;
    --peers) PEERS="${2:-}"; shift 2 ;;
    --with-cursor) WITH_CURSOR=1; shift ;;
    --out) OUT="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; PROMPT_ARGS+=("$@"); break ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *) PROMPT_ARGS+=("$1"); shift ;;
  esac
done

if [[ "$WITH_CURSOR" -eq 1 && "$PEERS" != *cursor* ]]; then
  PEERS="${PEERS},cursor"
fi

PROMPT=""
if [[ ${#PROMPT_ARGS[@]} -gt 0 ]]; then
  PROMPT="${PROMPT_ARGS[*]}"
elif [[ ! -t 0 ]]; then
  PROMPT="$(cat)"
fi

if [[ -z "${PROMPT// }" ]]; then
  echo "ERROR: empty prompt" >&2
  usage >&2
  exit 2
fi

CONTEXT=""
if [[ -n "$CONTEXT_FILE" ]]; then
  if [[ ! -f "$CONTEXT_FILE" ]]; then
    echo "ERROR: context file not found: $CONTEXT_FILE" >&2
    exit 2
  fi
  CONTEXT="$(cat "$CONTEXT_FILE")"
  if [[ ${#CONTEXT} -gt "$MAX_CONTEXT_CHARS" && "$ALLOW_LARGE_CONTEXT" -eq 0 ]]; then
    echo "NOTICE: Context (${#CONTEXT} chars) exceeds safety budget (${MAX_CONTEXT_CHARS} chars, ~4k tokens)." >&2
    echo "        Truncating to ${MAX_CONTEXT_CHARS} chars to prevent cloud token burnout. Pass --allow-large-context to override." >&2
    CONTEXT="${CONTEXT:0:$MAX_CONTEXT_CHARS}

[... Context truncated by Consilium token safety budget (${MAX_CONTEXT_CHARS} chars) ...]"
  fi
fi

if [[ -z "$OUT" ]]; then
  OUT="/tmp/consilium-$(date +%Y%m%d-%H%M%S).json"
fi

export CONSILIUM_PROMPT="$PROMPT"
export CONSILIUM_CONTEXT="$CONTEXT"
export CONSILIUM_PEERS="$PEERS"
export CONSILIUM_OUT="$OUT"

# Prefer personal-tools venv (has local_models); else local-models + PYTHONPATH.
PY=""
if [[ -x "${PT}/.venv/bin/python" ]]; then
  PY="${PT}/.venv/bin/python"
elif [[ -x "${LM}/.venv/bin/python" ]]; then
  export PYTHONPATH="${LM}/src:${PYTHONPATH:-}"
  PY="${LM}/.venv/bin/python"
else
  export PYTHONPATH="${LM}/src:${PYTHONPATH:-}"
  PY="$(command -v python3)"
fi

PYTHONUNBUFFERED=1 "$PY" - <<'PY'
import concurrent.futures
import json
import os
import shutil
import subprocess
import time
from pathlib import Path

prompt = os.environ["CONSILIUM_PROMPT"]
context = os.environ.get("CONSILIUM_CONTEXT") or ""
peers = [p.strip().lower() for p in os.environ["CONSILIUM_PEERS"].split(",") if p.strip()]
out_path = Path(os.environ["CONSILIUM_OUT"])

body = prompt if not context.strip() else f"CONTEXT:\n{context.strip()}\n\nQUESTION:\n{prompt.strip()}"

system = (
    "Independent sceptical peer reviewer. Advisory only — no file edits, no trades. "
    "Prefer pounds and concrete checks. Do not invent unverified rates/fees as FACT."
)
format_block = """
Output EXACTLY:
1. VERDICT: one short line
2. KEY_POINTS: max 4 bullets
3. RISKS_OR_GAPS: max 4 bullets
4. MUST_VERIFY: max 3 bullets
5. ONE_SENTENCE: blunt recommendation frame
"""
full_prompt = f"{format_block}\n\n{body}"

SPECS = {
    "qwen": {"kind": "lm", "kwargs": {"provider": "ollama", "model": "qwen2.5:7b", "timeout": 120, "max_tokens": 900}},
    "agy": {"kind": "lm", "kwargs": {"provider": "antigravity", "model": "gemini-3.8-flash-medium", "timeout": 180, "max_tokens": 1100}},
    "codex": {"kind": "lm", "kwargs": {"role": "codex", "timeout": 240, "max_tokens": 1100}},
    "cursor": {"kind": "cursor"},
}

unknown = [p for p in peers if p not in SPECS]
if unknown:
    raise SystemExit(f"Unknown peers: {', '.join(unknown)}. Allowed: {', '.join(SPECS)}")

client = None
if any(SPECS[p]["kind"] == "lm" for p in peers):
    from local_models import get_client
    client = get_client()


def run_lm(name: str, kwargs: dict) -> dict:
    t0 = time.monotonic()
    try:
        resp = client.complete(
            full_prompt,
            system_prompt=system,
            project="consilium",
            task=f"consilium_{name}",
            **kwargs,
        )
        return {
            "name": name,
            "ok": True,
            "model": getattr(resp, "model", None),
            "provider": getattr(resp, "provider", None),
            "latency_s": round(time.monotonic() - t0, 1),
            "content": resp.content,
            "error": None,
        }
    except Exception as e:
        return {
            "name": name,
            "ok": False,
            "model": kwargs.get("model") or kwargs.get("role"),
            "provider": kwargs.get("provider") or kwargs.get("role"),
            "latency_s": round(time.monotonic() - t0, 1),
            "content": "",
            "error": str(e),
        }


def run_cursor(name: str = "cursor") -> dict:
    t0 = time.monotonic()
    agent = shutil.which("agent") or shutil.which("cursor-agent")
    if not agent:
        return {
            "name": name,
            "ok": False,
            "model": "cursor-agent",
            "provider": "cursor",
            "latency_s": round(time.monotonic() - t0, 1),
            "content": "",
            "error": "agent/cursor-agent not on PATH",
        }
    cmd = [
        agent,
        "-p",
        "--mode",
        "ask",
        "--output-format",
        "text",
        f"{system}\n\n{full_prompt}",
    ]
    try:
        proc = subprocess.run(
            cmd,
            stdin=subprocess.DEVNULL,
            capture_output=True,
            text=True,
            timeout=300,
        )
        text = (proc.stdout or "").strip() or (proc.stderr or "").strip()
        ok = proc.returncode == 0 and bool(text)
        return {
            "name": name,
            "ok": ok,
            "model": "cursor-agent",
            "provider": "cursor",
            "latency_s": round(time.monotonic() - t0, 1),
            "content": text if ok else "",
            "error": None if ok else (text or f"exit {proc.returncode}"),
        }
    except Exception as e:
        return {
            "name": name,
            "ok": False,
            "model": "cursor-agent",
            "provider": "cursor",
            "latency_s": round(time.monotonic() - t0, 1),
            "content": "",
            "error": str(e),
        }


print(f"Consilium peers: {', '.join(peers)}", flush=True)
results = {}
with concurrent.futures.ThreadPoolExecutor(max_workers=max(1, len(peers))) as pool:
    futs = {}
    for name in peers:
        spec = SPECS[name]
        if spec["kind"] == "lm":
            futs[pool.submit(run_lm, name, spec["kwargs"])] = name
        else:
            futs[pool.submit(run_cursor, name)] = name
    for fut in concurrent.futures.as_completed(futs):
        name = futs[fut]
        r = fut.result()
        results[name] = r
        status = "OK" if r["ok"] else "FAIL"
        print(f"  [{name}] {status} ({r['latency_s']}s)", flush=True)

ok_n = sum(1 for r in results.values() if r["ok"])
panel = "COMPLETE" if ok_n >= 2 and ok_n == len(peers) else ("PARTIAL" if ok_n >= 2 else "INCOMPLETE")
payload = {
    "panel_status": panel,
    "ok_count": ok_n,
    "peer_count": len(peers),
    "peers": peers,
    "results": results,
}
out_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
print(f"Wrote {out_path}", flush=True)
print(f"PANEL STATUS: {panel} ({ok_n}/{len(peers)})", flush=True)

for name in peers:
    r = results[name]
    print("\n" + "=" * 72, flush=True)
    print(f"### {name.upper()} | {r.get('model')} | ok={r['ok']}", flush=True)
    print("=" * 72, flush=True)
    print(r["content"] or r["error"] or "(empty)", flush=True)
PY
