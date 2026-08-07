#!/bin/sh
set -eu

PREFIX=/opt
BIN="$PREFIX/sbin/nordvpn-wg"
CONF="$PREFIX/etc/nordvpn-wg.conf"
TOKEN_DIR="$PREFIX/etc/nordvpn-wg"
STATE_DIR="$PREFIX/var/lib/nordvpn-wg"

[ -d /opt ] || { echo "Entware (/opt) is required." >&2; exit 1; }
for cmd in bash curl jq; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Missing $cmd. Install prerequisites with: opkg install bash curl jq" >&2
    exit 1
  }
done

mkdir -p "$PREFIX/sbin" "$TOKEN_DIR" "$STATE_DIR/backups" "$STATE_DIR/profiles"
cp ./nordvpn-wg "$BIN"
chmod 755 "$BIN"
if [ ! -f "$CONF" ]; then
  cp ./nordvpn-wg.conf.example "$CONF"
  chmod 600 "$CONF"
fi
printf '%s\n' "Installed $BIN" "Config: $CONF" "Token file: $TOKEN_DIR/token (chmod 600)"
