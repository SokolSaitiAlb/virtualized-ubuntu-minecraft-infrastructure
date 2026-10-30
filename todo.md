# Project TODO — Implementation Checklist

This checklist separates verified work in the original personal lab from documentation/templates and tasks still requiring execution on the real host/guest. Checkboxes are not evidence of successful deployment unless explicitly stated.

## Primary lab — CachyOS / KVM / Ubuntu Server / Minecraft

### Phase A — Host and VM evidence

- [x] Use CachyOS as the physical Linux host.
- [x] Set up KVM/QEMU on CachyOS using the existing Arch-family installer.
- [x] Create an Ubuntu Server VM.
- [x] Configure VM resource allocation and passthrough for the original setup.
- [x] Document VM start/stop/recovery procedure in [VM lifecycle runbook](docs/runbooks/vm-lifecycle.md).
- [x] Add host/VM evidence collection procedure and sanitization requirements in [Phase A evidence](docs/phase-a-host-vm-evidence.md).
- [ ] Merge and verify automatic host-distribution detection in the KVM installer.
- [ ] Run installer `--check` on the actual CachyOS host after the installer PR is merged.
- [ ] Record exact host CPU/RAM/storage and VM vCPU/RAM/disk/PCI passthrough values.
- [ ] Commit reviewed, sanitized VM XML and guest-visible passthrough evidence.

