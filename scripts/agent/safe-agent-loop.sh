#!/usr/bin/env bash
# Safe loop harness for local agents (Mac / Fedora).
# Default: read-only preflight + bounded iterations. Never passes
# --dangerously-skip-permissions. Does not modify user data itself.
#
# Usage:
#   safe-agent-loop.sh --check              # preflight only
#   safe-agent-loop.sh -- cmd [args...]     # run cmd once if preflight OK
#   safe-agent-loop.sh -n 5 -- cmd ...      # up to 5 iterations
#   SAFE_AGENT_MIN_FREE_GB=25 safe-agent-loop.sh --check
#
# Env:
#   SAFE_AGENT_MIN_FREE_GB   abort if free space below this (default: 20)
#   SAFE_AGENT_MAX_ITERS     default max iterations (default: 3)
#   SAFE_AGENT_MAX_SECS      wall-clock budget (default: 1800)
#   SAFE_AGENT_LOG_DIR       log directory (default: ~/Library/Logs/safe-agent-loop
#                            or ~/.local/state/safe-agent-loop on Linux)
set -euo pipefail

MIN_FREE_GB="${SAFE_AGENT_MIN_FREE_GB:-20}"
MAX_ITERS="${SAFE_AGENT_MAX_ITERS:-3}"
MAX_SECS="${SAFE_AGENT_MAX_SECS:-1800}"
CHECK_ONLY=0
ITERS="$MAX_ITERS"

usage() {
  sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage 0 ;;
    --check) CHECK_ONLY=1; shift ;;
    -n|--iters) ITERS="${2:?}"; shift 2 ;;
    --) shift; break ;;
    -*) echo "Unknown flag: $1" >&2; usage 2 ;;
    *) break ;;
  esac
done

if [[ "$(uname -s)" == "Darwin" ]]; then
  LOG_DIR="${SAFE_AGENT_LOG_DIR:-$HOME/Library/Logs/safe-agent-loop}"
  free_gb() {
    # Prefer Data volume free space (APFS shared pool).
    df -g /System/Volumes/Data 2>/dev/null | awk 'NR==2{print $4}' \
      || df -g / | awk 'NR==2{print $4}'
  }
else
  LOG_DIR="${SAFE_AGENT_LOG_DIR:-$HOME/.local/state/safe-agent-loop}"
  free_gb() {
    df -BG / | awk 'NR==2{gsub(/G/,"",$4); print $4}'
  }
fi

mkdir -p "$LOG_DIR"
STAMP="$(date +%Y%m%dT%H%M%S)"
LOG="$LOG_DIR/run-$STAMP.log"
HEARTBEAT="$LOG_DIR/heartbeat"

log() { printf '[%s] %s\n' "$(date -u +%H:%M:%S)" "$*" | tee -a "$LOG"; }
fail() { log "FAIL: $*"; exit 1; }

deny_arg() {
  case "$1" in
    *--dangerously-skip-permissions*|*--dangerously-skip-permissions)
      return 0 ;;
  esac
  return 1
}

preflight() {
  local free
  free="$(free_gb)"
  free="${free%%.*}"
  log "preflight: free_gb=${free} min=${MIN_FREE_GB} host=$(hostname -s 2>/dev/null || hostname)"
  if [[ -z "$free" || "$free" -lt "$MIN_FREE_GB" ]]; then
    fail "disk free ${free:-?}GB < ${MIN_FREE_GB}GB — refusing agent work (set SAFE_AGENT_MIN_FREE_GB to override)"
  fi

  # Flag known runaway patterns (informational; does not kill).
  if pgrep -lf 'agy.*dangerously-skip-permissions' >/dev/null 2>&1 \
     || pgrep -lf 'agy --dangerously-skip-permissions' >/dev/null 2>&1; then
    log "WARN: agy running with --dangerously-skip-permissions (review/kill manually)"
  fi

  if command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then
      # AppTranslocation = quarantine / not properly installed under /Applications
      if ps aux 2>/dev/null | grep -q '[A]ppTranslocation.*Docker.app'; then
        log "WARN: Docker.app running from AppTranslocation (quarantine) — reinstall/move recommended"
      fi
    fi
  fi

  log "preflight OK"
}

run_once() {
  local i="$1"
  shift
  for a in "$@"; do
    if deny_arg "$a"; then
      fail "refusing unsafe flag in argv: --dangerously-skip-permissions"
    fi
  done
  printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "iter=$i" >"$HEARTBEAT"
  log "iter $i/$ITERS: $*"
  "$@"
}

preflight

if [[ "$CHECK_ONLY" -eq 1 ]]; then
  log "check-only complete → $LOG"
  exit 0
fi

if [[ $# -eq 0 ]]; then
  echo "No command given. Use --check or -- <cmd>." >&2
  usage 2
fi

START_TS="$(date +%s)"
for ((i = 1; i <= ITERS; i++)); do
  now="$(date +%s)"
  if (( now - START_TS >= MAX_SECS )); then
    fail "wall-clock budget ${MAX_SECS}s exceeded"
  fi
  free="$(free_gb)"; free="${free%%.*}"
  if [[ -n "$free" && "$free" -lt "$MIN_FREE_GB" ]]; then
    fail "disk dropped to ${free}GB mid-loop"
  fi
  if ! run_once "$i" "$@"; then
    rc=$?
    log "command exited $rc on iter $i"
    exit "$rc"
  fi
done

log "completed $ITERS iter(s) → $LOG"
