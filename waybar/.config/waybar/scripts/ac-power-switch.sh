#!/usr/bin/env bash
# ac-power-switch.sh – called by the systemd service

# Set up environment for systemd
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Log for debugging
echo "$(date): AC power switch script started" >> /tmp/ac-power-switch.log
echo "$(date): Running as user: $(whoami)" >> /tmp/ac-power-switch.log
echo "$(date): PATH: $PATH" >> /tmp/ac-power-switch.log
echo "$(date): HOME: $HOME" >> /tmp/ac-power-switch.log

# Check if powerprofilesctl is available
if ! command -v powerprofilesctl &> /dev/null; then
    echo "$(date): powerprofilesctl command not found in PATH" >> /tmp/ac-power-switch.log
    exit 1
fi

# Find the AC adapter device by checking common names
AC_PATH=""
for adapter in ACAD ADP1 AC ADP0; do
    if [[ -f "/sys/class/power_supply/$adapter/online" ]]; then
        AC_PATH="/sys/class/power_supply/$adapter"
        echo "$(date): Found AC adapter at $AC_PATH" >> /tmp/ac-power-switch.log
        break
    fi
done

# If no AC adapter found, exit
if [[ -z "$AC_PATH" ]]; then
    echo "$(date): No AC adapter found" >> /tmp/ac-power-switch.log
    exit 1
fi

ONLINE=$(cat "$AC_PATH/online" 2>/dev/null || echo "0")
echo "$(date): AC adapter online status: $ONLINE" >> /tmp/ac-power-switch.log

# Check current profile before changing
CURRENT_PROFILE=$(powerprofilesctl get 2>&1)
CURRENT_EXIT=$?
echo "$(date): Current profile command result: $CURRENT_PROFILE (exit: $CURRENT_EXIT)" >> /tmp/ac-power-switch.log

if [[ "$ONLINE" == "1" ]]; then
    # Plugged in → high‑performance mode
    echo "$(date): Attempting to set performance mode..." >> /tmp/ac-power-switch.log
    RESULT=$(powerprofilesctl set performance 2>&1)
    EXIT_CODE=$?
    echo "$(date): powerprofilesctl set performance result: $RESULT (exit code: $EXIT_CODE)" >> /tmp/ac-power-switch.log

    if [[ $EXIT_CODE -ne 0 ]]; then
        echo "$(date): Failed to set performance mode, trying with different approach..." >> /tmp/ac-power-switch.log
        # Try with explicit D-Bus
        RESULT2=$(busctl --system call org.freedesktop.UPower /org/freedesktop/UPower/PowerProfiles org.freedesktop.UPower.PowerProfiles SetProfile s performance 2>&1)
        echo "$(date): Direct D-Bus call result: $RESULT2" >> /tmp/ac-power-switch.log
    fi
else
    # On battery → balanced mode
    echo "$(date): Attempting to set balanced mode..." >> /tmp/ac-power-switch.log
    RESULT=$(powerprofilesctl set balanced 2>&1)
    EXIT_CODE=$?
    echo "$(date): powerprofilesctl set balanced result: $RESULT (exit code: $EXIT_CODE)" >> /tmp/ac-power-switch.log

    if [[ $EXIT_CODE -ne 0 ]]; then
        echo "$(date): Failed to set balanced mode, trying with different approach..." >> /tmp/ac-power-switch.log
        # Try with explicit D-Bus
        RESULT2=$(busctl --system call org.freedesktop.UPower /org/freedesktop/UPower/PowerProfiles org.freedesktop.UPower.PowerProfiles SetProfile s balanced 2>&1)
        echo "$(date): Direct D-Bus call result: $RESULT2" >> /tmp/ac-power-switch.log
    fi
fi

# Check profile after change
AFTER_PROFILE=$(powerprofilesctl get 2>&1)
echo "$(date): Profile after change: $AFTER_PROFILE" >> /tmp/ac-power-switch.log

echo "$(date): Script completed" >> /tmp/ac-power-switch.log
