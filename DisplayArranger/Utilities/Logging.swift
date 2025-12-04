//
//  Logging.swift
//  DisplayArranger
//
//  Created by Ole Christian Sollid on 04/12/2025.
//

import Foundation

func log(_ message: String) {
    let timestamp = ISO8601DateFormatter().string(from: Date())
    print("[DisplayArranger \(timestamp)] \(message)")
}
