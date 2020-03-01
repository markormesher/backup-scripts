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
  output_file="${backup_path}/${container}.sql"
  docker exec ${container} pg_dumpall -U postgres --clean > ${output_file}
done

# mysql backup for WP blog
wp_mysql_container="marksprojecttrustcouk_mysql_1"
if docker ps --format '{{.Names}}' | grep ${wp_mysql_container} &> /dev/null; then
  msg "Creating mysql dump for ${wp_mysql_container}"
  output_file="${backup_path}/${wp_mysql_container}.sql"
  password=$(cat /var/web/marksprojecttrust.co.uk/secrets/mysql.password)
  docker exec ${wp_mysql_container} mysqldump --all-databases --add-drop-database --user markspt -p"${password}" 2> /dev/null > ${output_file}
fi

# retention old backups
msg "Deleting backup files older than 21 days"
find /backups -type f -mtime +21 -exec rm -v {} +
find /backups -type d -empty -exec rm -rv {} +

# sync to borg
msg "Syncing backups to borg master"
archive_name="chuck-$(date -Iseconds | cut -d '+' -f 1)"
borg create -s --compression none "$@" \
  markormesher@morgan:/hdd/borg/repo0::"${archive_name}" \
  /backups \
  ~/vimwiki

msg "Backup finished"
