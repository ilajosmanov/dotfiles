# Auto Day/Night Theme Switcher for Omarchy

Automatically switches between light and dark Catppuccin themes based on sunrise/sunset times.

## How it works

- Uses `sunwait` to determine if it's day or night based on your coordinates
- Hooks into the existing `aether-scheduler` systemd timer (runs every minute)
- Only switches theme when needed (checks current vs desired)

## Dependencies

```bash
yay -S sunwait
```

## Installation

1. **Symlink the script to your PATH:**

```bash
ln -s ~/omconfig/auto-theme/omarchy-auto-theme ~/.local/bin/omarchy-auto-theme
```

2. **Create the systemd drop-in directory and symlink the config:**

```bash
mkdir -p ~/.config/systemd/user/aether-scheduler.service.d/
ln -s ~/omconfig/auto-theme/aether-scheduler.service.d/auto-theme.conf \
      ~/.config/systemd/user/aether-scheduler.service.d/auto-theme.conf
```

3. **Reload systemd:**

```bash
systemctl --user daemon-reload
```

## Configuration

Edit `omarchy-auto-theme` to change:

- `LIGHT_THEME` - theme for daytime (default: `catppuccin-latte`)
- `DARK_THEME` - theme for nighttime (default: `catppuccin`)
- `COORDS` - your location (default: `59.44N 24.75E` for Tallinn, Estonia)

Find your coordinates at https://www.latlong.net/

## Testing

```bash
# Check if it's day or night
sunwait poll 59.44N 24.75E && echo "DAY" || echo "NIGHT"

# See today's sunrise/sunset
sunwait list 59.44N 24.75E

# Run the script manually
omarchy-auto-theme
```

## Uninstall

```bash
rm ~/.local/bin/omarchy-auto-theme
rm ~/.config/systemd/user/aether-scheduler.service.d/auto-theme.conf
systemctl --user daemon-reload
```
