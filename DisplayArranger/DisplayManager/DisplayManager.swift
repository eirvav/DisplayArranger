//
//  DisplayManager.swift
//  DisplayArranger
//
//  Created by Ole Christian Sollid on 04/12/2025.
//


import Foundation
import CoreGraphics

class DisplayManager {

    func place(_ placement: DisplayPlacement) {

        let displays = getDisplayList()
        guard displays.count >= 2 else {
            log("No external display found.")
            return
        }

        let primary = displays[0]
        let external = displays[1]

        let primarySize = CGDisplayBounds(primary).size
        let externalSize = CGDisplayBounds(external).size

        let conn = _CGSDefaultConnection()

        var newX: Int32 = 0
        var newY: Int32 = 0

        switch placement {
        case .left:
            newX = -Int32(externalSize.width)
            newY = 0

        case .right:
            newX = Int32(primarySize.width)
            newY = 0

        case .above:
            newX = 0
            newY = -Int32(externalSize.height)

        case .below:
            newX = 0
            newY = Int32(primarySize.height)
        }

        CGSConfigureDisplayOrigin(conn, external, newX, newY)
        log("Moved display \(external) to \(placement)")
    }

    func getDisplayList() -> [CGDirectDisplayID] {
        var displayCount: UInt32 = 0
        CGGetActiveDisplayList(0, nil, &displayCount)

        var ids = [CGDirectDisplayID](repeating: 0, count: Int(displayCount))
        CGGetActiveDisplayList(displayCount, &ids, &displayCount)

        // primary display is always first
        return ids
    }
}
