//
//  Item.swift
//  Weather
//
//  Created by Ryan A Snell on 2/18/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
