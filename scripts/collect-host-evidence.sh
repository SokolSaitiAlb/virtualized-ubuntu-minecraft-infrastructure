#!/usr/bin/env bash
# Read-only CachyOS host and libvirt VM snapshot. Does not change host or guest state.
set -Eeuo pipefail
VM_NAME="${1:-}"
if [[ -z "$VM_NAME" ]]; then
  echo "Usage: $0 <libvirt-vm-name>" >&2
  exit 2
fi
command -v virsh >/dev/null || { echo "virsh is required" >&2; exit 1; }
echo "=== TIMESTAMP ==="; date --iso-8601=seconds
echo "=== HOST ==="; hostnamectl; uname -a; lscpu; free -h; uptime
echo "=== STORAGE ==="; lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL; df -hT
echo "=== NETWORK ==="; ip -s link; ip route
echo "=== LIBVIRT ==="; virsh -c qemu:///system dominfo "$VM_NAME"
virsh -c qemu:///system domstats "$VM_NAME" --vcpu --balloon --block --interface
echo "=== NOTE ==="
echo "Review output for hostnames, usernames, serials, MAC/IP addresses before sharing or committing."
