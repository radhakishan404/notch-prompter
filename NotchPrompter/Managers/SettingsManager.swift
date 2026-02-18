//
//  SettingsManager.swift
//  NotchPrompter
//
//  Persists and loads user settings via UserDefaults.
//

import Foundation
import Combine

final class SettingsManager: ObservableObject {
    
    static let shared = SettingsManager()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Script

    var scriptText: String {
        get {
            let text = defaults.string(forKey: AppSettings.scriptText)
            return (text?.isEmpty ?? true) ? AppSettings.defaultScript : text!
        }
        set { defaults.set(newValue, forKey: AppSettings.scriptText) }
    }
    
    // MARK: - Scroll Speed
    
    var scrollSpeed: Double {
        get {
            let value = defaults.double(forKey: AppSettings.scrollSpeed)
            return value > 0 ? value : AppSettings.defaultScrollSpeed
        }
        set {
            let clamped = min(max(newValue, AppSettings.minScrollSpeed), AppSettings.maxScrollSpeed)
            defaults.set(clamped, forKey: AppSettings.scrollSpeed)
        }
    }
    
    // MARK: - Font Size
    
    var fontSize: Double {
        get {
            let value = defaults.double(forKey: AppSettings.fontSize)
            return value > 0 ? value : AppSettings.defaultFontSize
        }
        set {
            let clamped = min(max(newValue, AppSettings.minFontSize), AppSettings.maxFontSize)
            defaults.set(clamped, forKey: AppSettings.fontSize)
        }
    }
    
    // MARK: - Opacity
    
    var opacity: Double {
        get {
            let value = defaults.double(forKey: AppSettings.opacity)
            return value > 0 ? value : AppSettings.defaultOpacity
        }
        set {
            let clamped = min(max(newValue, 0.1), 1.0)
            defaults.set(clamped, forKey: AppSettings.opacity)
        }
    }
    
    // MARK: - Blur
    
    var blurEnabled: Bool {
        get { defaults.object(forKey: AppSettings.blurEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: AppSettings.blurEnabled) }
    }
    
    // MARK: - Mirror
    
    var mirrorText: Bool {
        get { defaults.bool(forKey: AppSettings.mirrorText) }
        set { defaults.set(newValue, forKey: AppSettings.mirrorText) }
    }
    
    // MARK: - Window Dimensions
    
    var windowWidth: Double {
        get {
            let value = defaults.double(forKey: AppSettings.windowWidth)
            return value > 0 ? value : AppSettings.defaultWindowWidth
        }
        set {
            let clamped = min(max(newValue, AppSettings.minWindowWidth), AppSettings.maxWindowWidth)
            defaults.set(clamped, forKey: AppSettings.windowWidth)
        }
    }
    
    var windowHeight: Double {
        get {
            let value = defaults.double(forKey: AppSettings.windowHeight)
            return value > 0 ? value : AppSettings.defaultWindowHeight
        }
        set {
            let clamped = min(max(newValue, AppSettings.minWindowHeight), AppSettings.maxWindowHeight)
            defaults.set(clamped, forKey: AppSettings.windowHeight)
        }
    }
    
    // MARK: - Auto Hide

    var autoHideWhenIdle: Bool {
        get { defaults.object(forKey: AppSettings.autoHideWhenIdle) as? Bool ?? true }
        set { defaults.set(newValue, forKey: AppSettings.autoHideWhenIdle) }
    }

    // MARK: - Screen Capture Protection

    var hideFromScreenCapture: Bool {
        get { defaults.object(forKey: AppSettings.hideFromScreenCapture) as? Bool ?? true }
        set { defaults.set(newValue, forKey: AppSettings.hideFromScreenCapture) }
    }
}
