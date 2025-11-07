#!/usr/bin/env bash
# debug-ac.sh - Debug script to find AC adapter and test power switching

echo "=== Power Supply Devices ==="
ls -la /sys/class/power_supply/

echo -e "\n=== AC Adapter Detection ==="
for device in /sys/class/power_supply/*; do
    if [[ -f "$device/type" ]]; then
        type=$(cat "$device/type" 2>/dev/null)
        name=$(basename "$device")
        if [[ "$type" == "Mains" ]]; then
            online=$(cat "$device/online" 2>/dev/null || echo "N/A")
            echo "Found AC adapter: $name (online: $online)"
            echo "  Path: $device"
            echo "  Type: $type"
            if [[ -f "$device/uevent" ]]; then
                echo "  POWER_SUPPLY_NAME: $(grep POWER_SUPPLY_NAME= "$device/uevent" | cut -d= -f2)"
            fi
        fi
    fi
done

echo -e "\n=== Current Power Profile ==="
powerprofilesctl get

echo -e "\n=== Testing Power Profile Commands ==="
echo "Available profiles:"
powerprofilesctl list

echo -e "\n=== Testing AC Switch Script ==="
echo "Running ac-power-switch.sh..."
/home/ioio/.config/waybar/scripts/ac-power-switch.sh

echo -e "\n=== Recent Log Entries ==="
if [[ -f /tmp/ac-power-switch.log ]]; then
    tail -5 /tmp/ac-power-switch.log
else
    echo "No log file found"
fi
