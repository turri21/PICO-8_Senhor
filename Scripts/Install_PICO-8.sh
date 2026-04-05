#!/bin/bash
# Install_PICO-8.sh — One-time setup for PICO-8 on MiSTer
#
# Run this once from the MiSTer Scripts menu.
# After that, just load the PICO-8 core from the console menu.
#

BINARY=/media/fat/PICO-8/PICO-8
PICO8_DIR=/media/fat/games/PICO-8
STARTUP=/media/fat/linux/user-startup.sh
DAEMON_TAG="pico8_autolaunch"

echo "Installing PICO-8..."

# Create directories
mkdir -p "$PICO8_DIR/Carts" "$PICO8_DIR/Saves"

# Make binary executable
chmod +x "$BINARY"

# Check required files
if [ ! -f "$BINARY" ]; then
    echo "Error: $BINARY not found"
    exit 1
fi
if [ ! -f "$PICO8_DIR/boot.rom" ]; then
    echo "Error: $PICO8_DIR/boot.rom not found"
    exit 1
fi

# Install auto-launcher into user-startup.sh
if ! grep -q "$DAEMON_TAG" "$STARTUP" 2>/dev/null; then
    cat >> "$STARTUP" << 'DAEMON'

# pico8_autolaunch — auto-start PICO-8 emulator when core loads
(
LAST_CORE=""
while true; do
    CUR=$(cat /tmp/CORENAME 2>/dev/null)
    if [ "$CUR" = "PICO-8" ] && [ "$LAST_CORE" != "PICO-8" ]; then
        sleep 2
        taskset 03 /media/fat/PICO-8/PICO-8 -nativevideo -data /media/fat/games/PICO-8/ > /dev/null 2>&1 &
        echo $! > /tmp/pico8_arm.pid
    elif [ "$CUR" != "PICO-8" ] && [ "$LAST_CORE" = "PICO-8" ]; then
        kill $(cat /tmp/pico8_arm.pid 2>/dev/null) 2>/dev/null
        rm -f /tmp/pico8_arm.pid
    fi
    LAST_CORE="$CUR"
    sleep 1
done
) &
DAEMON
fi

# Start the daemon now so reboot isn't needed
pkill -f "PICO-8.*nativevideo" 2>/dev/null
(
LAST_CORE=""
while true; do
    CUR=$(cat /tmp/CORENAME 2>/dev/null)
    if [ "$CUR" = "PICO-8" ] && [ "$LAST_CORE" != "PICO-8" ]; then
        sleep 2
        taskset 03 /media/fat/PICO-8/PICO-8 -nativevideo -data /media/fat/games/PICO-8/ > /dev/null 2>&1 &
        echo $! > /tmp/pico8_arm.pid
    elif [ "$CUR" != "PICO-8" ] && [ "$LAST_CORE" = "PICO-8" ]; then
        kill $(cat /tmp/pico8_arm.pid 2>/dev/null) 2>/dev/null
        rm -f /tmp/pico8_arm.pid
    fi
    LAST_CORE="$CUR"
    sleep 1
done
) &

echo ""
echo "PICO-8 installed!"
echo "Load the PICO-8 core from the console menu to play."
echo "Use the MiSTer OSD to load carts."
echo ""
