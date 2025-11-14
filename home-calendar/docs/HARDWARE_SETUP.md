# Raspberry Pi Hardware Setup Guide

This guide covers setting up the home calendar on actual Raspberry Pi hardware with a touchscreen display.

## Hardware Requirements

### Required Components

1. **Raspberry Pi 4 Model B (2GB RAM minimum)** - $35-45
   - Or Raspberry Pi 5 (2GB) - $50-60
   - 4GB model recommended for smoother performance

2. **10" HDMI Touchscreen Display** - $50-100
   - Recommended: 1280x800 resolution
   - Look for IPS panel for better viewing angles
   - Should include HDMI controller board
   - Touch interface: USB or GPIO

3. **MicroSD Card (32GB minimum, Class 10)** - $8-12
   - SanDisk Ultra or Samsung EVO Plus recommended
   - Faster cards improve boot time

4. **Power Supply** - $8-12
   - Raspberry Pi 4: 5V 3A USB-C
   - Raspberry Pi 5: 5V 5A USB-C (or official 27W)
   - Must be official or high-quality brand

5. **Optional but Recommended**:
   - HDMI cable (usually included with display)
   - USB cable for touchscreen (if not GPIO)
   - Picture frame or custom enclosure
   - Heatsinks or fan for Pi
   - SD card reader for flashing

### Recommended Displays

**Budget Option (~$50-70)**:
- Elecrow 10.1" HDMI Display (1024x600)
- Waveshare 10.1" HDMI LCD (1024x600)

**Better Quality (~$80-100)**:
- Raspberry Pi Official 10.1" Display (1280x800)
- UPERFECT 10.1" IPS (1280x800)
- WIMAXIT 10.1" (1920x1280)

**Premium (~$100+)**:
- SunFounder 10.1" IPS (1920x1200)
- EVICIV 10.1" 2K (2560x1600)

## Assembly

### Step 1: Prepare the Display

1. Unpack the display and controller board
2. Connect the LCD panel to the controller board (usually pre-connected)
3. Connect HDMI cable to controller board
4. Connect USB cable for touch (or GPIO ribbon cable)
5. Note the power requirements (some displays have separate power)

### Step 2: Physical Assembly

**Option A: Desktop Stand**
1. Mount Pi on back of display using standoffs
2. Keep cables organized with zip ties
3. Place in desktop stand

**Option B: Wall Mount / Frame**
1. Measure and mark frame
2. Mount display in frame
3. Mount Pi on back or in frame space
4. Drill hole for power cable
5. Add wall mounting hardware

### Step 3: Connect Components

```
Raspberry Pi → Display
├── HDMI Port → Display HDMI Input
├── USB Port → Display Touch USB (if applicable)
└── Power Supply → Pi USB-C Port

Display Controller Board
├── Power Input → 12V adapter (if separate power needed)
└── Touch Output → Pi USB or GPIO
```

## Software Installation

### Step 1: Download Raspberry Pi OS

1. Download **Raspberry Pi Imager**: https://www.raspberrypi.com/software/
2. Install and open it
3. Choose:
   - **OS**: Raspberry Pi OS Lite (64-bit) - No desktop for pure kiosk
   - Or: Raspberry Pi OS with Desktop (if you want desktop access)
4. **Storage**: Select your SD card
5. Click **Settings** (gear icon)

### Step 2: Configure OS Settings

In the settings:

**General**:
- Set hostname: `homecalendar`
- Enable SSH: ✅
- Set username: `calendar`
- Set password: (create a secure password)
- Configure WiFi: (optional, or configure on first boot)
  - SSID: Your network name
  - Password: Your WiFi password
  - Country: Your country code
- Set locale:
  - Timezone: Your timezone
  - Keyboard: Your layout

**Services**:
- Enable SSH: ✅

Click **Save**, then **Write** to flash the SD card.

### Step 3: First Boot

1. Insert SD card into Raspberry Pi
2. Connect display via HDMI
3. Connect power supply
4. Pi should boot (takes 30-60 seconds first time)

**If you see rainbow screen**: Good! Hardware is working.
**If you see command line login**: Perfect!
**If you see desktop**: Also fine, depends on OS version chosen.

### Step 4: Initial Configuration

#### Option A: Direct (with keyboard/mouse)

1. Login with username `calendar` and your password
2. Update system:
```bash
sudo apt update
sudo apt full-upgrade -y
sudo reboot
```

