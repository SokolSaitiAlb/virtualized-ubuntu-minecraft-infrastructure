# Phase A — Host and VM Evidence

**Status:** Evidence collection template; exact host/VM values have not yet been captured in this repository.

This document records the real configuration of the CachyOS host and Ubuntu Server VM. Replace every `TBD` only with output collected from the actual machine. Do not copy example values from tutorials.

## 1. Evidence status

| Area | Current evidence | Status |
|---|---|---|
| Physical host distribution | Project history identifies CachyOS; fresh `/etc/os-release` output not attached here | Partially recorded |
| Host CPU | Project history identifies Intel Core i5-12400F | Hardware model known; host topology/output pending |
| Host RAM | Project history identifies 16 GB DDR4-3200 | Capacity known; current usable/available output pending |
| Host storage | Project history identifies 512 GB NVMe + 1 TB HDD | Device mapping, filesystem and VM disk backing pending |
| Virtualization | KVM/QEMU + libvirt used for the original VM | Existing setup recorded; current libvirt state pending |
| VM CPU/RAM | Not present in the source documentation | Pending |
| VM virtual disk | Not present in the source documentation | Pending |
| PCI/GPU/network passthrough | Passthrough was used, but exact devices and attachment types are not recorded | Pending |
| Sanitized domain XML | Not yet committed | Pending |

## 2. Physical host inventory

Run on the CachyOS host:

```bash
printf '\n=== OS ===\n'
cat /etc/os-release
printf '\n=== KERNEL / ARCH ===\n'
uname -a
uname -m
printf '\n=== CPU ===\n'
lscpu
printf '\n=== MEMORY ===\n'
free -h
printf '\n=== BLOCK DEVICES ===\n'
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
printf '\n=== FILESYSTEM SPACE ===\n'
df -hT
printf '\n=== LIBVIRT SERVICE ===\n'
systemctl status libvirtd --no-pager
printf '\n=== VM LIST ===\n'
virsh -c qemu:///system list --all
```

Record the date/time and the command output in the evidence section below. The inventory must distinguish physical RAM/storage from resources assigned to the guest.

### Host record

- Capture date/time: **TBD**
- Distribution/version: **TBD**
- Kernel: **TBD**
- CPU model / sockets / cores / threads: **TBD**
- Installed RAM: **TBD**
- NVMe device and filesystem: **TBD**
- HDD device and filesystem: **TBD**
- Libvirt service state: **TBD**
- VM domain name: **TBD**

## 3. VM configuration evidence

First identify the exact domain name:

```bash
virsh -c qemu:///system list --all
```

Set the shell variable to the exact name shown; do not include angle brackets:

```bash
VM_NAME='replace-with-exact-domain-name'
virsh -c qemu:///system dominfo "$VM_NAME"
virsh -c qemu:///system domstate "$VM_NAME"
virsh -c qemu:///system vcpucount "$VM_NAME"
virsh -c qemu:///system dommemstat "$VM_NAME"
virsh -c qemu:///system domblklist "$VM_NAME" --details
virsh -c qemu:///system domiflist "$VM_NAME"
virsh -c qemu:///system dumpxml "$VM_NAME" --inactive
```

If a command is unsupported by the installed libvirt version, record that fact rather than silently substituting an assumed value.

### Values to extract

| VM attribute | Actual value |
|---|---|
| Domain name / UUID | **TBD** — do not publish UUID |
| Guest OS / release | **TBD** |
| vCPU count and topology | **TBD** |
| Configured RAM | **TBD** |
| Memory backing / hugepages | **TBD** or not configured |
| Virtual disk path / backing device | **TBD** — redact private host paths if needed |
| Virtual disk capacity / format | **TBD** |
| Virtual NIC model / network / source | **TBD** |
| PCI devices passed through | **TBD** |
| GPU passed through and guest-visible identity | **TBD** |
| Boot order / firmware | **TBD** |
| Autostart enabled | **TBD** |

### Passthrough evidence

Use the inactive domain XML as the configuration source of truth, then correlate PCI host addresses with the host's device inventory. Record only what is actually configured. A host PCI address in XML is not, by itself, proof that the guest successfully initialized the device.

Useful read-only commands:

```bash
lspci -nn
virsh -c qemu:///system dumpxml "$VM_NAME" --inactive
```

For guest-visible confirmation, run inside Ubuntu Server:

```bash
lspci -nn
lsblk
ip -br link
```

Do not change PCI assignments, detach host devices, or edit domain XML during evidence collection.

## 4. Sanitization before committing

A copy of domain XML may expose infrastructure identifiers. Before committing it:

- Replace UUIDs with `REDACTED-UUID`.
- Replace MAC addresses with `REDACTED-MAC`.
- Replace serial numbers and host-specific identifiers with `REDACTED`.
- Replace private IP addresses with documentation placeholders such as `192.0.2.x` or `REDACTED-IP`.
- Remove usernames, home-directory paths, personal mount paths and disk serials.
- Remove secrets, tokens, passwords, private keys and credential-bearing command lines.
- Preserve structural information needed to understand CPU, memory, disk buses, network model and PCI passthrough. Do not remove the device model or PCI vendor/device IDs if safe to publish.

Never commit an unreviewed raw `dumpxml` output.

## 5. Verification checklist

- [ ] Host inventory collected from the actual CachyOS machine.
- [ ] VM domain name identified.
- [ ] vCPU count/topology verified.
- [ ] Configured RAM verified.
- [ ] Virtual disk backing and capacity verified.
- [ ] Host and guest storage mapping understood.
- [ ] Network interface and libvirt network verified.
- [ ] PCI/GPU passthrough configuration identified.
- [ ] Guest-visible devices checked from Ubuntu.
- [ ] Sanitized XML reviewed for identifiers and secrets.
- [ ] Evidence committed only after all values are checked.

## 6. Known limitations

This repository's earlier documentation confirms that the original lab used a CachyOS host, KVM/QEMU, an Ubuntu Server VM, and device passthrough. It does not provide exact VM resource values, PCI device mappings, or sanitized domain XML. Those details remain unverified until the commands above are run on the actual host and guest.
