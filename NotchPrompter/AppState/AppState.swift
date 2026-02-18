//
//  AppState.swift
//  NotchPrompter
//
//  Shared observable state used by all views and the prompter engine.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    
    // MARK: - Singleton (shared across app)
    
    static let shared = AppState()
    
    // MARK: - Settings Manager
    
    private let settings = SettingsManager.shared
    
    // MARK: - Script & Playback
    
    @Published var scriptText: String {
        didSet { settings.scriptText = scriptText }
    }
    
    @Published var isPlaying: Bool = false
    
    @Published var scrollOffset: CGFloat = 0
    
    // MARK: - Display Settings
    
    @Published var scrollSpeed: Double {
        didSet { settings.scrollSpeed = scrollSpeed }
    }
    
    @Published var fontSize: Double {
        didSet { settings.fontSize = fontSize }
    }
    
    @Published var opacity: Double {
        didSet { settings.opacity = opacity }
    }
    
    @Published var blurEnabled: Bool {
        didSet { settings.blurEnabled = blurEnabled }
    }
    
    @Published var mirrorText: Bool {
        didSet { settings.mirrorText = mirrorText }
    }
    
    @Published var windowWidth: Double {
        didSet { settings.windowWidth = windowWidth }
    }
    
    @Published var windowHeight: Double {
        didSet { settings.windowHeight = windowHeight }
    }
    
    @Published var autoHideWhenIdle: Bool {
        didSet { settings.autoHideWhenIdle = autoHideWhenIdle }
    }

    @Published var hideFromScreenCapture: Bool {
        didSet { settings.hideFromScreenCapture = hideFromScreenCapture }
    }

    // MARK: - Computed
    
    /// Opacity when idle (not playing); lower for "invisible" state
    var effectiveOpacity: Double {
        if autoHideWhenIdle && !isPlaying {
            return AppSettings.idleOpacity
        }
        return opacity
    }
    
    // MARK: - Init
    
    private init() {
        scriptText = settings.scriptText
        scrollSpeed = settings.scrollSpeed
        fontSize = settings.fontSize
        opacity = settings.opacity
        blurEnabled = settings.blurEnabled
        mirrorText = settings.mirrorText
        windowWidth = settings.windowWidth
        windowHeight = settings.windowHeight
        autoHideWhenIdle = settings.autoHideWhenIdle
        hideFromScreenCapture = settings.hideFromScreenCapture
    }
    
    // MARK: - Actions
    
    func reset() {
        scrollOffset = 0
    }
    
    func speedUp() {
        scrollSpeed = min(scrollSpeed + 10, AppSettings.maxScrollSpeed)
    }
    
    func speedDown() {
        scrollSpeed = max(scrollSpeed - 10, AppSettings.minScrollSpeed)
    }
    
    func fontSizeUp() {
        fontSize = min(fontSize + 2, AppSettings.maxFontSize)
    }
    
    func fontSizeDown() {
        fontSize = max(fontSize - 2, AppSettings.minFontSize)
    }
}
