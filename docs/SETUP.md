# Setup & Run Instructions

This document describes how to build, run, and develop Notch Prompter locally in Xcode.

## Prerequisites

- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 15.0 or later (from Mac App Store or Apple Developer)
- **No third-party dependencies** — the project uses only Apple frameworks

## Project Structure (Expected)

After scaffolding, the project will look like:

```
NotchPrompter/
├── NotchPrompter.xcodeproj
├── NotchPrompter/
│   ├── NotchPrompterApp.swift      # App entry point
│   ├── AppDelegate.swift               # App lifecycle, menu bar, shortcuts
│   ├── Models/
│   │   └── Settings.swift              # UserDefaults keys, settings model
│   ├── Views/
│   │   ├── PrompterView.swift          # Floating prompter text
│   │   ├── EditorView.swift            # Script editor
│   │   └── SettingsView.swift          # Controls panel
│   ├── Managers/
│   │   ├── WindowManager.swift         # NSPanel setup, positioning
│   │   ├── PrompterEngine.swift        # Scroll logic
│   │   └── SettingsManager.swift       # Persistence
│   └── Resources/
│       └── Assets.xcassets             # App icon, colors
└── docs/                               # Documentation
```

## Build & Run

### 1. Open the Project

```bash
cd /path/to/notch-prompter
open NotchPrompter.xcodeproj
```

Or in Xcode: **File → Open** and select `NotchPrompter.xcodeproj`.

### 2. Select Destination

- In the Xcode toolbar, choose **My Mac** (or your Mac’s name) as the run destination
- Ensure the scheme is **NotchPrompter** (not a test or other target)

### 3. Build

- Press **⌘B** or use **Product → Build**
- Resolve any signing or capability issues if prompted (see below)

### 4. Run

- Press **⌘R** or use **Product → Run**
- The app will launch; look for the menu bar icon
- Use the menu bar to open the editor, start/pause, or quit

## Signing & Capabilities

### Signing

- **Development**: Use your Apple ID under **Signing & Capabilities**
- **Team**: Select your personal team (or None for local only)
- **Bundle Identifier**: e.g. `com.yourname.NotchPrompter`

No special entitlements are required for basic functionality. The app:

- Does not use network
- Does not use sandbox-restricted APIs beyond normal window/UI
- Uses `UserDefaults` (allowed in sandbox)
- May need **Accessibility** or **Screen Recording** only if you add features that control other apps or capture screen—not for the base teleprompter

### Entitlements (Optional)

If you enable App Sandbox:

- **User Selected File** (Read/Write): Only if you add file import/export for scripts
- No network or other entitlements needed for core features

## Global Keyboard Shortcuts

The app registers global shortcuts. On first run, macOS may prompt for **Accessibility** permission so the app can receive key events when not focused.

If shortcuts don’t work:

1. Open **System Settings → Privacy & Security → Accessibility**
2. Add **NotchPrompter** (or Xcode while debugging) to the list
3. Enable the checkbox
4. Restart the app

## Running from Terminal

You can also build and run from the command line:

```bash
cd /path/to/notch-prompter
xcodebuild -scheme NotchPrompter -configuration Debug build
open build/Debug/NotchPrompter.app
```

Or use `xcodebuild` with `-destination` for more control.

## Debugging

- Set breakpoints in Xcode as usual
- Use **View → Debug Area → Activate Console** for logs
- Use `print()` or `os.log` for runtime debugging
- To inspect the NSPanel: break when the window is shown and inspect `panel.frame`, `panel.level`, etc.

## Troubleshooting

| Issue | Possible Fix |
|-------|--------------|
| Window not visible | Check `panel.level` and `panel.alphaValue`; ensure it’s on the correct screen |
| Window steals focus | Verify `ignoresMouseEvents` and non-activating configuration |
| Shortcuts not working | Add app to Accessibility in System Settings |
| Wrong screen | Ensure `NSScreen.main` is correct; add display selection in settings if needed |
| Build fails | Ensure deployment target is macOS 13+ and all files are in the target |

## Deployment Target

- Set **macOS Deployment Target** to **13.0** in the project settings
- This allows use of modern SwiftUI and AppKit APIs

## No Third-Party Integrations

The project intentionally uses **no**:

- Swift Package Manager dependencies
- CocoaPods
- Carthage
- SPM remote packages

Everything is implemented with:

- Swift Standard Library
- SwiftUI
- AppKit
- Foundation
- Combine (for observation)
