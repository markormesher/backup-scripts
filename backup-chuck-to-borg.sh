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
docker ps --format '{{.Names}}' | grep postgres | grep -v replica | while read container; do
  msg "Creating postgres dump for ${container}"
  output_file="${backup_path}/${container}.sql"
  docker exec ${container} pg_dumpall -U postgres --clean > ${output_file}
done

# back up WP blog if it hasn't been backed up in the last week
if ! find /backups -name 'marksprojecttrustcouk*' -mtime -7 | egrep '.' &> /dev/null; then
  wp_mysql_container="marksprojecttrustcouk_mysql_1"
  if docker ps --format '{{.Names}}' | grep ${wp_mysql_container} &> /dev/null; then
    msg "Creating mysql dump for ${wp_mysql_container}"
    output_file="${backup_path}/${wp_mysql_container}.sql"
    password=$(cat /var/web/marksprojecttrust.co.uk/secrets/mysql.password)
    docker exec ${wp_mysql_container} mysqldump --all-databases --add-drop-database --user markspt -p"${password}" 2> /dev/null > ${output_file}
  fi

  wp_content_container="marksprojecttrustcouk_app_1"
  if docker ps --format '{{.Names}}' | grep ${wp_content_container} &> /dev/null; then
    msg "Creating content tar for ${wp_content_container}"
    output_file="${backup_path}/${wp_content_container}.tar"
    docker exec ${wp_content_container} tar -cf - /var/www/html > ${output_file}
  fi
fi

# retention old backups
msg "Deleting backup files older than 21 days"
find /backups -type f -mtime +21 -exec rm -v {} +
find /backups -type d -empty -exec rm -rv {} +

# sync to borg
# temporarily disabled while chuck cannot reach out to bigmike
#msg "Syncing backups to borg"
#archive_name="chuck-$(date -Iseconds | cut -d '+' -f 1)"
#borg create -s --compression zlib \
#  markormesher@"${BORG_HOST}":"${BORG_REPO}"::"${archive_name}" \
#  /backups \
#  ~/vimwiki

msg "Backup finished"