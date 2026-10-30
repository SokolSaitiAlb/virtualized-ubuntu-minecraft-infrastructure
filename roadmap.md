# Roadmap — Virtualized Ubuntu Minecraft Infrastructure

This roadmap tracks the original Minecraft infrastructure lab and the separate Android Linux lab. Phase 6 is a second laboratory, not a change to the original server architecture.

## Phase 1 — CachyOS Host & Virtualization

**Status: Implemented (personal project; detailed configuration evidence may be added)**

- [x] Use CachyOS as the physical Linux host.
- [x] Set up KVM/QEMU using the personal host setup workflow.
- [x] Create an Ubuntu Server virtual machine.
- [x] Allocate VM resources and configure the required device/network passthrough for the original setup.
- [ ] Add sanitized VM configuration and verified resource allocation details.
- [ ] Document host-side virtualization troubleshooting and recovery.

## Phase 2 — Ubuntu Server Administration

**Status: Implemented, with operational hardening still outstanding**

- [x] Install Ubuntu Server in the KVM/QEMU guest.
- [x] Administer the guest remotely using OpenSSH.
- [x] Use Linux process/resource tools such as htop and btop.
- [ ] Document exact Ubuntu release, package versions, and SSH configuration.
- [ ] Review SSH authentication, access scope, and host-key handling.
- [ ] Define and test a repeatable guest update procedure.

## Phase 3 — Minecraft Services

**Status: Implemented and exercised**

- [x] Deploy PaperMC using Bash automation.
- [x] Install Geyser-Spigot using a Bash-based workflow.
- [x] Test the server with a local Minecraft client.
- [x] Test remote player connectivity.
- [ ] Record exact PaperMC, Minecraft, Java, and Geyser versions.
- [ ] Document plugin compatibility and upgrade/rollback steps.
- [ ] Add a verified service lifecycle procedure (start, stop, restart, logs).

## Phase 4 — Networking & External Connectivity

**Status: Implemented for connectivity; security hardening incomplete**

- [x] Configure Playit.gg tunnel connectivity.
- [x] Use the custom hostname `albkestrel.minecraft.party`.
- [x] Test the Geyser/Bedrock endpoint on UDP port `19132`.
- [x] Configure UFW during experimentation.
- [ ] Replace troubleshooting state with explicit, tested host and guest firewall policies.
- [ ] Verify only required ports and interfaces are exposed.
- [ ] Document DNS/tunnel troubleshooting without publishing sensitive identifiers.
- [ ] Re-test from a network outside the local LAN after firewall rules are applied.

**Security note:** Host and guest firewalls were disabled during troubleshooting. Do not mark firewall hardening complete until restrictive rules are configured and connectivity is re-tested.

## Phase 5 — Monitoring, Reliability & Documentation

**Status: Partially implemented**

- [x] Inspect processes and resource usage with htop/btop.
- [x] Test local and remote player connectivity.
- [ ] Capture repeatable CPU, memory, storage, and network observations.
- [ ] Implement and test server-world backups.
- [ ] Perform a restore test and document recovery time/results.
- [ ] Add operational runbooks for startup, shutdown, updates, logs, and common failures.
- [ ] Add a sanitized network and component diagram.
- [ ] Document known limitations and lessons learned.

## Phase 6 — Android Linux Administration & Portable Infrastructure Lab

**Status: Planned — not yet verified**

**Platform:** Pixel 8a · Android 17  
**Installer:** Complete Linux Installer  
**Runtime:** PRoot userspace  
**Distribution target:** Ubuntu or Debian

### Objectives

1. Install and initialize Ubuntu or Debian in Complete Linux Installer.
2. Validate basic shell access and package management.
3. Test Bash scripts and Python execution.
4. Install/use Git and clone a harmless test repository.
5. Configure OpenSSH in the PRoot environment and investigate Android network reachability.
6. Test SSH from CachyOS to the Pixel environment. Record whether the Android app must remain active and whether the device is reachable on the LAN.
7. Run NGINX locally, verify the response, then stop the service and confirm the port is released.
8. Create a PRoot environment backup.
9. Restore the backup and verify shell access, packages, and test files.
10. Document PRoot constraints compared with KVM/QEMU.

### Phase 6 acceptance criteria

- [ ] Ubuntu or Debian installed and distribution/version recorded.
- [ ] Bash test script runs successfully.
- [ ] Python test script runs successfully.
- [ ] Git clone/status workflow succeeds.
- [ ] SSH connection from CachyOS to Pixel succeeds, or a reproducible platform limitation is documented.
- [ ] NGINX serves a local test page and is stopped cleanly.
- [ ] Backup archive is created and its integrity checked.
- [ ] Restore test succeeds in a clean/recreated PRoot environment.
- [ ] PRoot vs KVM/QEMU comparison is documented from observed behavior and verified technical properties.
- [ ] Evidence is sanitized and committed.

### Important technical boundary

PRoot provides a Linux userspace environment, not a separate Linux kernel or KVM/QEMU virtual machine. Phase 6 is a portable administration lab; it is not part of the Minecraft server runtime and must not be presented as equivalent virtualization.

## Suggested completion order

1. Finish Phase 5 reliability and security work for the original server.
2. Start Phase 6 as an isolated Android experiment.
3. Record evidence and limitations as each test is completed.
4. Update `todo.md` only after a task has actually passed its acceptance test.
