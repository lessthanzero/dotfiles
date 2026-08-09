#!/bin/bash
# chezmoi:script
# chezmoi:change-after $CHEZMOI_SOURCE_DIR/skills
set -euo pipefail
exec "${CHEZMOI_SOURCE_DIR}/scripts/deploy-agent-skills.sh"
