#! /usr/bin/env bash
set -euo pipefail

export TMPDIR=/borg/tmp

rclone --transfers=1 --drive-chunk-size=250M "$@" sync /borg/repo0 b2-borg-repo0-crypt:
rclone cleanup b2-borg-repo0-crypt:
