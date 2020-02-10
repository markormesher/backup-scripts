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

if [[ ! -d /backups ]]; then
  msg "ERROR: /backups does not exist"
  exit 1
fi

backup_path="/backups/$(date +%Y-%m-%d-%H-%M-%S)"
mkdir ${backup_path}
cd ${backup_path}

msg "Backup starting in ${backup_path}"

# postgres dumps from docker
docker ps --format '{{.Names}}' | grep postgres | grep -v slave | while read container; do
  msg "Creating postgres dump for ${container}"
  output_file="${backup_path}/${container}.sql.gz"
  docker exec ${container} pg_dumpall -U postgres --clean | gzip > ${output_file}
done

# retention old backups
msg "Deleting backup files older than 21 days"
find /backups -type f -mtime +21 -exec rm -v {} +
find /backups -type d -empty -exec rm -rv {} +

# sync to borg
msg "Syncing backups to borg master"
borg create -s --compression none "$@" \
  markormesher@morgan:/borg/repo0::'{hostname}-{now}' \
  /backups \
  ~/vimwiki

msg "Backup finished"
