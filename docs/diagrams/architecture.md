# Architecture — Primary KVM lab and separate Android PRoot lab

```mermaid
flowchart TB
  subgraph HOST["Primary lab — physical host"]
    C["CachyOS workstation"]
    K["KVM / QEMU + libvirt"]
    C --> K
    K --> U["Ubuntu Server VM"]
    U --> P["PaperMC — Java Edition"]
    U --> G["Geyser-Spigot — Bedrock bridge"]
    U --> A["Playit.gg agent"]
    P --> G
    A --> T["Playit public tunnel endpoints"]
    T --> J["Remote Java clients"]
    T --> B["Remote Bedrock clients"]
    L["OpenSSH administration"] --> U
  end
  subgraph PHONE["Secondary lab — independent"]
    D["Pixel 8a / Android 17"]
    I["Complete Linux Installer"]
    R["PRoot Ubuntu or Debian userspace"]
    D --> I --> R
    R --> S["Bash · Python · Git"]
    R --> N["NGINX loopback test"]
    R --> SSH["OpenSSH experiment"]
  end
  C -. "LAN SSH test, only if supported" .-> SSH
```

The Android PRoot environment is independent of the Minecraft VM and does not boot a separate guest kernel. Diagram connections represent intended architecture; exact interfaces, addresses, port mappings and transport must be filled from live configuration.
