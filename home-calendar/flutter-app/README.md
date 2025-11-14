# Home Calendar - Flutter App

A beautiful, user-friendly calendar display app for Android and iOS tablets. Perfect for wall-mounted displays showing family schedules.

## Features

✨ **Native Calendar Integration**
- Syncs with device calendars (Google, Apple, Exchange, etc.)
- No complex URL setup required
- Works with all calendar accounts on the device

🎨 **Beautiful UI**
- Week view optimized for 10" landscape displays
- Color-coded multi-calendar support
- Touch-friendly navigation

⚙️ **Easy Setup**
- Simple wizard guides users through calendar selection
- No technical knowledge required
- Works out of the box on any Android/iOS device

🔄 **Auto-Refresh**
- Configurable refresh intervals (1-30 minutes)
- Always shows up-to-date events
- Works offline with cached events

🔒 **Kiosk Mode** (Android)
- Can be set as home screen launcher
- Prevents accidental exits
- Perfect for dedicated calendar displays

## Prerequisites

- **Flutter SDK**: 3.0 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Android Studio** or **Xcode** (for building)
- **Android device** (Android 7.0+) or **iOS device** (iOS 12+)

## Installation

### 1. Install Flutter

Follow the official guide: https://docs.flutter.dev/get-started/install

### 2. Clone and Setup

```bash
cd home-calendar/flutter-app

# Get Flutter dependencies
flutter pub get

# Generate code (for Hive adapters)
flutter pub run build_runner build
```

### 3. Run on Device

**Android:**
```bash
# Connect Android device via USB (enable USB debugging)
# OR start Android emulator

flutter run
```

**iOS:**
```bash
# Connect iPhone/iPad via USB
# OR start iOS simulator

flutter run
```

## Building for Production

### Android APK

