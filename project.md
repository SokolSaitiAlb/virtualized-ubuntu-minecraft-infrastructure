# Project Record — Virtualized Ubuntu Minecraft Infrastructure

## Overview

A personal infrastructure project built to practice Linux administration, virtualization, remote server operations, application deployment, networking, and monitoring. The repository also tracks a separate Android-based Linux administration lab.

**Project type:** Personal infrastructure / portfolio project  
**Primary host:** CachyOS workstation  
**Primary guest:** Ubuntu Server VM  
**Secondary platform:** Pixel 8a running Android 17  
**Status:** Primary Minecraft lab implemented and exercised; Android lab planned.

## 1. Primary lab — Minecraft infrastructure

### Architecture

```text
Physical workstation
└── CachyOS
    └── KVM / QEMU + libvirt
        └── Ubuntu Server VM
            ├── PaperMC
            ├── Geyser-Spigot
            └── Playit.gg agent and tunnels
```

This is the original and primary project architecture. It remains unchanged by the Android lab.

### Host identification and KVM installer

The host operating system should be identified before installing virtualization packages. The project guide uses `/etc/os-release`, architecture information, and CPU virtualization flags as preflight checks.

The linked installer repository is:

https://github.com/SokolSaitiAlb/install-kvm-cachyos.sh

The inspected installer uses `pacman` to install QEMU/KVM, libvirt, Virt-Manager, and supporting packages. It enables `libvirtd` and adds the current user to the `libvirt` group.

**Current limitation:** the script does not automatically detect the host distribution and is intended for CachyOS/Arch-based systems. It must not be run as a universal installer on Ubuntu, Debian, Fedora, or other non-Arch distributions. Automatic distribution detection and safe per-distribution handling are future improvements.

### Host and virtualization

- CachyOS is the physical Linux host.
- KVM/QEMU is used to run an Ubuntu Server virtual machine.
- The VM was provisioned with CPU, storage, and device/network passthrough configuration for the original setup.
- The repeatable procedure is documented in [roadmap.md](roadmap.md).

Exact VM resource values and passthrough mappings should be recorded from the actual configuration rather than inferred.

### Guest administration

- Ubuntu Server was installed as the guest operating system.
- OpenSSH was used to administer the server from the CachyOS terminal and from Android Termux.
- htop and btop were used to inspect processes and resource utilization.

### Application deployment

- PaperMC was installed using a Bash-based installation workflow.
- Geyser-Spigot was installed using a Bash-based workflow and its plugin JAR.
- The server was tested from a local Minecraft client using Prism Launcher.
- The setup was also exercised by remote players.

The step-by-step guide covers Ubuntu Server installation, Java runtime selection, PaperMC startup, EULA handling, and Geyser plugin installation. Do not add unverified version numbers, service unit names, benchmark results, or uptime claims.

### Networking

- Playit.gg provided tunnel-based external connectivity.
- The configured custom hostname was `albkestrel.minecraft.party`.
- The Geyser/Bedrock endpoint used port `19132` in the original setup.
- The setup was tested from local and external networks, including players in Prishtina and Shkup.

The exact tunnel configuration may change over time. Geyser transport settings and Playit protocol availability are version- and plan-dependent. Match the Playit tunnel protocol and local origin to the active Geyser configuration. Do not commit private tunnel credentials or expose sensitive dashboard information.

### Firewall and security state

UFW was configured during experimentation. However, both the Ubuntu Server and CachyOS firewalls were disabled during troubleshooting. Therefore:

- Firewall hardening is **not** a completed project outcome.
- Re-enable firewalls only after defining required host and guest rules.
- Verify SSH and Minecraft connectivity after applying restrictive policies.
- Do not expose administrative services to the public internet without a deliberate security design.

## 2. Secondary lab — Android Linux Administration & Portable Infrastructure Lab

This is a separate lab in the same repository. It is not a component of the Minecraft server and does not change its architecture.

### Intended architecture

```text
Pixel 8a
└── Android 17
    └── Complete Linux Installer
        └── PRoot
            └── Ubuntu or Debian userspace
                ├── Bash
                ├── Python
                ├── Git
                ├── OpenSSH
                └── NGINX (local test)
```

### Purpose

Use an Android phone as a portable Linux command-line and service-administration practice environment. The goal is to exercise familiar Linux tooling on a second platform and document the practical differences.

### Planned work

- Install Ubuntu or Debian using Complete Linux Installer.
- Run Bash and Python test scripts.
- Install and use Git.
- Configure and test SSH from CachyOS to the Pixel environment.
- Run a local NGINX test service.
- Back up and restore the PRoot environment.
- Record Android networking, background execution, storage, and process-lifecycle constraints encountered during testing.

### PRoot versus KVM/QEMU

