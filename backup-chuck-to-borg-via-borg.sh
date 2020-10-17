#! /usr/bin/env bash
set -euo pipefail

# Temp script to pull chuck backups down to bigmike and add them to borg locally,
# because chuck can't send to bigmike for now.
# Also backs up ~/.vimwiki because chuck used to do that.

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${script_dir}/utils.sh"

load_secrets
load_settings
check_proc_not_running borg

local_chuck_backup_path="/mnt/hdd/temp-chuck-backups"

if [[ ! -d "${local_chuck_backup_path}" ]]; then
  msg "ERROR: ${local_chuck_backup_path} does not exist"
  exit 1
fi

msg "Cloning backups to ${local_chuck_backup_path}"

rsync -avzh --delete chuck:/backups/ "${local_chuck_backup_path}"/

# sync to borg
msg "Syncing backups to borg"
archive_name="chuck-$(date -Iseconds | cut -d '+' -f 1)"
borg create -s --compression zlib \
  "${BORG_REPO}"::"${archive_name}" \
  "${local_chuck_backup_path}" \
  ~/vimwiki

msg "Backup finished"
