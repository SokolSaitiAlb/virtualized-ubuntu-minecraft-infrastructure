# Project TODO — Implementation Checklist

This checklist distinguishes work already performed in the original personal lab from tasks that remain open. Checkboxes must reflect verified work, not intentions.

## Primary lab — CachyOS / KVM / Ubuntu Server / Minecraft

### Host identification and virtualization

- [x] Use CachyOS as the physical Linux host.
- [x] Set up KVM/QEMU on CachyOS using the existing Arch-family installer.
- [x] Create an Ubuntu Server VM.
- [x] Configure VM resource allocation and the required passthrough for the original setup.
- [ ] Add automatic host-distribution detection to the KVM installer.
- [ ] Add safe handling for unsupported distributions; do not run pacman commands on non-Arch systems.
- [ ] Test OS detection on CachyOS and representative non-Arch distributions.
- [ ] Record exact CPU, memory, storage, and device passthrough settings.
- [ ] Add sanitized VM configuration evidence.
- [ ] Document VM start/stop and recovery procedure.

> **Current installer status:** The existing `install-kvm-cachyos.sh` uses `pacman` and targets CachyOS/Arch-based systems. It does not currently auto-detect the host distribution. The detection and multi-distro behavior above are planned script improvements, not implemented features.

### Ubuntu Server administration

- [x] Install Ubuntu Server in the VM.
- [x] Connect to the server using OpenSSH.
- [x] Administer the server from CachyOS terminal.
- [x] Access/administer the server from Android Termux.
- [x] Inspect processes and resource usage with htop/btop.
- [ ] Record OS version and package inventory.
- [ ] Document SSH configuration and authentication approach.
- [ ] Review and document least-privilege access.

### Minecraft services

- [x] Deploy PaperMC using Bash automation.
- [x] Install Geyser-Spigot using a Bash workflow.
- [x] Test local Minecraft client connectivity.
- [x] Test remote player connectivity.
- [ ] Record PaperMC, Minecraft, Java, and Geyser versions.
- [ ] Document plugin installation and update procedure.
- [ ] Document server lifecycle commands and log locations.
- [ ] Implement repeatable Minecraft world backups.
- [ ] Perform and document a successful restore test.

### Playit.gg, network and security

- [x] Configure Playit.gg tunnel connectivity.
- [x] Configure/use custom hostname `albkestrel.minecraft.party`.
- [x] Test the Geyser/Bedrock endpoint on port `19132`.
- [x] Configure UFW during initial experimentation.
- [ ] Re-enable and configure UFW on CachyOS with explicit required rules.
- [ ] Re-enable and configure UFW in Ubuntu Server with explicit required rules.
- [ ] Verify SSH access remains limited to intended trusted sources.
- [ ] Verify Minecraft Java and Geyser connectivity after firewall rules are applied.
- [ ] Document current Geyser transport requirements and matching Playit tunnel protocol.
- [ ] Document exposed ports and network paths.
- [ ] Review tunnel configuration and remove obsolete credentials.

> **Important:** The host and guest firewalls were disabled during troubleshooting. The checked UFW configuration item means UFW was configured during experimentation; it does not mean the current environment is hardened.

### Monitoring and documentation

- [x] Use htop/btop for interactive monitoring.
- [x] Test the server with local and remote players.
- [x] Add a repository README with architecture, links, scope, and security notes.
- [x] Add a step-by-step host, VM, PaperMC, Geyser, and Playit deployment guide to `roadmap.md`.
- [ ] Capture repeatable resource observations under idle and player load.
- [ ] Document common failure scenarios and troubleshooting.
- [ ] Add sanitized architecture/network diagrams.
- [ ] Add operational runbooks.
- [ ] Review all documentation for secrets and unsupported claims.

## Secondary lab — Phase 6: Android Linux Administration & Portable Infrastructure Lab

**Status: Planned. No Phase 6 task is marked complete yet.**

Device: Pixel 8a · Android 17  
Application: Complete Linux Installer  
Runtime: PRoot  
Target distribution: Ubuntu or Debian

### Installation and shell

- [ ] Install Complete Linux Installer from its trusted distribution channel.
- [ ] Install Ubuntu or Debian in the PRoot environment.
- [ ] Record app, Android, and distribution versions.
- [ ] Confirm shell startup and package manager operation.
- [ ] Record storage footprint and startup behavior.

### Bash, Python, and Git

- [ ] Run a Bash script that prints environment and system information.
- [ ] Run a Python script and record the interpreter version.
- [ ] Install Git and record its version.
- [ ] Clone a test repository.
- [ ] Test `git status`, a local commit, and repository cleanup.

### SSH from CachyOS to Pixel

- [ ] Determine whether an SSH server can run in the selected PRoot distribution.
- [ ] Configure SSH without exposing the service to the public internet.
- [ ] Identify the Pixel's LAN address and relevant Android network restrictions.
- [ ] Attempt SSH from CachyOS to the Pixel environment.
- [ ] Record the exact successful connection path, or document the reproducible limitation.
- [ ] Test key-based authentication if supported and remove test credentials safely.

### Local NGINX test

- [ ] Install NGINX in the PRoot environment.
- [ ] Create a simple local test page.
- [ ] Start NGINX bound to loopback where supported.
- [ ] Verify the HTTP response from an appropriate local client.
- [ ] Stop NGINX and verify the test port is no longer listening.
- [ ] Document Android background/lifecycle behavior observed during the test.

### PRoot backup and restore

- [ ] Identify the application's supported backup/export procedure.
- [ ] Create a backup archive of the PRoot environment.
- [ ] Verify archive integrity and record its size.
- [ ] Preserve the backup outside the environment being tested.
- [ ] Restore into a clean/recreated environment.
- [ ] Verify distribution startup, test files, packages, and command execution.
- [ ] Document any data or configuration that did not survive restore.

### PRoot versus KVM/QEMU

- [ ] Explain that PRoot provides userspace execution and does not boot a separate Linux kernel.
- [ ] Compare isolation and kernel control.
- [ ] Compare virtual hardware and device passthrough.
- [ ] Compare networking and inbound SSH reachability.
- [ ] Compare background execution and lifecycle constraints.
- [ ] Record practical observations without claiming equivalence to a VM.
- [ ] Add final test results and evidence to `project.md` and `roadmap.md`.

## Final portfolio review

- [ ] Ensure primary and secondary lab architectures remain visually and textually separate.
- [ ] Ensure no Phase 6 item is marked complete without evidence.
- [ ] Remove secrets, private keys, passwords, and sensitive tunnel details.
- [ ] Verify all repository links.
- [ ] Review documentation for accurate distinction between personal projects and professional experience.
