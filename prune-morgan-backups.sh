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

prune_config="--stats --keep-daily 14 --keep-weekly 4 --keep-monthly 6 --keep-yearly -1"

msg "Pruning backups for chuck"
borg prune --prefix chuck ${prune_config} /hdd/borg/repo0

msg "Pruning backups for kirito"
borg prune --prefix kirito ${prune_config} /hdd/borg/repo0

msg "Pruning backups for casey"
borg prune --prefix casey ${prune_config} /hdd/borg/repo0

msg "Pruning backups for archive"
borg prune --prefix archive ${prune_config} /hdd/borg/repo0

mkdir -p data
date -Iseconds > data/last-prune-morgan-backups.txt
msg "Finished pruning backups"
