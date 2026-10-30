# Minecraft Operations Runbook — PaperMC and Geyser

**Scope:** PaperMC Java server with Geyser-Spigot on Ubuntu Server. The repository confirms that PaperMC and Geyser were deployed with Bash workflows and tested locally/remotely. Exact server paths, versions, process manager, and unit names are not yet captured. This runbook uses explicit placeholders until inspected.

## 1. Capture exact versions

Run from the actual Paper server directory:

```bash
pwd
java -version
java -XshowSettings:properties -version 2>&1 | grep -E 'java.version|java.vendor|java.home'
```

If the server is running, use its console or logs to record the Paper build and Minecraft version. Also record plugin versions from the server startup log and plugin metadata. Do not infer versions from the current latest downloads.

Record:

| Component | Exact observed version/build |
|---|---|
| Ubuntu Server | TBD |
| Java runtime/vendor | TBD |
| Minecraft server protocol/game version | TBD |
| Paper build | TBD |
| Geyser-Spigot build | TBD |
| ViaVersion (if installed) | TBD / not confirmed |
| Other plugins | TBD |

For Paper, verify the Java requirement against the official Paper documentation for the exact Minecraft/Paper version before updating Java. Do not upgrade Java independently of the target server version.

## 2. Plugin inventory and safe update procedure

Record plugin inventory from the live server directory:

```bash
find plugins -maxdepth 2 -type f -printf '%P\n' | sort
```

For each plugin record name, version, source URL, checksum, compatibility range, and date installed. Do not assume every JAR is official or compatible.

Update procedure:
1. Announce maintenance and stop player connections.
2. Create and verify a pre-update backup using the backup runbook.
3. Check the plugin's official release notes and compatibility with the exact Paper/Minecraft version.
4. Download from the plugin's official project page/API only. Do not use random JAR mirrors.
5. Verify a published checksum/signature when the publisher provides one.
6. Stop Paper gracefully using the confirmed service manager/console method.
7. Preserve the previous JAR outside the active `plugins/` directory, with version and checksum recorded.
8. Install the new JAR and set ownership/permissions consistently.
9. Start the server and inspect startup logs for dependency errors, unsupported APIs, migration warnings, and failed plugin loads.
10. Test login, world loading, permissions, and Geyser/Bedrock behavior.
11. If validation fails, stop the server, restore the previous JAR and matching configuration/data backup, then start and verify again.

Never replace plugin JARs while Paper is running unless the plugin explicitly supports hot reload. Avoid `/reload`; a full graceful restart is safer for plugin lifecycle consistency.

## 3. Server lifecycle and logs

The current repository does not confirm a systemd unit, tmux/screen session, server directory, or startup command. Discover the actual process first:

```bash
pgrep -a -f 'paper|minecraft|java'
ps -eo user,pid,ppid,lstart,args | grep -E '[j]ava|[p]aper'
sudo systemctl list-units --type=service --all | grep -iE 'minecraft|paper|geyser'
```

Find the real working directory from the process command line and inspect its parent process. Do not assume the current directory is the server root.

Typical Paper log locations, if the standard directory layout is used:
- `<server-dir>/logs/latest.log`
- `<server-dir>/logs/YYYY-MM-DD-*.log`
- `<server-dir>/crash-reports/`

Read recent logs:

```bash
tail -n 200 '<server-dir>/logs/latest.log'
grep -Ei 'error|warn|exception|failed|geyser' '<server-dir>/logs/latest.log' | tail -n 100
```

If a confirmed systemd service exists, use its exact name:

```bash
sudo systemctl status <confirmed-unit-name> --no-pager
sudo journalctl -u <confirmed-unit-name> -n 200 --no-pager
```

Lifecycle actions must use the actual discovered process manager. Preferred stop is the Paper console `stop` command or a confirmed systemd unit's graceful `systemctl stop`. Do not use `kill -9` as normal shutdown.

## 4. Geyser and transport verification

Inspect the actual Geyser configuration (commonly `plugins/Geyser-Spigot/config.yml`) and startup log. Record:
- Bedrock listener address and port.
- Configured Bedrock transport (RakNet/UDP or NetherNet/TCP+UDP, depending on the installed Geyser build/configuration).
- Remote/Java server target.
- Authentication mode.
- Whether ViaVersion or Floodgate is installed and its exact version/configuration.

The historic project record identifies Bedrock port 19132, but does not prove the current transport or listener binding. Match the Playit tunnel protocol and local destination to the current Geyser configuration. Do not assume UDP only or TCP+UDP without inspecting it.

## 5. Backup automation prerequisites

A repeatable full server backup requires:
- A confirmed server root directory.
- A confirmed graceful lifecycle mechanism.
- A backup destination on storage independent of the live server directory.
- Enough free space for a full copy plus retention.
- Restricted permissions because a full server backup can contain credentials and private configuration.
- A successful restore test in an isolated directory.

The repository includes `scripts/backup-minecraft.sh` as a fail-closed template. It requires a confirmed systemd unit and explicit source/destination paths. It refuses to run if the unit is not active, stops it gracefully, archives the server directory, creates a SHA-256 checksum, and attempts to restart the unit. It does not install or configure a systemd service. Configure it only after confirming the actual service unit and paths.

## 6. Backup and restore acceptance

A backup is accepted only if:
- Archive creation completes.
- SHA-256 verification succeeds.
- Archive listing succeeds.
- Ownership/permissions and secret handling are reviewed.
- The archive is copied to independent storage.
- Restore is extracted to a separate test directory, never over the live server.
- The restored world/config/plugins are inspected and a test instance can start without binding production ports or connecting to the production tunnel.

Restore test record:
- Backup archive/date: TBD
- SHA-256: TBD
- Test extraction path: TBD
- Archive integrity: [ ]
- World directories present: [ ]
- Plugin/config files present: [ ]
- Isolated startup result: TBD
- Test client connection (isolated): TBD
- Differences/errors: TBD

Do not mark backup or restore complete until this test is performed.
