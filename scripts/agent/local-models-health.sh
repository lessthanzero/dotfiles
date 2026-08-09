#!/usr/bin/env bash
# Check Ollama / local-models stack on Fedora pc.
set -euo pipefail

run_health() {
  local host="$1"
  ssh -o ConnectTimeout=10 -o BatchMode=yes "$host" \
    'if [[ -x ~/Developer/local-models/scripts/health.sh ]]; then
       ~/Developer/local-models/scripts/health.sh
     elif curl -sf http://127.0.0.1:11434/api/tags >/dev/null; then
       echo "OK: Ollama responding"; curl -s http://127.0.0.1:11434/api/tags | head -c 200
     else
       echo "WARN: health.sh missing and Ollama not responding"; exit 1
     fi'
}

if [[ "$(hostname -s 2>/dev/null)" == "fedora" ]] || [[ -f /etc/fedora-release ]]; then
  if [[ -x "${HOME}/Developer/local-models/scripts/health.sh" ]]; then
    exec "${HOME}/Developer/local-models/scripts/health.sh"
  fi
  curl -sf http://127.0.0.1:11434/api/tags && echo "OK: Ollama local" || exit 1
fi

if ssh -o ConnectTimeout=5 -o BatchMode=yes pc 'echo ok' &>/dev/null; then
  exec run_health pc
fi

if ssh -o ConnectTimeout=5 -o BatchMode=yes pc-remote 'echo ok' &>/dev/null; then
  exec run_health pc-remote
fi

echo "ERROR: cannot reach pc for local-models health" >&2
exit 1
