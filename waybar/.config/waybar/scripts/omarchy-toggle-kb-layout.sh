#!/bin/bash

# Dynamically find the main keyboard device name
# The 'select(.main)' part ensures we get the primary keyboard, especially useful for multi-keyboard setups.
KB_DEVICE=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main) | .name')

# Switch to the next layout for the found keyboard
hyprctl switchxkblayout "$KB_DEVICE" next
