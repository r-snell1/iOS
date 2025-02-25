//
//  LocationManager.swift
//  Weather
//
//  Created by Ryan A Snell on 2/18/25.
//

import Foundation
import CoreLocation

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
    }

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
    }

    // Delegate method for successful location update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = location
        }
    }

    // Delegate method for handling location errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
