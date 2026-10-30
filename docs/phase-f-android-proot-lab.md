# Phase F — Android PRoot Linux Administration Lab

<badge>Planned — not yet executed</badge>

**Device recorded for this project:** Pixel 8a, Android 17.  
**Intended installer:** Complete Linux Installer.  
**Runtime:** PRoot.  
**Target userspace:** Ubuntu or Debian.

This is a separate learning lab. It does not host or replace the KVM Minecraft server. Complete Linux Installer/PRoot behavior, package availability, SSH reachability, and Android background restrictions must be verified on the actual device before any task is marked complete.

## 1. Scope and safety

Objectives:
- Install an Ubuntu or Debian userspace through Complete Linux Installer.
- Exercise Bash, Python and Git.
- Attempt SSH from CachyOS to the PRoot environment over a trusted LAN.
- Run NGINX as a loopback-only local test.
- Export/backup and restore the PRoot environment.
- Compare PRoot with KVM/QEMU based on observed behavior.

Use the app's trusted distribution channel and verify its current maintenance status, Android compatibility, permissions, and export/restore behavior before installation. Do not grant root access or unlock the bootloader for this lab. Do not expose SSH/NGINX to the public internet.

## 2. Installation and initial inventory

Before installation, record:
- Android version/build and available storage.
- Complete Linux Installer version and source.
- Chosen distribution and release.
- Installer/runtime settings and storage path (redact private paths if publishing).

After starting the environment:

```bash
cat /etc/os-release
uname -a
id
pwd
printf 'Shell: %s\n' "$SHELL"
command -v apt || command -v apt-get
df -h
free -h
```

Important: `uname -a` normally reports the Android host kernel, not a separately booted Ubuntu/Debian kernel. Record this as expected PRoot architecture behavior, not an installation defect.

Update package metadata and install only the required lab tools:

```bash
sudo apt update
sudo apt install -y bash python3 python3-venv git openssh-server nginx curl ca-certificates
```

If `sudo` is not configured in the app's userspace, use the documented package-management method provided by the installer. Do not assume systemd is available inside PRoot.

## 3. Bash, Python and Git exercises

Bash:
```bash
cat > ~/lab-info.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'Timestamp: '; date -Is
printf 'Distro: '; . /etc/os-release; printf '%s %s\n' "$NAME" "$VERSION_ID"
printf 'Architecture: '; dpkg --print-architecture
printf 'User: '; id
printf 'Working directory: '; pwd
df -h /
EOF
chmod +x ~/lab-info.sh
~/lab-info.sh
```

Python:
```bash
python3 --version
python3 - <<'PY'
import os, platform, sys
print("Python:", sys.version)
print("Machine:", platform.machine())
print("Kernel:", platform.release())
print("UID:", os.getuid())
PY
```

Git:
```bash
git --version
mkdir -p ~/prout-lab-repo
cd ~/prout-lab-repo
git init
printf '# PRoot lab test\n' > README.md
git add README.md
git -c user.name='PRoot Lab' -c user.email='lab@example.invalid' commit -m 'test: initialize local PRoot lab'
git status --short --branch
```

The example Git identity is local test metadata, not an account identity. Replace it if you later publish the repository.

## 4. SSH from CachyOS to Pixel

First determine whether OpenSSH server can bind a TCP listener in this PRoot environment and whether Android permits the app to remain active in the background.

Inside PRoot:
```bash
sudo ssh-keygen -A
sudo /usr/sbin/sshd -t
sudo /usr/sbin/sshd -D -e -p 2222
```

Run sshd in the foreground for the initial test. If the binary/path or privilege model is unsupported, record the exact error; do not invent a workaround that requires root.

On CachyOS, on the same trusted LAN:
```bash
ip route
ssh -vv -p 2222 <prout-user>@<pixel-lan-ip>
```

Use key authentication where supported. Keep the private key on CachyOS. Restrict the listener to a reachable private interface or loopback as the environment allows. Do not router-forward port 2222. Stop the foreground sshd with Ctrl-C after testing.

