# Monitor layout (example)

`~/.config/hypr/UserConfigs/monitors.lua` reads `~/.config/hypr/monitors.conf`
when it exists, so `nwg-displays` output can be used without editing Lua.

`monitors.conf` is machine-specific and is **not** stored in this repo.
Generate it on the new machine with `nwg-displays`, or copy it from the old
disk and adjust the output name.

Example (replace `HDMI-A-1` with your real output from `hyprctl monitors`):

```ini
monitor=HDMI-A-1,1920x1080@120.0,0x0,1.0
# monitor=eDP-1,2880x1800@120.0,0x0,1.5
```

If the file does not exist, `monitors.lua` silently does nothing and
Hyprland falls back to automatic monitor detection.
