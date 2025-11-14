# VirtualBox Development Environment Setup

This guide will help you set up a complete development environment in VirtualBox to build and test the home calendar system before purchasing hardware.

## Prerequisites

- **VirtualBox** installed ([Download here](https://www.virtualbox.org/wiki/Downloads))
- **8GB+ RAM** on host machine (will allocate 2GB to VM)
- **20GB+ free disk space**

## Step 1: Download Debian ISO

1. Go to https://www.debian.org/download
2. Download **Debian 12 (Bookworm) - netinst** ISO (~600MB)
   - Alternative: Download the full DVD ISO if you have slow internet
3. Save it to your Downloads folder

## Step 2: Create Virtual Machine

### Create New VM

1. Open VirtualBox
2. Click **New** button
3. Configure:
   - **Name**: `HomeCalendarDev`
   - **Type**: Linux
   - **Version**: Debian (64-bit)
   - Click **Next**

### Memory Size

- Allocate **2048 MB (2GB)** RAM
- If you have 16GB+ host RAM, you can allocate 4GB
- Click **Next**

### Hard Disk

- Select **Create a virtual hard disk now**
- Click **Create**
- **Type**: VDI (VirtualBox Disk Image)
- Click **Next**
- **Storage**: Dynamically allocated
- Click **Next**
- **Size**: 20 GB
- Click **Create**

## Step 3: Configure VM Settings

1. Select your VM and click **Settings**

### System Tab

- **Motherboard**:
  - Boot Order: Hard Disk, Optical, (uncheck Floppy)
- **Processor**:
  - Allocate **2 CPUs**
- **Enable PAE/NX**: Checked

### Display Tab

- **Video Memory**: 128 MB
- **Graphics Controller**: VMSVGA
- **Monitor Count**: 1
- **Scale Factor**: 100%

### Network Tab

- **Adapter 1**:
  - **Enable Network Adapter**: Checked
  - **Attached to**: NAT
  - This allows internet access

### Storage Tab

- Click on **Empty** under Controller: IDE
- Click disk icon on right → **Choose a disk file**
- Select the Debian ISO you downloaded
- Click **OK**

## Step 4: Install Debian

1. Start the VM (click **Start**)
2. At boot menu, select **Graphical Install**

### Installation Wizard

**Select a language**:
- English (or your preference)

**Select your location**:
- Your country

**Configure keyboard**:
- Your keyboard layout

**Configure network**:
- Let it auto-configure via DHCP
- **Hostname**: `homecalendar`
- **Domain name**: Leave blank (press Enter)

**Set up users and passwords**:
- **Root password**: Create a strong password (write it down!)
- **Re-enter root password**: Same password
- **Full name for new user**: Your name
- **Username for your account**: `calendar`
- **Choose a password**: Create a password (write it down!)
- **Re-enter password**: Same password

**Configure the clock**:
- Select your timezone

**Partition disks**:
- Select **Guided - use entire disk**
- Select the only disk available (Virtual disk)
- Choose **All files in one partition (recommended for new users)**
- Select **Finish partitioning and write changes to disk**
- **Write changes to disks?**: **Yes**

**Configure the package manager**:
- **Scan extra installation media?**: **No**
- **Debian archive mirror country**: Your country
- **Debian archive mirror**: `deb.debian.org` (default is fine)
- **HTTP proxy information**: Leave blank (unless you need one)

**Configure popularity-contest**:
- **No** (doesn't matter)

**Software selection**:
- Use Space to select/deselect:
  - ✅ **Debian desktop environment**
  - ✅ **LXDE** (lightweight, similar to Pi environment)
  - Uncheck GNOME if selected
  - ✅ **web server**
  - ✅ **SSH server**
  - ✅ **standard system utilities**
- Press **Tab** to highlight Continue, press **Enter**

**Install the GRUB boot loader**:
- **Install the GRUB boot loader to your primary drive?**: **Yes**
- **Device for boot loader installation**: `/dev/sda`

**Finish the installation**:
- **Installation complete**: Click **Continue**
- VM will reboot (remove the ISO if prompted)

## Step 5: First Boot and System Setup

1. VM will reboot and show login screen
2. Login with:
   - Username: `calendar`
   - Password: (the password you created)
3. Desktop environment will load
4. Open **Terminal** (Menu → System Tools → LXTerminal)

### Update System

```bash
# Update package lists
sudo apt update

# Upgrade all packages
sudo apt upgrade -y

# This may take a few minutes
```

### Install Required Software

```bash
# Install Node.js 18.x LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install Git
sudo apt install -y git

# Install development tools
sudo apt install -y build-essential curl wget vim nano

# Install Chromium browser (for kiosk mode testing)
sudo apt install -y chromium

# Install network tools (for WiFi testing)
sudo apt install -y network-manager wpasupplicant

# Install unclutter (hides mouse cursor in kiosk mode)
sudo apt install -y unclutter

# Verify installations
node --version   # Should show v18.x.x
npm --version    # Should show 9.x.x or higher
git --version    # Should show git version 2.x
chromium --version  # Should show Chromium version
```

## Step 6: Clone and Setup Project

```bash
# Navigate to home directory
cd ~

# Clone your repository (replace with your actual repo URL when ready)
# For now, you can copy the files manually or use:
mkdir -p home-calendar
cd home-calendar

# If you have the files, copy them here
# Otherwise, you'll add them after building in the next steps
```

## Step 7: Configure Display Resolution

To simulate a 10" display (1280x800):

### Method 1: Using xrandr (Immediate, temporary)

```bash
# Check current resolution
xrandr

# Set resolution (temporary until reboot)
xrandr --output Virtual-1 --mode 1280x800

# If 1280x800 isn't available, create it:
cvt 1280 800 60
# Copy the Modeline output (everything after "Modeline")
# Then run:
xrandr --newmode "1280x800_60.00" 83.50  1280 1352 1480 1680  800 803 809 831 -hsync +vsync
xrandr --addmode Virtual-1 1280x800_60.00
xrandr --output Virtual-1 --mode 1280x800_60.00
```

### Method 2: Make it permanent

Create a startup script:

```bash
# Create autostart directory
mkdir -p ~/.config/autostart

# Create desktop file
nano ~/.config/autostart/set-resolution.desktop
```

Add this content:

```ini
[Desktop Entry]
Type=Application
Name=Set Resolution
Exec=xrandr --output Virtual-1 --mode 1280x800
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
```

Save (Ctrl+O, Enter, Ctrl+X) and reboot to test.

## Step 8: Install Project Dependencies

Once you have the project files in place:

```bash
cd ~/home-calendar/backend

# Install Node.js dependencies
npm install

# Verify installation
ls node_modules/  # Should show installed packages
```

## Step 9: Test the Calendar Application

```bash
# Start the backend server
cd ~/home-calendar/backend
npm start
```

You should see:
```
Calendar server running on http://localhost:3000
Setup wizard available at http://localhost:3000/setup.html
```

Open Chromium browser:
```bash
chromium http://localhost:3000/setup.html
```

## Step 10: Test Kiosk Mode (Optional)

To test how it will look in kiosk mode:

```bash
# Stop the server (Ctrl+C in terminal)

# Run kiosk setup script
cd ~/home-calendar
chmod +x scripts/setup-kiosk.sh
./scripts/setup-kiosk.sh

# Reboot to test
sudo reboot
```

After reboot, the calendar should auto-start in fullscreen.

## Differences Between VM and Raspberry Pi

| Feature | VirtualBox VM | Raspberry Pi |
|---------|--------------|--------------|
| **Performance** | Faster (depends on host CPU) | Slower but adequate |
| **Display** | Simulated 1280x800 | Real HDMI 1280x800 touchscreen |
| **Touch Input** | Mouse simulation | Actual capacitive touch |
| **WiFi** | Virtual network adapter | Built-in WiFi chip |
| **GPIO** | Not available | Available (can add buttons) |
| **Power** | Host computer powered | 5V 3A USB-C adapter |
| **Boot time** | 20-30 seconds | 30-45 seconds |
| **Portability** | Not portable | Fully portable |

## Tips for Development

### Quick Testing Cycle

1. Edit files on host machine (share folder with VM)
2. Restart server in VM
3. Refresh browser
4. Repeat

### Shared Folders (Optional)

Set up VirtualBox shared folders to edit on host:

1. VM → Settings → Shared Folders
2. Add folder: Select your home-calendar directory
3. Name: `calendar-dev`
4. Auto-mount: Yes
5. In VM: Access at `/media/sf_calendar-dev`

### Snapshots

Create snapshots at key points:

- **Clean Install**: Right after Debian installation
- **Dependencies Installed**: After installing Node, Git, etc.
- **Working Application**: After calendar works

To create snapshot:
- VM → Machine → Take Snapshot
- Name it clearly (e.g., "Clean with Node.js installed")

## Troubleshooting

### VM is slow

**Solutions**:
- Increase RAM to 4GB in VM settings
- Increase CPU cores to 4
- Enable 3D acceleration in Display settings
- Use LXDE instead of GNOME (lighter)
- Close other applications on host

### Network not working

**Check**:
```bash
# Check network status
ip addr show

# Test internet
ping -c 4 google.com

# Restart network
sudo systemctl restart NetworkManager
```

### Screen resolution won't change

**Try**:
```bash
# Install VirtualBox Guest Additions
sudo apt install virtualbox-guest-utils virtualbox-guest-x11
sudo reboot
```

### Can't install Node.js from script

**Alternative**:
```bash
# Download manually from nodejs.org
wget https://nodejs.org/dist/v18.19.0/node-v18.19.0-linux-x64.tar.xz
tar -xf node-v18.19.0-linux-x64.tar.xz
sudo mv node-v18.19.0-linux-x64 /usr/local/nodejs
echo 'export PATH=/usr/local/nodejs/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### Browser won't start in kiosk mode

**Check**:
```bash
# Test manually
chromium --kiosk --noerrdialogs --disable-infobars http://localhost:3000

# Check autostart
cat ~/.config/lxsession/LXDE/autostart
```

### Server won't start

**Check**:
```bash
# Verify Node.js works
node --version

# Check for errors
cd ~/home-calendar/backend
npm start

# Check if port 3000 is already in use
sudo netstat -tlnp | grep 3000
```

## Performance Testing

Test calendar performance:

```bash
# Monitor system resources
htop  # (install with: sudo apt install htop)

# Check memory usage
free -h

# Check CPU usage while calendar running
top
```

The VM should use:
- **RAM**: 200-400MB for calendar app
- **CPU**: 5-15% average, spikes during refresh

## Next Steps

1. ✅ VirtualBox VM is ready
2. → Build the calendar application
3. → Test calendar sync with Google Calendar
4. → Test WiFi setup UI
5. → Test kiosk mode
6. → Document any issues
7. → Purchase Raspberry Pi hardware
8. → Deploy to production

## Useful Commands Reference

```bash
# System
sudo reboot                    # Restart VM
sudo shutdown -h now          # Shutdown VM
sudo apt update && sudo apt upgrade -y  # Update system

# Project
cd ~/home-calendar/backend    # Go to project
npm start                      # Start server
npm install                    # Install dependencies

# Browser
chromium http://localhost:3000  # Open calendar
chromium --kiosk http://localhost:3000  # Kiosk mode

# Network
ip addr show                   # Show IP addresses
ping google.com                # Test internet
```

## Resources

- [VirtualBox Manual](https://www.virtualbox.org/manual/)
- [Debian Documentation](https://www.debian.org/doc/)
- [Node.js Documentation](https://nodejs.org/docs/)
- [Chromium Command Line Switches](https://peter.sh/experiments/chromium-command-line-switches/)
