#! /usr/bin/env bash
set -euo pipefail

function msg() {
  echo
  echo "[$(date -Iseconds)] $1"
}

if pgrep rclone > /dev/null; then
  msg "rclone is already running - aborting"
  exit 0
fi

exit 0

export TMPDIR=/borg/tmp

rclone --transfers=1 --drive-chunk-size=250M "$@" sync /borg/repo0 b2-borg-repo0-crypt:
rclone cleanup b2-borg-repo0-crypt:
