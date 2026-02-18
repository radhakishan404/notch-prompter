# Window Management

This document explains how the floating prompter window is implemented: positioning, click-through, always-on-top, and multi-monitor behavior.

## Window Type: NSPanel

We use `NSPanel` (a subclass of `NSWindow`) because:

- Designed for auxiliary, floating interfaces
- Can be configured as non-activating (does not steal focus)
- Supports borderless, transparent, and utility-level display

## Configuration

### Borderless & Transparent

```swift
// Conceptual configuration
panel.styleMask = [.borderless]
panel.isOpaque = false
panel.backgroundColor = .clear
panel.hasShadow = false
```

- **Borderless**: No title bar, no close/minimize buttons
- **Non-opaque**: Allows see-through background
- **Clear backgroundColor**: Transparent by default; content provides its own background

### Always on Top

```swift
panel.level = .floating  // or .statusBar for even higher persistence
```

- **`.floating`**: Stays above normal app windows; good balance of visibility and behavior
- **`.statusBar`**: Stays above most UI; use if `.floating` is insufficient
- **Does NOT steal focus**: `panel.ignoresMouseEvents` when in click-through mode, and we use `NSPanel` with `becomesKeyOnlyIfNeeded` or avoid making it key

### Non-Activating

To prevent the panel from stealing focus when it appears:

```swift
panel.hidesOnDeactivate = false
// NSPanel: set to not become key window when shown
// Use NSWindow.CollectionBehavior or configure so it doesn't take focus
```

We configure the panel so it does **not** become the key window. This keeps focus in your active app (Zoom, OBS, etc.) while the prompter floats on top.

## Click-Through (Ignores Mouse Events)

When "locked" or in prompter-only mode, the window should be **click-through**: mouse clicks pass through to whatever is beneath.

```swift
panel.ignoresMouseEvents = true   // Click-through mode
panel.ignoresMouseEvents = false  // Normal mode (e.g., when editor is open)
```

- **`ignoresMouseEvents = true`**: All mouse events pass through; the window is effectively invisible to the cursor
- **`ignoresMouseEvents = false`**: Window receives clicks (needed for any interactive controls on the panel, if any)

For a pure "display only" prompter, we typically keep `ignoresMouseEvents = true` so it never steals focus or blocks clicks.

## Positioning: Top-Center, Notch-Aligned

### Primary Display

We use the primary (main) display:

```swift
guard let screen = NSScreen.main else { return }
let frame = screen.visibleFrame  // Excludes menu bar and dock
```

### Notch / Camera Region

On MacBooks with a notch:

- The notch is at the top-center of the screen
- Safe area / camera housing varies by model
- We approximate a region that visually aligns with the notch

**Approach 1: Fixed dimensions**  
Use configurable width/height (e.g., 300×60 pt) that fits most notch regions.

**Approach 2: Screen-relative**  
Compute based on `screen.frame` and known notch proportions (Apple doesn’t expose notch geometry, so we use heuristics).

```swift
// Conceptual: center horizontally, align to top
let panelWidth: CGFloat = 280   // Configurable, typical notch width
let panelHeight: CGFloat = 50   // Configurable
let x = screen.visibleFrame.midX - (panelWidth / 2)
let y = screen.visibleFrame.maxY - panelHeight  // Top of visible area
panel.setFrameOrigin(NSPoint(x: x, y: y))
panel.setContentSize(NSSize(width: panelWidth, height: panelHeight))
```

### Non-Notch Macs

On Macs without a notch (e.g., older MacBook, iMac, external monitor):

- Same logic applies: top-center of the visible frame
- The "notch area" is effectively the top-center camera region or a generic top bar
- User can adjust width/height in settings to match their setup

## Multi-Monitor

### Primary vs. All Screens

- **Primary display**: `NSScreen.main` — usually the one with the menu bar
- **All displays**: `NSScreen.screens`

We position the prompter on the **primary display** by default. For "prompter on specific display" we would:

1. Let the user choose a display (e.g., in settings)
2. Use `NSScreen.screens[index]` for that display
3. Compute `visibleFrame` for that screen
4. Position the panel in that screen’s top-center

### Coordinate Space

- `NSScreen.frame` and `visibleFrame` are in **global (screen) coordinates**
- `NSScreen.main?.frame` has origin at bottom-left of the main display
- For multiple displays, origins depend on arrangement in System Settings → Displays
- We always use `visibleFrame` to avoid menu bar and dock

## Persistence

- Store user overrides: width, height, chosen display (if we support it)
- On launch, restore last frame or apply saved dimensions
- Re-apply position when display configuration changes (e.g., plug/unplug monitor)

## Summary

| Concern | Implementation |
|--------|----------------|
| **Always on top** | `panel.level = .floating` (or `.statusBar`) |
| **No focus steal** | Non-activating panel; avoid becoming key window |
| **Click-through** | `panel.ignoresMouseEvents = true` |
| **Transparent** | `isOpaque = false`, `backgroundColor = .clear` |
| **Borderless** | `styleMask = [.borderless]` |
| **Position** | Top-center of primary display’s `visibleFrame` |
| **Notch alignment** | Configurable width/height; center horizontally, align to top |
