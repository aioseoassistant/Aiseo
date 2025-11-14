#!/bin/bash

# Kiosk Mode Setup Script
# Configures the system to auto-start the calendar in fullscreen kiosk mode

set -e  # Exit on error

echo "========================================="
echo "  Kiosk Mode Setup"
echo "========================================="
echo ""

# Check if running as regular user
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please do not run this script as root"
    echo "   Run: ./setup-kiosk.sh"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "📁 Project directory: $PROJECT_DIR"
echo ""

# Detect desktop environment
echo "1️⃣  Detecting desktop environment..."

if [ -d "/etc/xdg/lxsession/LXDE-pi" ]; then
    AUTOSTART_DIR="/home/$USER/.config/lxsession/LXDE-pi"
    AUTOSTART_FILE="$AUTOSTART_DIR/autostart"
    echo "✅ Detected: LXDE (Raspberry Pi OS Desktop)"
elif [ -d "/etc/xdg/lxsession/LXDE" ]; then
    AUTOSTART_DIR="/home/$USER/.config/lxsession/LXDE"
    AUTOSTART_FILE="$AUTOSTART_DIR/autostart"
    echo "✅ Detected: LXDE"
elif [ -n "$XDG_CURRENT_DESKTOP" ]; then
    AUTOSTART_DIR="/home/$USER/.config/autostart"
    AUTOSTART_FILE="$AUTOSTART_DIR/calendar-kiosk.desktop"
    echo "✅ Detected: $XDG_CURRENT_DESKTOP"
else
    # Fallback for minimal setup
    AUTOSTART_DIR="/home/$USER/.config/autostart"
    AUTOSTART_FILE="$AUTOSTART_DIR/calendar-kiosk.desktop"
    echo "⚠️  Desktop environment not detected, using fallback"
fi

echo ""

# 2. Create autostart directory
echo "2️⃣  Creating autostart directory..."
mkdir -p "$AUTOSTART_DIR"
echo "✅ Directory created: $AUTOSTART_DIR"
echo ""

# 3. Determine which browser to use
echo "3️⃣  Detecting browser..."

if command -v chromium-browser &> /dev/null; then
    BROWSER="chromium-browser"
elif command -v chromium &> /dev/null; then
    BROWSER="chromium"
else
    echo "❌ Chromium not found"
    exit 1
fi

echo "✅ Using browser: $BROWSER"
echo ""

# 4. Create autostart configuration
echo "4️⃣  Creating autostart configuration..."

if [[ "$AUTOSTART_FILE" == *.desktop ]]; then
    # Desktop entry format (for autostart directory)
    cat > "$AUTOSTART_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=Calendar Display
Comment=Home Calendar Kiosk Mode
Exec=/bin/bash -c 'while ! curl -s http://localhost:3000/api/health > /dev/null; do sleep 1; done; DISPLAY=:0 $BROWSER --kiosk --noerrdialogs --disable-infobars --disable-session-crashed-bubble --disable-restore-session-state --disable-backgrounding-occluded-windows --no-first-run --check-for-update-interval=31536000 http://localhost:3000'
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
else
    # LXDE autostart format
    # First, preserve existing autostart settings if they exist
    if [ -f "$AUTOSTART_FILE" ]; then
        # Backup existing file
        cp "$AUTOSTART_FILE" "$AUTOSTART_FILE.backup"
        echo "✅ Backed up existing autostart file"
    fi

    # Create or append to autostart file
    cat > "$AUTOSTART_FILE" <<EOF
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash

# Disable screen blanking
@xset s off
@xset -dpms
@xset s noblank

# Hide mouse cursor after inactivity
@unclutter -idle 0.5 -root

# Start calendar in kiosk mode (wait for server to be ready)
@bash -c 'while ! curl -s http://localhost:3000/api/health > /dev/null; do sleep 1; done; DISPLAY=:0 $BROWSER --kiosk --noerrdialogs --disable-infobars --disable-session-crashed-bubble --disable-restore-session-state --disable-backgrounding-occluded-windows --no-first-run --check-for-update-interval=31536000 http://localhost:3000'
EOF
fi

echo "✅ Autostart configuration created"
echo ""

# 5. Configure Chromium preferences (disable restore prompt)
echo "5️⃣  Configuring Chromium preferences..."

CHROMIUM_CONFIG_DIR="/home/$USER/.config/chromium/Default"
mkdir -p "$CHROMIUM_CONFIG_DIR"

# Create preferences file to disable restore prompt
cat > "$CHROMIUM_CONFIG_DIR/Preferences" <<'EOF'
{
   "profile": {
      "exit_type": "Normal",
      "exited_cleanly": true
   },
   "session": {
      "restore_on_startup": 4,
      "startup_urls": ["http://localhost:3000"]
   }
}
EOF

echo "✅ Chromium configured"
echo ""

# 6. Disable screen blanking (additional method)
echo "6️⃣  Disabling screen blanking..."

# Create X11 config
sudo mkdir -p /etc/X11/xorg.conf.d

sudo tee /etc/X11/xorg.conf.d/10-monitor.conf > /dev/null <<'EOF'
Section "ServerFlags"
    Option "BlankTime" "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "0"
EndSection
EOF

echo "✅ Screen blanking disabled"
echo ""

# 7. Optional: Hide mouse cursor (install unclutter if not present)
echo "7️⃣  Checking for unclutter (mouse cursor hider)..."

if ! command -v unclutter &> /dev/null; then
    echo "   Installing unclutter..."
    sudo apt-get update -qq
    sudo apt-get install -y unclutter
    echo "✅ Unclutter installed"
else
    echo "✅ Unclutter already installed"
fi
echo ""

# 8. Set up first boot detection (for setup wizard)
echo "8️⃣  Setting up first boot detection..."

CONFIG_FILE="$PROJECT_DIR/config/calendar-config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p "$PROJECT_DIR/config"
    cat > "$CONFIG_FILE" <<EOF
{
  "calendars": [],
  "settings": {
    "refreshInterval": 5,
    "timeFormat": "12h",
    "firstDayOfWeek": "sunday",
    "showPastDays": 1,
    "showFutureDays": 14,
    "showLocation": true,
    "showDescription": false
  }
}
EOF
    echo "✅ Default configuration created"
    echo "   First boot will show setup wizard"
else
    echo "✅ Configuration already exists"
fi
echo ""

# 9. Installation complete
echo "========================================="
echo "✅ Kiosk Mode Setup Complete!"
echo "========================================="
echo ""
echo "Your calendar will now start automatically in fullscreen mode on boot."
echo ""
echo "What happens next:"
echo "  1. Calendar server starts on boot"
echo "  2. Chromium launches in kiosk mode"
echo "  3. Shows setup wizard (if first time)"
echo "  4. Otherwise shows calendar"
echo ""
echo "To test now:"
echo "  - Reboot: sudo reboot"
echo "  - Or start manually:"
echo "    DISPLAY=:0 $BROWSER --kiosk http://localhost:3000"
echo ""
echo "To exit kiosk mode:"
echo "  - Press: Alt+F4"
echo "  - Or: Ctrl+Alt+F1 (switch to terminal)"
echo ""
echo "Configuration files:"
echo "  - Autostart: $AUTOSTART_FILE"
echo "  - Calendar: $CONFIG_FILE"
echo ""
