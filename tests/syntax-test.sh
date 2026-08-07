#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
bash -n "$ROOT/nordvpn-wg"
"$ROOT/nordvpn-wg" --version >/dev/null
"$ROOT/nordvpn-wg" --help >/dev/null
printf 'syntax/help tests: PASS\n'
