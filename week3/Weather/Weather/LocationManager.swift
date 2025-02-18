//
//  LocationManager.swift
//  Weather
//
//  Created by Ryan A Snell on 2/18/25.
//

import Foundation
import CoreLocation
import SwiftData

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    var modelContext: ModelContext?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = location
        }
    }

    func saveCurrentLocation() {
        guard let location = currentLocation, let context = modelContext else { return }
        
        let newLocation = SavedLocation(latitude: location.coordinate.latitude,
                                        longitude: location.coordinate.longitude,
                                        timestamp: Date(),
                                        name: "Current Location")

        context.insert(newLocation)
        
        do {
            try context.save()
        } catch {
            print("Failed to save location: \(error)")
        }
    }
}
