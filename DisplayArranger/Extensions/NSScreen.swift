//
//  NSScreen.swift
//  DisplayArranger
//
//  Created by Ole Christian Sollid on 04/12/2025.
//

import AppKit
import CoreGraphics

extension NSScreen {

    var displayID: CGDirectDisplayID? {
        guard let uuid = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
            return nil
        }
        return CGDirectDisplayID(uuid.uint32Value)
    }

    var isBuiltIn: Bool {
        return backingScaleFactor == NSScreen.main?.backingScaleFactor
    }
}
