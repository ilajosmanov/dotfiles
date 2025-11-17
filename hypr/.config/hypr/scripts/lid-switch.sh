#!/bin/bash

# Lid switch handler for Hyprland
# Safely disables laptop screen only when external monitor is connected

LID_STATE="$1"  # "on" = closed, "off" = open

# Get list of connected monitors (excluding eDP-1)
EXTERNAL_MONITORS=$(hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | .name')

if [ "$LID_STATE" = "on" ]; then
    # Lid closed
    if [ -n "$EXTERNAL_MONITORS" ]; then
        echo "Lid closed with external monitor connected - disabling eDP-1"

        # Get the first external monitor name
        EXTERNAL_MONITOR=$(echo "$EXTERNAL_MONITORS" | head -n1)

        # Move workspace 4 to external monitor before disabling
        hyprctl dispatch moveworkspacetomonitor 4 "$EXTERNAL_MONITOR"

        # Switch to workspace 1 (so we're not stuck on disabled workspace 4)
        hyprctl dispatch workspace 1

        # Disable laptop screen
        hyprctl keyword monitor "eDP-1,disable"
    else
        echo "Lid closed but no external monitor - keeping eDP-1 enabled"
        # Optionally: lock the screen or suspend
        # hyprctl dispatch dpms off eDP-1
    fi
else
    # Lid opened
    echo "Lid opened - re-enabling eDP-1"
    hyprctl keyword monitor "eDP-1,preferred,auto,1.333333"

    # Move workspace 4 back to laptop screen
    hyprctl dispatch moveworkspacetomonitor 4 eDP-1
fi
