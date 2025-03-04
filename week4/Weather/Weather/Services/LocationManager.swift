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
    @Published var locationPermissionDenied: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
        checkLocationAuthorization()
    }

    func requestLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation() // Requests a single location update
        } else {
            DispatchQueue.main.async {
                self.locationPermissionDenied = true
            }
        }
    }// end func

    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            DispatchQueue.main.async {
                self.locationPermissionDenied = true
            }
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation() // Fetch location only once
        @unknown default:
            break
        }
    }// end func

    // Delegate method for successful location update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = location
        }
    }// end func

    // Delegate method for handling location errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }// end func
}// end class

extension LocationManager {
    func saveWeatherLocation(_ weather: WeatherResponse, to modelContext: ModelContext) -> (success: Bool, message: String?) {
        let newLocation = SavedLocationModel(
            id: UUID(),
            name: weather.name,
            latitude: weather.coord.lat,
            longitude: weather.coord.lon,
            country: weather.sys.country,
            timestamp: Date(),
            temp: weather.main.temp,
            condition: weather.weather.first?.description ?? "Unknown"
        )
        
        // Insert the new location into the model context
        modelContext.insert(newLocation)
        
        do {
            try modelContext.save()
            print("Successfully saved location: \(newLocation.name)")
            return (true, nil)
        } catch {
            let errorMessage = "Failed to save location: \(error.localizedDescription)"
            print("Error saving location: \(error)")
            return (false, errorMessage)
        }
    }// end func
}// end extension
