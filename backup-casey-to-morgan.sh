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
msg "Syncing backups to borg master"
archive_name="casey-$(date -Iseconds | cut -d '+' -f 1)"
borg create -s --compression none "$@" \
  markormesher@morgan:/hdd/borg/repo0::"${archive_name}" \
  /home/markormesher/Pictures \
  /opt/digikam

msg "Backup finished"
