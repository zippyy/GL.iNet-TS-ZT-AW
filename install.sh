#!/bin/sh
# One-line installer for GL.iNet Tailscale + ZeroTier + AstroWarp Watchdog.

set -eu

REPO_RAW="https://raw.githubusercontent.com/zippyy/GL.iNet-TS-ZT-AW/main"
WATCHDOG="/usr/bin/astrowarp-overlay-watch"
INIT="/etc/init.d/astrowarp-overlay-watch"

[ "$(id -u)" -eq 0 ] || {
    echo "Run this installer as root." >&2
    exit 1
}

download() {
    url="$1"
    destination="$2"

    if command -v uclient-fetch >/dev/null 2>&1; then
        uclient-fetch -q -O "$destination" "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$destination" "$url"
    elif command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$destination"
    else
        echo "No supported downloader found (uclient-fetch, wget, or curl)." >&2
        exit 1
    fi
}

echo "Installing AstroWarp overlay watchdog..."
download "$REPO_RAW/astrowarp-overlay-watch" "$WATCHDOG"
download "$REPO_RAW/astrowarp-overlay-watch.init" "$INIT"

chmod 0755 "$WATCHDOG" "$INIT"
/etc/init.d/astrowarp-overlay-watch enable
/etc/init.d/astrowarp-overlay-watch restart

echo "Installed and started. Check with:"
echo "  /etc/init.d/astrowarp-overlay-watch status"
echo "  logread -e astrowarp-overlay-watch"
