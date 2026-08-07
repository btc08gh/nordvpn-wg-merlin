# nordvpn-wg — NordVPN WireGuard Manager for Asuswrt-Merlin

Router-native NordVPN WireGuard configuration and lifecycle management for Asuswrt-Merlin.

The tool runs under Merlin's stock `/bin/sh`. Entware is required for `curl` and `jq`.

## Requirements

- Asuswrt-Merlin
- Entware
- `/opt/bin/curl`
- `/opt/bin/jq`
- NordVPN access token created under Nord Account manual/advanced configuration

## Install / update

This project intentionally uses a Git workflow rather than an Entware package.

```sh
git clone https://github.com/btc08gh/nordvpn-wg-merlin.git
cd nordvpn-wg-merlin
chmod 755 install.sh
./install.sh
```

For later versions:

```sh
git pull
./install.sh
```

Store the Nord access token as one line in `/opt/etc/nordvpn-wg/token` and protect it:

```sh
chmod 600 /opt/etc/nordvpn-wg/token
```

## Core commands

```sh
nordvpn-wg --version
nordvpn-wg auth-test
nordvpn-wg countries
nordvpn-wg servers --country US --limit 10
```

## Merlin inspection

```sh
nordvpn-wg merlin list
nordvpn-wg merlin show wgc2
nordvpn-wg merlin show wgc2 --show-secrets
```

Private keys and PSKs are redacted by default.

## Safe create workflow

Preview what would be written:

```sh
nordvpn-wg merlin create wgc2 --country US --city Dallas --dry-run --yes
```

Compare current values to a proposed full configuration:

```sh
nordvpn-wg merlin diff wgc2 --country US --city Dallas
```

Write and commit NVRAM without activating the tunnel:

```sh
nordvpn-wg merlin create wgc2 --country US --city Dallas
```

Inspect it:

```sh
nordvpn-wg merlin show wgc2
```

Activate only when ready:

```sh
nordvpn-wg merlin apply wgc2
```

To deliberately write and apply in one command:

```sh
nordvpn-wg merlin create wgc2 --country US --city Dallas --apply
```

**Applying is never the default.** Older `AUTO_APPLY` settings in existing config files are ignored by version 0.2 and later.

## Update an existing Nord slot

`update` changes only server-derived fields: description, endpoint, resolved endpoint, port and peer public key. It preserves the private key, DNS, NAT, firewall, MTU, allowed IPs and other Merlin policy settings.

```sh
nordvpn-wg merlin update wgc2 --country US --city Dallas
nordvpn-wg merlin apply wgc2
```

Or explicitly in one step:

```sh
nordvpn-wg merlin update wgc2 --country US --city Dallas --apply
```

## Lifecycle commands

```sh
nordvpn-wg merlin apply wgc2
nordvpn-wg merlin restart wgc2
nordvpn-wg merlin start wgc2
nordvpn-wg merlin stop wgc2
nordvpn-wg merlin enable wgc2
nordvpn-wg merlin disable wgc2
```

`enable` and `disable` modify/commit NVRAM but do not start/stop the client unless `--apply` is supplied.

## Backup and restore

Create an explicit backup:

```sh
nordvpn-wg merlin backup wgc2
```

Backups are stored under `/opt/var/lib/nordvpn-wg/backups`.

Restore the newest backup for a slot:

```sh
nordvpn-wg merlin restore wgc2
```

Or restore a particular file:

```sh
nordvpn-wg merlin restore wgc2 /opt/var/lib/nordvpn-wg/backups/wgc2-YYYYMMDD-HHMMSS.nvram
```

Restore does not activate the client unless `--apply` is supplied. A safety backup of the current slot is created before restoration.

## Persistence control

Writes commit NVRAM by default. To deliberately make a runtime-only NVRAM change:

```sh
nordvpn-wg merlin create wgc2 --country US --no-commit
```

## Merlin field handling

The tool manages the normal `wgcN_*` configuration fields used by Merlin. `wgcN_rip` is treated as runtime public-exit-IP state and is never written by create/update.

## Nord authentication

The service-credentials request uses an explicit HTTP Basic Authorization header built from `token:<ACCESS_TOKEN>`. This avoids a curl `-u` compatibility issue observed on Asuswrt-Merlin/Entware.

Nord tokens are validated locally as 64 hexadecimal characters. Token-file cleanup strips only CR/LF because some router `tr` implementations mishandle POSIX character classes in delete sets.

## Attribution

The project uses ideas and behavior from:

- `Deano86/NordConverter`
- `Caleb9/asuswrt-merlin-nordvpn-wg-updater`
- the latter credits `sfiorini/NordVPN-Wireguard`
- `ruudmens/LazyAdmin` provided a useful reference for Nord service-credential authentication

Applicable upstream licenses/notices must be preserved when code is copied or materially adapted. NordConverter currently serves as a behavioral/design reference unless its licensing permits direct reuse.

## Scope

WireGuard client management only. VPN Director/policy-routing management is intentionally out of scope for now.