#### Option B: SSH (headless)

1. Find Pi's IP address (check your router or use `ping homecalendar.local`)
2. SSH from your computer:
```bash
ssh calendar@homecalendar.local
# Or: ssh calendar@<IP_ADDRESS>
```

3. Update system:
```bash
sudo apt update
sudo apt full-upgrade -y
sudo reboot
```

### Step 5: Install Required Software

SSH back in after reboot:

```bash
ssh calendar@homecalendar.local
```

Install everything:

```bash
# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install Git
sudo apt install -y git

# Install Chromium browser
sudo apt install -y chromium-browser

# Install X server and window manager (if using Lite)
sudo apt install -y xserver-xorg x11-xserver-utils xinit openbox

# Install unclutter (hides mouse cursor)
sudo apt install -y unclutter

# Install network manager
sudo apt install -y network-manager

# Verify installations
node --version
npm --version
chromium-browser --version
```

### Step 6: Install Calendar Application

```bash
# Clone your repository (replace with your actual repo URL)
cd ~
git clone https://github.com/yourusername/home-calendar.git
cd home-calendar

# Install dependencies
cd backend
npm install
cd ..

# Make scripts executable
chmod +x scripts/*.sh
```

### Step 7: Configure Auto-Start

```bash
# Run the installation script
cd ~/home-calendar
sudo ./scripts/install.sh

# This will:
# 1. Install the calendar as a system service
# 2. Configure kiosk mode
# 3. Set up auto-start on boot
# 4. Configure WiFi setup on first boot
```

### Step 8: Test the Calendar

```bash
# Start the calendar service
sudo systemctl start calendar-display

# Check status
sudo systemctl status calendar-display

# View logs
sudo journalctl -u calendar-display -f
```

Open Chromium manually to test:
```bash
DISPLAY=:0 chromium-browser --kiosk http://localhost:3000
```

### Step 9: Enable Kiosk Mode

```bash
# Run kiosk setup
cd ~/home-calendar
./scripts/setup-kiosk.sh

# Reboot to activate
sudo reboot
```

After reboot, the calendar should auto-start in fullscreen!

## Display Configuration

### Rotate Display

If you want portrait mode:

```bash
# Edit boot config
sudo nano /boot/config.txt

# Add at the end:
display_rotate=1    # 90 degrees
# or
display_rotate=3    # 270 degrees

# Save and reboot
sudo reboot
```

### Adjust Resolution

```bash
# Edit boot config
sudo nano /boot/config.txt

# Uncomment and edit these lines:
hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=87
hdmi_cvt=1280 800 60 6 0 0 0

# Save and reboot
sudo reboot
```

Common HDMI modes:
- `hdmi_mode=16`: 1024x768
- `hdmi_mode=85`: 1280x720
- `hdmi_mode=87`: Custom (use with hdmi_cvt)

### Calibrate Touchscreen

If touch is offset:

```bash
# Install calibration tool
sudo apt install -y xinput-calibrator

# Run calibration
DISPLAY=:0 xinput_calibrator

# Follow on-screen instructions
# Save the output to:
sudo nano /etc/X11/xorg.conf.d/99-calibration.conf

# Paste the calibration data
# Reboot
sudo reboot
```

## WiFi Configuration

### Manual WiFi Setup

```bash
# List available networks
sudo nmcli dev wifi list

# Connect to network
sudo nmcli dev wifi connect "YourSSID" password "YourPassword"

# Check connection
nmcli con show
```

### WiFi Setup UI (First Boot)

The calendar includes a first-boot WiFi setup screen:

1. On first boot, calendar detects no WiFi connection
2. Shows WiFi setup page with available networks
3. User selects network and enters password
4. Saves configuration and connects
5. Redirects to calendar setup

## Power Management

### Auto Power On/Off

**Wake on Schedule**:
Pi doesn't have RTC, but you can use a smart plug with schedule.

**Sleep Display**:
```bash
# Screen off after 10 minutes of inactivity
sudo nano /etc/xdg/openbox/autostart

# Add:
xset s 600 600
xset dpms 600 600 600
```

### Clean Shutdown Button

Add a physical shutdown button:

```bash
# Install GPIO shutdown script
sudo apt install -y python3-gpiozero

# Create shutdown script
sudo nano /usr/local/bin/shutdown-button.py
```

