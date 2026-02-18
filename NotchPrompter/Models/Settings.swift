//
//  AppSettings.swift
//  NotchPrompter
//
//  UserDefaults keys and default values for app settings.
//

import Foundation

/// UserDefaults keys and default values. Named to avoid conflict with SwiftUI's Settings scene.
enum AppSettings {

    // MARK: - Keys

    static let scriptText = "scriptText"
    static let scrollSpeed = "scrollSpeed"
    static let fontSize = "fontSize"
    static let opacity = "opacity"
    static let blurEnabled = "blurEnabled"
    static let mirrorText = "mirrorText"
    static let windowWidth = "windowWidth"
    static let windowHeight = "windowHeight"
    static let autoHideWhenIdle = "autoHideWhenIdle"
    static let hideFromScreenCapture = "hideFromScreenCapture"

    // MARK: - Defaults

    static let defaultScrollSpeed: Double = 50      // Slightly slower for readability
    static let minScrollSpeed: Double = 10
    static let maxScrollSpeed: Double = 200

    static let defaultFontSize: Double = 24         // Larger font for better visibility
    static let minFontSize: Double = 14
    static let maxFontSize: Double = 64

    static let defaultOpacity: Double = 0.95
    static let idleOpacity: Double = 0.15           // More subtle when idle

    // Larger default window for better readability
    static let defaultWindowWidth: Double = 380
    static let defaultWindowHeight: Double = 80
    static let minWindowWidth: Double = 200
    static let maxWindowWidth: Double = 600
    static let minWindowHeight: Double = 50
    static let maxWindowHeight: Double = 200

    // MARK: - Default Script

    static let defaultScript = """
        Welcome to Notch Prompter.
        A free, open-source teleprompter for Mac.
        """
}
