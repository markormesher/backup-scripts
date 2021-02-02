#! /usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

function msg() {
  echo
  echo "[$(date -Iseconds)] $1"
}

function load_secrets() {
  if [[ ! -f "${script_dir}/.secrets" ]]; then
    msg "ERROR: .secrets file could not be loaded!"
    exit 1
  else
    source "${script_dir}/.secrets"
  fi
}

function load_settings() {
  if [[ ! -f "${script_dir}/.settings" ]]; then
    msg "ERROR: .settings file could not be loaded!"
    exit 1
  else
    source "${script_dir}/.settings"
  fi
}

function ensure_borg_host() {
  if [[ "${BORG_HOST}" != "$(hostname)" ]] && [[ "${BORG_HOST_LOCAL_NAME}" != "$(hostname)" ]]; then
    msg "ERROR: this script should only be run on ${BORG_HOST}"
    exit 1
  fi
}

function check_proc_not_running() {
  if pgrep "$1" > /dev/null; then
    msg "$1 is already running - aborting"
    exit 0
  fi
}
