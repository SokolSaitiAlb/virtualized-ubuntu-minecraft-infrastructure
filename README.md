# Virtualized Ubuntu Minecraft Infrastructure

A personal Linux infrastructure project documenting how to build and operate a Minecraft server on an Ubuntu Server virtual machine hosted by a CachyOS workstation. The repository also tracks a completely separate Android Linux lab.

> **Project scope:** This is a personal learning and portfolio project, not a claim of professional production infrastructure experience. Tasks are marked complete only when supported by actual execution or test evidence.

## Architecture

### Primary lab — Minecraft infrastructure

```text
CachyOS Host
└── KVM / QEMU + libvirt
    └── Ubuntu Server VM
        ├── PaperMC (Java Edition server)
        ├── Geyser-Spigot (Bedrock-to-Java bridge)
        └── Playit.gg agent and tunnels
```

### Secondary lab — Android Linux administration

```text
Pixel 8a · Android 17
└── Complete Linux Installer
    └── PRoot userspace
        └── Ubuntu or Debian
            ├── Bash · Python · Git
            ├── OpenSSH
            └── NGINX local test
```

The Android PRoot environment is a separate laboratory. It is not KVM/QEMU, does not boot a separate Linux kernel, and is not part of the Minecraft server architecture.

## Documentation and runbooks

| Document | Purpose |
|---|---|
| [masterplan.md](masterplan.md) | Scope, architecture, security principles, and lab separation |
| [roadmap.md](roadmap.md) | Phased plan and deployment guide |
| [project.md](project.md) | Technical project record, known state, and limitations |
| [todo.md](todo.md) | Evidence-based implementation checklist |
| [Phase A host/VM evidence](docs/phase-a-host-vm-evidence.md) | Host/guest inventory, VM resource/passthrough evidence, XML sanitization |
| [VM lifecycle runbook](docs/runbooks/vm-lifecycle.md) | Start, graceful stop, diagnostics, and recovery |
| [Ubuntu administration runbook](docs/runbooks/ubuntu-server-administration.md) | OS/package inventory, SSH, authentication, least privilege |
| [Minecraft operations runbook](docs/runbooks/minecraft-operations.md) | Versions, plugins, lifecycle, logs, backup/restore |
| [Network security runbook](docs/runbooks/network-security.md) | Host/guest firewall, SSH restrictions, Playit and connectivity tests |

## Backup automation template

`scripts/backup-minecraft.sh` is a fail-closed template for a PaperMC directory managed by a confirmed systemd unit. It requires explicit absolute source/destination paths and unit name, stops the active unit gracefully, creates a full-directory archive and SHA-256 checksum, and attempts to restart the service.

It does **not** create a service unit, discover the live server path, configure a schedule, or claim that a backup/restore has been tested. Full backups may contain private configuration and credentials; protect them and do not commit archives. A restore test must extract into an isolated test directory/environment, never over the live world.

Static checks:

```bash
bash -n scripts/backup-minecraft.sh
bash tests/test-backup-template.sh
```

## Deployment overview

The existing deployment guide remains in [roadmap.md](roadmap.md). It covers CachyOS/KVM, Ubuntu Server, PaperMC, Geyser-Spigot, and Playit.gg. Always verify exact Java/Paper compatibility and Geyser transport requirements against official documentation for the versions actually installed.

## Host OS detection limitation

The default branch of the KVM installer must be checked before use. The installer repository's separate [host OS detection PR](https://github.com/SokolSaitiAlb/install-kvm-cachyos.sh/pull/1) is not considered released until merged and tested on the real CachyOS host. The script is not a universal multi-distro installer; it targets CachyOS/Arch-family systems and must not run pacman commands on non-Arch systems.

## Security and accuracy notes

- Never commit passwords, SSH private keys, Playit claim tokens, agent secrets, or unredacted configuration files.
- Do not expose SSH or RCON to the public internet.
- Playit tunnels use an outbound agent connection; do not automatically expose Minecraft/SSH ports on the router.
- Host and guest firewalls were disabled during troubleshooting. Firewall hardening remains unverified.
- Do not apply firewall policy until libvirt forwarding, trusted SSH sources, Paper/Geyser listeners, and Playit tunnel protocol/origin have been mapped.
- Backups are not considered verified until checksum validation and an isolated restore test succeed.
- Do not claim a systemd service, server path, Java/Paper/Geyser version, or firewall rule unless observed on the actual VM.

## Project status

- **Primary Minecraft lab:** deployed and exercised as a personal project; Phase B-D evidence capture, operational automation, firewall hardening, and restore testing remain in progress.
- **Android Linux lab / Phase 6:** planned; installation and tests on Pixel 8a have not been recorded as complete.

See [todo.md](todo.md) for current acceptance criteria.
