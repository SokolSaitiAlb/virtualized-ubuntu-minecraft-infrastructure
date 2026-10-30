#!/usr/bin/env bash
# Fail-closed full-directory backup template for a PaperMC server managed by systemd.
# Configure only after confirming the real unit name, server directory and backup target.

set -Eeuo pipefail
umask 077

usage() {
  cat <<'USAGE'
Usage:
  MC_SERVER_DIR=/absolute/server/path MC_BACKUP_DIR=/absolute/backup/path MC_SYSTEMD_UNIT=unit.service ./scripts/backup-minecraft.sh

Requirements:
  - The Paper server is managed by a confirmed systemd unit.
  - The unit is active before backup.
  - Backup destination is outside MC_SERVER_DIR and has sufficient free space.
  - This script is run by an account allowed to stop/start the unit and read server files.

The script gracefully stops the unit, archives the full server directory, writes a SHA-256
checksum, and attempts to restart the unit. Archives may contain secrets; protect them.
USAGE
}

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ -n "${MC_SERVER_DIR:-}" && -n "${MC_BACKUP_DIR:-}" && -n "${MC_SYSTEMD_UNIT:-}" ]] || {
  usage >&2
  exit 2
}

[[ "$MC_SERVER_DIR" == /* && "$MC_BACKUP_DIR" == /* ]] || fail "Both paths must be absolute."
[[ -d "$MC_SERVER_DIR" ]] || fail "Server directory does not exist."
[[ -d "$MC_BACKUP_DIR" ]] || fail "Backup directory must already exist; refusing to create an unknown mount/path."
[[ -f "$MC_SERVER_DIR/server.properties" ]] || fail "server.properties not found; check MC_SERVER_DIR."
[[ "$MC_SERVER_DIR" != "/" && "$MC_BACKUP_DIR" != "$MC_SERVER_DIR" ]] || fail "Unsafe source/destination path."

SOURCE_REAL="$(realpath "$MC_SERVER_DIR")"
DEST_REAL="$(realpath "$MC_BACKUP_DIR")"
case "$DEST_REAL/" in
  "$SOURCE_REAL/"*) fail "Backup destination is inside the live server directory." ;;
esac

command -v systemctl >/dev/null || fail "systemctl is required."
command -v tar >/dev/null || fail "tar is required."
command -v sha256sum >/dev/null || fail "sha256sum is required."
command -v flock >/dev/null || fail "flock is required."

systemctl cat "$MC_SYSTEMD_UNIT" >/dev/null 2>&1 || fail "Unknown systemd unit: $MC_SYSTEMD_UNIT"
systemctl is-active --quiet "$MC_SYSTEMD_UNIT" || fail "Server unit must be active before backup."
[[ -r "$SOURCE_REAL/server.properties" ]] || fail "Server files are not readable."

LOCK_FILE="$DEST_REAL/.minecraft-backup.lock"
exec 9>"$LOCK_FILE"
flock -n 9 || fail "Another backup appears to be running."

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
BASE="minecraft-server-$STAMP.tar.gz"
ARCHIVE="$DEST_REAL/$BASE"
TMP_ARCHIVE="$ARCHIVE.partial"
RESTART_REQUIRED=0
BACKUP_OK=0

restart_server() {
  if (( RESTART_REQUIRED )); then
    printf 'Restarting %s...\n' "$MC_SYSTEMD_UNIT" >&2
    systemctl start "$MC_SYSTEMD_UNIT" || {
      printf 'CRITICAL: backup ended but server restart failed. Start %s manually.\n' "$MC_SYSTEMD_UNIT" >&2
      return 1
    }
    RESTART_REQUIRED=0
  fi
}

cleanup() {
  local status=$?
  rm -f "$TMP_ARCHIVE"
  if (( RESTART_REQUIRED )); then
    restart_server || status=1
  fi
  exit "$status"
}
trap cleanup EXIT INT TERM

printf 'Stopping %s gracefully...\n' "$MC_SYSTEMD_UNIT"
systemctl stop "$MC_SYSTEMD_UNIT"
RESTART_REQUIRED=1
systemctl is-active --quiet "$MC_SYSTEMD_UNIT" && fail "Unit still reports active after stop request."
[[ ! -e "$ARCHIVE" ]] || fail "Archive path collision."

printf 'Creating backup archive: %s\n' "$ARCHIVE"
tar -czf "$TMP_ARCHIVE" -C "$(dirname "$SOURCE_REAL")" "$(basename "$SOURCE_REAL")"
tar -tzf "$TMP_ARCHIVE" >/dev/null
mv "$TMP_ARCHIVE" "$ARCHIVE"
chmod 600 "$ARCHIVE"
sha256sum "$ARCHIVE" > "$ARCHIVE.sha256"
chmod 600 "$ARCHIVE.sha256"
sha256sum -c "$ARCHIVE.sha256"
BACKUP_OK=1

printf 'Backup verified: %s\n' "$ARCHIVE"
printf 'SHA256: '
sha256sum "$ARCHIVE"

restart_server
trap - EXIT INT TERM
printf 'Backup complete. Server restart was requested; verify service health separately.\n'
