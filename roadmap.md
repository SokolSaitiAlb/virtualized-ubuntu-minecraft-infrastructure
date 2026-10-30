# Roadmap — Virtualized Ubuntu Minecraft Infrastructure

This roadmap covers the original CachyOS-hosted Minecraft infrastructure lab and a separate Android Linux lab. The Android lab does not change or become part of the Minecraft server architecture.

## Primary architecture — unchanged

```text
CachyOS Host
└── KVM / QEMU + libvirt
    └── Ubuntu Server VM
        ├── PaperMC
        ├── Geyser-Spigot
        └── Playit.gg agent and tunnels
```

## Phase 1 — Host identification, CachyOS & KVM/QEMU

**Status: Implemented for the original CachyOS setup; automatic OS detection is a future improvement.**

### Step 1. Identify the host operating system

On the physical host, open a terminal and run:

```bash
cat /etc/os-release
uname -m
```

Check CPU virtualization support:

```bash
lscpu | grep -E 'Virtualization|Architecture'
grep -E -c '(vmx|svm)' /proc/cpuinfo
```

- Confirm the distribution and architecture before installing virtualization packages.
- Confirm Intel VT-x or AMD-V is enabled in BIOS/UEFI.
- If the virtualization flag count is zero, check BIOS/UEFI settings and CPU support.
- Do not assume that every Linux distribution uses the same package manager or service names.

### Important installer limitation

