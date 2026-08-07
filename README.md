# nordvpn-wg — NordVPN WireGuard Manager for Asuswrt-Merlin

Early v0.1.0 prototype combining the rich selection/config-generation ideas of NordConverter with direct Asuswrt-Merlin WireGuard client management.

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
./install.sh
printf '%s\n' 'YOUR_NORD_ACCESS_TOKEN' > /opt/etc/nordvpn-wg/token
chmod 600 /opt/etc/nordvpn-wg/token
```

Review `/opt/etc/nordvpn-wg.conf` before first use.

## First commands

```sh
nordvpn-wg countries
nordvpn-wg servers --country US --limit 10
nordvpn-wg config --country US --city Dallas
nordvpn-wg merlin list
nordvpn-wg merlin show wgc3
nordvpn-wg merlin create wgc3 --country US --city Dallas --dry-run
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
- Interactive menu from NordConverter is not ported yet.
- Live Merlin behavior must be tested on target firmware before calling this production-ready.

## Attribution

Design/code was informed by the user-provided NordConverter project and `caleb9/asuswrt-merlin-nordvpn-wg-updater`. The latter in turn credits `sfiorini/NordVPN-Wireguard`. This project is a new implementation rather than a line-for-line merge.
