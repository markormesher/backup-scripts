#! /usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${script_dir}/utils.sh"

load_secrets
load_settings
ensure_borg_host
check_proc_not_running borg

msg "Backing up"
archive_name="tatsu-$(date -Iseconds | cut -d '+' -f 1)"
borg create -s --compression zlib \
  --exclude '*/node_modules/*' \
  --exclude '*/.piolibdeps/*' \
  --progress \
  "${BORG_REPO}"::"${archive_name}" \
  /mnt/hdd/cloud/Archive \
  ~/apps

msg "Backup finished"
