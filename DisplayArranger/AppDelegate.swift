//
//  AppDelegate.swift
//  DisplayArranger
//
//  Created by Ole Christian Sollid on 04/12/2025.
//


import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    let menuController = MenuBarController()

    func applicationDidFinishLaunching(_ notification: Notification) {

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "🖥️"
        statusItem.menu = menuController.buildMenu()

        // Observe screen changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenConfigurationChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        updateVisibility()
    }

    @objc func screenConfigurationChanged() {
        updateVisibility()
    }

    func updateVisibility() {
        let hasExternal = NSScreen.screens.count > 1
        statusItem.isVisible = hasExternal
    }
}
