# Piano Practice iPad - Build Guide

## Quick Setup Guide for Xcode

### Step 1: Create New Xcode Project

1. Open **Xcode**
2. Select **File → New → Project** (or press ⌘⇧N)
3. Choose **iOS** tab, then select **App**
4. Click **Next**

### Step 2: Configure Project

Fill in the following details:
- **Product Name**: `PianoLearnIPad`
- **Team**: Select your development team
- **Organization Identifier**: `com.yourname` (or any reverse domain)
- **Bundle Identifier**: Will auto-generate as `com.yourname.PianoLearnIPad`
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: None needed
- Uncheck "Use Core Data"
- Uncheck "Include Tests" (optional)

Click **Next**, choose the `piano_learn_ipad` folder as location, then **Create**.

### Step 3: Add Source Files

Xcode will create some default files. Replace/add as follows:

1. **Delete** the auto-generated `PianoLearnIPadApp.swift` and `ContentView.swift`
2. **Add all files** from the current directory:
   - Drag `PianoLearnApp.swift` into the project
   - Drag `ContentView.swift` into the project
   - Drag the entire `Models` folder
   - Drag the entire `Views` folder
   - Make sure "Copy items if needed" is checked
   - Make sure your target is selected

### Step 4: Configure Info.plist

1. In the project navigator, select your project
2. Select the target `PianoLearnIPad`
3. Go to the **Info** tab
4. Add or verify these settings:
   - **Supported interface orientations (iPad)**: All 4 orientations
   - **Launch Screen**: Leave as default

### Step 5: Set Deployment Target

1. Still in target settings, go to **General** tab
2. Under **Deployment Info**:
   - **iOS Deployment Target**: 15.0
   - **Device**: iPad
   - **Supports multiple windows**: Unchecked
   - **Requires full screen**: Unchecked

### Step 6: Build and Run

1. Select your iPad device from the device dropdown (or iPad simulator)
2. Press **⌘R** or click the **Play** button
3. If using a physical iPad:
   - Connect via USB or WiFi
   - Trust the developer certificate on iPad
   - May need to enable "Developer Mode" in Settings

## Troubleshooting

### "Failed to verify bitcode"
- Go to Build Settings
- Search for "Enable Bitcode"
- Set to **No**

### "Signing requires a development team"
- In General tab, select your team under **Signing & Capabilities**
- Or use "Automatically manage signing"

### Audio not playing
- Check iPad is not in silent mode
- Verify volume is up
- Check Privacy settings allow audio

### App crashes on launch
- Verify all source files are included in target
- Check Build Phases → Compile Sources includes all .swift files
- Clean build folder (⌘⇧K) and rebuild

### iPad not appearing in device list
- Make sure iPad is unlocked
- Trust the computer on iPad
- Check cable connection
- Try WiFi pairing in Xcode → Window → Devices and Simulators

## Testing on iPad Simulator

If you don't have a physical iPad:

1. In Xcode, select **Product → Destination → iPad Pro 11-inch (3rd generation)**
2. Press **⌘R** to build and run
3. Simulator will launch with the app

Note: Simulator may have different performance than real hardware.

## App Store Distribution (Optional)

To distribute via TestFlight or App Store:

1. Set up App Store Connect account
2. Create an App ID
3. Configure signing with Distribution certificate
4. Archive the app (Product → Archive)
5. Upload to App Store Connect
6. Submit for TestFlight or review

## Building for Multiple iPads

The app supports all iPad models running iOS 15+. To ensure compatibility:

1. Test on different simulator sizes
2. Verify layouts work in both Portrait and Landscape
3. Check touch targets are appropriate on smaller iPads
4. Test on physical devices if possible

## Development Tips

### Live Preview in Xcode

You can use SwiftUI previews for faster iteration:

```swift
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad Pro (11-inch) (3rd generation)")
    }
}
```

Add this at the bottom of any View file to see live previews.

### Debugging Audio

If audio isn't working:
1. Check device volume
2. Verify AudioManager.shared is initialized
3. Check console for audio engine errors
4. Test with simple sine wave first

### Performance Optimization

For better performance:
- Test on real device, not just simulator
- Profile with Instruments (⌘I)
- Reduce animation complexity if needed
- Optimize audio buffer sizes

## File Structure in Xcode

Your project navigator should look like:

```
PianoLearnIPad
├── PianoLearnApp.swift
├── ContentView.swift
├── Models
│   ├── Note.swift
│   ├── GameEngine.swift
│   ├── PracticeSession.swift
│   └── AudioManager.swift
├── Views
│   ├── StartScreen.swift
│   ├── SummaryScreen.swift
│   ├── PianoView.swift
│   └── StaffView.swift
├── Assets.xcassets
└── Info.plist
```

## Next Steps

Once your app is running:

1. **Test all features**: Try each screen and interaction
2. **Adjust layouts**: Modify spacing/sizes if needed for your iPad
3. **Customize colors**: Change gradients and themes to your preference
4. **Add features**: Extend with your own ideas
5. **Share**: Send to TestFlight for friends to try

Happy coding! 🎹
