//
//  CGSPrivateAPI.swift
//  DisplayArranger
//
//  Created by Ole Christian Sollid on 04/12/2025.
//

import Foundation
import CoreGraphics

// Returns system connection ID
@_silgen_name("CGSDefaultConnection")
func _CGSDefaultConnection() -> Int32

// Moves display origin
@_silgen_name("CGSConfigureDisplayOrigin")
func CGSConfigureDisplayOrigin(_ cid: Int32,
                               _ display: CGDirectDisplayID,
                               _ x: Int32,
                               _ y: Int32)
