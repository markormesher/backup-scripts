#! /usr/bin/env bash
set -euo pipefail

function msg() {
  echo
  echo "[$(date -Iseconds)] $1"
}

if pgrep borg > /dev/null; then
  msg "borg is already running - aborting"
  exit 0
fi

# sync to borg
msg "Syncing archive to borg master"
borg create -s --compression none "$@" \
  /hdd/borg/repo0::'archive-{now}' \
  /hdd/archive

msg "Backup finished"
