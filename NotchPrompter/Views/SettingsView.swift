//
//  SettingsView.swift
//  NotchPrompter
//
//  Professional settings interface for teleprompter customization.
//

import SwiftUI

struct SettingsView: View {

    @ObservedObject var appState: AppState

    var body: some View {
        Form {
            // Playback Section
            Section {
                settingRow(
                    icon: "gauge.with.needle",
                    iconColor: .blue,
                    title: "Scroll Speed",
                    value: "\(Int(appState.scrollSpeed)) px/s"
                ) {
                    Slider(
                        value: $appState.scrollSpeed,
                        in: AppSettings.minScrollSpeed...AppSettings.maxScrollSpeed,
                        step: 5
                    )
                }
            } header: {
                Label("Playback", systemImage: "play.circle")
            }

            // Text Appearance Section
            Section {
                settingRow(
                    icon: "textformat.size",
                    iconColor: .orange,
                    title: "Font Size",
                    value: "\(Int(appState.fontSize)) pt"
                ) {
                    Slider(
                        value: $appState.fontSize,
                        in: AppSettings.minFontSize...AppSettings.maxFontSize,
                        step: 2
                    )
                }

                Toggle(isOn: $appState.mirrorText) {
                    Label {
                        Text("Mirror Text")
                    } icon: {
                        Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
                            .foregroundColor(.purple)
                    }
                }
                .help("Flip text horizontally for teleprompter mirrors")
            } header: {
                Label("Text", systemImage: "textformat")
            }

            // Window Appearance Section
            Section {
                settingRow(
                    icon: "circle.lefthalf.filled",
                    iconColor: .gray,
                    title: "Opacity",
                    value: "\(Int(appState.opacity * 100))%"
                ) {
                    Slider(value: $appState.opacity, in: 0.2...1.0, step: 0.05)
                }

                Toggle(isOn: $appState.blurEnabled) {
                    Label {
                        Text("Background Blur")
                    } icon: {
                        Image(systemName: "drop.halffull")
                            .foregroundColor(.cyan)
                    }
                }
                .help("Enable frosted glass effect")

                Toggle(isOn: $appState.autoHideWhenIdle) {
                    Label {
                        Text("Fade When Paused")
                    } icon: {
                        Image(systemName: "eye.slash")
                            .foregroundColor(.secondary)
                    }
                }
                .help("Reduce opacity when not playing")
            } header: {
                Label("Appearance", systemImage: "paintbrush")
            }

            // Window Size Section
            Section {
                settingRow(
                    icon: "arrow.left.and.right",
                    iconColor: .green,
                    title: "Width",
                    value: "\(Int(appState.windowWidth)) px"
                ) {
                    Slider(
                        value: $appState.windowWidth,
                        in: AppSettings.minWindowWidth...AppSettings.maxWindowWidth,
                        step: 20
                    )
                }

                settingRow(
                    icon: "arrow.up.and.down",
                    iconColor: .green,
                    title: "Height",
                    value: "\(Int(appState.windowHeight)) px"
                ) {
                    Slider(
                        value: $appState.windowHeight,
                        in: AppSettings.minWindowHeight...AppSettings.maxWindowHeight,
                        step: 10
                    )
                }
            } header: {
                Label("Window Size", systemImage: "rectangle.dashed")
            } footer: {
                Text("Adjust the teleprompter window to fit your display and notch area.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Privacy Section
            Section {
                Toggle(isOn: $appState.hideFromScreenCapture) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Hide from Screen Share")
                            Text("Invisible during Zoom, Teams, recordings")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "eye.slash.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .help("When enabled, the teleprompter is completely invisible during screen sharing, recordings, and screenshots")
            } header: {
                Label("Privacy", systemImage: "lock.shield")
            } footer: {
                Text("Perfect for presentations - only you can see the teleprompter while sharing your screen.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // About Section
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notch Prompter")
                            .font(.headline)
                        Text("Free & Open Source")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("v1.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                }
            } header: {
                Label("About", systemImage: "info.circle")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 400, minHeight: 500)
    }

    // MARK: - Setting Row Helper

    @ViewBuilder
    private func settingRow<Content: View>(
        icon: String,
        iconColor: Color,
        title: String,
        value: String,
        @ViewBuilder control: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .frame(width: 20)
                Text(title)
                Spacer()
                Text(value)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)
            }
            control()
        }
        .padding(.vertical, 2)
    }
}
