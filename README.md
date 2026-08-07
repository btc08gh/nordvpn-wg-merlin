# nordvpn-wg — NordVPN WireGuard Manager for Asuswrt-Merlin

Early v0.1.0 prototype combining the server-selection/config-generation ideas of NordConverter with direct Asuswrt-Merlin WireGuard client management.

## Scope

WireGuard configuration only. VPN Director and unrelated routing-policy management are intentionally out of scope.

## Requirements

- Asuswrt-Merlin for `merlin` commands
- Entware **required**
- Entware `bash`, `curl`, and `jq` **required**
- A Nord Account access token created under NordVPN manual configuration

Install prerequisites:

```sh
opkg install bash curl jq
```

## Install

```sh
git clone https://github.com/btc08gh/nordvpn-wg-merlin.git
cd nordvpn-wg-merlin
sh install.sh
printf '%s\n' 'YOUR_NORD_ACCESS_TOKEN' > /opt/etc/nordvpn-wg/token
chmod 600 /opt/etc/nordvpn-wg/token
```

Review `/opt/etc/nordvpn-wg.conf` before first use.

## First safe tests

```sh
nordvpn-wg --version
nordvpn-wg countries
nordvpn-wg servers --country US --limit 10
nordvpn-wg merlin list
nordvpn-wg merlin show wgc3
```

Then exercise the write path without changing NVRAM:

```sh
nordvpn-wg merlin create wgc3 --country US --city "St Louis" --dry-run
```

Do **not** run `merlin create` without `--dry-run` until the proposed values have been compared with a known-good Merlin client on the target router.

Other implemented commands include:

```sh
nordvpn-wg config --country US --city Dallas
nordvpn-wg merlin create wgc3 --country US --city Dallas
nordvpn-wg merlin update wgc3 --country US
```

`merlin create` writes a complete `wgcN_*` configuration using defaults plus CLI overrides. `merlin update` deliberately changes only server-derived fields (`desc`, endpoint, resolved endpoint, port, server public key), preserving the slot's private key, DNS, NAT, firewall, MTU, allowed IPs and other Merlin policy settings.

`wgcN_rip` is **never written**. Merlin uses it as runtime public-exit-IP state; the tool only reads it for status/verification.

## Nord API usage

The account NordLynx private key is retrieved directly on the router with the access token through Nord's service-credentials endpoint. Server data comes from Nord's recommendations/catalogue API, so the official NordVPN Linux client is not required on the router.

## Safety

Before NVRAM writes, the current slot is backed up under `/opt/var/lib/nordvpn-wg/backups`. Use `--dry-run` to inspect generated NVRAM changes without touching the router. Changes are persisted with `nvram commit` and applied with Merlin's `service "restart_wgc N"` action.

## Current v0.1 limitations

- City filtering currently filters the first 100 country recommendations; a later revision will use a cached full catalogue for exhaustive city/group searches.
- Backup restore command is not implemented yet.
- Scheduled refresh is not implemented yet.
- Interactive menu/creature features inspired by NordConverter are not ported yet.
- Live Merlin behavior must be tested on target firmware before calling this production-ready.

## Upstream projects / attribution

This project intentionally draws on behavior, ideas, and documented workflows from:

- **Deano86/NordConverter** — https://github.com/Deano86/NordConverter
- **caleb9/asuswrt-merlin-nordvpn-wg-updater** — https://github.com/caleb9/asuswrt-merlin-nordvpn-wg-updater
- The Merlin updater project also references **sfiorini/NordVPN-Wireguard**.

NordConverter's current NOTICE states that no open-source license is granted unless a separate LICENSE is added. Accordingly, this project treats NordConverter as a behavioral/design reference and does not copy its source verbatim without permission or an applicable license. See `NOTICE.md` for details.
