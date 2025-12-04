//
//  MenuBarController.swift
//  DisplayArranger
//
//  Created by Ole Christian Sollid on 04/12/2025.
//


import AppKit

class MenuBarController: NSObject {

    let displayManager = DisplayManager()

    func buildMenu() -> NSMenu {
        let menu = NSMenu()

        menu.addItem(withTitle: "Place screen to the Left",
                     action: #selector(placeLeft), keyEquivalent: "")
        menu.addItem(withTitle: "Place screen to the Right",
                     action: #selector(placeRight), keyEquivalent: "")
        menu.addItem(withTitle: "Place screen Above",
                     action: #selector(placeAbove), keyEquivalent: "")
        menu.addItem(withTitle: "Place screen Below",
                     action: #selector(placeBelow), keyEquivalent: "")

        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")

        return menu
    }

    @objc func placeLeft()  { displayManager.place(.left) }
    @objc func placeRight() { displayManager.place(.right) }
    @objc func placeAbove() { displayManager.place(.above) }
    @objc func placeBelow() { displayManager.place(.below) }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
