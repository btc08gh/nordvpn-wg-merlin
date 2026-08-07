#!/bin/sh
set -eu

PREFIX=/opt
BIN="$PREFIX/sbin/nordvpn-wg"
CONF="$PREFIX/etc/nordvpn-wg.conf"
TOKEN_DIR="$PREFIX/etc/nordvpn-wg"
STATE_DIR="$PREFIX/var/lib/nordvpn-wg"

[ -d "$PREFIX" ] || {
  echo "Entware (/opt) is required." >&2
  exit 1
}

# The tool itself runs under Asuswrt-Merlin's stock /bin/sh (BusyBox ash).
# Entware is required for utilities, not for Bash.
PATH="/opt/bin:/opt/sbin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"
export PATH

for cmd in curl jq; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Missing $cmd. Install prerequisites with: opkg install curl jq" >&2
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

printf '%s\n' \
  "Installed $BIN" \
  "Config: $CONF" \
  "Token file: $TOKEN_DIR/token (chmod 600)" \
  "Runtime shell: /bin/sh (Asuswrt-Merlin BusyBox ash)"
