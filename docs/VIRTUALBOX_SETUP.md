# VirtualBox Development Environment Setup

This guide will help you set up a complete development environment in VirtualBox to build and test the home calendar system before purchasing hardware.

## Prerequisites

- **VirtualBox** installed ([Download here](https://www.virtualbox.org/wiki/Downloads))
- **8GB+ RAM** on host machine (will allocate 2GB to VM)
- **20GB+ free disk space**

## Step 1: Download Debian ISO

1. Go to https://www.debian.org/download
2. Download **Debian 12 (Bookworm) - netinst** ISO (smaller, ~600MB)
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
- **Processor**: Allocate 2 CPUs
- **Enable PAE/NX**: Checked

### Display Tab
- **Video Memory**: 128 MB
- **Graphics Controller**: VMSVGA
- **Resolution**: 1280x800 (simulates 10" screen)

### Network Tab
- **Adapter 1**:
  - **Enable Network Adapter**: Checked
  - **Attached to**: NAT
- **Adapter 2**:
  - **Enable Network Adapter**: Checked
  - **Attached to**: Bridged Adapter
  - This allows VM to access internet like the Pi will

### Storage Tab
- Click on **Empty** under Controller: IDE
- Click disk icon on right → **Choose a disk file**
- Select the Debian ISO you downloaded
- Click **OK**

## Step 4: Install Debian

1. Start the VM (click **Start**)
2. At boot menu, select **Graphical Install**

### Installation Steps

**Select a language**: English (or your preference)
**Select your location**: Your country
**Configure keyboard**: Your keyboard layout

**Configure network**:
- Let it auto-configure via DHCP
- **Hostname**: `homecalendar`
- **Domain name**: Leave blank

**Set up users and passwords**:
- **Root password**: Create a strong password (write it down!)
- **Full name**: Your name
- **Username**: `calendar`
- **Password**: Create a password (write it down!)

**Partition disks**:
- Select **Guided - use entire disk**
- Select the virtual disk
- Choose **All files in one partition**
- Select **Finish partitioning**
- Confirm: **Yes**

**Configure package manager**:
- **Scan extra installation media**: No
- **Debian archive mirror country**: Your country
- **Mirror**: `deb.debian.org` (default)
- **HTTP proxy**: Leave blank

**Configure popularity contest**: No

**Software selection**:
- ✅ **Debian desktop environment**
- ✅ **GNOME** (or **LXDE** for lighter weight)
- ✅ **web server**
- ✅ **SSH server**
- ✅ **standard system utilities**
- (Uncheck everything else)

**Install GRUB bootloader**:
- **Yes** to install GRUB
- Select `/dev/sda`

**Finish installation**:
- Click **Continue** to reboot

## Step 5: First Boot and System Setup

1. VM will reboot
2. Login with username `calendar` and your password
3. Open **Terminal** (should be in applications menu)

### Update System

```bash
sudo apt update
sudo apt upgrade -y
```

### Install Required Software

```bash
# Install Node.js (v18 LTS)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install Git
sudo apt install -y git

# Install development tools
sudo apt install -y build-essential curl wget vim

# Install Chromium browser (for kiosk mode)
sudo apt install -y chromium chromium-browser

# Install network tools
sudo apt install -y network-manager wpasupplicant

# Verify installations
node --version   # Should show v18.x.x
npm --version    # Should show 9.x.x or higher
git --version    # Should show git version
```

## Step 6: Clone and Setup Project

```bash
# Create project directory
cd ~
git clone <your-repo-url> home-calendar
cd home-calendar

# Install backend dependencies
cd backend
npm install
cd ..

# Make scripts executable
chmod +x scripts/*.sh
```

## Step 7: Configure Display Resolution

To simulate a 10" display (1280x800):

```bash
# Edit GRUB
sudo nano /etc/default/grub

# Find line: GRUB_CMDLINE_LINUX_DEFAULT="quiet"
# Change to: GRUB_CMDLINE_LINUX_DEFAULT="quiet video=1280x800"

# Save (Ctrl+O, Enter, Ctrl+X)

# Update GRUB
sudo update-grub

# Reboot
sudo reboot
```

## Step 8: Test the Calendar Application

After the project is built (next steps), you'll test it:

```bash
cd ~/home-calendar/backend
npm start
```

Then open Chromium browser and go to: `http://localhost:3000`

## Step 9: Simulate Kiosk Mode (Optional)

To test kiosk mode in the VM:

```bash
cd ~/home-calendar
./scripts/setup-kiosk.sh
```

This will configure Chromium to auto-start in kiosk mode on boot.

## Differences Between VM and Raspberry Pi

| Feature | VirtualBox VM | Raspberry Pi |
|---------|--------------|--------------|
| Performance | Faster (depends on host) | Slower but adequate |
| Display | Simulated resolution | Actual HDMI display |
| Touch | Mouse simulation | Actual touchscreen |
| WiFi | Bridged network | Built-in WiFi |
| GPIO | Not available | Available (future) |
| Power | Host powered | 5V USB-C |

## Next Steps

1. ✅ VM is ready for development
2. → Build the calendar application (see main README)
3. → Test calendar sync
4. → Test kiosk mode
5. → Once satisfied, deploy to Raspberry Pi

## Troubleshooting

### VM is slow
- Increase RAM to 4GB in VM settings
- Increase CPU cores to 2-4
- Use LXDE instead of GNOME (lighter desktop)

### Network not working
- Check VM Network settings (use Bridged Adapter)
- Restart network: `sudo systemctl restart NetworkManager`

### Screen resolution wrong
- Try setting manually:
  ```bash
  xrandr --output Virtual-1 --mode 1280x800
  ```

### Can't install Node.js
- Manually download from nodejs.org
- Or use NVM (Node Version Manager)

## Snapshot Your VM

Once everything is working, create a snapshot:

1. VM → Machine → Take Snapshot
2. Name: "Clean Development Environment"
3. This lets you restore if something breaks

## Resources

- [VirtualBox Documentation](https://www.virtualbox.org/manual/)
- [Debian Documentation](https://www.debian.org/doc/)
- [Node.js Documentation](https://nodejs.org/docs/)
