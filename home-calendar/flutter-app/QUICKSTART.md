# Quick Start Guide - Home Calendar Flutter App

## For Developers

### 1. Install Flutter

```bash
# macOS/Linux
curl -fsSL https://flutter.dev/setup/install.sh | bash

# Or download from: https://docs.flutter.dev/get-started/install
```

### 2. Setup Project

```bash
cd home-calendar/flutter-app

# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run on Device

```bash
# Android (USB debugging enabled)
flutter run

# iOS (connected via USB)
flutter run

# Or use VS Code/Android Studio with Flutter plugin
```

### 4. Build Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (use Xcode)
open ios/Runner.xcworkspace
```

## For Commercial Product

### Quick Deployment Checklist

- [ ] Change `applicationId` in `android/app/build.gradle`
- [ ] Change Bundle ID in Xcode (iOS)
- [ ] Update app name in manifest files
- [ ] Replace app icon
- [ ] Build release APK/AAB
- [ ] Test on actual tablet hardware
- [ ] Set up Google Play Console account ($25)
- [ ] Create store listing with screenshots
- [ ] Submit for review

### Fastest Path to Market

**Week 1:**
- Customize app (name, icon, colors)
- Build and test on 2-3 tablets
- Create app store listing

**Week 2:**
- Submit to Google Play Store
- Order 10 tablets for testing
- Design packaging/instructions

**Week 3:**
- App approved (usually 1-7 days)
- Receive tablets
- Install app + configure kiosk mode
- Ship to first customers!

### Pre-Loading Apps on Tablets

**Method 1: ADB Install** (< 50 units)
```bash
# Build APK
flutter build apk --release

# Connect tablet via USB
adb devices

# Install
adb install build/app/outputs/flutter-apk/app-release.apk

# Set as launcher (manual on device)
# Home button → Select Home Calendar → Always
```

**Method 2: Play Store** (50+ units)
1. Publish app to Play Store
2. On each tablet: Open Play Store → Search → Install
3. Much faster than ADB for bulk

**Method 3: MDM** (100+ units)
1. Use Samsung Knox, Google Workspace, or other MDM
2. Push app to all devices remotely
3. Configure kiosk settings remotely
4. Best for enterprise

## Customer Setup (Their Experience)

### What They Receive
- Tablet with your app already installed
- Quick start card with 3 steps

### Setup Instructions (Give to Customer)

**Step 1: Turn On**
- Press power button
- App launches automatically

**Step 2: Select Calendars**
- Check the calendars you want to display
- Tap "Finish"

**Step 3: Done!**
- Calendar shows everyone's events
- Updates automatically every 5 minutes

**To add more calendars later:**
- Tap Settings ⚙️ → Calendars → + Add Calendar

## Common Customizations

### Change Primary Color

`lib/main.dart` line 34:
```dart
seedColor: const Color(0xFF3788d8),  // Change hex color
```

### Change Refresh Interval Default

`lib/services/storage_service.dart` line 89:
```dart
'refreshInterval': 5,  // Change from 5 to your preferred minutes
```

### Change Calendar Colors

`lib/services/storage_service.dart` - Look for color arrays

### Lock to Portrait Mode

`lib/main.dart` line 20:
```dart
await SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,  // Change from landscape
]);
```

## Pricing Strategy Examples

### Retail Model
- **Cost**: $120 (tablet) + $30 (frame/packaging) = $150
- **Price**: $299
- **Profit**: $149 per unit
- **Target**: Families, small businesses

### Subscription Model
- **App**: Free on app stores
- **Service**: $4.99/month for cloud sync, family features
- **Target**: Ongoing revenue, larger market

### B2B Model
- **Bundle**: Tablet + Installation + Support
- **Price**: $500-1000 per unit
- **Add-ons**: Custom branding, training
- **Target**: Offices, schools, healthcare

## Marketing Ideas

### Where to Sell
- Etsy (handmade/custom category)
- Amazon (electronics)
- Your own website (Shopify/WooCommerce)
- Facebook Marketplace (local)
- B2B direct sales

### Positioning
- "Never Miss a Family Event Again"
- "The Smart Home Calendar for Busy Families"
- "Replace Your Paper Wall Calendar"
- "Sync Everyone's Schedule in One Place"

### Target Customers
1. **Families** with kids (sports, activities, appointments)
2. **Small Offices** (meeting rooms, shared schedules)
3. **Senior Living** (activities, appointments)
4. **Vacation Rentals** (check-in/out, cleaning schedules)

## Support & FAQ

### How do I update the app after selling?

**Play Store:**
- Build new version with incremented version code
- Upload to Play Store
- Customers auto-update

**Direct Install:**
- Build new APK
- Email download link to customers
- They install over existing app (settings preserved)

### How do I handle customer support?

**Common Issues:**
1. "Events not showing" → Check calendar permissions
2. "App won't start" → Reinstall app
3. "How to add calendar?" → Settings → Calendars → Add

**Create support docs:**
- Video tutorials on YouTube
- FAQ page on your website
- Email support address

### Can I white-label this?

Yes! This is MIT licensed - free for commercial use. You can:
- Change all branding
- Add your logo
- Rename the app
- Sell devices with it pre-installed

Just maintain the MIT license in the source code.

## Next Steps

1. ✅ Get app running on a tablet
2. ✅ Customize branding
3. ✅ Build release APK
4. ✅ Order test tablets
5. ✅ Create store listing
6. ✅ Submit to Play Store
7. 🚀 Launch!

## Resources

- [Flutter Docs](https://docs.flutter.dev/)
- [Google Play Console](https://play.google.com/console)
- [Apple Developer](https://developer.apple.com/)
- [Wholesale Tablets](https://www.alibaba.com/) - Buy in bulk
- [Custom Packaging](https://www.packlane.com/) - Branded boxes

Good luck with your calendar business! 🎉
