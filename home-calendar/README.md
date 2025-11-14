# Home Calendar Display

A wall-mounted calendar display that syncs with Google Calendar, iCloud, and other CalDAV calendars. Designed for Raspberry Pi but can be developed and tested in VirtualBox.

## Features

- 📅 Multi-calendar sync (Google Calendar, iCloud, CalDAV)
- 🔄 Auto-refresh every 5 minutes
- 🖥️ Kiosk mode (auto-starts on boot)
- 📱 Easy user setup via web interface
- 🔌 WiFi configuration on first boot
- 🎨 Clean, readable 10" display optimized layout

## Project Structure

```
home-calendar/
├── docs/
│   ├── VIRTUALBOX_SETUP.md    # VirtualBox development environment setup
│   ├── HARDWARE_SETUP.md      # Raspberry Pi hardware setup
│   └── USER_GUIDE.md          # End-user setup guide
├── backend/
│   ├── server.js              # Node.js backend server
│   ├── calendar-sync.js       # Calendar API integration
│   ├── config.js              # Configuration management
│   └── package.json           # Node dependencies
├── frontend/
│   ├── index.html             # Main calendar display
│   ├── setup.html             # First-time setup wizard
│   ├── css/
│   │   ├── calendar.css       # Calendar styling
│   │   └── setup.css          # Setup wizard styling
│   └── js/
│       ├── calendar.js        # Calendar display logic
│       └── setup.js           # Setup wizard logic
├── scripts/
│   ├── install.sh             # Installation script
│   ├── setup-kiosk.sh         # Kiosk mode setup
│   └── wifi-config.sh         # WiFi configuration helper
└── config/
    └── calendar-config.json   # User calendar configuration
```

## Quick Start

### For Development (VirtualBox)

1. **Set up VirtualBox VM** - See [docs/VIRTUALBOX_SETUP.md](docs/VIRTUALBOX_SETUP.md)
2. **Clone this project** in the VM
3. **Install dependencies**:
   ```bash
   cd home-calendar/backend
   npm install
   ```
4. **Start the server**:
   ```bash
   npm start
   ```
5. **Open browser**: http://localhost:3000

### For Production (Raspberry Pi)

See [docs/HARDWARE_SETUP.md](docs/HARDWARE_SETUP.md) and [docs/USER_GUIDE.md](docs/USER_GUIDE.md)

## Technology Stack

- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Backend**: Node.js, Express
- **Calendar APIs**: Google Calendar API, CalDAV
- **OS**: Debian/Raspberry Pi OS
- **Display**: Chromium in kiosk mode

## Hardware Requirements

### Recommended Hardware

- **Computer**: Raspberry Pi 4 (2GB+ RAM) or Raspberry Pi 5
- **Display**: 10" HDMI touchscreen (1280x800 recommended)
- **Power**: 5V 3A USB-C power supply
- **Storage**: 16GB+ microSD card
- **Connectivity**: Built-in WiFi

### Estimated Cost

- Raspberry Pi 4 (2GB): $35-45
- 10" HDMI Touchscreen: $50-100
- Power supply: $8-12
- MicroSD card (32GB): $8-12
- Case/Frame: $10-30
- **Total**: ~$110-200

## Setup Overview

1. **First Boot**: Device shows WiFi setup screen
2. **Connect WiFi**: User selects network and enters password
3. **Calendar Setup**: User adds their calendars (Google, iCloud, etc.)
4. **Auto-start**: Calendar displays automatically on every boot

## Development Workflow

1. Develop and test in VirtualBox
2. Test all features (calendar sync, UI, etc.)
3. Flash Raspberry Pi OS to SD card
4. Install project on Pi
5. Configure kiosk mode
6. Mount in frame

## License

MIT License

## Contributing

This is a personal project. Feel free to fork and customize for your own use.
