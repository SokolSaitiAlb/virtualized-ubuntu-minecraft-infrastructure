# Master Plan — Virtualized Ubuntu Minecraft Infrastructure

## 1. Project purpose

This repository documents two separate personal Linux infrastructure laboratories:

1. **Primary lab — Virtualized Minecraft Infrastructure:** Linux host administration, KVM/QEMU virtualization, Ubuntu Server operations, remote administration, game-server deployment, network connectivity, and monitoring.
2. **Secondary lab — Android Linux Administration & Portable Infrastructure Lab:** Linux command-line and service-administration practice on a Pixel 8a using Complete Linux Installer and PRoot.

The Android lab extends the learning portfolio. It does not extend, replace, or form part of the original Minecraft server architecture.

> **Accuracy rule:** This is a personal learning and infrastructure project, not professional production operations experience. Features are marked implemented only when supported by the project history; planned work must not be presented as completed.

## 2. Primary architecture — unchanged

```text
CachyOS Host
└── KVM / QEMU
    └── Ubuntu Server VM
        ├── PaperMC
        ├── Geyser-Spigot
        └── Playit.gg tunnel
```

### Primary lab components

| Layer | Component | Role |
|---|---|---|
| Host OS | CachyOS | Physical Linux workstation and virtualization host |
| Virtualization | KVM / QEMU | Runs the Ubuntu Server virtual machine |
| Guest OS | Ubuntu Server | Hosts the Minecraft server workloads |
| Game server | PaperMC | Minecraft Java server |
| Cross-play | Geyser-Spigot | Allows compatible Bedrock clients to connect |
| Remote access | OpenSSH | Remote administration from Linux and Android Termux |
| Connectivity | Playit.gg | Tunnel-based external player connectivity |
| Automation | Bash | Installation and setup scripts |
| Monitoring | htop / btop | Interactive process and resource inspection |

The original setup used VM resource allocation and device/network passthrough. Exact device mappings and performance measurements should be added only when verified from configuration or test evidence.

### Primary lab operational notes

- The server was tested locally and with remote players, including connections across Prishtina and Shkup.
- The Playit.gg configuration used the custom hostname `albkestrel.minecraft.party` and the Minecraft Bedrock/Geyser endpoint on UDP port `19132`.
- UFW was configured during experimentation, but host and guest firewalls were disabled during troubleshooting. This must not be described as a completed firewall-hardening implementation.
- Do not publish tunnel credentials, SSH private keys, passwords, public IP details, or other secrets.
- Add verified systemd service management, backup automation, firewall rules, monitoring history, and recovery procedures only after implementing and testing them.

## 3. Secondary architecture — Android Linux Lab

```text
Pixel 8a
└── Android 17
    └── Complete Linux Installer
        └── PRoot userspace environment
            ├── Ubuntu or Debian
            ├── Bash
            ├── Python
            ├── Git
            ├── OpenSSH
            └── Local NGINX test
```

This is a separate Android-based lab. Complete Linux Installer uses PRoot to run a Linux userspace environment; it is not KVM/QEMU, does not boot a separate Linux kernel, and must not be represented as a virtual machine equivalent to the Ubuntu Server guest.

### Phase 6 objectives

**Phase 6 — Android Linux Administration & Portable Infrastructure Lab**

- Install Ubuntu or Debian on the Pixel 8a using Complete Linux Installer.
- Exercise Bash, Python, Git, and SSH inside the PRoot environment.
- Establish and test SSH access from CachyOS to the Pixel environment, where Android networking and application lifecycle constraints permit it.
- Run NGINX locally and verify access from an appropriate client.
- Test PRoot environment backup and restore.
- Document PRoot limitations and compare them with KVM/QEMU.
- Record commands, test results, screenshots where useful, and any device-specific constraints.

All Phase 6 objectives are **planned** until individually tested and evidenced.

## 4. Separation and comparison

| Concern | Primary Minecraft lab | Android lab |
|---|---|---|
| Physical platform | CachyOS workstation | Pixel 8a |
| Isolation/runtime | KVM / QEMU virtual machine | PRoot userspace |
| Linux environment | Ubuntu Server guest | Ubuntu or Debian userspace |
| Main purpose | Host and server infrastructure | Portable Linux administration practice |
| Workloads | PaperMC, Geyser-Spigot | Bash, Python, Git, SSH, NGINX tests |
| Relationship | Original project | Independent supplementary lab |

PRoot does not provide a separate guest kernel or the same hardware virtualization and device-passthrough model as KVM/QEMU. Do not imply equivalent isolation, kernel control, hardware access, or production hosting capability.

## 5. Security and operational principles

- Keep secrets out of Git. Use local environment files and placeholders in examples.
- Never commit SSH private keys, passwords, tokens, or unredacted configuration exports.
- Prefer least-privilege access and explicit firewall rules.
- Do not expose SSH or NGINX to public networks during initial tests.
- Bind test services to loopback unless remote access is deliberately required and secured.
- Record the difference between a successful connectivity test and a security-hardened deployment.
- Backups are not verified until a restore test succeeds.
- Document commands with prerequisites, expected results, and rollback/cleanup steps.

## 6. Evidence and portfolio standards

For each completed task, retain appropriate non-sensitive evidence:

- OS and tool versions.
- Relevant commands and sanitized output.
- Configuration excerpts with secrets removed.
- Test procedure and pass/fail result.
- Known limitations and follow-up work.

Do not fabricate benchmark values, uptime, security claims, or completed tests. Clearly label work as **Implemented**, **Tested**, **Planned**, or **Needs verification**.

## 7. Repository map

- `masterplan.md` — project scope, architecture, separation, and standards.
- `roadmap.md` — phased implementation and learning sequence.
- `project.md` — technical project record and current known state.
- `todo.md` — implementation checklist and outstanding work.

## 8. Current status

The primary Minecraft lab has been built and exercised as a personal project. Some implementation details still need stronger evidence and operational hardening. The Android lab is a planned second laboratory; Phase 6 must remain open until installation and tests are completed.