Record:
- Pixel LAN address and whether it changes.
- PRoot sshd bind address/port and startup result.
- Android battery/background restrictions observed.
- CachyOS connection result and authentication method.
- Whether connection survives screen-off/app backgrounding.

A failure caused by Android/PRoot networking is a valid documented result. Do not mark SSH complete unless a real end-to-end connection succeeds.

## 5. NGINX local test

Run NGINX only as a local test. Confirm the packaged config can be used in the PRoot runtime; do not assume systemd service management.

Inspect and configure a loopback-only listener on an unprivileged port:

```bash
mkdir -p ~/nginx-lab
printf 'PRoot NGINX test\n' > ~/nginx-lab/index.html
```

Use a separate temporary NGINX config (not the system-wide default) with:
- `daemon off;`
- `pid` and logs under `$HOME/nginx-lab/`
- `listen 127.0.0.1:8080;`
- document root `$HOME/nginx-lab`

Start NGINX in the foreground using that config, then in another PRoot shell:
```bash
curl -i http://127.0.0.1:8080/
```

Expected response body: `PRoot NGINX test`. Stop NGINX with Ctrl-C and confirm the listener closes. Do not bind `0.0.0.0` or expose the test service to Wi-Fi/LAN unless a separate security design is approved.

## 6. Backup and restore

Use the installer's documented export/backup feature if available. First identify exactly what it captures: rootfs, package metadata, user home, app configuration, and any external storage mounts.

If a documented export method is unavailable, do not assume that copying a live rootfs is consistent. Stop all PRoot processes, then use the app-supported method or a cold archive of the documented environment path.

Acceptance:
1. Record source environment release and storage size.
2. Stop PRoot processes cleanly.
3. Export to a destination outside the environment.
4. Verify archive integrity/checksum.
5. Preserve the backup separately.
6. Restore into a fresh test environment/path without overwriting the source.
7. Verify login, package manager, Bash/Python/Git, and NGINX local test.
8. Record files/configuration that did not restore.

Never store the archive in Git. It may contain SSH host keys, user data, and credentials.

## 7. PRoot versus KVM/QEMU

| Capability | Android PRoot userspace | KVM/QEMU VM on CachyOS |
|---|---|---|
| Execution model | Userspace filesystem/process emulation and identity handling | Full-system hardware virtualization |
| Separate guest kernel | No; uses Android host kernel | Yes, conventional guest kernel |
| Root semantics | PRoot-simulated root; not Android host root | Guest root within the VM |
| Virtual hardware | No complete virtual hardware platform | Virtual CPU, RAM, disks and devices |
| Kernel modules | Cannot load a separate guest kernel module stack | Guest kernel modules where supported |
| PCI/GPU passthrough | Not equivalent | Possible with compatible host hardware/configuration |
| Networking | Android app/PRoot constraints; must test | libvirt NAT/bridge or configured virtual networking |
| Background lifecycle | Subject to Android app/battery/process management | Managed by host hypervisor and guest services |
| Best use in this project | Portable Linux CLI and lightweight service exercises | Ubuntu Server and Minecraft infrastructure |

The comparison is architectural. Add observed results from this Pixel device only after testing; do not claim PRoot provides VM-grade isolation or a separate kernel.

## 8. Evidence checklist

- [ ] Complete Linux Installer source/version recorded.
- [ ] Ubuntu or Debian userspace installed and booted.
- [ ] OS, package manager, architecture and storage inventory recorded.
- [ ] Bash script executed successfully.
- [ ] Python script executed successfully.
- [ ] Git init/add/commit/status completed.
- [ ] SSH server feasibility tested inside PRoot.
- [ ] SSH connection attempted from CachyOS over trusted LAN.
- [ ] NGINX loopback test passed and listener stopped.
- [ ] App-supported backup/export completed.
- [ ] Checksum/integrity verified.
- [ ] Restore into a separate environment tested.
- [ ] PRoot/KVM comparison updated with measured limitations.
- [ ] No secrets or environment archives committed.

**Status rule:** Phase F remains Planned until evidence is collected for each individual acceptance item.
