//
//  MenuBarController.swift
//  DisplayArranger
//
//  Created by Ole Christian Sollid on 04/12/2025.
//
import AppKit
import ServiceManagement
import SwiftUI

class MenuBarController: NSObject, ObservableObject {
    let displayManager = DisplayManager()
    @Published private(set) var launchAtStartupEnabled = false

    private let popover = NSPopover()
    private weak var statusButton: NSStatusBarButton?

    override init() {
        super.init()
        launchAtStartupEnabled = isLaunchAtStartupEnabled()
    }

    func configureStatusItem(_ statusItem: NSStatusItem) {
        guard let button = statusItem.button else { return }

        statusButton = button
        button.target = self
        button.action = #selector(togglePopover(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])

        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 560, height: 390)
        popover.contentViewController = NSHostingController(
            rootView: ArrangeDisplaysPopoverView(controller: self)
        )
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
            return
        }

        launchAtStartupEnabled = isLaunchAtStartupEnabled()

        guard let button = statusButton else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }

    func closePopover() {
        popover.performClose(nil)
    }

    func place(_ placement: DisplayPlacement) {
        displayManager.place(placement)
    }

    func currentPlacement() -> DisplayPlacement {
        displayManager.currentPlacement() ?? .below
    }

    func currentLayout() -> DisplayLayoutSnapshot? {
        displayManager.currentLayout()
    }

    func setLaunchAtStartup(enabled: Bool) {
        if enabled {
            enableLaunchAtStartup()
        } else {
            disableLaunchAtStartup()
        }

        launchAtStartupEnabled = isLaunchAtStartupEnabled()
    }

    func quit() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Launch at startup helpers

    private func isLaunchAtStartupEnabled() -> Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        } else {
            // Fallback for older macOS versions
            return UserDefaults.standard.bool(forKey: "launchAtStartup")
        }
    }
    
    private func enableLaunchAtStartup() {
        if #available(macOS 13.0, *) {
            do {
                try SMAppService.mainApp.register()
                log("Launch at startup enabled")
            } catch {
                log("Failed to enable launch at startup: \(error)")
            }
        } else {
            // Fallback for older macOS versions
            UserDefaults.standard.set(true, forKey: "launchAtStartup")
        }
    }
    
    private func disableLaunchAtStartup() {
        if #available(macOS 13.0, *) {
            do {
                try SMAppService.mainApp.unregister()
                log("Launch at startup disabled")
            } catch {
                log("Failed to disable launch: \(error)")
            }
        } else {
            // Fallback for older macOS versions
            UserDefaults.standard.set(false, forKey: "launchAtStartup")
        }
    }
}
