#!/bin/bash

# Home Calendar Installation Script
# This script installs and configures the home calendar system

set -e  # Exit on error

echo "========================================="
echo "  Home Calendar Installation"
echo "========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please do not run this script as root"
    echo "   Run: ./install.sh"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "📁 Project directory: $PROJECT_DIR"
echo ""

# 1. Check dependencies
echo "1️⃣  Checking dependencies..."

if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed"
    echo "   Please install Node.js 18.x first"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed"
    echo "   Please install npm first"
    exit 1
fi

if ! command -v chromium-browser &> /dev/null && ! command -v chromium &> /dev/null; then
    echo "❌ Chromium is not installed"
    echo "   Please install chromium-browser first"
    exit 1
fi

echo "✅ All dependencies found"
echo ""

# 2. Install Node.js dependencies
echo "2️⃣  Installing Node.js dependencies..."
cd "$PROJECT_DIR/backend"

if [ ! -d "node_modules" ]; then
    npm install
    echo "✅ Dependencies installed"
else
    echo "✅ Dependencies already installed"
fi
echo ""

# 3. Create systemd service
echo "3️⃣  Creating systemd service..."

SERVICE_FILE="/etc/systemd/system/calendar-display.service"

sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Home Calendar Display
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$PROJECT_DIR/backend
ExecStart=/usr/bin/node $PROJECT_DIR/backend/server.js
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=calendar-display

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable calendar-display.service

echo "✅ Systemd service created and enabled"
echo ""

# 4. Start the service
echo "4️⃣  Starting calendar service..."
sudo systemctl start calendar-display.service

# Wait a moment for service to start
sleep 2

# Check service status
if sudo systemctl is-active --quiet calendar-display.service; then
    echo "✅ Calendar service is running"
else
    echo "⚠️  Calendar service may not be running properly"
    echo "   Check logs: sudo journalctl -u calendar-display -n 50"
fi
echo ""

# 5. Test the server
echo "5️⃣  Testing server connection..."
sleep 1

if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "✅ Server is responding"
else
    echo "⚠️  Server may not be responding"
    echo "   Check logs: sudo journalctl -u calendar-display -n 50"
fi
echo ""

# 6. Installation complete
echo "========================================="
echo "✅ Installation Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Run setup wizard: ./scripts/setup-kiosk.sh"
echo "  2. Or access manually:"
echo "     - Calendar: http://localhost:3000"
echo "     - Setup: http://localhost:3000/setup.html"
echo ""
echo "Service management:"
echo "  - Status:  sudo systemctl status calendar-display"
echo "  - Stop:    sudo systemctl stop calendar-display"
echo "  - Start:   sudo systemctl start calendar-display"
echo "  - Restart: sudo systemctl restart calendar-display"
echo "  - Logs:    sudo journalctl -u calendar-display -f"
echo ""
