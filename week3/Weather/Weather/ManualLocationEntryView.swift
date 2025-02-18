//
//  ManualLocationEntryView.swift
//  Weather
//
//  Created by Ryan A Snell on 2/18/25.
//
import SwiftUI
import CoreLocation
import SwiftData

struct ManualLocationEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var locationName: String = ""
    @State private var errorMessage: String?
    @State private var weather: WeatherResponse? // Add a property to hold weather data
    @State private var isWeatherFetching: Bool = false // Flag to track weather fetching state
    let geocoder = CLGeocoder()
    let weatherService = WeatherService() // Initialize WeatherService

    var body: some View {
        VStack {
            // Text field for location entry
            TextField("Enter a location", text: $locationName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Show weather button
            Button("Show Weather") {
                fetchWeatherForEnteredLocation()
            }
            .padding()

            // Save location button
            Button("Save Location") {
                saveLocation()
            }
            .padding()

            // Show error message if any
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            // Display weather data if available
            if let weather = weather {
                Text("Weather in \(weather.name), \(weather.sys.country):")
                    .font(.headline)
                Text("Temperature: \(String(format: "%.1f", weather.main.temp))°F")
                Text("Humidity: \(weather.main.humidity)%")
                Text("Condition: \(weather.weather.first?.description ?? "N/A")")
            }

            // Show loading message if weather data is being fetched
            if isWeatherFetching {
                Text("Fetching weather...")
                    .padding()
            }
        }
        .navigationTitle("Add Location")
    }

    private func fetchWeatherForEnteredLocation() {
        // Use geocoder to convert location name to coordinates
        geocoder.geocodeAddressString(locationName) { placemarks, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }

            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                DispatchQueue.main.async {
                    errorMessage = "Location not found"
                }
                return
            }

            // Start fetching weather
            isWeatherFetching = true
            weatherService.fetchWeather(latitude: location.coordinate.latitude,
                                        longitude: location.coordinate.longitude) { weatherResponse in
                DispatchQueue.main.async {
                    isWeatherFetching = false
                    if let weatherResponse = weatherResponse {
                        self.weather = weatherResponse
                    } else {
                        self.errorMessage = "Failed to fetch weather"
                    }
                }
            }
        }
    }

    private func saveLocation() {
        // Use geocoder to convert location name to coordinates
        geocoder.geocodeAddressString(locationName) { placemarks, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }

            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                DispatchQueue.main.async {
                    errorMessage = "Location not found"
                }
                return
            }

            // Save the location
            let newLocation = SavedLocation(latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude,
                                            timestamp: Date(),
                                            name: locationName)

            modelContext.insert(newLocation)

            do {
                try modelContext.save()
                DispatchQueue.main.async {
                    errorMessage = nil // Clear error message on success
                    locationName = ""  // Reset location name
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to save location"
                }
            }
        }
    }
}
