# Feature Specifications

This document describes the behavior and specifications of each feature in Notch Prompter.

---

## Core UI / Behavior

### 1. Floating, Borderless, Transparent Window

- **Type**: `NSPanel` (or custom `NSWindow`)
- **Style**: Borderless, no title bar, no traffic lights
- **Appearance**: Transparent background; content provides its own background (pill/blur)
- **Shadow**: Optional, minimal or none to avoid visual clutter

### 2. Top-Center Positioning

- **Location**: Top-center of the primary display
- **Alignment**: Horizontal center; vertically aligned with top of visible frame (below menu bar)
- **Notch**: Width roughly matches notch/camera area; configurable in settings
- **Multi-monitor**: Uses primary display; future: optional display picker

### 3. Always on Top, No Focus Steal

- **Level**: `NSWindow.Level.floating` or `.statusBar`
- **Focus**: Panel does not become key window; focus stays in the active app (Zoom, OBS, etc.)
- **Behavior**: Floats above other windows without stealing clicks or keyboard focus

### 4. Text Appearance

- **Font**: White, monospaced or system font
- **Background**: Soft black translucent pill or blurred background (`NSVisualEffectView` or custom)
- **Readability**: High contrast for easy reading at a glance

### 5. Smooth Auto-Scrolling

- **Direction**: Vertical, upward (text moves up as in a teleprompter)
- **Smoothness**: Continuous scroll driven by timer or display link
- **Speed**: Adjustable (pixels per second or equivalent)

### 6. Idle State (Low Opacity)

- **When idle**: Reduced opacity so the prompter is subtle when not in use
- **When playing**: Full opacity (or user-defined)
- **Transition**: Smooth fade between idle and active

---

## Features

### Editable Script Text

- **Editor**: Dedicated panel/window with a text field or `NSTextView`/SwiftUI `TextEditor`
- **Content**: Plain text only
- **Persistence**: Saved to `UserDefaults`; restored on launch
- **Access**: Via menu bar “Open Editor” or keyboard shortcut

### Start / Pause / Reset

- **Play**: Starts scrolling from current position (or from top if reset)
- **Pause**: Stops scrolling; preserves position
- **Reset**: Jumps to top; sets scroll position to 0
- **UI**: Buttons in editor/settings; also via menu bar and shortcuts

### Scroll Speed

- **Control**: Slider (e.g., 10–200 pixels/second or similar scale)
- **Shortcuts**: 
  - Speed up (e.g., `⌘+` or `⌘⇧+]`)
  - Slow down (e.g., `⌘-` or `⌘⇧+[`)
- **Persistence**: Saved in settings

### Font Size

- **Range**: e.g., 12–48 pt (configurable)
- **Control**: Slider or stepper
- **Shortcuts**: Increase (`⌘+`), Decrease (`⌘-`) — may need to avoid conflict with speed
- **Persistence**: Saved in settings

### Opacity

- **Range**: 0.0–1.0 (or 0–100%)
- **Control**: Slider
- **Applies to**: Overall window or text/background composite
- **Persistence**: Saved in settings

### Background Blur

- **Toggle**: On/Off
- **When on**: Use `NSVisualEffectView` with `.hudWindow` or `.menu` material
- **When off**: Solid translucent background (e.g., dark gray with alpha)
- **Persistence**: Saved in settings

### Auto-Hide When Not Playing

- **When**: No text is playing (paused or stopped)
- **Behavior**: Window fades to very low opacity or hides completely
- **Trigger**: User-defined; e.g., after N seconds of pause, or immediate
- **Return**: Show when Play is pressed

### Global Keyboard Shortcuts

| Action | Shortcut (suggested) |
|--------|----------------------|
| Play / Pause | `⌘⇧Space` |
| Speed up | `⌘⇧+]` |
| Slow down | `⌘⇧+[` |
| Font size up | `⌘⇧+=` |
| Font size down | `⌘⇧+-` |
| Open Editor | `⌘⇧E` |
| Reset | `⌘⇧R` |

*Implement with `NSEvent.addGlobalMonitorForEvents` or `addLocalMonitorForEvents`; requires Accessibility permission.*

### Optional: Mirror Text

- **Toggle**: Horizontal mirror (flip text left–right)
- **Use case**: Teleprompter with mirror/reflector
- **Implementation**: `scaleX: -1` or equivalent transform on text layer
- **Persistence**: Saved in settings

---

## Window Management

### NSPanel Configuration

- **Borderless**: `styleMask = [.borderless]`
- **Transparent**: `isOpaque = false`, `backgroundColor = .clear`
- **Non-activating**: Does not become key window

### Click-Through (Ignores Mouse Events)

- **When locked**: `ignoresMouseEvents = true` — clicks pass through
- **When editing**: `ignoresMouseEvents = false` if the prompter window has interactive controls
- **Toggle**: Via menu bar or settings

### Notch / Camera Snapping

- **Logic**: Position and size computed from primary screen’s `visibleFrame`
- **Dimensions**: Configurable width/height in settings
- **Recompute**: On launch and when display configuration changes

### Multi-Monitor

- **Default**: Primary display
- **Geometry**: Use `NSScreen.main.visibleFrame` for positioning
- **Future**: Option to choose display in settings

### Persistence (UserDefaults)

Stored keys (conceptual):

| Key | Type | Description |
|-----|------|-------------|
| `scriptText` | String | Full script content |
| `scrollSpeed` | Double | Pixels per second |
| `fontSize` | Double | Font size in points |
| `opacity` | Double | 0.0–1.0 |
| `blurEnabled` | Bool | Background blur on/off |
| `mirrorText` | Bool | Horizontal flip on/off |
| `windowWidth` | Double | Panel width |
| `windowHeight` | Double | Panel height |
| `autoHideWhenIdle` | Bool | Hide when paused |

---

## Menu Bar

### Status Item

- **Icon**: Minimal icon in menu bar (e.g., small “T” or teleprompter symbol)
- **Visibility**: Always visible when app is running

### Menu Items

| Item | Action |
|------|--------|
| Play | Start scrolling |
| Pause | Pause scrolling |
| Open Editor | Show script editor window |
| Settings | Open settings panel (if separate) |
| Quit | Terminate app |

---

## Architecture Summary

- **UI**: SwiftUI views (Prompter, Editor, Settings)
- **Window**: `WindowManager` + `NSPanel`
- **Engine**: `PrompterEngine` for scroll state and position
- **Persistence**: `SettingsManager` + `UserDefaults`
- **State**: Shared `ObservableObject` (e.g., `AppState`) across views

---

## Non-Goals (Out of Scope)

- Cloud sync
- User accounts or login
- Network connectivity
- Third-party SDKs
- Mobile or iPad version
- Cross-platform (Windows, Linux)
