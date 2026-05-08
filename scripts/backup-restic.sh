#!/bin/bash
# Reference / example — copy to ~/bin (or PATH) and add ~/.config/restic/ (exclude, environment, password).
# Repo copy may lag behind the machine you maintain.
#
# Backup $HOME to Restic: target "usb" or "cloud" (Google Drive via rclone).
set -euo pipefail

TARGET="${1:-}"
CONFIG_DIR="${HOME}/.config/restic"
PASSWORD_FILE="${RESTIC_PASSWORD_FILE:-$CONFIG_DIR/repo.password}"
EXCLUDE_FILE="$CONFIG_DIR/exclude.txt"
ENV_FILE="$CONFIG_DIR/environment"

# shellcheck source=/dev/null
[[ -f "$ENV_FILE" ]] && source "$ENV_FILE"

export RESTIC_PASSWORD_FILE="${RESTIC_PASSWORD_FILE:-$PASSWORD_FILE}"

notify() {
  local u="${DBUS_SESSION_BUS_ADDRESS:-}"
  if [[ -n "$u" ]] && command -v notify-send &>/dev/null; then
    notify-send -a "Home backup" "$1" "${2:-}" || true
  fi
}

die() { echo "backup-restic: $*" >&2; notify "Backup failed" "$*"; exit 1; }

[[ -f "$RESTIC_PASSWORD_FILE" ]] || die "Missing $RESTIC_PASSWORD_FILE (see $CONFIG_DIR/PASSWORD-README.txt)"

BACKUP_ROOT="${HOME}"

set_repo_usb() {
  local root="${USB_BACKUP_ROOT:-/media/svetlana/BACKUP}"
  local sub="${USB_REPO_DIR:-restic-laptop}"
  [[ -d "$root" ]] || die "USB not mounted at $root — plug in the stick and wait for it to mount."
  export RESTIC_REPOSITORY="$root/$sub"
}

set_repo_cloud() {
  local remote="${RCLONE_REMOTE:-gdrive}"
  local path="${RCLONE_PATH:-ResticLaptop}"
  rclone listremotes 2>/dev/null | grep -qx "${remote}:" || die "No rclone remote '${remote}:'. Run ${HOME}/bin/rclone-setup-gdrive.sh once."
  export RESTIC_REPOSITORY="rclone:${remote}:${path}"
}

case "${TARGET}" in
  init-usb)
    set_repo_usb
    restic init
    echo "Initialized $RESTIC_REPOSITORY"
    ;;
  init-cloud)
    set_repo_cloud
    restic init
    echo "Initialized $RESTIC_REPOSITORY"
    ;;
  usb|cloud)
    if [[ "${TARGET}" == "usb" ]]; then
      set_repo_usb
    else
      set_repo_cloud
    fi
    [[ -f "$EXCLUDE_FILE" ]] || die "Missing exclude file $EXCLUDE_FILE"

    restic -r "$RESTIC_REPOSITORY" backup "$BACKUP_ROOT" \
      --exclude-file="$EXCLUDE_FILE" \
      --tag "${TARGET}" \
      --compression "${RESTIC_COMPRESSION:-auto}"

    if [[ "${TARGET}" == "cloud" ]]; then
      restic -r "$RESTIC_REPOSITORY" forget \
        --keep-daily 7 \
        --keep-weekly 4 \
        --prune
    fi

    notify "Backup done" "${TARGET} snapshot saved."
    ;;
  *)
    echo "Usage: $0 {usb|cloud|init-usb|init-cloud}" >&2
    exit 64
    ;;
esac