Add:
```python
#!/usr/bin/env python3
from gpiozero import Button
from signal import pause
import os

shutdown_btn = Button(3)  # GPIO 3 (Pin 5)
shutdown_btn.when_pressed = lambda: os.system("sudo shutdown -h now")
pause()
```

```bash
# Make executable
sudo chmod +x /usr/local/bin/shutdown-button.py

# Create service
sudo nano /etc/systemd/system/shutdown-button.service
```

Add:
```ini
[Unit]
Description=Shutdown Button

[Service]
ExecStart=/usr/local/bin/shutdown-button.py
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
# Enable service
sudo systemctl enable shutdown-button
sudo systemctl start shutdown-button
```

## Troubleshooting

### Display shows "No signal"

**Check**:
1. HDMI cable firmly connected
2. Display powered on
3. Try different HDMI port on display
4. Add to `/boot/config.txt`:
   ```
   hdmi_force_hotplug=1
   ```

### Touchscreen not working

**Check**:
1. USB cable connected (if USB touch)
2. Driver installed:
   ```bash
   lsusb  # Should show touchscreen device
   sudo apt install -y xinput
   xinput list  # Should show touchscreen
   ```
3. Check dmesg for errors:
   ```bash
   dmesg | grep -i touch
   ```

### Calendar doesn't auto-start

**Check**:
```bash
# Check service status
sudo systemctl status calendar-display

# Check kiosk config
cat ~/.config/lxsession/LXDE-pi/autostart

# Check logs
sudo journalctl -u calendar-display -n 50
```

### WiFi not connecting

**Check**:
```bash
# Check WiFi status
nmcli device status

# Check saved connections
nmcli con show

# Reconnect
sudo nmcli con up "YourSSID"

# Check country code (important!)
sudo raspi-config
# → Localisation Options → WLAN Country
```

### Performance is slow

**Optimize**:
```bash
# Increase GPU memory
sudo raspi-config
# → Performance Options → GPU Memory → 128

# Disable unnecessary services
sudo systemctl disable bluetooth
sudo systemctl disable hciuart

# Overclock (Pi 4)
sudo nano /boot/config.txt
# Add:
over_voltage=6
arm_freq=2000
```

### Screen goes blank

**Disable screensaver**:
```bash
# Edit autostart
nano ~/.config/lxsession/LXDE-pi/autostart

# Add:
@xset s off
@xset -dpms
@xset s noblank
```

## Maintenance

### Update Calendar Software

```bash
cd ~/home-calendar
git pull
cd backend
npm install
sudo systemctl restart calendar-display
```

### Update System

```bash
sudo apt update
sudo apt full-upgrade -y
sudo reboot
```

### Backup Configuration

```bash
# Backup calendar config
cp ~/home-calendar/config/calendar-config.json ~/calendar-backup.json

# Restore
cp ~/calendar-backup.json ~/home-calendar/config/calendar-config.json
sudo systemctl restart calendar-display
```

### View Logs

```bash
# Calendar app logs
sudo journalctl -u calendar-display -f

# System logs
sudo journalctl -n 100

# Boot logs
sudo journalctl -b
```

## Mounting Options

### Picture Frame

1. Measure display dimensions
2. Purchase frame (Ikea RIBBA or custom)
3. Remove glass and backing
4. Mount display in frame
5. Attach Pi to back with standoffs
6. Drill hole for power cable
7. Attach wall mounting hardware

### 3D Printed Enclosure

Search Thingiverse/Printables for:
- "Raspberry Pi 10 inch display case"
- Customize for your display model

### Wall Mount

Use VESA mount adapter if display supports it, or:
1. 3M Command Strips (for temporary, <2 lbs)
2. French cleats (for permanent)
3. Flush mount in wall cavity (advanced)

## Bill of Materials Example

| Item | Model | Price |
|------|-------|-------|
| Raspberry Pi 4 (4GB) | - | $55 |
| 10" Touchscreen | Waveshare 10.1" | $75 |
| MicroSD Card (32GB) | SanDisk Ultra | $10 |
| Power Supply (USB-C 3A) | Official Pi | $12 |
| HDMI Cable | 1ft short cable | $5 |
| Picture Frame | Ikea RIBBA | $20 |
| Standoffs/Screws | M2.5 kit | $8 |
| **Total** | | **$185** |

## Resources

- [Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/)
- [Raspberry Pi Forums](https://forums.raspberrypi.com/)
- [eLinux RPi Config](https://elinux.org/RPi_config.txt)
