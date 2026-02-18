# Notch Prompter — Documentation

Documentation for the Notch Prompter macOS app. Start with the [main README](../README.md) for an overview.

## Documentation Index

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | System architecture, layer separation, data flow, design decisions |
| [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) | File layout, module responsibilities, dependencies |
| [WINDOW_MANAGEMENT.md](WINDOW_MANAGEMENT.md) | Window positioning, notch alignment, click-through, always-on-top |
| [FEATURES.md](FEATURES.md) | Feature specifications and behavior |
| [SETUP.md](SETUP.md) | Build, run, and development setup in Xcode |

## Reading Order

1. **README.md** (root) — Overview and quick start
2. **SETUP.md** — Get the app building and running
3. **ARCHITECTURE.md** — Understand how it’s built
4. **PROJECT_STRUCTURE.md** — Navigate the codebase
5. **WINDOW_MANAGEMENT.md** — Deep dive on window behavior
6. **FEATURES.md** — Feature details and specs

## No Third-Party Dependencies

This app uses only:

- Swift Standard Library
- SwiftUI
- AppKit
- Foundation
- Combine

No SPM packages, CocoaPods, Carthage, or external SDKs.
