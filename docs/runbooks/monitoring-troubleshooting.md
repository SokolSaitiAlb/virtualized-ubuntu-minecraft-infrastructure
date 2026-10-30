# Phase E — Monitoring, Troubleshooting and Operational Evidence

**Status:** Monitoring tools have been used interactively (htop/btop). No repeatable idle/load benchmark dataset has yet been supplied. This runbook defines a reproducible measurement method; all numeric results must be captured from the real host/guest.

## 1. Measurement protocol

Record each sample with:
- UTC timestamp and timezone
- Host or guest identity and OS/kernel version
- VM state and configured vCPU/RAM
- Workload state: idle / normal players / peak test
- Player count and test duration
- Paper/Minecraft/Java/Geyser versions
- CPU, memory, disk capacity/I/O, network counters
- Any concurrent host workloads

Use at least three comparable windows:
1. **Idle baseline:** server started, no connected players, allow startup/settling before sampling.
2. **Normal load:** representative player activity for a fixed interval.
3. **Controlled peak:** a repeatable, non-destructive test with a documented player count and duration.

Do not compare samples taken with different VM allocations, Java heap settings, world state, or host background workloads without noting the differences. Do not invent averages or claim performance improvements from a single sample.

## 2. Host collection — CachyOS

Run from the host. These commands are observational:

```bash
date --iso-8601=seconds
hostnamectl
uname -a
lscpu
free -h
uptime
vmstat 1 10
df -hT
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
ip -s link
virsh -c qemu:///system list --all
virsh -c qemu:///system domstats '<vm-name>' --vcpu --balloon --block --interface
```

Optional if installed:
- `iostat -xz 1 10` (sysstat)
- `sar -n DEV 1 10` (sysstat)
- `pidstat -dur 1 10` (sysstat)

Use `htop` or `btop` for interactive process inspection. Save terminal output to a private evidence file and review it before committing.

## 3. Guest collection — Ubuntu Server

Run inside the VM:

```bash
date --iso-8601=seconds
hostnamectl
uname -a
uptime
nproc
free -h
vmstat 1 10
df -hT
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
ip -s link
ps -eo user,pid,pcpu,pmem,rss,etime,args --sort=-pcpu | head -n 20
```

For Paper-specific observations, capture:
- Java process CPU and RSS
- Java heap usage from the server console or configured JVM monitoring
- Tick performance (MSPT/TPS) from a supported Paper diagnostic/plugin/tool if installed
- Player count, world activity, chunk generation, plugin warnings/errors
- Disk usage and growth of world, logs, and backup directories

Do not install a monitoring plugin solely to create a metric without checking compatibility and permissions.

## 4. Results ledger

Append actual observations; leave values blank until collected.

| Date/time UTC | Environment | Workload | Players | CPU | RAM used/available | Disk free | Network | Notes |
|---|---|---|---:|---:|---:|---:|---|---|
| TBD | CachyOS host | Idle | TBD | TBD | TBD | TBD | TBD | Not measured |
| TBD | Ubuntu VM | Idle | 0 | TBD | TBD | TBD | TBD | Not measured |
| TBD | Ubuntu VM | Normal | TBD | TBD | TBD | TBD | TBD | Not measured |
| TBD | Ubuntu VM | Controlled peak | TBD | TBD | TBD | TBD | TBD | Not measured |

Keep raw outputs in a private local evidence directory first. Publish only sanitized summaries. Do not claim a benchmark result until the sampling method and environment are reproducible.

## 5. Troubleshooting decision guide

### VM will not start
1. Check `virsh list --all`, `virsh domstate <vm>`, and `systemctl status libvirtd`.
2. Inspect `journalctl -u libvirtd -n 200 --no-pager` and the VM's QEMU/libvirt logs.
3. Check free host RAM/disk, storage pool state, ISO/disk paths, and host device ownership.
4. Inspect recent XML changes and passthrough device availability.
5. Do not delete/recreate the VM disk as a first response.

### SSH unreachable
1. Confirm VM state and guest IP via console.
2. Check guest `systemctl status ssh`, `ss -lntp`, route and address.
3. Check host/guest firewall and libvirt network state.
4. Test TCP reachability from the trusted LAN.
5. Use virt-manager console for recovery; do not expose SSH publicly as a workaround.

### Paper fails to start
1. Inspect `logs/latest.log` and confirmed service journal.
2. Check Java runtime version, JAR path, available disk/RAM and file ownership.
3. Identify the first causal exception, not just the final shutdown line.
4. Check plugin compatibility and recent updates.
5. Restore a known-good plugin/config backup if a change caused the failure.

### Geyser / Bedrock cannot connect
1. Confirm Paper is healthy and Geyser plugin loaded.
2. Inspect Geyser config and startup log for actual listener, port, and transport.
3. Confirm Playit agent online and tunnel origin/protocol matches Geyser.
4. Test from LAN before external network.
5. Check UDP/TCP support according to the installed transport; a generic UDP probe is not an application test.

### Playit agent offline
1. Check the actual package/service/process installed; do not assume unit name.
2. Inspect agent logs and outbound DNS/network reachability.
3. Verify account claim/agent status in dashboard without exposing tokens.
4. Confirm the tunnel still targets the correct local address and port.

### Disk full / world corruption concern
1. Stop writes gracefully if disk is critically full.
2. Check `df -hT`, `df -i`, and directory sizes.
3. Preserve logs and existing backup archives.
4. Do not delete world files or region files to reclaim space.
5. Restore only into an isolated test location first.

## 6. Operational runbooks and incident record

Use the Phase A VM lifecycle, Phase B Ubuntu administration, Phase C Minecraft operations/backup, and Phase D network security runbooks as the authoritative procedures. This phase adds the troubleshooting decision tree and evidence ledger.

For each incident record:
- UTC start/end time and impact
- Symptoms and exact error excerpts (redacted)
- Environment and versions
- Diagnostic commands and results
- Root cause (confirmed vs suspected)
- Remediation and rollback
- Post-change SSH/Java/Bedrock/Playit checks
- Backup/restore state and follow-up action

## 7. Security and secrets review

Before each push/release:
1. Inspect `git status --short` and `git diff --check`.
2. Review staged and unstaged diffs for credentials, tokens, private keys, IPs, usernames, MACs, serials, and unredacted VM XML.
3. Check tracked files for accidental secret-like content using a dedicated scanner such as Gitleaks; review findings manually.
4. Review the full Git history when a secret may previously have been committed. Removing it from the latest commit does not revoke it.
5. Rotate/revoke any exposed credential at its issuer, then consider history cleanup as a separate coordinated action.
6. Keep `.env`, backups, SSH keys, Playit agent state, RCON passwords and raw logs out of Git.
7. Use least-privilege file permissions and a separate protected backup filesystem.
8. Do not paste raw secret-bearing output into issues, PRs or chat.

This checklist is a procedure, not evidence that a scanner has already been run. No credentials have been declared clean by this document.

## 8. Acceptance criteria

- [ ] Host and guest idle baseline captured.
- [ ] Normal-load and controlled-peak samples captured.
- [ ] Measurement environment and methodology recorded.
- [ ] Raw outputs reviewed and sanitized.
- [ ] Troubleshooting guide exercised against at least one real incident or controlled failure.
- [ ] Operational runbooks cross-linked and current.
- [ ] Secret scanner run against working tree and repository history.
- [ ] Findings triaged; exposed credentials rotated/revoked.
- [ ] No private backup, raw XML, private key, or credential committed.
