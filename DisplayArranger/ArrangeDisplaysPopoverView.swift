//
//  ArrangeDisplaysPopoverView.swift
//  DisplayArranger
//
//  Created by Codex on 16/02/2026.
//

import AppKit
import SwiftUI

struct ArrangeDisplaysPopoverView: View {
    @ObservedObject var controller: MenuBarController

    @State private var initialPlacement: DisplayPlacement = .below
    @State private var pendingPlacement: DisplayPlacement = .below
    @State private var primaryPixelSize = CGSize(width: 2560, height: 1440)
    @State private var secondaryPixelSize = CGSize(width: 1280, height: 720)
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Arrange Displays")
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(.white)

            Text("To rearrange displays, drag them to the desired position.")
                .font(.system(size: 13))
                .foregroundStyle(Color.white.opacity(0.68))

            arrangementCanvas

            HStack {
                Toggle(
                    "Run at startup",
                    isOn: Binding(
                        get: { controller.launchAtStartupEnabled },
                        set: { controller.setLaunchAtStartup(enabled: $0) }
                    )
                )
                .toggleStyle(.checkbox)
                .font(.system(size: 13))
                .foregroundStyle(.white)

                Spacer()

                Button("Quit") {
                    controller.quit()
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)

                Button("Done") {
                    if pendingPlacement != initialPlacement {
                        controller.place(pendingPlacement)
                    }
                    controller.closePopover()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
        }
        .padding(16)
        .frame(width: 560, height: 390)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: NSColor(calibratedWhite: 0.14, alpha: 0.98)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .onAppear {
            refreshLayout()
        }
    }

    private var arrangementCanvas: some View {
        GeometryReader { geometry in
            let canvasSize = geometry.size
            let maxFootprintWidth = min(canvasSize.width * 0.58, 290)
            let maxFootprintHeight = min(canvasSize.height * 0.76, 210)
            let scale = min(
                maxFootprintWidth / max(primaryPixelSize.width + secondaryPixelSize.width, 1),
                maxFootprintHeight / max(primaryPixelSize.height + secondaryPixelSize.height, 1)
            )
            let primarySize = CGSize(
                width: max(primaryPixelSize.width * scale, 96),
                height: max(primaryPixelSize.height * scale, 56)
            )
            let secondarySize = CGSize(
                width: max(secondaryPixelSize.width * scale, 64),
                height: max(secondaryPixelSize.height * scale, 40)
            )
            let primaryCenter = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2 - 6)
            let primaryFrame = CGRect(
                x: primaryCenter.x - primarySize.width / 2,
                y: primaryCenter.y - primarySize.height / 2,
                width: primarySize.width,
                height: primarySize.height
            )
            let baseSecondaryCenter = center(
                for: pendingPlacement,
                primaryFrame: primaryFrame,
                secondarySize: secondarySize
            )
            let liveSecondaryCenter = CGPoint(
                x: baseSecondaryCenter.x + dragOffset.width,
                y: baseSecondaryCenter.y + dragOffset.height
            )
            let livePlacement = nearestPlacement(
                to: liveSecondaryCenter,
                primaryFrame: primaryFrame,
                secondarySize: secondarySize
            )

            let dragGesture = DragGesture(minimumDistance: 0)
                .onChanged { value in
                    isDragging = true
                    dragOffset = value.translation
                }
                .onEnded { _ in
                    let newPlacement = livePlacement
                    withAnimation(.spring(duration: 0.25)) {
                        pendingPlacement = newPlacement
                        dragOffset = .zero
                        isDragging = false
                    }
                }

            ZStack {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(Color.white.opacity(0.11), lineWidth: 1)
                    )

                DisplayTile(size: primarySize, strokeOpacity: 0.35)
                    .position(primaryCenter)

                DisplayTile(
                    size: secondarySize,
                    strokeOpacity: isDragging ? 0.78 : 0.5
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(
                            livePlacement == pendingPlacement ? Color.white.opacity(0.22) : Color(nsColor: .controlAccentColor).opacity(0.9),
                            lineWidth: livePlacement == pendingPlacement ? 1 : 2
                        )
                )
                .position(liveSecondaryCenter)
                .gesture(dragGesture)
            }
        }
        .frame(height: 255)
        .padding(.vertical, 2)
    }

    private func refreshLayout() {
        if let layout = controller.currentLayout() {
            initialPlacement = layout.placement
            pendingPlacement = layout.placement
            primaryPixelSize = layout.primarySize
            secondaryPixelSize = layout.externalSize
        } else {
            let fallbackPlacement = controller.currentPlacement()
            initialPlacement = fallbackPlacement
            pendingPlacement = fallbackPlacement
        }

        dragOffset = .zero
        isDragging = false
    }

    private func center(
        for placement: DisplayPlacement,
        primaryFrame: CGRect,
        secondarySize: CGSize
    ) -> CGPoint {
        switch placement {
        case .left:
            return CGPoint(
                x: primaryFrame.minX - secondarySize.width / 2,
                y: primaryFrame.midY
            )
        case .right:
            return CGPoint(
                x: primaryFrame.maxX + secondarySize.width / 2,
                y: primaryFrame.midY
            )
        case .above:
            return CGPoint(
                x: primaryFrame.midX,
                y: primaryFrame.minY - secondarySize.height / 2
            )
        case .below:
            return CGPoint(
                x: primaryFrame.midX,
                y: primaryFrame.maxY + secondarySize.height / 2
            )
        }
    }

    private func nearestPlacement(
        to point: CGPoint,
        primaryFrame: CGRect,
        secondarySize: CGSize
    ) -> DisplayPlacement {
        let centers: [(DisplayPlacement, CGPoint)] = DisplayPlacement.allCases.map {
            ($0, center(for: $0, primaryFrame: primaryFrame, secondarySize: secondarySize))
        }

        return centers.min { lhs, rhs in
            lhs.1.distance(to: point) < rhs.1.distance(to: point)
        }?.0 ?? .below
    }
}

private struct DisplayTile: View {
    let size: CGSize
    let strokeOpacity: Double

    var body: some View {
        ZStack {
            if NSImage(named: "DisplayBackground") != nil {
                Image("DisplayBackground")
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [.blue.opacity(0.9), .purple.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .stroke(Color.white.opacity(strokeOpacity), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
    }
}

private extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - x
        let dy = point.y - y
        return sqrt((dx * dx) + (dy * dy))
    }
}
