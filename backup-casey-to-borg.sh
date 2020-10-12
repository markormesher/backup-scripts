#! /usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${script_dir}/utils.sh"

load_secrets
load_settings
check_proc_not_running borg

# sync to borg
msg "Syncing backups to borg"
archive_name="casey-$(date -Iseconds | cut -d '+' -f 1)"
borg create -s --compression zlib \
  markormesher@"${BORG_HOST}":"${BORG_REPO}"::"${archive_name}" \
  /home/markormesher/Pictures \
  /opt/digikam

msg "Backup finished"
