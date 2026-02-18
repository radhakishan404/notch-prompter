//
//  PrompterEngine.swift
//  NotchPrompter
//
//  Drives smooth auto-scrolling. Uses a Timer to update scrollOffset
//  based on scrollSpeed (pixels per second).
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class PrompterEngine: ObservableObject {
    
    // MARK: - Dependencies
    
    weak var appState: AppState?
    
    // MARK: - Timer
    
    private var timer: Timer?
    private var lastTickTime: CFTimeInterval?
    
    // MARK: - Control
    
    func start() {
        guard appState?.scriptText.isEmpty == false else { return }
        appState?.isPlaying = true
        lastTickTime = CACurrentMediaTime()
        scheduleTimer()
    }
    
    func pause() {
        appState?.isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        pause()
        appState?.reset()
    }
    
    func togglePlayPause() {
        if appState?.isPlaying == true {
            pause()
        } else {
            start()
        }
    }
    
    // MARK: - Timer Logic
    
    private func scheduleTimer() {
        timer?.invalidate()
        let interval = 1.0 / 60.0 // ~60 fps for smooth scroll
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func tick() {
        guard let state = appState, state.isPlaying else {
            timer?.invalidate()
            timer = nil
            return
        }
        
        let now = CACurrentMediaTime()
        let elapsed = lastTickTime.map { now - $0 } ?? 0
        lastTickTime = now
        
        let delta = CGFloat(elapsed) * CGFloat(state.scrollSpeed)
        state.scrollOffset += delta
        
        // Optional: stop at end of script (no loop)
        // For now we allow scrolling past the end; UI can clamp or fade
    }
}
