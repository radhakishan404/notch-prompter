# Notch Prompter

[![CI](https://github.com/radhakishan404/notch-prompter/actions/workflows/ci.yml/badge.svg)](https://github.com/radhakishan404/notch-prompter/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-black)](https://www.apple.com/macos)

A native macOS teleprompter that stays aligned to the notch/camera area, so you can read scripts naturally during calls, demos, and recordings.

## Highlights

- Notch-aligned floating window
- Always-on-top with optional click-through behavior
- Smooth auto-scroll with adjustable speed
- Global shortcuts for playback and controls
- Privacy mode to hide from screen sharing/recording
- Offline-first: no account, no telemetry, no network dependency

## Requirements

- macOS 13.0+
- Xcode 15.0+ (for development)

## Download And Install

Install from the latest release:

1. Open the [latest release](https://github.com/radhakishan404/notch-prompter/releases/latest).
2. Download `NotchPrompter.dmg`.
3. Open the DMG and drag `NotchPrompter.app` to `Applications`.
4. Launch the app.
5. Grant Accessibility permission when prompted so global shortcuts work in other apps.

## Quick Start

```bash
git clone https://github.com/radhakishan404/notch-prompter.git
cd notch-prompter
open NotchPrompter.xcodeproj
```

Then in Xcode:

1. Select the `NotchPrompter` scheme
2. Choose `My Mac`
3. Press `Cmd+R`

## Build From Terminal

```bash
xcodebuild \
  -project NotchPrompter.xcodeproj \
  -scheme NotchPrompter \
  -configuration Debug \
  -destination 'platform=macOS' \
  build
```

## Keyboard Shortcuts

- `Cmd+Shift+Space`: Play/Pause
- `Cmd+Shift+E`: Open Editor
- `Cmd+Shift+R`: Reset
- `Cmd+Shift+]`: Increase speed
- `Cmd+Shift+[` : Decrease speed
- `Cmd+Shift+=`: Increase font size
- `Cmd+Shift+-`: Decrease font size

## Documentation

- [Setup](docs/SETUP.md)
- [Installation Guide](INSTALL.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Project Structure](docs/PROJECT_STRUCTURE.md)
- [Window Management](docs/WINDOW_MANAGEMENT.md)
- [Features](docs/FEATURES.md)
- [Troubleshooting](TROUBLESHOOTING.md)
- [Screen Share Protection](SCREEN_SHARE_PROTECTION.md)

## Open Source

- [Contributing Guide](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Security Policy](SECURITY.md)

## License

MIT License. See [LICENSE](LICENSE).
