#!/usr/bin/env bash
# Run Flow Analyzer CLI against a client review folder.
set -euo pipefail

PT="${HOME}/Developer/personal-tools"
FA_BIN="${PT}/.venv/bin/flow-analyzer"
PY_BIN="${PT}/.venv/bin/python"

looks_like_review() {
  local dir="$1"
  [[ -d "${dir}/screencasts" || -d "${dir}/screenshots" || -d "${dir}/text" ]]
}

run_fa() {
  if [[ -x "$FA_BIN" ]]; then
    exec "$FA_BIN" "$@"
  fi
  if [[ -x "$PY_BIN" ]]; then
    export PYTHONPATH="${PT}/src:${PYTHONPATH:-}"
    exec "$PY_BIN" -m personal_tools.flow_analyzer "$@"
  fi
  echo "ERROR: personal-tools Flow Analyzer not found." >&2
  echo "Expected ${FA_BIN} or ${PY_BIN} with PYTHONPATH=src." >&2
  echo "Bootstrap: cd ~/Developer/personal-tools && uv sync (or create .venv)." >&2
  exit 1
}

if [[ ! -d "$PT" ]]; then
  echo "ERROR: personal-tools missing at ${PT}" >&2
  exit 1
fi

if [[ $# -eq 0 ]]; then
  echo "Usage: flow-analyzer.sh <command> [review_dir] [flags...]" >&2
  echo "Commands: analyze | status | report | ingest | transcribe | frames | subtitles | optimize-video | export | snapshots" >&2
  exit 1
fi

cmd="$1"
shift

# Inject default review dir when omitted (next arg missing or is a flag).
if [[ $# -eq 0 || "${1:-}" == -* ]]; then
  if looks_like_review "$PWD"; then
    set -- "$PWD" "$@"
  else
    echo "ERROR: review_dir required (cwd is not a review folder)." >&2
    echo "Pass an explicit path, e.g. analyze ~/Developer/taxnova" >&2
    exit 1
  fi
fi

run_fa "$cmd" "$@"
