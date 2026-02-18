# Architecture

This document describes the architecture of Notch Prompter, including layers, components, and design decisions.

## High-Level Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      App Entry (SwiftUI)                     │
├─────────────────────────────────────────────────────────────┤
│  Menu Bar          │  Editor Panel      │  Prompter Window   │
│  (StatusItem)      │  (NSWindow)        │  (NSPanel)         │
└─────────┬──────────┴─────────┬──────────┴─────────┬──────────┘
          │                    │                    │
          └────────────────────┼────────────────────┘
                               │
┌──────────────────────────────┼──────────────────────────────┐
│                    AppState / ViewModels                     │
│              (ObservableObject, Shared State)                │
├──────────────────────────────┼──────────────────────────────┤
│                    PrompterEngine                            │
│         (Scroll logic, timer, position calculation)          │
├──────────────────────────────┼──────────────────────────────┤
│                    WindowManager                             │
│     (NSPanel setup, positioning, notch detection)            │
├──────────────────────────────┼──────────────────────────────┤
│                    SettingsManager                           │
│              (UserDefaults persistence)                      │
└──────────────────────────────┴──────────────────────────────┘
```

## Layer Separation

### 1. UI Layer (SwiftUI)

- **PrompterView** — Renders the scrolling text inside the floating panel
- **EditorView** — Text editor for script input
- **SettingsView** — Controls for speed, font size, opacity, blur
- **MenuBarView** — Status item menu with quick actions

All UI is declarative SwiftUI. AppKit bridges are used only where SwiftUI cannot achieve the required behavior (e.g., NSPanel, NSStatusItem).

### 2. Window Manager

Responsible for:

- Creating and configuring the `NSPanel` (borderless, transparent, floating)
- Positioning at top-center of primary display
- Snapping to notch/camera region
- Setting `level` for always-on-top
- Configuring click-through (ignores mouse events) when locked
- Handling multi-monitor geometry

Uses `NSWindow`/`NSPanel` APIs and `NSScreen` for display geometry. No third-party libraries.

### 3. Prompter Engine

Responsible for:

- Managing scroll state (idle, playing, paused)
- Computing visible text based on scroll position and viewport height
- Driving smooth animation via `Timer` or `CADisplayLink`-style updates
- Supporting variable scroll speed
- Handling reset and position jumps

The engine is **decoupled** from the UI: it exposes state (e.g., `scrollOffset`, `isPlaying`) that views observe. This keeps logic testable and UI reusable.

### 4. Settings / Persistence

- **SettingsManager** — Wraps `UserDefaults` (keys in `AppSettings`) for:
  - Script text
  - Scroll speed
  - Font size
  - Opacity
  - Blur on/off
  - Mirror text on/off
  - Window dimensions (width, height)
  - Last window position (for multi-monitor)

Settings are read at launch and written when changed. No iCloud, no sync—everything is local.

## Data Flow

1. **User edits script** → `EditorView` → `AppState.scriptText` → `SettingsManager.save()`
2. **User presses Play** → Menu/Shortcut → `AppState.isPlaying = true` → `PrompterEngine.start()`
3. **Engine ticks** → `scrollOffset` increases → `PrompterView` re-renders visible text
4. **User changes speed** → Slider/Shortcut → `AppState.scrollSpeed` → Engine updates timer interval
5. **Window moves** → `WindowManager` recalculates frame → Panel `setFrameOrigin` / `setFrame`

## Design Decisions

### Why NSPanel instead of NSWindow?

- `NSPanel` is designed for auxiliary, floating UI
- Better default behavior for “utility” windows
- Integrates well with `NSWindowLevel` for always-on-top

### Why ObservableObject for shared state?

- SwiftUI’s natural state management
- Single source of truth for script, speed, play state
- Easy to inject into multiple views (Prompter, Editor, Menu)

### Why Timer for scrolling instead of Animation?

- Teleprompter scrolling needs precise control over pixels per second
- `Animation` is time-based; we need distance-based scroll
- Timer allows variable speed and pause without animation state conflicts

### Why no third-party dependencies?

- Keeps the app lightweight and fast
- No supply-chain or license risks
- Easier to maintain and audit
- Apple frameworks cover all needs

## Threading Model

- **Main thread**: All UI updates, window operations, engine ticks
- **Background**: None required for core functionality; UserDefaults is synchronous but fast for small payloads

For future enhancements (e.g., large script files), consider moving UserDefaults writes to a background queue.

## Extensibility

- **New settings**: Add key to `SettingsManager`, UI control, and persistence
- **New shortcuts**: Register in `AppDelegate` or `Settings` → Keyboard Shortcuts
- **New window type**: Create another `WindowManager`-style component with its own `NSWindow`/`NSPanel`
- **Themes**: Extract colors/opacity into a `Theme` type; plug into `PrompterView`
