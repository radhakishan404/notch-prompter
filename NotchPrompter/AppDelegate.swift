//
//  AppDelegate.swift
//  NotchPrompter
//
//  Menu bar status item, global keyboard shortcuts, and prompter window setup.
//

import AppKit
import SwiftUI
import Combine

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - State

    var statusItem: NSStatusItem?
    var windowManager: WindowManager?
    let prompterEngine: PrompterEngine

    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var windowObserver: Any?
    private var cancellables = Set<AnyCancellable>()

    override init() {
        // Initialize engine in init so it's ready before SwiftUI body runs
        let engine = PrompterEngine()
        engine.appState = AppState.shared
        self.prompterEngine = engine
        super.init()
    }

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {

        let wm = WindowManager(appState: AppState.shared, prompterEngine: prompterEngine)
        windowManager = wm

        // Create floating prompter panel
        wm.createPrompterPanel()

        // Create menu bar icon
        setupStatusItem()

        // Check and request accessibility permissions for global shortcuts
        checkAccessibilityPermissions()

        // Register global shortcuts
        registerShortcuts()

        // Observe window creation to apply screen capture protection
        setupWindowObserver()

        // Observe changes to screen capture setting
        observeScreenCaptureSettingChanges()

        // Hide the default editor window on launch; user opens via menu bar "Open Editor"
        DispatchQueue.main.async {
            NSApp.windows.first { $0.title == "Script Editor" }?.close()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        prompterEngine.pause()
        if let g = globalMonitor { NSEvent.removeMonitor(g) }
        if let l = localMonitor { NSEvent.removeMonitor(l) }
        if let w = windowObserver { NotificationCenter.default.removeObserver(w) }
    }

    // MARK: - Screen Capture Protection for All Windows

    /// Observes when new windows are created and applies screen capture protection
    private func setupWindowObserver() {
        windowObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let window = notification.object as? NSWindow else { return }
            self?.applyScreenCaptureProtection(to: window)
        }

        // Apply to any existing windows
        DispatchQueue.main.async { [weak self] in
            for window in NSApp.windows {
                self?.applyScreenCaptureProtection(to: window)
            }
        }
    }

    /// Observes changes to the screen capture setting and updates all windows
    private func observeScreenCaptureSettingChanges() {
        AppState.shared.$hideFromScreenCapture
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateAllWindowsScreenCaptureProtection()
                }
            }
            .store(in: &cancellables)
    }

    /// Applies screen capture protection to a specific window
    private func applyScreenCaptureProtection(to window: NSWindow) {
        if AppState.shared.hideFromScreenCapture {
            window.sharingType = .none
        } else {
            window.sharingType = .readOnly
        }
    }

    /// Updates screen capture protection for all app windows
    private func updateAllWindowsScreenCaptureProtection() {
        for window in NSApp.windows {
            applyScreenCaptureProtection(to: window)
        }
        // Also update the prompter panel
        windowManager?.updateSharingType()
    }

    // MARK: - Accessibility Permissions

    /// Checks if the app has accessibility permissions and prompts user if not
    private func checkAccessibilityPermissions() {
        // Check without prompting - don't annoy users who already granted permission
        let accessEnabled = AXIsProcessTrusted()
        
        if !accessEnabled {
            // Show a helpful alert
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let alert = NSAlert()
                alert.messageText = "Accessibility Permission Required"
                alert.informativeText = "Notch Prompter needs accessibility access to enable global keyboard shortcuts that work even when other apps are in focus.\n\nPlease grant permission in System Settings > Privacy & Security > Accessibility."
                alert.alertStyle = .informational
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Later")
                
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    // Open System Settings to Accessibility pane
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
    }

    
    // MARK: - Menu Bar
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "text.viewfinder", accessibilityDescription: "Notch Prompter")
            button.toolTip = "Notch Prompter"
        }
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Play", action: #selector(menuPlay), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Pause", action: #selector(menuPause), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Open Editor", action: #selector(menuOpenEditor), keyEquivalent: "e"))
        menu.addItem(NSMenuItem(title: "Settings…", action: #selector(menuSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(menuQuit), keyEquivalent: "q"))
        
        for item in menu.items {
            item.target = self
        }
        
        statusItem?.menu = menu
    }
    
    @objc private func menuPlay() {
        prompterEngine.start()
    }
    
    @objc private func menuPause() {
        prompterEngine.pause()
    }
    
    @objc private func menuOpenEditor() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.title == "Script Editor" }) {
            applyScreenCaptureProtection(to: window)
            window.makeKeyAndOrderFront(nil)
        } else {
            // Create new window via SwiftUI
            let contentView = EditorView(appState: AppState.shared, prompterEngine: prompterEngine)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.title = "Script Editor"
            window.contentView = NSHostingView(rootView: contentView)

            // Apply screen capture protection
            applyScreenCaptureProtection(to: window)

            window.makeKeyAndOrderFront(nil)
        }
    }
    
    @objc private func menuSettings() {
        showSettingsWindow()
    }
    
    /// Shows the Settings window. Uses SwiftUI's Settings scene.
    func showSettingsWindow() {
        print("🔧 showSettingsWindow called")
        NSApp.activate(ignoringOtherApps: true)
        
        // Try to find existing settings window first
        if let settingsWindow = NSApp.windows.first(where: { $0.title.contains("Settings") || $0.title.contains("Preferences") }) {
            print("✅ Found existing settings window")
            settingsWindow.makeKeyAndOrderFront(nil)
            return
        }
        
        // Open the SwiftUI Settings scene using macOS standard API
        print("📱 Attempting to open settings via selector")
        if #available(macOS 14.0, *) {
            NSApp.sendAction(Selector("showSettingsWindow:"), to: nil, from: nil)
        } else {
            // macOS 13 uses the older selector name
            NSApp.sendAction(Selector("showPreferencesWindow:"), to: nil, from: nil)
        }
        
        // Fallback: Create settings window manually if the selector didn't work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if NSApp.windows.first(where: { $0.title.contains("Settings") || $0.title.contains("Preferences") }) == nil {
                print("⚠️ Settings window not found, creating manually")
                let contentView = SettingsView(appState: AppState.shared)
                let window = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: 450, height: 550),
                    styleMask: [.titled, .closable, .miniaturizable],
                    backing: .buffered,
                    defer: false
                )
                window.center()
                window.title = "Settings"
                window.contentView = NSHostingView(rootView: contentView)
                window.makeKeyAndOrderFront(nil)
            } else {
                print("✅ Settings window opened successfully")
            }
        }
    }
    
    @objc private func menuQuit() {
        NSApp.terminate(nil)
    }
    
    // MARK: - Global Shortcuts
    
    private func registerShortcuts() {
        print("🎹 Registering global shortcuts...")
        let flags: NSEvent.ModifierFlags = [.command, .shift]
        
        // Check if we have accessibility permissions
        let hasPermission = AXIsProcessTrusted()
        print("🔐 Accessibility permission status: \(hasPermission)")
        
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            print("🌍 Global key event: keyCode=\(event.keyCode), modifiers=\(event.modifierFlags)")
            self?.handleKeyDown(event)
        }
        
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            print("📍 Local key event: keyCode=\(event.keyCode), modifiers=\(event.modifierFlags)")
            if self?.handleKeyDown(event) == true {
                return nil // Consume
            }
            return event
        }
        
        print("✅ Shortcuts registered. Global monitor: \(globalMonitor != nil), Local monitor: \(localMonitor != nil)")
    }
    
    @discardableResult
    private func handleKeyDown(_ event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        print("⌨️ handleKeyDown: keyCode=\(event.keyCode), flags=\(flags)")
        
        // ⌘⇧Space: Play/Pause
        if event.keyCode == 49 && flags == [.command, .shift] {
            print("▶️ Play/Pause triggered")
            prompterEngine.togglePlayPause()
            return true
        }
        
        // ⌘⇧E: Open Editor
        if event.keyCode == 14 && flags == [.command, .shift] {
            menuOpenEditor()
            return true
        }
        
        // ⌘⇧R: Reset
        if event.keyCode == 15 && flags == [.command, .shift] {
            prompterEngine.reset()
            return true
        }
        
        // ⌘⇧]: Speed up
        if event.keyCode == 30 && flags == [.command, .shift] {
            AppState.shared.speedUp()
            return true
        }
        
        // ⌘⇧[: Slow down
        if event.keyCode == 33 && flags == [.command, .shift] {
            AppState.shared.speedDown()
            return true
        }
        
        // ⌘⇧=: Font size up
        if event.keyCode == 24 && flags == [.command, .shift] {
            AppState.shared.fontSizeUp()
            return true
        }
        
        // ⌘⇧-: Font size down
        if event.keyCode == 27 && flags == [.command, .shift] {
            AppState.shared.fontSizeDown()
            return true
        }
        
        return false
    }
}
