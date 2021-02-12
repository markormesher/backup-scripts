#! /usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${script_dir}/utils.sh"

load_secrets
load_settings
check_proc_not_running borg

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
  output_file="${backup_path}/${container}.sql"
  docker exec ${container} pg_dumpall -U postgres --clean > ${output_file}
done

# retention old backups
msg "Deleting backup files older than 21 days"
find /backups -type f -mtime +21 -exec rm -v {} +
find /backups -type d -empty -exec rm -rv {} +

# sync to borg
msg "Backing up"
archive_name="kirito-$(date -Iseconds | cut -d '+' -f 1)"
borg create -s --compression zlib \
  markormesher@"${BORG_HOST}":"${BORG_REPO}"::"${archive_name}" \
  /backups

msg "Backup finished"
