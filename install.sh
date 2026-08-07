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

# Entware is a hard requirement for this project. Check the canonical Entware
# locations directly rather than relying on BusyBox shell command discovery.
[ -x /opt/bin/curl ] || {
  echo "Missing Entware curl at /opt/bin/curl. Install with: opkg install curl" >&2
  exit 1
}

[ -x /opt/bin/jq ] || {
  echo "Missing Entware jq at /opt/bin/jq. Install with: opkg install jq" >&2
  exit 1
}

# The tool itself runs under Asuswrt-Merlin's stock /bin/sh (BusyBox ash).
PATH="/opt/bin:/opt/sbin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"
export PATH

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
