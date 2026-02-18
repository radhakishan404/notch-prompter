//
//  NotchPrompterApp.swift
//  NotchPrompter
//
//  App entry point. Uses AppDelegate for menu bar and shortcuts.
//

import SwiftUI

@main
struct NotchPrompterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Editor window
        WindowGroup("Script Editor") {
            EditorView(appState: AppState.shared, prompterEngine: appDelegate.prompterEngine)
                .frame(minWidth: 400, minHeight: 300)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 500, height: 400)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
        
        // Settings
        Settings {
            SettingsView(appState: AppState.shared)
        }
    }
}
