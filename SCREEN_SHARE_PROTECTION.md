# Screen Share Protection - Hide Teleprompter During Screen Sharing

Notch Prompter includes a powerful privacy feature that makes **ALL app windows completely invisible** during screen sharing, recordings, and screenshots. This includes:

- **Teleprompter Window** - The floating prompter display
- **Script Editor** - Where you write and edit your scripts
- **Settings Window** - Your configuration preferences

This is perfect for presentations, meetings, and video calls where you want to read your notes and edit scripts without anyone seeing them.

---

## How It Works

macOS provides a window property called `sharingType` that controls whether a window can be captured:

- **`sharingType = .none`** - Window is **invisible** to all screen capture methods
- **`sharingType = .readOnly`** - Window is **visible** in screen captures (default)

When "Hide from Screen Share" is enabled, Notch Prompter sets **ALL windows'** sharing type to `.none`, making them completely invisible to:

| Application | Hidden? |
|-------------|---------|
| Zoom screen share | Yes |
| Microsoft Teams | Yes |
| Google Meet | Yes |
| Slack Huddles | Yes |
| Discord screen share | Yes |
| QuickTime screen recording | Yes |
| OBS Studio | Yes |
| macOS Screenshot (Cmd+Shift+3/4) | Yes |
| macOS Screen Recording | Yes |
| Any other screen capture app | Yes |

---

## How to Enable/Disable

### Option 1: Settings UI
1. Click the Notch Prompter icon in the menu bar
2. Select "Settings..." (or press ⌘,)
3. Find the **Privacy** section
4. Toggle **"Hide from Screen Share"**

### Option 2: The setting is ON by default
The feature is enabled by default for your privacy. You only see the teleprompter on your physical screen.

---

## Use Cases

### 1. Video Presentations
Present to an audience while reading your script. They see your slides, you see your notes.

### 2. Online Meetings
Participate in Zoom/Teams meetings while referencing your talking points.

### 3. Live Streaming
Stream on Twitch/YouTube while keeping your prompter private from viewers.

### 4. Screen Recording Tutorials
Record tutorials while reading your script without it appearing in the video.

### 5. Sales Demos
Demo your product while following your pitch script invisibly.

---

## Technical Implementation

The implementation uses Apple's native `NSWindow.SharingType` API:

```swift
// In AppDelegate.swift - Applied to ALL windows (Editor, Settings, etc.)

private func applyScreenCaptureProtection(to window: NSWindow) {
    if AppState.shared.hideFromScreenCapture {
        window.sharingType = .none  // Invisible
    } else {
        window.sharingType = .readOnly  // Visible
    }
}

// Automatically applied when any window becomes active
NotificationCenter.default.addObserver(
    forName: NSWindow.didBecomeKeyNotification,
    object: nil,
    queue: .main
) { notification in
    guard let window = notification.object as? NSWindow else { return }
    applyScreenCaptureProtection(to: window)
}
```

```swift
// In WindowManager.swift - Applied to the floating Prompter panel

func updateSharingType(for panel: NSPanel? = nil) {
    let targetPanel = panel ?? self.panel
    if appState.hideFromScreenCapture {
        targetPanel?.sharingType = .none
    } else {
        targetPanel?.sharingType = .readOnly
    }
}
```

This is the same technique used by professional teleprompter apps and password managers to hide sensitive content.

---

## FAQ

### Q: Does this work with all screen sharing apps?
**A:** Yes! This is a macOS system-level feature. Any app that uses the standard screen capture APIs (which is all of them) will not be able to see the window.

### Q: Can someone bypass this protection?
**A:** No. The window content is simply not included in the screen buffer that macOS provides to capture applications. There's no way to capture it programmatically.

### Q: Will this affect my ability to see the teleprompter?
**A:** No. You will always see the teleprompter on your physical display. Only screen captures are affected.

### Q: Does this work on external monitors?
**A:** Yes. The protection applies regardless of which display the teleprompter is on.

### Q: What macOS versions support this?
**A:** This feature works on macOS 10.0 and later (all modern versions).

### Q: Can I take screenshots of the teleprompter for testing?
**A:** Turn off "Hide from Screen Share" in Settings to temporarily allow screenshots.

---

## Testing the Feature

### Test 1: Screenshot
1. Enable "Hide from Screen Share" in Settings
2. Press Cmd+Shift+4 and try to capture the teleprompter area
3. The teleprompter will NOT appear in the screenshot

### Test 2: Screen Recording
1. Open QuickTime Player → File → New Screen Recording
2. Start recording your screen
3. The teleprompter will NOT appear in the recording

### Test 3: Zoom/Teams
1. Start a screen share in Zoom or Teams
2. Ask a colleague to confirm they cannot see the teleprompter
3. The teleprompter will NOT appear in their view

---

## Troubleshooting

### Teleprompter IS visible during screen share
1. Open Settings (⌘,)
2. Ensure "Hide from Screen Share" is **ON** (toggle should be blue/enabled)
3. The setting applies immediately - no restart needed

### Teleprompter is NOT visible but I want to share it
1. Open Settings (⌘,)
2. Turn **OFF** "Hide from Screen Share"
3. The teleprompter will now be visible in screen captures

---

## Privacy Note

This feature is designed to protect your privacy during screen sharing. Notch Prompter:

- Does NOT send any data over the network
- Does NOT require an internet connection
- Does NOT have analytics or tracking
- Stores all data locally on your Mac
- Is 100% open source - you can verify the code yourself

Your scripts and settings never leave your computer.
