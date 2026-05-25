#!/usr/bin/env bash
# chezmoi run_once: alias for install-omz-p10k.sh (idempotent; installs both OMZ and p10k)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${SCRIPT_DIR}/scripts/install-omz-p10k.sh"
