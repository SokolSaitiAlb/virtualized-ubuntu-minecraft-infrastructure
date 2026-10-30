# Ubuntu Server Administration Runbook

**Scope:** The Ubuntu Server guest running under KVM/QEMU. This is an evidence-led procedure: values marked `TBD` must come from the actual VM.

## 1. OS and package inventory

Run inside Ubuntu Server and retain the output privately until reviewed:

```bash
date --iso-8601=seconds
cat /etc/os-release
uname -a
hostnamectl
dpkg --print-architecture
apt list --installed 2>/dev/null
apt-mark showmanual
```

For a compact package inventory file:

```bash
mkdir -p "$HOME/server-inventory"
{
  date --iso-8601=seconds
  cat /etc/os-release
  uname -a
  dpkg --print-architecture
  apt-mark showmanual
} > "$HOME/server-inventory/ubuntu-inventory.txt"
```

Do not publish full package output without review: package lists can reveal host details and installed security tools. Record:

| Field | Observed value |
|---|---|
| Ubuntu release / VERSION_ID | TBD |
| Kernel | TBD |
| Architecture | TBD |
| Hostname (sanitize if public) | TBD |
| Last inventory timestamp | TBD |
| Manually installed packages relevant to server | TBD |
| Pending security updates | TBD |

Check update state without applying changes:

```bash
sudo apt update
apt list --upgradable
```

Apply updates in a maintenance window after backing up data and checking Paper/Minecraft/Java compatibility:

```bash
sudo apt upgrade
```

Do not use an unattended `full-upgrade` as an undocumented maintenance action on the game server.

## 2. SSH configuration and authentication audit

Capture current effective settings (not just file contents):

```bash
sudo sshd -T | grep -E '^(port|permitrootlogin|passwordauthentication|pubkeyauthentication|kbdinteractiveauthentication|authenticationmethods|allowusers|allowgroups|maxauthtries|x11forwarding)'
sudo systemctl status ssh --no-pager
sudo ss -lntp | grep -E 'sshd|:22'
```

Inspect configuration sources:

```bash
sudo grep -RniE '^(Include|Port|PermitRootLogin|PasswordAuthentication|PubkeyAuthentication|KbdInteractiveAuthentication|AuthenticationMethods|AllowUsers|AllowGroups|MaxAuthTries|X11Forwarding)' /etc/ssh/sshd_config /etc/ssh/sshd_config.d 2>/dev/null
```

Before changing SSH:
1. Keep the current SSH session open.
2. Confirm console access through virt-manager as a recovery path.
3. Back up the file being changed.
4. Validate syntax with `sudo sshd -t`.
5. Reload (not blindly restart) SSH and open a second session to test.
6. Only then close the original session.

Recommended target state, after confirming client key access:
- A named, non-root administrative account.
- Public-key authentication tested from CachyOS and any intended Termux client.
- `PermitRootLogin no`.
- Password authentication disabled only after key authentication is proven and recovery access exists.
- `AllowUsers` or `AllowGroups` restricts who may log in.
- Private keys remain on client devices and never enter the repository.

Example configuration fragment (review against the existing effective configuration before applying):

```text
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
MaxAuthTries 3
X11Forwarding no
AllowUsers <admin-user>
```

Do not paste this blindly: cloud-init or files under `sshd_config.d` may override values. Ubuntu's OpenSSH configuration uses first-value/Include ordering rules; verify the result with `sshd -T`.

## 3. Least-privilege review

Collect:

```bash
id
getent passwd
getent group sudo
getent group adm
sudo -l
ps -eo user,group,pid,comm --sort=user
sudo ss -tulpn
```

Review:
- Which accounts have interactive shells?
- Which accounts are in `sudo`, `adm`, `docker`, `lxd`, or other privileged groups?
- Does the Minecraft process run as a dedicated unprivileged service account rather than root?
- Does the server directory belong to that service account?
- Are SSH login users limited to the intended administrator(s)?
- Are RCON credentials, Playit credentials, and private keys readable only by the service account/administrator?
- Does any process listen on an unnecessary interface or port?

Target model:
- One named admin account with sudo for maintenance.
- Dedicated `minecraft` service account with no sudo and no interactive login where practical.
- Server files writable only by the service account and administrators.
- No shared account or routine root login.
- Secrets stored in root/service-account-readable files with restrictive permissions, not in Git or shell history.

Do not remove users or groups based only on a generic recommendation. First identify ownership, active sessions, service dependencies, and recovery access.

## 4. Evidence record

- Ubuntu release: TBD
- Kernel / architecture: TBD
- Installed/manual package inventory captured: [ ]
- SSH effective configuration captured: [ ]
- Authentication method verified: TBD
- Root login policy verified: TBD
- Allowed SSH users/groups: TBD
- Admin and service accounts reviewed: [ ]
- Minecraft process UID/GID verified: TBD
- Listening sockets reviewed: [ ]
- Least-privilege changes applied and retested: [ ]

No SSH or account changes are claimed by this document. Complete the evidence record from the running guest.
