//
//  WindowManager.swift
//  NotchPrompter
//
//  Creates and configures the floating NSPanel:
//  - Borderless, transparent, always-on-top
//  - Positioned at top-center (notch/camera region)
//  - Click-through when locked (ignoresMouseEvents)
//  - Does not steal focus
//  - Automatically updates when window size settings change
//

import AppKit
import SwiftUI
import Combine

@MainActor
final class WindowManager: ObservableObject {

    // MARK: - Panel

    private var panel: NSPanel?
    private var hostingView: NSHostingView<PrompterView>?

    // MARK: - State

    private var appState: AppState
    private var prompterEngine: PrompterEngine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(appState: AppState, prompterEngine: PrompterEngine) {
        self.appState = appState
        self.prompterEngine = prompterEngine
        observeWindowSizeChanges()
    }

    // MARK: - Observe Size Changes

    private func observeWindowSizeChanges() {
        // Observe window width changes
        appState.$windowWidth
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.positionPanel()
            }
            .store(in: &cancellables)

        // Observe window height changes
        appState.$windowHeight
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.positionPanel()
            }
            .store(in: &cancellables)

        // Observe screen capture protection changes
        appState.$hideFromScreenCapture
            .sink { [weak self] _ in
                self?.updateSharingType()
            }
            .store(in: &cancellables)
    }

    // MARK: - Create Panel

    func createPrompterPanel() {
        guard panel == nil else {
            panel?.orderFrontRegardless()
            return
        }

        let width = appState.windowWidth
        let height = appState.windowHeight

        let contentRect = NSRect(x: 0, y: 0, width: width, height: height)

        let panel = NSPanel(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]

        // Does not steal focus when shown
        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = true

        // Click-through: passes mouse events to windows below
        panel.ignoresMouseEvents = true

        // Enable smooth animations
        panel.animationBehavior = .utilityWindow

        // IMPORTANT: Hide from screen capture/sharing when enabled
        // This makes the teleprompter invisible during screen share, recordings, and screenshots
        updateSharingType(for: panel)

        let prompterView = PrompterView(
            appState: appState,
            prompterEngine: prompterEngine
        )
        let hosting = NSHostingView(rootView: prompterView)
        hosting.frame = contentRect
        panel.contentView = hosting

        self.panel = panel
        self.hostingView = hosting

        positionPanel()
        panel.orderFrontRegardless()
    }

    // MARK: - Positioning

    /// Positions the panel at top-center of the primary display.
    /// Aligns with notch/camera region on MacBooks.
    func positionPanel() {
        guard let panel = panel, let screen = NSScreen.main else { return }

        let width = appState.windowWidth
        let height = appState.windowHeight

        // Use screen.frame (full display) to position at absolute top, aligned with notch/camera
        // visibleFrame excludes menu bar, which would leave a gap below the notch
        let screenFrame = screen.frame

        // Center horizontally, align to very top of screen (notch/camera region)
        let x = screenFrame.midX - (width / 2)
        let y = screenFrame.maxY - height

        // Animate the size/position change for smooth transitions
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            panel.animator().setFrame(
                NSRect(x: x, y: y, width: width, height: height),
                display: true
            )
        }

        hostingView?.frame = NSRect(x: 0, y: 0, width: width, height: height)
    }

    // MARK: - Visibility

    func show() {
        panel?.orderFrontRegardless()
    }

    func hide() {
        panel?.orderOut(nil)
    }

    func toggleClickThrough(_ passThrough: Bool) {
        panel?.ignoresMouseEvents = passThrough
    }

    // MARK: - Screen Sharing Protection

    /// Updates the window sharing type based on user preference.
    /// When set to .none, the window is completely invisible during:
    /// - Screen sharing (Zoom, Teams, Meet, etc.)
    /// - Screen recording (QuickTime, OBS, etc.)
    /// - Screenshots (Cmd+Shift+3/4)
    func updateSharingType(for panel: NSPanel? = nil) {
        let targetPanel = panel ?? self.panel
        if appState.hideFromScreenCapture {
            targetPanel?.sharingType = .none
        } else {
            targetPanel?.sharingType = .readOnly
        }
    }
}
