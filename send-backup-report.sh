#! /usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${script_dir}/utils.sh"

load_secrets
load_settings
ensure_borg_host
check_proc_not_running borg

function check_archive() {
  display_name="$1"
  prefix="$2"
  threshold_hours="$3"

  backup_time=$(borg list --prefix "${prefix}" --format '{end}{NEWLINE}' --sort-by timestamp "${BORG_REPO}" | tail -n 1)
  backup_ts=$(date -d "${backup_time}" +%s)
  now_ts=$(date +%s)

  backup_age=$(( now_ts - backup_ts ))

  backup_age_m=$(( (backup_age / 60) % 60 ))
  backup_age_h=$(( backup_age / 60 / 60 ))

  if [[ "${backup_age_h}" -lt "${threshold_hours}" ]]; then
    echo "OK: ${display_name} - ${backup_age_h}h ${backup_age_m}m ago"
  else
    echo "ERROR: ${display_name} - ${backup_age_h}h ${backup_age_m}m ago"
  fi
}

function check_from_file() {
  display_name="$1"
  file="$2"
  threshold_hours="$3"

  run_time=$(cat "${file}")
  run_ts=$(date -d "${run_time}" +%s)
  now_ts=$(date +%s)

  run_age=$(( now_ts - run_ts ))

  run_age_m=$(( (run_age / 60) % 60 ))
  run_age_h=$(( run_age / 60 / 60 ))

  if [[ "${run_age_h}" -lt "${threshold_hours}" ]]; then
    echo "OK: ${display_name} - ${run_age_h}h ${run_age_m}m ago"
  else
    echo "ERROR: ${display_name} - ${run_age_h}h ${run_age_m}m ago"
  fi
}

report_output=$(mktemp)
trap 'rm -f "${report_output}"' EXIT

{
  check_archive "Tatsu" "tatsu" 25
  check_archive "Casey" "casey" $(( 7 * 24 ))
  check_archive "Chuck" "chuck" 25
  check_archive "Kirito" "kirito" 25
  check_from_file "Backup prune" "${script_dir}/data/last-prune.txt" 25
  check_from_file "Sync to B2" "${script_dir}/data/last-sync.txt" 25
} >> "${report_output}"

if grep ERROR "${report_output}" > /dev/null; then
  report_title="Backup Errors"
else
  report_title="Backups okay!"
fi

curl -s -X POST "https://api.pushover.net/1/messages.json" \
  -F "token=${PUSHOVER_TOKEN}" \
  -F "user=${PUSHOVER_USER}" \
  -F "title=${report_title}" \
  -F "message=$(cat "${report_output}")"
