#!/usr/bin/env bash
# Report local-models content-free usage / metrics telemetry.
set -euo pipefail

LM="${HOME}/Developer/local-models"
USAGE_SH="${LM}/scripts/usage.sh"

if [[ ! -d "$LM" ]]; then
  echo "ERROR: local-models missing at ${LM}" >&2
  exit 1
fi

sub="${1:-usage}"
if [[ "$sub" == "usage" || "$sub" == "metrics" ]]; then
  shift
else
  # No subcommand — treat all args as usage flags.
  sub="usage"
fi

case "$sub" in
  usage)
    if [[ -x "$USAGE_SH" ]]; then
      exec "$USAGE_SH" "$@"
    fi
    export PYTHONPATH="${LM}/src:${PYTHONPATH:-}"
    exec python3 -m local_models.cli usage "$@"
    ;;
  metrics)
    export PYTHONPATH="${LM}/src:${PYTHONPATH:-}"
    exec python3 -m local_models.cli metrics "$@"
    ;;
  *)
    echo "Usage: local-models-usage.sh [usage|metrics] [--today|--days N|--project NAME|-v] …" >&2
    exit 1
    ;;
esac
