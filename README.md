# GL.iNet Tailscale + ZeroTier + AstroWarp Watchdog

Keeps Tailscale and ZeroTier enabled on GL.iNet / OpenWrt routers where enabling AstroWarp can disable or interrupt the other overlay services.

This was built and tested around GL.iNet's UCI-backed services:

- Tailscale interface: `tailscale0`
- ZeroTier interface: dynamically detected from interfaces beginning with `zt`
- AstroWarp tunnel interface: `mptun0` (not managed by the watchdog)

## What it does

Every 30 seconds, the watchdog checks whether Tailscale and ZeroTier have an IPv4 address on their respective interfaces.

When Tailscale is missing or down, it restores these GL.iNet settings and restarts Tailscale:

```text
 tailscale.settings.enabled=1
 tailscale.settings.lan_enabled=1
 tailscale.settings.wan_enabled=1
 tailscale.settings.masq=1
```

When ZeroTier is missing or down, it restores:

```text
 zerotier.gl.enabled=1
```

The script logs recovery events to the system log under the tag `astrowarp-overlay-watch`.

## Install

Copy the files to the router:

```sh
scp astrowarp-overlay-watch root@ROUTER_IP:/usr/bin/
scp astrowarp-overlay-watch.init root@ROUTER_IP:/etc/init.d/astrowarp-overlay-watch
```

Then, on the router:

```sh
chmod 0755 /usr/bin/astrowarp-overlay-watch
chmod 0755 /etc/init.d/astrowarp-overlay-watch
/etc/init.d/astrowarp-overlay-watch enable
/etc/init.d/astrowarp-overlay-watch start
```

Verify it is running:

```sh
/etc/init.d/astrowarp-overlay-watch status
logread -e astrowarp-overlay-watch
```

## Manual recovery commands

Use these if AstroWarp has already disabled Tailscale or ZeroTier:

```sh
uci set tailscale.settings.enabled='1'
uci set tailscale.settings.lan_enabled='1'
uci set tailscale.settings.wan_enabled='1'
uci set tailscale.settings.masq='1'
uci commit tailscale

uci set zerotier.gl.enabled='1'
uci commit zerotier

/etc/init.d/tailscale restart
/etc/init.d/zerotier restart
```

## Notes

- The watchdog checks for an assigned IPv4 address, not merely whether the service process exists.
- It deliberately does not restart AstroWarp or modify `mptun0`; AstroWarp remains responsible for its own tunnel lifecycle.
- `masq=1` is included because LAN-to-Tailscale access required masquerading in the original setup.
- GL.iNet package/service names and UCI paths can vary by firmware release. Check them before deploying on a substantially different device or firmware branch.
