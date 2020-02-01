#! /usr/bin/env bash
set -euo pipefail

source .secrets

function msg() {
  echo
  echo "[$(date -Iseconds)] $1"
}

# sync to borg
msg "Syncing backups to borg master"
borg create -s --compression none \
  markormesher@morgan:/borg/repo0::'{hostname}-{now}' \
  /home/markormesher/Pictures \
  /opt/digikam

msg "Backup finished"
