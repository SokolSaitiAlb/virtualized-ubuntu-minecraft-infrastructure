# Virtualized Ubuntu Minecraft Infrastructure

A personal Linux infrastructure project documenting how to build and operate a Minecraft server on an Ubuntu Server virtual machine hosted by a CachyOS workstation. The repository also tracks a completely separate Android Linux lab.

> **Project scope:** This is a personal learning and portfolio project. The documented setup is not represented as a professional production environment. Follow the security notes and verify each step on your own hardware.

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

The Android PRoot environment is a separate laboratory. It is **not** KVM/QEMU, does not boot a separate Linux kernel, and is not part of the Minecraft server architecture.

## Quick navigation

| Document | Purpose |
|---|---|
| [masterplan.md](masterplan.md) | Scope, architecture, security principles, and lab separation |
| [roadmap.md](roadmap.md) | Phased plan and step-by-step deployment guide |
| [project.md](project.md) | Technical project record, known state, and limitations |
| [todo.md](todo.md) | Implementation checklist and remaining work |

## Primary lab: end-to-end deployment guide

The full procedure is documented in [roadmap.md](roadmap.md), under **Phase 1–4: Step-by-step deployment guide**. The high-level sequence is:

1. Identify the host Linux distribution and verify hardware virtualization support.
2. On CachyOS/Arch-based hosts, review and run the [KVM installer script](https://github.com/SokolSaitiAlb/install-kvm-cachyos.sh).
3. Download an Ubuntu Server ISO from the [official Ubuntu download page](https://ubuntu.com/download/server).
4. Create and install an Ubuntu Server VM with KVM/QEMU using Virtual Machine Manager.
5. Update Ubuntu Server and configure OpenSSH.
6. Install the Java runtime required by the selected PaperMC release.
7. Download and start [PaperMC](https://papermc.io/software/paper/).
8. Install [Geyser-Spigot](https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot) in the Paper `plugins` directory.
9. Create a [Playit.gg](https://playit.gg/) account, claim the Linux agent, create the required tunnels, and test external connectivity.
10. Apply firewall rules deliberately, verify the server, and document backup and recovery procedures.

## Host OS detection: important limitation

The current `install-kvm-cachyos.sh` script uses `pacman` and installs Arch-family packages. It is intended for CachyOS/Arch-based systems. **The current script does not automatically detect the host distribution or install the correct virtualization stack on arbitrary Linux distributions.**

Start by identifying the host:

```bash
cat /etc/os-release
uname -m
```

Check that CPU virtualization is available:

```bash
lscpu | grep -E 'Virtualization|Architecture'
grep -E -c '(vmx|svm)' /proc/cpuinfo
```

If the host is CachyOS or a compatible Arch-based distribution, review the installer source before running it. Do not run this pacman-based script on Ubuntu, Debian, Fedora, or another non-Arch distribution. Support for automatic distribution detection and distribution-specific installation paths is a future enhancement, not an existing feature.

## Official downloads and references

- [KVM installer repository](https://github.com/SokolSaitiAlb/install-kvm-cachyos.sh)
- [Ubuntu Server downloads](https://ubuntu.com/download/server)
- [PaperMC downloads](https://papermc.io/software/paper/)
- [Geyser-Spigot latest download](https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot)
- [Geyser setup documentation](https://geysermc.org/wiki/geyser/setup/)
- [Playit.gg](https://playit.gg/)
- [Playit Linux agent guide](https://playit.gg/support/run-on-linux/)
- [Playit Linux 24/7 guide](https://playit.gg/support/host-247-with-playit/)

Always check the official documentation for version-specific Java requirements, Minecraft compatibility, Geyser transport settings, and Playit tunnel availability before deployment.

## Security and accuracy notes

- Never commit passwords, SSH private keys, Playit claim tokens, agent secrets, or unredacted configuration files.
- Do not expose SSH or RCON to the public internet.
- Playit tunnels are configured in the Playit account and point to local service ports; do not publish agent credentials.
- Do not assume that a successful tunnel test means the host and guest are fully hardened.
- UFW was used during experimentation, but host and guest firewalls were disabled during troubleshooting. Firewall hardening remains an open task.
- Backups are not considered verified until a restore test succeeds.
- Mark tasks as completed only after they have been performed and tested.

## Project status

- **Primary Minecraft lab:** built and exercised as a personal project; additional documentation, firewall hardening, and repeatable backup/restore evidence remain open.
- **Android Linux lab / Phase 6:** planned; installation and tests on the Pixel 8a have not yet been recorded as completed.

See [roadmap.md](roadmap.md) for the full procedure and [todo.md](todo.md) for current work items.
