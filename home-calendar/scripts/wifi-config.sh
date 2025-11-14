#!/bin/bash

# WiFi Configuration Helper Script
# This script helps configure WiFi on Raspberry Pi from command line

echo "========================================="
echo "  WiFi Configuration Helper"
echo "========================================="
echo ""

# Check if NetworkManager is available
if ! command -v nmcli &> /dev/null; then
    echo "❌ NetworkManager (nmcli) is not installed"
    echo "   Install it with: sudo apt install network-manager"
    exit 1
fi

# Function to scan WiFi networks
scan_networks() {
    echo "🔍 Scanning for WiFi networks..."
    echo ""

    sudo nmcli dev wifi rescan 2>/dev/null
    sleep 2

    sudo nmcli dev wifi list
    echo ""
}

# Function to connect to WiFi
connect_wifi() {
    echo "📶 Connect to WiFi"
    echo ""

    read -p "Enter SSID (network name): " ssid

    if [ -z "$ssid" ]; then
        echo "❌ SSID cannot be empty"
        return
    fi

    read -sp "Enter password (leave empty for open network): " password
    echo ""

    echo "Connecting to $ssid..."

    if [ -z "$password" ]; then
        # Open network
        sudo nmcli dev wifi connect "$ssid"
    else
        # Secured network
        sudo nmcli dev wifi connect "$ssid" password "$password"
    fi

    if [ $? -eq 0 ]; then
        echo "✅ Connected to $ssid"
    else
        echo "❌ Failed to connect to $ssid"
    fi

    echo ""
}

# Function to show current connection
show_status() {
    echo "📊 WiFi Status"
    echo ""

    # Get current connection
    CONNECTION=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active | grep wifi | cut -d: -f1)

    if [ -n "$CONNECTION" ]; then
        echo "✅ Connected to: $CONNECTION"
        echo ""

        # Show details
        nmcli connection show "$CONNECTION" | grep -E "ipv4.address|GENERAL.STATE|802-11-wireless.ssid"
    else
        echo "❌ Not connected to WiFi"
    fi

    echo ""
}

# Function to disconnect WiFi
disconnect_wifi() {
    echo "📴 Disconnect WiFi"
    echo ""

    CONNECTION=$(nmcli -t -f NAME,TYPE connection show --active | grep wifi | cut -d: -f1)

    if [ -z "$CONNECTION" ]; then
        echo "❌ Not connected to any WiFi network"
        return
    fi

    echo "Disconnecting from $CONNECTION..."
    sudo nmcli connection down "$CONNECTION"

    if [ $? -eq 0 ]; then
        echo "✅ Disconnected"
    else
        echo "❌ Failed to disconnect"
    fi

    echo ""
}

# Function to list saved connections
list_saved() {
    echo "💾 Saved WiFi Networks"
    echo ""

    nmcli connection show | grep wifi
    echo ""
}

# Function to forget network
forget_network() {
    echo "🗑️  Forget Network"
    echo ""

    list_saved

    read -p "Enter network name to forget: " network

    if [ -z "$network" ]; then
        echo "❌ Network name cannot be empty"
        return
    fi

    echo "Removing $network..."
    sudo nmcli connection delete "$network"

    if [ $? -eq 0 ]; then
        echo "✅ Removed $network"
    else
        echo "❌ Failed to remove $network"
    fi

    echo ""
}

# Main menu
while true; do
    echo "Select an option:"
    echo "  1) Scan for networks"
    echo "  2) Connect to WiFi"
    echo "  3) Show current status"
    echo "  4) Disconnect WiFi"
    echo "  5) List saved networks"
    echo "  6) Forget network"
    echo "  7) Exit"
    echo ""
    read -p "Enter choice [1-7]: " choice

    case $choice in
        1)
            scan_networks
            ;;
        2)
            connect_wifi
            ;;
        3)
            show_status
            ;;
        4)
            disconnect_wifi
            ;;
        5)
            list_saved
            ;;
        6)
            forget_network
            ;;
        7)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid choice"
            echo ""
            ;;
    esac
done
