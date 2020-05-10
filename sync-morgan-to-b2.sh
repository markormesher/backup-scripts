#! /usr/bin/env bash
set -euo pipefail

BORG_REPO="/hdd/borg/repo0"
B2_BUCKET="mormesher-borg-repo0"
RCLONE_REMOTE="b2-mormesher-borg-repo0"

function msg() {
  echo
  echo "[$(date -Iseconds)] $1"
}

if pgrep rclone > /dev/null; then
  msg "rclone is already running - aborting"
  exit 0
fi

export TMPDIR=/hdd/borg/tmp

msg "Syncing to B2"
rclone --transfers=2 "$@" sync "${BORG_REPO}" "${RCLONE_REMOTE}:${B2_BUCKET}"
rclone cleanup "${RCLONE_REMOTE}:${B2_BUCKET}"


mkdir -p data
date -Iseconds > data/last-sync-morgan-to-b2.txt
msg "Finished syncing to B2"
