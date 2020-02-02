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

msg "Pruning backups for chuck"
borg prune --prefix chuck --stats --keep-daily 14 --keep-weekly 4 --keep-monthly 6 /borg/repo0

msg "Pruning backups for casey"
borg prune --prefix casey --stats --keep-daily 14 --keep-weekly 4 --keep-monthly 6 /borg/repo0

mkdir -p data
date -Iseconds > data/last-prune-morgan-backups.txt
msg "Finished pruning backups"
