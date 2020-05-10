#! /usr/bin/env bash
set -euo pipefail

BORG_REPO="/hdd/borg/repo0"

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
archive_name="archive-$(date -Iseconds | cut -d '+' -f 1)"
borg create -s --compression zlib \
  "${BORG_REPO}"::"${archive_name}" \
  /hdd/archive

msg "Backup finished"
