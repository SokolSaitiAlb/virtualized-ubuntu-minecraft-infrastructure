# Network flow — evidence template

```mermaid
flowchart LR
  Admin["CachyOS administrator"] -->|"SSH TCP / verified port"| VM["Ubuntu Server VM"]
  VM --> Paper["PaperMC listener / verified Java port"]
  VM --> Geyser["Geyser listener / verified transport + port"]
  VM --> Agent["Playit agent — outbound"]
  Agent --> Edge["Playit public endpoint"]
  Java["External Java client"] -->|"Public Java tunnel"| Edge
  Bedrock["External Bedrock client"] -->|"Public Bedrock tunnel"| Edge
  Edge -->|"Tunnel origin: protocol + address + port"| Paper
  Edge -->|"Tunnel origin: protocol + address + port"| Geyser
```

## Fill from actual state

| Flow | Protocol | Public endpoint | Local origin | Verified |
|---|---|---|---|---|
| Admin SSH | TBD | Not intended to be public | VM SSH listener | No |
| Java | TBD | Playit dashboard value | Paper listener | No |
| Bedrock | RakNet/UDP or NetherNet TCP+UDP per live config | Playit dashboard value | Geyser listener | No |
| RCON | TCP if enabled; local only | None | Loopback/private | No |

Do not use the diagram as a firewall specification until each value has been inspected and tested.