The current [install-kvm-cachyos.sh](https://github.com/SokolSaitiAlb/install-kvm-cachyos.sh) script is designed for CachyOS and Arch-based systems. The inspected script runs `pacman`, installs QEMU/KVM-related packages, enables `libvirtd`, and adds the current user to the `libvirt` group. It **does not currently auto-detect the host distribution** and it is not a universal Linux installer.

Automatic distribution detection and clear handling for unsupported distributions are future improvements. Until then, run this installer only on CachyOS/compatible Arch-based hosts.

### Step 2. Download and review the KVM installer

Clone the repository:

```bash
git clone https://github.com/SokolSaitiAlb/install-kvm-cachyos.sh.git
cd install-kvm-cachyos.sh
```

Review the script before executing it:

```bash
less install-kvm-cachyos.sh
```

Run it on a supported CachyOS/Arch-based host:

```bash
chmod +x install-kvm-cachyos.sh
./install-kvm-cachyos.sh
```

The current script installs these components through the Arch package manager:

- `qemu-full`
- `virt-manager`
- `virt-viewer`
- `dnsmasq`
- `vde2`
- `bridge-utils`
- `openbsd-netcat`
- `libvirt`
- `iptables-nft`

It enables and starts `libvirtd`, then adds the current user to the `libvirt` group. Log out and back in (or reboot) for group membership changes to take effect.

Verify the service and virtualization connection:

```bash
systemctl status libvirtd
virsh -c qemu:///system list --all
```

Launch the graphical VM manager:

```bash
virt-manager
```

**Do not run the CachyOS installer on Ubuntu/Debian/Fedora.** Those distributions require their own package names and setup procedures.

## Phase 2 — Download and install Ubuntu Server in a VM

**Status: Implemented for the original project; this section documents the repeatable setup procedure.**

### Step 1. Download the official Ubuntu Server ISO

1. Open the [official Ubuntu Server download page](https://ubuntu.com/download/server).
2. Select the current Ubuntu Server LTS release suitable for the project.
3. Download the ISO image.
4. Keep the ISO in a known location, such as `~/Downloads`.
5. Optionally verify the ISO checksum using the checksum published by Ubuntu.

Do not download installation images from unofficial mirrors when the official image is available.

### Step 2. Create the virtual machine

Open Virtual Machine Manager (`virt-manager`) on CachyOS.

1. Select **Create a new virtual machine**.
2. Choose **Local install media (ISO image or CDROM)**.
3. Browse to the downloaded Ubuntu Server ISO.
4. Select the Ubuntu operating system profile if it is not detected automatically.
5. Allocate CPU and RAM based on the physical host's capacity. Leave sufficient resources for CachyOS and other running applications.
6. Create a virtual disk on the host NVMe storage with enough capacity for Ubuntu, server files, logs, and world data.
7. Use the default virtual network (typically NAT) for the initial installation unless a bridged network is specifically required.
8. Review the VM summary and finish creation.
9. Start the VM and open its console.

Exact CPU, RAM, disk, and passthrough values are hardware-specific. Record the actual values used rather than copying arbitrary example values.

### Step 3. Install Ubuntu Server

In the Ubuntu Server installer:

1. Select the language and keyboard layout.
2. Configure the network. DHCP is suitable for an initial setup; a DHCP reservation on the router can make the VM easier to reach consistently.
3. Select the default Ubuntu Server installation unless a documented requirement calls for a different profile.
4. Configure the storage layout for the VM's virtual disk.
5. Set the server hostname, create a non-root administrator account, and use a strong unique password.
6. Enable **Install OpenSSH server** if the installer offers that option.
7. Review the installation summary and install.
8. Reboot when prompted and detach/eject the ISO if the VM boots back into the installer.

### Step 4. Update the guest and verify its network

Log in through the VM console:

```bash
sudo apt update
sudo apt full-upgrade -y
sudo reboot
```

After reboot, check the guest identity, address, and resources:

```bash
hostnamectl
ip -br address
free -h
df -h
```

Record the VM's LAN/NAT address. For example, if `ip -br address` shows `192.168.122.50`, use that actual address in the SSH command; do not copy the example address blindly.

### Step 5. Configure and test SSH

If OpenSSH Server was not installed during setup:

```bash
sudo apt install -y openssh-server
sudo systemctl enable --now ssh
sudo systemctl status ssh
```

From the CachyOS host, connect using the Ubuntu account and the VM's actual IP address:

```bash
ssh <ubuntu-username>@<ubuntu-vm-ip>
```

Accept the host key only after confirming that the address belongs to the VM. Use SSH keys for regular administration and keep private keys out of Git.

## Phase 3 — Deploy PaperMC and Geyser-Spigot

**Status: Implemented and exercised in the original project.**

### Step 1. Prepare Ubuntu Server

Connect to the Ubuntu VM over SSH, then create a dedicated server directory:

```bash
mkdir -p ~/minecraft/plugins
cd ~/minecraft
```

Install a Java runtime compatible with the PaperMC version you intend to run. Java requirements change with Minecraft/Paper releases. Check the [official PaperMC requirements](https://docs.papermc.io/paper/getting-started/) before installing Java.

For example, the current Paper documentation lists Java 25 for Paper 26.1+ and Java 21 for Paper 1.20–1.21.11. On Ubuntu, check which package is available for your release:

```bash
apt-cache search openjdk
```

Install the matching headless runtime (use the package version required by the Paper release):

```bash
sudo apt install -y openjdk-25-jre-headless
java -version
```

If the selected Paper version requires a different Java release, install that supported runtime instead. Do not assume the example package exists on every Ubuntu release.

### Step 2. Download PaperMC

1. Open the official [PaperMC downloads page](https://papermc.io/software/paper/).
2. Select the Minecraft version you intend to host.
3. Download the recommended Paper build for that version.
4. Transfer the JAR to `~/minecraft` on the Ubuntu VM (or download it directly in the VM using the official download link).
5. Rename the downloaded file to `paper.jar` for the commands below.

Check that the file exists:

```bash
ls -lh ~/minecraft/paper.jar
```

### Step 3. First startup and EULA

From the server directory:

```bash
cd ~/minecraft
java -Xms2G -Xmx4G -jar paper.jar --nogui
```

Adjust the memory values to the VM's actual RAM allocation. Do not allocate all guest memory to Java; leave room for Ubuntu and other processes.

The first run will create the server files and stop because the Minecraft EULA has not yet been accepted. Read the [Minecraft EULA](https://www.minecraft.net/en-us/eula). If you agree to it, edit `eula.txt` and set:

```text
eula=true
```

Start Paper again:

```bash
java -Xms2G -Xmx4G -jar paper.jar --nogui
```

Wait for the server to finish startup and report that it is ready. Stop it cleanly with `stop` in the server console before making plugin or configuration changes.

### Step 4. Install Geyser-Spigot

Geyser allows compatible Bedrock clients to connect to a Java server. It is installed as a Paper plugin.

Download the latest Spigot/Paper plugin build from the official Geyser download endpoint:

```bash
cd ~/minecraft
wget -O plugins/Geyser-Spigot.jar 'https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot'
```

Start Paper again so Geyser can generate its configuration:

```bash
java -Xms2G -Xmx4G -jar paper.jar --nogui
```

Stop the server cleanly, then inspect:

```bash
nano ~/minecraft/plugins/Geyser-Spigot/config.yml
```

Review the `bedrock` listener address, port, and transport settings. The common default port is `19132`, but use the settings required by the installed Geyser release and the selected Playit tunnel.

**Version and protocol warning:** Geyser's transport behavior and port requirements can change. Current Geyser documentation describes newer NetherNet and RakNet options; some configurations require both TCP and UDP, while older RakNet configurations use UDP. Follow the current [Geyser setup documentation](https://geysermc.org/wiki/geyser/setup/) and match the Playit tunnel protocol to the active Geyser configuration. Do not assume that every Geyser version uses UDP only.

If the Java server version is outside Geyser's currently supported range, follow Geyser's compatibility guidance and install ViaVersion only if the documentation says it is required.

## Phase 4 — Playit.gg account, Linux agent, tunnels, and connectivity

**Status: Implemented for the original project; re-check account and protocol settings when recreating tunnels.**

Playit provides a tunnel so players can reach a locally hosted server without configuring traditional router port forwarding. The Playit agent must run on the machine that can reach the local Minecraft service — in this architecture, the Ubuntu Server VM.

### Step 1. Create a Playit account

1. Open [https://playit.gg/](https://playit.gg/).
2. Select the sign-up option and create an account.
3. Verify the account if requested.
4. Sign in to the Playit dashboard.
5. Keep account credentials private. Never commit them to this repository.

### Step 2. Install the Linux agent on Ubuntu Server

Use the official [Playit Linux installation guide](https://playit.gg/support/run-on-linux/). For Ubuntu/Debian, the current documented APT installation commands are:

```bash
curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list
sudo apt update
sudo apt install playit
```

Claim the agent for your account:

```bash
playit setup
```

Follow the terminal instructions and open the displayed claim link/code in a browser where you are signed in to your Playit account. Confirm the agent appears online in the dashboard.

For an agent installed through the official APT package, the Playit Linux guide documents systemd management:

```bash
sudo systemctl enable --now playit
sudo systemctl status playit
```

If the service does not exist on the installed package/version, follow the current Playit documentation for that installation method. Do not create an unverified service unit manually.

### Step 3. Create the Minecraft Java tunnel

In the Playit dashboard:

1. Open the tunnel creation page.
2. Choose the Minecraft Java preset if it is available.
3. Select the agent running on the Ubuntu Server VM.
4. Set the local/origin destination to the Paper server listener, normally `127.0.0.1:25565`.
5. Create the tunnel and record the public hostname and port shown by Playit.
6. Ensure Paper's `server.properties` uses the expected local server port (normally `25565`).

The public port assigned by Playit may differ from the local origin port. Give players the exact public hostname and port shown in the dashboard.

### Step 4. Create the Geyser / Bedrock tunnel

Follow the current [Playit Geyser on Paper guide](https://playit.gg/support/use-geyser-on-paper/):

1. Create a second tunnel for Minecraft Bedrock/Geyser if the account and current Playit protocol options support the transport required by your Geyser version.
2. Select the same Ubuntu Server agent.
3. Set the tunnel's local origin to the Geyser listener address and port configured in `plugins/Geyser-Spigot/config.yml`.
4. Match the tunnel's protocol to the Geyser transport. Newer Geyser transport options may need TCP and UDP; older RakNet setups may use UDP.
5. If Playit assigns a public port different from the local Geyser port, use the public hostname and port displayed by Playit when connecting.
6. If the Playit setup guide instructs you to change Geyser's listener port to a specific assigned port, update both sides consistently and restart Paper.

**Plan/protocol availability:** Playit's available tunnel types and protocol support can depend on the current product offering and account plan. Check the dashboard and the current Playit/Geyser documentation rather than assuming every Bedrock transport is available on every plan.

### Step 5. Verify connectivity

On the Ubuntu VM, verify that Paper and Geyser are listening on the expected local ports:

```bash
ss -lntup
```

Then test from a device outside the local network:

- **Java Edition:** enter the Playit Java hostname and public port in the multiplayer server address.
- **Bedrock Edition:** enter the Playit Bedrock hostname and public port in the server address fields.
- Confirm the agent remains online and the server process is running.

For local testing, connect using the VM's LAN address and the local port. Do not use a public Playit address to diagnose a local listener failure.

### Step 6. Keep the agent running

Check the official [Playit 24/7 Linux guide](https://playit.gg/support/host-247-with-playit/). For supported APT installs, use the systemd service shown above. Verify after a VM reboot that the agent returns online and that the tunnels point to the correct local service ports.

### Step 7. Firewall and network safety

- Do not disable the host or guest firewall as a permanent fix.
- Before enabling UFW, allow the SSH path you actually use, otherwise you may lock yourself out.
- Apply only the inbound rules required by the selected local access design.
- Playit tunnels use an outbound agent connection; do not automatically expose Minecraft or SSH ports on the router.
- Never expose SSH, RCON, or the Playit agent's private credentials to the public internet.
- Verify local service reachability from the agent before debugging the external tunnel.

The original project used UFW during experimentation but disabled firewalls on the host and guest while troubleshooting. Firewall hardening is therefore still an open task.

## Phase 5 — Monitoring, backups, reliability & documentation

**Status: Partially implemented**

- [x] Inspect processes and resource usage with htop/btop.
- [x] Test the server with local and remote players.
- [ ] Record CPU, memory, storage, and network observations under idle and player load.
- [ ] Implement repeatable backups of the Minecraft world and configuration.
- [ ] Restore a backup into a test location and verify that it is usable.
- [ ] Document Paper and Geyser update/rollback steps.
- [ ] Document startup, shutdown, logs, and common troubleshooting procedures.
- [ ] Re-enable and verify host and guest firewall policies.
- [ ] Add sanitized VM and network diagrams.
- [ ] Record exact VM resources, OS versions, Java version, Paper build, and Geyser build.

A backup is not considered tested until a restore has succeeded.

## Phase 6 — Android Linux Administration & Portable Infrastructure Lab

**Status: Planned — not yet verified**

**Platform:** Pixel 8a · Android 17  
**Installer:** Complete Linux Installer  
**Runtime:** PRoot userspace  
**Distribution target:** Ubuntu or Debian

This is an independent second laboratory. It is not part of the Minecraft server architecture.

### Objectives

1. Install and initialize Ubuntu or Debian in Complete Linux Installer.
2. Validate shell access and package management.
3. Test Bash scripts and Python execution.
4. Install/use Git and clone a test repository.
5. Configure OpenSSH in PRoot and investigate Android network reachability.
6. Test SSH from CachyOS to the Pixel environment, where Android networking and app lifecycle constraints permit it.
7. Run NGINX locally and verify its HTTP response.
8. Back up the PRoot environment.
9. Restore the backup and verify files and packages.
10. Document PRoot limitations compared with KVM/QEMU.

### Acceptance criteria

- [ ] Ubuntu or Debian installed and version recorded.
- [ ] Bash test script succeeds.
- [ ] Python test script succeeds.
- [ ] Git clone/status workflow succeeds.
- [ ] SSH from CachyOS succeeds, or a reproducible platform limitation is documented.
- [ ] NGINX serves a local test page and stops cleanly.
- [ ] Backup archive is created and integrity checked.
- [ ] Restore test succeeds in a clean/recreated PRoot environment.
- [ ] PRoot vs KVM/QEMU comparison is documented.
- [ ] Sanitized evidence is committed.

PRoot provides a Linux userspace environment, not a separate Linux kernel or KVM/QEMU virtual machine. Do not claim equivalent isolation, kernel control, virtual hardware, or passthrough.

## Suggested completion order

1. Review and repeat the primary host/VM/server deployment guide where needed.
2. Complete Phase 5 security and backup work for the Minecraft lab.
3. Start Phase 6 as an isolated Android experiment.
4. Record test evidence and limitations as each Android task is completed.
5. Update `todo.md` only after a task has actually passed its acceptance test.
