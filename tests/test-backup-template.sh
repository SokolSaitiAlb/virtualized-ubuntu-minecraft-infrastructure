#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bash -n "$ROOT/scripts/backup-minecraft.sh"
grep -q 'MC_SERVER_DIR' "$ROOT/scripts/backup-minecraft.sh"
grep -q 'systemctl stop' "$ROOT/scripts/backup-minecraft.sh"
grep -q 'sha256sum -c' "$ROOT/scripts/backup-minecraft.sh"
grep -q 'flock -n' "$ROOT/scripts/backup-minecraft.sh"
grep -q 'different filesystem' "$ROOT/scripts/backup-minecraft.sh"
echo "PASS: backup template syntax and required safety guards are present."
echo "NOTE: this static test does not run systemctl, stop a server, or create an archive."
