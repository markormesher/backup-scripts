#! /usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${script_dir}/utils.sh"

load_secrets
load_settings
ensure_borg_host
check_proc_not_running borg
check_proc_not_running rclone

if pgrep rclone > /dev/null; then
  msg "rclone is already running - aborting"
  exit 0
fi

msg "Syncing to B2"
rclone --transfers=2 "$@" sync "${BORG_REPO}" "${RCLONE_REMOTE}:${B2_BUCKET}"
rclone cleanup "${RCLONE_REMOTE}:${B2_BUCKET}"

mkdir -p data
date -Iseconds > "${script_dir}/data/last-sync.txt"
msg "Finished syncing to B2"
