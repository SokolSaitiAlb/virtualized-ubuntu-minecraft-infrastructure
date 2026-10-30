# Network Security Runbook — CachyOS Host, Ubuntu Guest, Playit

**Current known risk:** During troubleshooting, UFW was disabled on both CachyOS and Ubuntu Server. This document is a staged configuration and verification plan, not evidence that firewalls are currently enabled.

## 1. Map traffic before changing firewall policy

First collect the real topology.

On CachyOS:
```bash
ip -br address
ip route
sudo ufw status verbose
sudo nft list ruleset
virsh -c qemu:///system net-list --all
virsh -c qemu:///system domiflist '<vm-name>'
```

On Ubuntu:
```bash
ip -br address
ip route
sudo ufw status verbose
sudo ss -tulpn
```

Inspect Playit dashboard and local agent configuration without copying tokens or secrets into chat/repository. Record the exact tunnel protocol, public endpoint, local target, and agent status.

### Port and path inventory (fill from actual config)

| Purpose | Protocol/port | Listener / destination | Exposure |
|---|---|---|---|
| SSH administration | TCP 22 (unless configured otherwise) | Ubuntu VM | Trusted LAN/admin source only |
| Paper Java | Usually TCP 25565; verify server.properties | Paper listener | Only if Java tunnel/direct access is enabled |
| Geyser Bedrock | Historic port 19132; protocol must be verified | Geyser listener | Through matching Playit tunnel |
| Geyser NetherNet | TCP+UDP only if current Geyser config requires it | Geyser listener | Match tunnel protocol exactly |
| RCON | TCP 25575 if enabled | Paper RCON | Loopback/private management only; never public |
| Playit agent | Outbound connections | Ubuntu agent process | Outbound; do not expose agent credentials |

The table lists conventional defaults, not confirmed live listeners. Actual ports and protocols must come from `server.properties`, Geyser config, process sockets and Playit tunnel settings.

## 2. CachyOS host firewall review

Do not enable UFW or set a default-deny policy until the current rules, active SSH path, libvirt bridge/NAT, and any host-side port forwarding are understood. UFW and libvirt-managed nftables/iptables rules can interact and disrupt guest networking.

Read-only review:
```bash
sudo ufw status numbered
sudo ufw show raw
sudo nft list ruleset
sudo iptables -S
sudo iptables -t nat -S
ip -br link
ip route
virsh -c qemu:///system net-list --all
```

Host policy principles:
- Keep outbound traffic available for package updates, DNS, and the Playit agent unless a separately tested egress policy exists.
- Do not expose SSH on all interfaces if remote administration is not required.
- Do not add public Java/Bedrock inbound rules merely because the server uses Playit; Playit normally relies on the agent's outbound connection.
- Preserve libvirt bridge/NAT forwarding and DHCP/DNS paths.
- Apply rules in a maintenance window with local console access and a rollback plan.
- Verify the guest can still reach DNS, updates, Playit, and the intended local listener after each change.

Do not run a generic `ufw reset` or blindly enable UFW on the host.

## 3. Ubuntu guest firewall review and staged policy

Before any firewall changes, identify the actual admin source subnet and current SSH port. Keep the VM console open in virt-manager and an existing SSH session open.

Read current state:
```bash
sudo ufw status numbered
sudo ufw show raw
sudo ss -tulpn
ip route
```

Replace placeholders with verified values. Example only:

```bash
# Example — replace the subnet and port with observed values.
sudo ufw allow from <trusted-admin-subnet> to any port 22 proto tcp
sudo ufw allow 25565/tcp
sudo ufw allow 19132/udp
```

Only add Java/Bedrock rules for ports that actually receive direct inbound traffic. If those services are reachable exclusively through a local Playit agent, inbound rules may not be required for the public tunnel path; the local agent-to-service traffic still must work.

Do not enable the policy until the rules have been reviewed. Then:
1. Open a second SSH session and verify it works.
2. Confirm VM console access.
3. Run `sudo ufw enable`.
4. Immediately check `sudo ufw status verbose`.
5. Verify SSH from the trusted source.
6. Verify local Paper and Geyser listeners.
7. Verify the Playit agent remains online and can reach the target.
8. Test Java and Bedrock clients from the intended networks.
9. If any required path fails, use VM console to correct the specific rule; do not disable all filtering as the first response.

## 4. SSH restrictions

- Allow SSH only from the trusted management subnet or a dedicated VPN path.
- Do not forward SSH through the public Playit Minecraft hostname.
- Prefer SSH keys; disable password authentication only after key login is tested.
- Disable root SSH login after confirming a sudo-capable admin account.
- Keep private keys and known_hosts private; never commit them.
- If SSH uses a non-default port, document the actual port and update both sshd and firewall rules consistently.

## 5. Connectivity test matrix

Record timestamp, source network, destination, protocol, result, and relevant log excerpt.

| Test | Source | Target | Expected |
|---|---|---|---|
| SSH admin | CachyOS trusted LAN | Ubuntu VM TCP/<actual SSH port> | Key-authenticated login |
| Paper local | LAN Java client | Ubuntu VM TCP/<actual Paper port> | Login and world load |
| Paper remote | External Java client | Playit endpoint, if configured | Login and world load |
| Geyser local | LAN Bedrock client | Ubuntu VM <actual Geyser transport/port> | Login and world load |
| Geyser remote | External Bedrock client | Playit endpoint | Login and world load |
| Playit agent | Ubuntu VM | Playit service outbound | Agent online; tunnel target reachable |
| RCON | Local management only | 127.0.0.1:<actual RCON port> | Local-only access if enabled |

Use `nc -vz <host> <tcp-port>` for TCP reachability. UDP requires an application-level client test; a successful generic UDP probe is not proof that Geyser works.

After firewall changes, check:
```bash
sudo ufw status verbose
sudo ss -tulpn
sudo journalctl -u ssh -n 100 --no-pager
```

## 6. Evidence and rollback

- Host firewall backend/current policy: TBD
- Guest UFW status/rules: TBD
- Trusted SSH source subnet: TBD
- SSH authentication method: TBD
- Paper listener address/port: TBD
- Geyser transport/address/port: TBD
- Playit public protocol and local target: TBD
- RCON status/bind address: TBD
- Java local/remote tests: TBD
- Bedrock local/remote tests: TBD
- Rollback method and console path: TBD

No firewall rule is applied by this document. Do not mark network hardening complete until both host and guest policies are enabled and the connectivity matrix passes.
