//
//  PrompterView.swift
//  NotchPrompter
//
//  A professional teleprompter display with smooth scrolling text.
//  Designed to align with the MacBook notch for an immersive experience.
//

import SwiftUI

struct PrompterView: View {

    @ObservedObject var appState: AppState
    @ObservedObject var prompterEngine: PrompterEngine

    // Corner radius that matches MacBook notch aesthetic
    private let cornerRadius: CGFloat = 18

    var body: some View {
        GeometryReader { geo in
            let height = geo.size.height
            let width = geo.size.width

            ZStack {
                // Background layer
                backgroundView(width: width, height: height)

                // Text content with gradient mask
                textContent(width: width, height: height)
                    .mask(edgeFadeMask(height: height))
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .opacity(appState.effectiveOpacity)
            .animation(.easeInOut(duration: 0.25), value: appState.effectiveOpacity)
        }
    }

    // MARK: - Background

    @ViewBuilder
    private func backgroundView(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            if appState.blurEnabled {
                // Frosted glass effect
                VisualEffectBlur(material: .hudWindow)

                // Dark overlay for better text contrast
                Color.black.opacity(0.3)
            } else {
                // Solid dark background with slight gradient for depth
                LinearGradient(
                    colors: [
                        Color(white: 0.08),
                        Color(white: 0.04)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }

            // Subtle inner border for definition
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.5
                )
        }
    }

    // MARK: - Text Content

    private func textContent(width: CGFloat, height: CGFloat) -> some View {
        let font = Font.custom("SF Mono", size: appState.fontSize)
            .weight(.medium)

        return ZStack(alignment: .top) {
            Text(appState.scriptText)
                .font(font)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .tracking(0.5)  // Slight letter spacing for readability
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)
                .padding(.top, height * 0.3)  // Start text 30% from top
                .offset(y: -appState.scrollOffset)
                .scaleEffect(x: appState.mirrorText ? -1 : 1, y: 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Edge Fade Mask

    /// Creates a gradient mask that fades text at top and bottom edges
    private func edgeFadeMask(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            // Top fade
            LinearGradient(
                colors: [.clear, .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: height * 0.25)

            // Middle - fully visible
            Rectangle()
                .fill(Color.white)

            // Bottom fade
            LinearGradient(
                colors: [.white, .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: height * 0.2)
        }
    }
}

// MARK: - Visual Effect Blur

/// SwiftUI wrapper for NSVisualEffectView with configurable material.
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.wantsLayer = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