```bash
# Build APK (for testing)
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
# Build App Bundle
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS IPA (for App Store)

```bash
# Open Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select "Any iOS Device" as target
# 2. Product → Archive
# 3. Distribute App → App Store Connect
```

## Configuration for Commercial Product

### 1. Change App Identity

**Android** (`android/app/build.gradle`):
```gradle
defaultConfig {
    applicationId "com.yourcompany.homecalendar"  // Change this
    minSdkVersion 24
    targetSdkVersion 34
    versionCode 1
    versionName "1.0.0"
}
```

**iOS** (in Xcode):
- Open `ios/Runner.xcworkspace`
- Select Runner → General → Bundle Identifier
- Change to: `com.yourcompany.homecalendar`

### 2. Update App Name and Icon

**App Name:**
- Android: Edit `android/app/src/main/AndroidManifest.xml`
  ```xml
  <application
      android:label="Your Calendar Name"
  ```

- iOS: Edit `ios/Runner/Info.plist`
  ```xml
  <key>CFBundleDisplayName</key>
  <string>Your Calendar Name</string>
  ```

**App Icon:**
- Use [App Icon Generator](https://appicon.co/)
- Replace icons in:
  - Android: `android/app/src/main/res/mipmap-*/`
  - iOS: `ios/Runner/Assets.xcassets/AppIcon.appleicon set/`

### 3. Sign the App

**Android:**

Create `android/key.properties`:
```properties
storePassword=yourStorePassword
keyPassword=yourKeyPassword
keyAlias=yourKeyAlias
storeFile=/path/to/your/keystore.jks
```

Update `android/app/build.gradle`:
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

**iOS:**
- Open `ios/Runner.xcworkspace` in Xcode
- Select Runner → Signing & Capabilities
- Select your Team
- Xcode will automatically manage provisioning

## Pre-Loading on Tablets for Sale

### Option A: Manual Installation

1. **Build APK** (Android):
   ```bash
   flutter build apk --release
   ```

2. **Install on each tablet**:
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

3. **Set as kiosk** (optional):
   - Install a kiosk launcher from Play Store
   - Set Home Calendar as the kiosk app

### Option B: Custom ROM/Factory Image (Advanced)

For selling 100+ units:
1. Create a custom Android ROM with your app pre-installed
2. Flash to tablets before shipping
3. Requires Android development expertise

### Option C: Mobile Device Management (MDM)

For enterprise/bulk deployments:
1. Use MDM solution (Samsung Knox, Google Workspace, etc.)
2. Push app remotely to all devices
3. Configure kiosk mode remotely

## Setting Up Kiosk Mode

### Android Kiosk Mode

**Method 1: Using App as Launcher** (Simplest)

The app is already configured to be selectable as a launcher. After installation:
1. Press Home button
2. Select "Home Calendar"
3. Tap "Always"

**Method 2: Using Third-Party Kiosk App**

1. Install [Fully Kiosk Browser](https://www.fully-kiosk.com/) or similar
2. Set Home Calendar as the app to launch
3. Configure kiosk settings (disable back button, hide status bar, etc.)

**Method 3: Android Enterprise (Most Secure)**

For commercial deployments:
1. Enroll device in Android Enterprise
2. Use EMM/MDM to set single-app kiosk mode
3. Lock device to Home Calendar app

### iOS Guided Access (Kiosk Mode)

iOS doesn't allow custom launcher apps, but you can use Guided Access:

1. **Enable Guided Access**:
   - Settings → Accessibility → Guided Access → On
   - Set a passcode

2. **Lock to Home Calendar**:
   - Open Home Calendar app
   - Triple-click Home button (or Side button on newer iPads)
   - Tap "Start"

3. **Exit Guided Access**:
   - Triple-click Home button
   - Enter passcode

## Hardware Recommendations

### For 100% Kiosk/Wall-Mount Use

**Android Tablets:**
- **Budget**: Lenovo Tab M10 Plus (Gen 3) - $150-180
  - 10.6" display, WiFi, good battery
- **Mid-Range**: Samsung Galaxy Tab A8 - $180-230
  - 10.5" display, great build quality
- **Premium**: Samsung Galaxy Tab S9 FE - $350-450
  - 10.9" display, best performance

**iOS Tablets:**
- **iPad (9th Gen)** - $329
  - 10.2" display, most affordable iPad
- **iPad (10th Gen)** - $449
  - 10.9" display, modern design
- **iPad Air** - $599
  - 10.9" display, best value for performance

### Accessories

- **Wall Mount**: ~$20-40
  - Look for VESA-compatible or adhesive mounts
- **Power Cable Management**: ~$10-20
  - Right-angle USB-C cables
  - Cable concealment

## User Setup Instructions

### First-Time Setup (Customer)

1. **Turn on tablet**
2. **Setup wizard will appear automatically**:
   - Welcome screen → Tap "Next"
   - Select calendars to display → Tap checkboxes
   - Tap "Finish"
3. **Calendar displays automatically!**

That's it! No WiFi passwords, no URLs, no complex setup.

### Adding/Removing Calendars Later

1. Tap the **Settings** icon (⚙️) in top right
2. Go to **Calendars** tab
3. Tap **+ Add Calendar** to add more
4. Tap **trash icon** to remove a calendar

### Changing Preferences

1. Tap **Settings** icon
2. Go to **Preferences** tab
3. Adjust:
   - Refresh interval
   - Time format (12h/24h)
   - First day of week
   - Show location/description

## Troubleshooting

### Calendar Permission Denied

**Android:**
- Settings → Apps → Home Calendar → Permissions → Calendar → Allow

**iOS:**
- Settings → Privacy & Security → Calendars → Home Calendar → On

### Events Not Showing

1. Check calendar permissions (above)
2. Verify calendars are selected (Settings → Calendars tab)
3. Check that events exist in device calendar app
4. Try manual refresh (Settings → pull down to refresh)

### App Crashes on Startup

- Uninstall and reinstall app
- Check device OS version (Android 7.0+ or iOS 12+ required)
- Clear app data: Settings → Apps → Home Calendar → Storage → Clear Data

## Development

### Project Structure

```
lib/
├── main.dart                  # App entry point
├── models/
│   ├── calendar_model.dart    # Calendar data model
│   └── event_model.dart       # Event data model
├── screens/
│   ├── home_screen.dart       # Main calendar display
│   ├── setup_screen.dart      # First-time setup wizard
│   └── settings_screen.dart   # Settings & calendar management
├── services/
│   ├── calendar_service.dart  # Native calendar integration
│   └── storage_service.dart   # Local data persistence
└── widgets/
    ├── day_column.dart        # Single day column
    └── event_card.dart        # Event display card
```

### Key Dependencies

- `device_calendar` - Native calendar access
- `hive` - Local storage
- `provider` - State management
- `google_fonts` - Typography
- `intl` - Date/time formatting

### Customization

**Colors:**
Edit `lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFF3788d8), // Change this
  brightness: Brightness.light,
),
```

**Default Calendar Colors:**
Edit `lib/services/storage_service.dart` - look for color arrays.

## Publishing

### Google Play Store

1. **Create Developer Account**: $25 one-time fee
2. **Prepare Store Listing**:
   - Screenshots (tablet landscape)
   - App icon
   - Description
   - Privacy policy URL
3. **Upload App Bundle**:
   ```bash
   flutter build appbundle --release
   ```
4. **Submit for Review**

### Apple App Store

1. **Create Developer Account**: $99/year
2. **Prepare Store Listing** in App Store Connect
3. **Upload IPA** via Xcode or Transporter
4. **Submit for Review**

## Monetization Ideas

1. **Sell Pre-Configured Tablets**
   - Buy tablets wholesale ($80-150 each)
   - Pre-install app and configure kiosk mode
   - Add custom frame
   - Sell for $200-350
   - Profit: $50-150 per unit

2. **Subscription Service** (future enhancement)
   - Add cloud sync
   - Family sharing features
   - $2.99/month or $19.99/year

3. **B2B Enterprise**
   - Office calendar displays
   - Conference room scheduling
   - Custom branding
   - $500-2000 per installation

## Support

For questions or issues, refer to:
- [Flutter Documentation](https://docs.flutter.dev/)
- [device_calendar Plugin](https://pub.dev/packages/device_calendar)

## License

MIT License - Free for commercial use
