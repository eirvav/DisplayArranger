//
//  DisplayArrangerApp.swift
//  DisplayArranger
//
//  Created by Ole Christian Sollid on 04/12/2025.
//

import SwiftUI

@main
struct DisplayArrangerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
