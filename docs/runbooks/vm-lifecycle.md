# VM Lifecycle Runbook — Start, Stop and Recovery

**Scope:** The Ubuntu Server guest running under KVM/QEMU and libvirt on the CachyOS host.

**Safety rule:** These are operational procedures, not proof that the VM is currently healthy. Use the actual domain name and verify every state transition. Do not use force-stop/reset as a normal shutdown method.

## 1. Preconditions

On the CachyOS host:

```bash
virsh -c qemu:///system list --all
systemctl is-active libvirtd
```

Set the exact domain name reported by libvirt:

```bash
VM_NAME='replace-with-exact-domain-name'
```

Confirm that the domain exists:

```bash
virsh -c qemu:///system dominfo "$VM_NAME"
virsh -c qemu:///system domstate "$VM_NAME"
```

If the domain name is unknown or the domain is missing, stop and investigate before defining or recreating anything.

## 2. Start the VM

Start only if the VM is currently shut off:

```bash
virsh -c qemu:///system start "$VM_NAME"
virsh -c qemu:///system domstate "$VM_NAME"
virsh -c qemu:///system list --all
```

Expected result: the domain transitions to `running`.

If the start command fails, capture the exact error and continue to the recovery diagnostics. Do not repeatedly issue start commands or edit XML without understanding the failure.

## 3. Graceful guest shutdown

Preferred method: shut down from the Ubuntu guest itself:

```bash
sudo shutdown -h now
```

Alternatively, from the CachyOS host, request an ACPI shutdown:

```bash
virsh -c qemu:///system shutdown "$VM_NAME"
```

Poll the state:

```bash
virsh -c qemu:///system domstate "$VM_NAME"
virsh -c qemu:///system list --all
```

Expected result: `shut off`.

Do not assume that a shutdown request completed just because the command returned successfully. Verify the domain state.

## 4. Pause and resume

Use pause/resume only for a deliberate temporary suspension, not as a substitute for shutdown:

```bash
virsh -c qemu:///system suspend "$VM_NAME"
virsh -c qemu:///system domstate "$VM_NAME"
virsh -c qemu:///system resume "$VM_NAME"
virsh -c qemu:///system domstate "$VM_NAME"
```

Verify that the final state is `running`.

## 5. Recovery diagnostics

If the VM will not start, appears stuck, or is unreachable:

1. Record the exact error and current time.
2. Check the host and libvirt service:

```bash
systemctl is-active libvirtd
systemctl status libvirtd --no-pager
journalctl -u libvirtd -b --no-pager -n 150
```

3. Check domain state and configuration:

```bash
virsh -c qemu:///system list --all
virsh -c qemu:///system dominfo "$VM_NAME"
virsh -c qemu:///system domstate "$VM_NAME"
virsh -c qemu:///system dumpxml "$VM_NAME" --inactive
```

4. Check libvirt networks and storage references:

```bash
virsh -c qemu:///system net-list --all
virsh -c qemu:///system domblklist "$VM_NAME" --details
virsh -c qemu:///system domiflist "$VM_NAME"
```

5. Check host capacity and passthrough devices:

```bash
free -h
df -h
lsblk
lspci -nn
```

6. If libvirtd is inactive, inspect its journal and configuration before attempting service recovery. Restarting libvirt can affect other guests and networks; do not do so while another workload depends on it without checking.

7. After identifying and correcting the specific cause, retry a normal start and verify guest reachability.

## 6. If the VM is paused

Inspect the reason and host logs first. If the pause was intentional and the host/device condition is resolved, resume:

```bash
virsh -c qemu:///system resume "$VM_NAME"
virsh -c qemu:///system domstate "$VM_NAME"
```

Do not resume a guest if its storage or passed-through device is in an unsafe or failed state.

## 7. Force-stop / reset — emergency only

`virsh destroy` is equivalent to abruptly removing power from the VM. It can cause filesystem or world-data corruption. It is **not** a normal stop command.

Only consider it when the guest is irrecoverably unresponsive, graceful shutdown has failed, the risk is understood, and no safer recovery path remains:

```bash
# Emergency only — abrupt power-off; possible guest data corruption.
virsh -c qemu:///system destroy "$VM_NAME"
```

After an emergency power-off:

1. Do not immediately restart in a loop.
2. Check host storage health and available space.
3. Inspect the guest disk and libvirt logs.
4. Start the VM only after deciding that the guest filesystem can safely undergo recovery.
5. Verify Ubuntu filesystem/service health and Minecraft world integrity before allowing players to connect.

Do not use `virsh reset` as a routine recovery action; it is also an abrupt guest reset.

## 8. Guest and application verification after boot

From the CachyOS host, identify the guest address:

```bash
virsh -c qemu:///system domifaddr "$VM_NAME"
```

If this does not report an address, use the guest console or the guest's own network command; do not assume that the VM is offline.

Inside Ubuntu Server:

```bash
hostnamectl
ip -br address
systemctl status ssh --no-pager
```

Then test SSH from CachyOS using the actual guest IP:

```bash
ssh <ubuntu-user>@<ubuntu-vm-ip>
```

After connecting, verify Minecraft services using the actual deployment method and paths. The repository does not yet establish a confirmed systemd unit or fixed server directory, so this runbook intentionally does not invent service names or commands for PaperMC/Geyser/Playit.

Before opening the server to players, confirm:
- Ubuntu is responsive and storage is mounted.
- SSH works through the intended trusted path.
- PaperMC is running and reports ready.
- Geyser is loaded and listening on its configured endpoint.
- Playit agent is online and tunnel protocol/origin match Geyser's current configuration.
- Local and remote client tests succeed.

## 9. Autostart

Check the current setting:

```bash
virsh -c qemu:///system dominfo "$VM_NAME"
```

If automatic startup is desired, first verify that host capacity, passthrough dependencies and guest shutdown behavior are understood. Then explicitly enable it:

```bash
virsh -c qemu:///system autostart "$VM_NAME"
virsh -c qemu:///system dominfo "$VM_NAME"
```

To disable it:

```bash
virsh -c qemu:///system autostart --disable "$VM_NAME"
```

Autostart is not enabled or disabled by this document. Record the actual state in the Phase A evidence file.

## 10. Recovery record

For each incident, record:

- Date/time:
- VM domain:
- Initial domain state:
- User-visible symptom:
- Exact error:
- Relevant libvirt journal excerpt:
- Host capacity/storage status:
- Passthrough device status:
- Action taken:
- Final domain state:
- Ubuntu/SSH verification:
- Paper/Geyser/Playit verification:
- Data integrity / world verification:

## 11. Explicitly out of scope

This runbook does not:
- Change VM CPU/RAM/disk allocations.
- Modify domain XML or PCI passthrough assignments.
- Reconfigure host or guest firewalls.
- Force a shutdown during normal operation.
- Assume a PaperMC, Geyser, or Playit systemd unit exists.
- Claim that backups or restore have been tested.

Complete the host/VM evidence document before adding exact hardware-specific recovery instructions.
