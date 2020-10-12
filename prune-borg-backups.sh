#! /usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${script_dir}/utils.sh"

load_secrets
load_settings
ensure_borg_host
check_proc_not_running borg

prune_config="--stats --keep-daily 14 --keep-weekly 4 --keep-monthly 6 --keep-yearly -1 --save-space"

msg "Pruning backups for chuck"
borg prune --prefix chuck ${prune_config} "${BORG_REPO}"

msg "Pruning backups for kirito"
borg prune --prefix kirito ${prune_config} "${BORG_REPO}"

msg "Pruning backups for casey"
borg prune --prefix casey ${prune_config} "${BORG_REPO}"

msg "Pruning backups for archive"
borg prune --prefix archive ${prune_config} "${BORG_REPO}"

mkdir -p data
date -Iseconds > "${script_dir}/data/last-prune.txt"
msg "Finished pruning backups"
