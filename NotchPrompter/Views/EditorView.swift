//
//  EditorView.swift
//  NotchPrompter
//
//  Professional script editor with intuitive playback controls.
//

import SwiftUI
import AppKit

struct EditorView: View {

    @ObservedObject var appState: AppState
    @ObservedObject var prompterEngine: PrompterEngine

    @FocusState private var isEditorFocused: Bool

    /// Opens the Settings window via AppDelegate.
    private func openSettingsWindow() {
        (NSApp.delegate as? AppDelegate)?.showSettingsWindow()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main Toolbar
            toolbarView
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Script Editor
            editorView

            Divider()

            // Footer with status and shortcuts
            footerView
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(minWidth: 500, minHeight: 400)
    }

    // MARK: - Toolbar

    private var toolbarView: some View {
        HStack(spacing: 16) {
            // Playback Controls
            HStack(spacing: 8) {
                Button(action: { prompterEngine.togglePlayPause() }) {
                    Image(systemName: appState.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.borderedProminent)
                .tint(appState.isPlaying ? .orange : .blue)
                .keyboardShortcut(.space, modifiers: [.command, .shift])

                Button(action: { prompterEngine.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 12, weight: .medium))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.bordered)
                .help("Reset scroll position")
            }

            Divider()
                .frame(height: 24)

            // Speed Control
            HStack(spacing: 8) {
                Image(systemName: "gauge.with.needle")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))

                Slider(
                    value: $appState.scrollSpeed,
                    in: AppSettings.minScrollSpeed...AppSettings.maxScrollSpeed
                )
                .frame(width: 100)

                Text("\(Int(appState.scrollSpeed))")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 28, alignment: .trailing)
            }
            .help("Scroll speed (px/s)")

            Spacer()

            // Font Size Control
            HStack(spacing: 6) {
                Button(action: { appState.fontSizeDown() }) {
                    Image(systemName: "textformat.size.smaller")
                        .font(.system(size: 10))
                }
                .buttonStyle(.borderless)

                Text("\(Int(appState.fontSize))pt")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 32)

                Button(action: { appState.fontSizeUp() }) {
                    Image(systemName: "textformat.size.larger")
                        .font(.system(size: 10))
                }
                .buttonStyle(.borderless)
            }

            Divider()
                .frame(height: 24)

            // Settings Button
            Button(action: { openSettingsWindow() }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 13))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.bordered)
            .help("Open Settings")
        }
    }

    // MARK: - Editor

    private var editorView: some View {
        TextEditor(text: $appState.scriptText)
            .font(.system(size: 15, weight: .regular, design: .monospaced))
            .scrollContentBackground(.hidden)
            .padding(16)
            .background(Color(NSColor.textBackgroundColor))
            .focused($isEditorFocused)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 16) {
            // Status indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(appState.isPlaying ? Color.green : Color.secondary.opacity(0.5))
                    .frame(width: 8, height: 8)

                Text(appState.isPlaying ? "Playing" : "Paused")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(appState.isPlaying ? .primary : .secondary)
            }

            Spacer()

            // Keyboard shortcuts hint
            Text("⌘⇧Space Play/Pause • ⌘⇧R Reset • ⌘⇧[ ] Speed • ⌘⇧- = Font")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }
}
