# Contributing

Thanks for contributing to Notch Prompter.

## Development Setup

1. Fork and clone the repository.
2. Open `NotchPrompter.xcodeproj` in Xcode.
3. Select the `NotchPrompter` scheme and run on `My Mac`.

## Pull Request Checklist

- Keep changes focused and small.
- Update docs when behavior changes.
- Run a local build before opening a PR:

```bash
xcodebuild -project NotchPrompter.xcodeproj -scheme NotchPrompter -configuration Debug -destination 'platform=macOS' build
```

- Include a clear description of what changed and why.

## Commit Style

Use clear, imperative commit messages, for example:

- `Add manual display selector in settings`
- `Fix panel repositioning on external monitors`

## Reporting Bugs

Open a GitHub issue and include:

- macOS version
- Xcode version
- Reproduction steps
- Expected and actual behavior
- Screenshots/logs if relevant
