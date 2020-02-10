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

export TMPDIR=/hdd/borg/tmp

msg "Syncing to B2"
rclone --transfers=1 --drive-chunk-size=250M "$@" sync /hdd/borg/repo0 b2-borg-repo0-crypt:
rclone cleanup b2-borg-repo0-crypt:

mkdir -p data
date -Iseconds > data/last-sync-morgan-to-b2.txt
msg "Finished syncing to B2"
