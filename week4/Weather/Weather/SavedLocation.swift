//
//  SwiftData.swift
//  Weather
//
//  Created by Ryan A Snell on 2/18/25.
//

import SwiftData
import Foundation


@Model
class SavedLocationModel: Identifiable {
    @Attribute var id: UUID = UUID()
    var name: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var country: String = ""
    var timestamp: Date = Date()
    var temp: Double = 0.0
    var condition: String = ""
    
    init(id: UUID, name: String, latitude: Double, longitude: Double, country: String, timestamp: Date, temp: Double, condition: String) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.country = country
        self.timestamp = timestamp
        self.temp = temp
        self.condition = condition
    }// end init
    
}// end class Model

struct CodeableSavedLocation: Codable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
    let timestamp: Date
    let temp: Double
    let condition: String

    
    init(from savedLocation: SavedLocationModel) {
        self.id = savedLocation.id
        self.name = savedLocation.name
        self.latitude = savedLocation.latitude
        self.longitude = savedLocation.longitude
        self.country = savedLocation.country
        self.timestamp = savedLocation.timestamp
        self.temp = savedLocation.temp
        self.condition = savedLocation.condition
    }// end init

    func toSavedLocation() -> SavedLocationModel {
        return SavedLocationModel(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            country: country,
            timestamp: timestamp,
            temp: temp,
            condition: condition
        )
    }// end func
    
}// end struct

// Extension for saving locations properly with SwiftData
extension SavedLocationModel {
    static func saveLocation(_ location: SavedLocationModel, context: ModelContext) {
        context.insert(location)
        print("Location inserted: \(location.name)")
        
        do {
            // First, attempt a normal save
            try context.save()
            print("Context saved successfully")
            
            // Verify save worked with a simpler approach
            let descriptor = FetchDescriptor<SavedLocationModel>()
            let allLocations = try context.fetch(descriptor)
            
            let found = allLocations.contains { $0.id == location.id }
            if !found {
                print("WARNING: Save verified but location not found in database!")
            } else {
                print("Location verified in database: \(location.name)")
            }
            
            // Count all locations
            let count = allLocations.count
            print("Total saved locations: \(count)")
        } catch {
            print("Failed to save location: \(error)")
        }
    }
}

