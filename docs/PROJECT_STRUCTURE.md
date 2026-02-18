# Project Structure

This document describes the file organization and module layout for Notch Prompter.

## Directory Layout

```
NotchPrompter/
│
├── NotchPrompter.xcodeproj     # Xcode project file
│
├── NotchPrompter/              # Main app target
│   │
│   ├── NotchPrompterApp.swift  # @main entry point, SwiftUI App
│   ├── AppDelegate.swift            # NSApplicationDelegate, menu bar, shortcuts
│   │
│   ├── Models/
│   │   └── Settings.swift           # Settings keys, structs, UserDefaults constants
│   │
│   ├── Views/
│   │   ├── PrompterView.swift       # Floating prompter content (text + background)
│   │   ├── EditorView.swift         # Script text editor
│   │   ├── SettingsView.swift       # Speed, font, opacity, blur controls
│   │   └── Components/              # Optional: reusable UI bits
│   │       └── (empty or minimal)
│   │
│   ├── Managers/
│   │   ├── WindowManager.swift      # NSPanel creation, positioning, notch logic
│   │   ├── PrompterEngine.swift     # Scroll logic, timer, state
│   │   └── SettingsManager.swift    # UserDefaults read/write
│   │
│   ├── AppState/
│   │   └── AppState.swift           # ObservableObject holding shared state
│   │
│   └── Resources/
│       ├── Assets.xcassets          # App icon, colors
│       └── Info.plist               # App metadata (if needed)
│
└── docs/                            # Documentation
    ├── ARCHITECTURE.md
    ├── WINDOW_MANAGEMENT.md
    ├── SETUP.md
    ├── FEATURES.md
    └── PROJECT_STRUCTURE.md
```

## File Responsibilities

### App Entry & Lifecycle

| File | Role |
|------|------|
| `NotchPrompterApp.swift` | `@main`, SwiftUI `App`; creates `AppDelegate` via `UIApplicationDelegateAdaptor` if needed |
| `AppDelegate.swift` | `NSApplicationDelegate`; creates menu bar status item; registers global shortcuts; coordinates window visibility |

### Models

| File | Role |
|------|------|
| `Settings.swift` | `AppSettings` enum: `UserDefaults` keys and default values; no business logic |

### Views (SwiftUI)

| File | Role |
|------|------|
| `PrompterView.swift` | Renders scrolling text; uses `PrompterEngine` state; applies font, opacity, blur, mirror |
| `EditorView.swift` | `TextEditor` or equivalent for script; bindings to `AppState.scriptText`; Play/Pause/Reset buttons |
| `SettingsView.swift` | Sliders and toggles for speed, font size, opacity, blur, mirror; bindings to `AppState` / `SettingsManager` |

### Managers

| File | Role |
|------|------|
| `WindowManager.swift` | Creates `NSPanel`; configures borderless, transparent, always-on-top; positions at top-center; handles click-through |
| `PrompterEngine.swift` | Holds `scrollOffset`, `isPlaying`; drives `Timer`; computes visible text; supports variable speed |
| `SettingsManager.swift` | Reads/writes `UserDefaults`; exposes `@Published` or callback-based API for UI |

### App State

| File | Role |
|------|------|
| `AppState.swift` | `ObservableObject`; holds `scriptText`, `scrollSpeed`, `fontSize`, `opacity`, `blurEnabled`, `mirrorText`, `isPlaying`; bridges between UI and engine/settings |

## Dependencies Between Modules

```
AppDelegate
    ├── WindowManager (creates panel, hosts PrompterView)
    ├── AppState (injected into views)
    └── SettingsManager (load on launch)

PrompterView
    ├── AppState (font, opacity, blur, mirror, script)
    └── PrompterEngine (scrollOffset, visible text)

EditorView
    └── AppState (scriptText, isPlaying, reset)

SettingsView
    └── AppState (all settings)

PrompterEngine
    └── AppState (or callbacks) for script, speed, play state

SettingsManager
    └── UserDefaults
```

## Naming Conventions

- **Views**: `*View` (e.g., `PrompterView`, `EditorView`)
- **Managers**: `*Manager` (e.g., `WindowManager`, `SettingsManager`)
- **Engine**: `PrompterEngine` (domain logic)
- **Models**: Plain nouns (e.g., `Settings`, `PrompterState`)

## Code Style

- SwiftUI: Prefer declarative layout; use `@State`, `@Binding`, `@ObservedObject` appropriately
- AppKit bridges: Isolate in `WindowManager` and `AppDelegate`; keep SwiftUI views AppKit-agnostic where possible
- Comments: Document non-obvious behavior (e.g., why `.floating` level, notch heuristic)
- Modularity: Each manager/engine has a clear responsibility; avoid circular dependencies

## Extension Points

- **New settings**: Add key in `Settings.swift`, property in `AppState`, control in `SettingsView`, persistence in `SettingsManager`
- **New shortcut**: Register in `AppDelegate`; route to `AppState` or `PrompterEngine`
- **New window**: Add another manager (e.g., `EditorWindowManager`) if the editor becomes a separate `NSWindow`
- **Themes**: Introduce `Theme` model and apply in `PrompterView`