> Installer detection remains in [installer PR #1](https://github.com/SokolSaitiAlb/install-kvm-cachyos.sh/pull/1), separate from this repository. It must not be called released until merged and tested on the actual CachyOS host.

### Phase B — Ubuntu Server administration

- [x] Install Ubuntu Server in the VM.
- [x] Connect using OpenSSH; administer from CachyOS and Android Termux.
- [x] Use htop/btop for interactive resource inspection.
- [x] Add [Ubuntu Server administration runbook](docs/runbooks/ubuntu-server-administration.md) with OS/package inventory, SSH audit, authentication hardening sequence, and least-privilege review.
- [ ] Capture actual Ubuntu release, kernel, architecture, and package inventory.
- [ ] Record effective SSH configuration from `sshd -T`.
- [ ] Record and test the actual SSH authentication method(s).
- [ ] Review actual users, sudo/group memberships, service account, file ownership, and listening sockets.
- [ ] Apply any justified least-privilege changes and retest administrative access.

### Phase C — Minecraft operations

- [x] Deploy PaperMC using Bash automation.
- [x] Install Geyser-Spigot using a Bash workflow.
- [x] Test local and remote player connectivity in the original lab.
- [x] Add [Minecraft operations runbook](docs/runbooks/minecraft-operations.md) covering version capture, plugin install/update/rollback, lifecycle discovery, logs, and backup/restore acceptance.
- [x] Add fail-closed [systemd backup template](scripts/backup-minecraft.sh) requiring explicit server directory, backup directory, and confirmed systemd unit.
- [x] Add static safety test for the backup template.
- [ ] Capture actual Paper, Minecraft, Java, Geyser, and plugin versions/builds.
- [ ] Confirm the actual Paper server directory and process manager/service unit.
- [ ] Validate plugin inventory, official sources, compatibility, and update/rollback process.
- [ ] Execute the backup template only after confirming the real systemd unit and paths.
- [ ] Store backup archives outside the live server directory and protect them as sensitive data.
- [ ] Verify archive checksum and integrity.
- [ ] Perform isolated restore test into a separate directory/environment; never overwrite the live world.
- [ ] Verify restored world/config/plugins and isolated startup.

> The backup script is a template, not a claim that a service unit exists or that a backup has been executed. It intentionally refuses to run without explicit configuration. The script currently has no retention/deletion policy; define and test one before scheduling recurring backups.

### Phase D — Network security

- [x] Configure UFW during initial experimentation.
- [x] Add [network security runbook](docs/runbooks/network-security.md) covering host/guest review, staged firewall activation, SSH restrictions, port mapping, Playit/Geyser transport matching, and connectivity tests.
- [ ] Capture current CachyOS firewall backend/rules and libvirt network/forwarding topology.
- [ ] Capture current Ubuntu UFW state and listening sockets.
- [ ] Identify trusted SSH source subnet and verify key-based access.
- [ ] Identify exact Paper Java listener and protocol.
- [ ] Identify exact Geyser listener, transport (RakNet/UDP or NetherNet/TCP+UDP), and port.
- [ ] Record actual Playit public protocol/endpoint and local origin mapping without publishing credentials.
- [ ] Design and review host firewall policy without breaking libvirt NAT/bridge forwarding.
- [ ] Design and review guest UFW policy with SSH recovery access preserved.
- [ ] Enable host and guest firewall policies during a maintenance window.
- [ ] Verify SSH from the trusted source after firewall activation.
- [ ] Verify Java Edition local and external connectivity after firewall activation.
- [ ] Verify Bedrock local and external connectivity after firewall activation.
- [ ] Verify Playit agent status and protocol/origin after firewall activation.
- [ ] Review RCON bind address and ensure it is not publicly exposed.

> **Known risk:** Host and guest firewalls were disabled during troubleshooting. Documentation and example rules do not mean either firewall is currently enabled or hardened. Do not apply generic default-deny rules until actual libvirt and Playit paths have been mapped.

### Monitoring, documentation and portfolio evidence

- [x] Use htop/btop for interactive monitoring.
- [x] Test the original server with local and remote players.
- [x] Add README, roadmap, masterplan, project record, and implementation checklist.
- [x] Add Phase A, B, C, and D runbooks/templates.
- [ ] Capture repeatable idle/load CPU, memory, storage, and network observations.
- [ ] Add sanitized architecture and network diagrams.
- [ ] Record operational test evidence and troubleshooting outcomes.
- [ ] Review docs/scripts for secrets, path assumptions, and unsupported claims.

## Secondary lab — Phase 6: Android Linux Administration & Portable Infrastructure Lab

**Status: Planned. No Phase 6 task is marked complete.**

Device: Pixel 8a · Android 17  
Application: Complete Linux Installer  
Runtime: PRoot  
Target distribution: Ubuntu or Debian

### Installation and shell

- [ ] Install Complete Linux Installer from its trusted distribution channel.
- [ ] Install Ubuntu or Debian in PRoot.
- [ ] Record app, Android, and distribution versions.
- [ ] Confirm shell startup and package manager operation.
- [ ] Record storage footprint and startup behavior.

### Bash, Python, and Git

- [ ] Run a Bash environment/system-information script.
- [ ] Run a Python script and record interpreter version.
- [ ] Install Git and record version.
- [ ] Clone a test repository and verify status/commit/cleanup.

### SSH from CachyOS to Pixel

- [ ] Determine whether SSH server can run in the selected PRoot distribution.
- [ ] Configure SSH without public internet exposure.
- [ ] Identify Pixel LAN address and Android network restrictions.
- [ ] Attempt SSH from CachyOS and record success or reproducible limitation.
- [ ] Test key authentication if supported and remove test credentials safely.

### Local NGINX test

- [ ] Install NGINX in PRoot.
- [ ] Create a local test page and bind to loopback where supported.
- [ ] Verify HTTP response.
- [ ] Stop NGINX and verify listener closure.
- [ ] Document Android background/lifecycle behavior.

### PRoot backup and restore

- [ ] Identify supported app backup/export procedure.
- [ ] Create archive and verify integrity.
- [ ] Preserve backup outside tested environment.
- [ ] Restore into clean/recreated environment.
- [ ] Verify startup, files, packages, and command execution.
- [ ] Document anything not restored.

### PRoot versus KVM/QEMU

- [ ] Explain PRoot userspace execution and lack of separate kernel.
- [ ] Compare isolation, kernel control, virtual hardware, passthrough, networking, and lifecycle.
- [ ] Record practical observations without claiming equivalence.
- [ ] Add evidence to `project.md` and `roadmap.md`.

## Final portfolio review

- [ ] Keep primary KVM lab and secondary Android PRoot lab separate.
- [ ] Do not mark Phase 6 complete without evidence.
- [ ] Remove secrets, private keys, passwords, and sensitive tunnel details.
- [ ] Verify repository links and scripts.
- [ ] Distinguish personal project work from professional employment experience.
