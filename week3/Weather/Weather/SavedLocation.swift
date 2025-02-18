//
//  SwiftData.swift
//  Weather
//
//  Created by Ryan A Snell on 2/18/25.
//

import SwiftData
import CoreLocation

@Model
class SavedLocation {
    @Attribute var id: UUID
    @Attribute var latitude: Double
    @Attribute var longitude: Double
    @Attribute var timestamp: Date
    @Attribute var name: String

    init(latitude: Double, longitude: Double, timestamp: Date, name: String) {
        self.id = UUID()
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.name = name
    }
}
