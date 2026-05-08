#!/bin/bash
# Reference / example — copy to ~/bin if you use backup-restic.sh; run once for browser OAuth.
# Repo copy may lag behind the machine you maintain.
#
# One-time: create rclone remote "gdrive" for Google Drive (browser OAuth).
set -euo pipefail
if rclone listremotes 2>/dev/null | grep -qx 'gdrive:'; then
  echo "Remote 'gdrive' already exists. Use 'rclone config' to edit."
  rclone listremotes
  exit 0
fi
echo "Opening rclone config: choose 'n' for new remote, name it 'gdrive',"
echo "storage 'drive', leave client_id/secret empty, scope 1 (full access),"
echo "then authenticate in the browser."
echo ""
exec rclone config
