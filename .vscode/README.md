# VS Code Launch Configuration

This directory contains VS Code launch configurations for debugging Flutter apps.

## Launch Configurations

- **Flutter: Run on CPH2709** - Runs on your specific device (CPH2709)
- **Flutter: Run (Select Device)** - Prompts you to select a device
- **Flutter: Run (Debug/Profile/Release)** - Runs in different modes

## Troubleshooting F5/CTRL+F5 Getting Stuck

If the app gets stuck at "Installing build/app/outputs/flutter-apk/app-debug.apk...":

1. **Restart ADB server:**
   ```bash
   adb kill-server
   adb start-server
   adb devices
   ```

2. **Clean build:**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Check device connection:**
   ```bash
   flutter devices
   ```

4. **Try uninstalling and reinstalling:**
   ```bash
   adb uninstall com.tiltandplay.tiltandplay
   flutter run -d CPH2709
   ```

5. **Check USB debugging:**
   - Ensure USB debugging is enabled on your phone
   - Try disconnecting and reconnecting the USB cable
   - On your phone, check if there's a "Allow USB debugging" prompt

6. **Use the terminal instead:**
   If F5 still doesn't work, use the terminal command:
   ```bash
   flutter run -d CPH2709
   ```
