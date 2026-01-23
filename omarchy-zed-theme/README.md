# Omarchy Zed Theme Sync

Syncs Omarchy theme changes to Zed editor using the `theme-set` hook.

## How it works

1. When you run `omarchy-theme-set <theme>`, omarchy copies theme files to `~/.config/omarchy/current/theme/`
2. At the end, it calls `omarchy-hook theme-set <theme>`
3. The hook reads `zed.json` from the current theme and updates `~/.config/zed/settings.json`

## Installation

```bash
cd ~/omconfig

# 1. Stow the hook
stow omarchy-zed-theme

# 2. Copy zed.json files to omarchy theme dirs
cp omarchy-zed-theme/zed-themes/catppuccin.json ~/.config/omarchy/themes/catppuccin/zed.json
cp omarchy-zed-theme/zed-themes/catppuccin-latte.json ~/.config/omarchy/themes/catppuccin-latte/zed.json
```

This creates:
- `~/.config/omarchy/hooks/theme-set` → hook script (symlink)
- `~/.config/omarchy/themes/*/zed.json` → theme configs (copied)

## Dependencies

- `jq` - for parsing zed.json

## Test

```bash
# Check current theme
cat ~/.config/omarchy/current/theme.name

# Manually trigger hook
omarchy-hook theme-set catppuccin

# Verify zed settings updated
grep '"theme"' ~/.config/zed/settings.json
```

## Adding more themes

Create `zed.json` in the theme directory:

```bash
# Example for nord theme
echo '{"name": "Nord", "extension": "arcticicestudio.nord-visual-studio-code"}' > ~/.config/omarchy/themes/nord/zed.json
```

Add the reference file to `zed-themes/` for backup/replication.

## Disable

Create toggle file to skip Zed theme changes:

```bash
mkdir -p ~/.local/state/omarchy/toggles
touch ~/.local/state/omarchy/toggles/skip-zed-theme-changes
```

## Zed theme names

Find theme names in Zed: `Cmd+Shift+P` → "theme selector: toggle"

Common mappings:
| Omarchy Theme | Zed Theme Name |
|---------------|----------------|
| catppuccin | Catppuccin Mocha |
| catppuccin-latte | Catppuccin Latte |
| nord | Nord |
| gruvbox | Gruvbox Dark |
| tokyo-night | Tokyo Night |