| Capability | PRoot on Android | KVM/QEMU on CachyOS |
|---|---|---|
| Runtime model | Userspace environment using PRoot | Hardware-assisted/full-system virtualization where supported |
| Separate guest kernel | No | Yes, for a conventional VM |
| Guest OS userspace | Yes | Yes |
| VM hardware model | No equivalent virtual hardware platform | Virtual CPU, memory, storage, and virtual devices |
| PCI/GPU passthrough | Not equivalent to VM passthrough | Possible when host hardware, firmware, and configuration support it |
| Intended role here | Portable Linux tooling practice | Ubuntu Server infrastructure host |

This table describes the architectural distinction; actual Android app behavior and network reachability must be confirmed through Phase 6 testing.

## 3. Technology inventory

| Technology | Use |
|---|---|
| CachyOS | Physical Linux host |
| KVM / QEMU + libvirt | Primary lab virtualization |
| Ubuntu Server | Minecraft server guest |
| Bash | Installation and administration automation |
| OpenSSH | Remote administration |
| PaperMC | Minecraft Java server |
| Geyser-Spigot | Bedrock-to-Java connectivity |
| Playit.gg | External tunnel connectivity |
| UFW | Firewall tooling; hardening remains incomplete |
| htop / btop | Interactive process/resource monitoring |
| Pixel 8a / Android 17 | Secondary lab device |
| Complete Linux Installer / PRoot | Planned Android Linux userspace |
| Ubuntu or Debian | Planned Android userspace distribution |
| Python / Git / NGINX | Planned Android lab exercises |

## 4. Validation and evidence

For each test, record:

1. Date and environment.
2. Software and OS versions.
3. Exact commands or configuration changes, with secrets removed.
4. Expected result.
5. Actual result and pass/fail status.
6. Limitations and cleanup performed.

Useful evidence includes sanitized terminal output, configuration excerpts, service responses, and successful backup-restore verification.

## 5. Known gaps and next work

- Implement and test host OS detection and safe unsupported-distribution handling in the separate KVM installer repository.
- Apply and verify restrictive host and guest firewall rules.
- Document exact VM CPU, memory, storage, and passthrough configuration.
- Record application and runtime versions.
- Implement and test repeatable backup and restore for the Minecraft world.
- Document service lifecycle and recovery procedures.
- Complete the Android Phase 6 tests before marking them implemented.

## 6. Related resources

- Host KVM setup workflow: https://github.com/SokolSaitiAlb/install-kvm-cachyos.sh
- Ubuntu Server downloads: https://ubuntu.com/download/server
- PaperMC: https://papermc.io/software/paper/
- Geyser-Spigot latest download: https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot
- Geyser setup guide: https://geysermc.org/wiki/geyser/setup/
- Playit.gg: https://playit.gg/
- Playit Linux agent guide: https://playit.gg/support/run-on-linux/
- Complete Linux Installer: https://f-droid.org/packages/com.devwithzachary.completelinuxinstaller
- Complete Linux Installer source: https://github.com/devwithzachary/LinuxOnAndroid
- Minecraft test video: https://youtu.be/TmqTv8vhd3o

## 7. Status vocabulary

- **Implemented:** configured or built as part of the project.
- **Tested:** exercised with an observable result.
- **Planned:** intended work not yet completed.
- **Needs verification:** described in project history but lacking sufficient repeatable evidence.

The Android lab must remain **Planned** until the corresponding tests are completed.


## 8. Phase E — Monitoring and operational documentation

The repository now includes [monitoring and troubleshooting runbook](docs/runbooks/monitoring-troubleshooting.md), [architecture diagram](docs/diagrams/architecture.md), and [network flow diagram](docs/diagrams/network-flow.md).

The monitoring method distinguishes host and guest measurements and defines idle, normal-load and controlled-peak windows. Actual numeric measurements have not yet been supplied; no benchmark result or performance improvement is claimed. The diagrams are templates and must be populated with verified, sanitized values.

The read-only helper `scripts/collect-host-evidence.sh <vm-name>` collects host and libvirt data. It does not collect guest metrics or change host/VM configuration.

The `scripts/review-secrets.sh` helper checks a limited set of tracked working-tree patterns and prints filenames only. It is not a comprehensive secret scanner and does not inspect full repository history, ignored/untracked files, or every credential format. A dedicated history-aware scan and credential rotation are still required before declaring the repository security-reviewed.

## 9. Phase F — Android PRoot lab status

**Status: Planned; not executed.**

The detailed plan is in [docs/phase-f-android-proot-lab.md](docs/phase-f-android-proot-lab.md). It covers Complete Linux Installer, Ubuntu/Debian, Bash, Python, Git, SSH from CachyOS, loopback-only NGINX, backup/restore and PRoot-versus-KVM comparison.

The plan intentionally does not assume:
- that the installer is currently maintained or compatible with this Android build;
- that systemd works inside the PRoot environment;
- that sshd can bind a reachable LAN interface;
- that Android permits persistent background services;
- that app backup/export captures every file or restores cleanly.

These points require tests on the actual Pixel device. PRoot uses the Android host kernel and does not provide a separate guest kernel or KVM-equivalent hardware virtualization.
