//
//  DisplayManager.swift
//  DisplayArranger
//
//  Created by Ole Christian Sollid on 04/12/2025.
//

import Foundation
import CoreGraphics

struct DisplayLayoutSnapshot {
    let primarySize: CGSize
    let externalSize: CGSize
    let placement: DisplayPlacement
}

class DisplayManager {
    /**
     * Attempts to place the second active display relative to the primary display
     * using public Core Graphics configuration functions.
     * @param placement The desired relative position (.left, .right, .above, or .below).
     */
    func place(_ placement: DisplayPlacement) {
        guard let (primary, external) = primaryAndExternalDisplay() else {
            print("Only one display found. Cant arrange")
            return
        }

        let primaryBounds = CGDisplayBounds(primary)
        let externalBounds = CGDisplayBounds(external)
        
        var newX: CGFloat = 0
        var newY: CGFloat = 0
        
        // Calculate the new origin (top-left corner) for extra display
        switch placement {
        case .left:
            // x = -(width of external display)
            newX = -externalBounds.width
            // Center vertically relative to primary
            newY = (primaryBounds.height - externalBounds.height) / 2
            
        case .right:
            // x = (width of primary display)
            newX = primaryBounds.width
            newY = (primaryBounds.height - externalBounds.height) / 2
            
        case .above:
            newY = -externalBounds.height
            newX = (primaryBounds.width - externalBounds.width) / 2
            
        case .below:
            newY = primaryBounds.height
            newX = (primaryBounds.width - externalBounds.width) / 2
        }
        
        var configRef: CGDisplayConfigRef?
        
        // Start the config transaction
        let beginResult = CGBeginDisplayConfiguration(&configRef)
        guard beginResult == .success, let config = configRef else {
            print("CGBeginDisplayConfiguration failed: \(beginResult.rawValue)")
            return
        }
        
        // Set the new origin for the extra display
        let setResult = CGConfigureDisplayOrigin(config, external, Int32(newX), Int32(newY))
        
        if setResult == .success {
            // Commit change permanently and save to usrprefs
            let completeResult = CGCompleteDisplayConfiguration(config, .permanently)
            if completeResult == .success {
                print("Reposition complete: External display moved \(placement)")
            } else {
                print("CGCompleteDisplayConfiguration failed: \(completeResult.rawValue)")
            }
        } else {
            print("CGConfigureDisplayOrigin failed: \(setResult.rawValue)")
            // If setting the origin fails, cancel transaction
            CGCompleteDisplayConfiguration(config, .forAppOnly)
        }
    }

    func currentPlacement() -> DisplayPlacement? {
        currentLayout()?.placement
    }

    func currentLayout() -> DisplayLayoutSnapshot? {
        guard let (primary, external) = primaryAndExternalDisplay() else {
            return nil
        }

        let primaryBounds = CGDisplayBounds(primary)
        let externalBounds = CGDisplayBounds(external)

        return DisplayLayoutSnapshot(
            primarySize: primaryBounds.size,
            externalSize: externalBounds.size,
            placement: placement(for: primaryBounds, externalBounds: externalBounds)
        )
    }
    
    /**
     * Gets a list of all currently active (on and connected) displays.
     * @return An array of CGDirectDisplayID for active displays.
     */
    private func activeDisplays() -> [CGDirectDisplayID] {
        var count: UInt32 = 0
        
        // Get the count of active displays
        CGGetActiveDisplayList(0, nil, &count)
        
        // Allocate space for the list
        var list = [CGDirectDisplayID](repeating: 0, count: Int(count))
        
        // Get the list of IDs
        CGGetActiveDisplayList(count, &list, &count)
        
        return list
    }

    private func primaryAndExternalDisplay() -> (CGDirectDisplayID, CGDirectDisplayID)? {
        let displays = activeDisplays()
        guard displays.count >= 2 else { return nil }

        let primary = CGMainDisplayID()
        if let external = displays.first(where: { $0 != primary }) {
            return (primary, external)
        }

        return nil
    }

    private func placement(for primaryBounds: CGRect, externalBounds: CGRect) -> DisplayPlacement {
        let dx = externalBounds.midX - primaryBounds.midX
        let dy = externalBounds.midY - primaryBounds.midY

        if abs(dx) >= abs(dy) {
            return dx >= 0 ? .right : .left
        }

        return dy >= 0 ? .below : .above
    }
}
