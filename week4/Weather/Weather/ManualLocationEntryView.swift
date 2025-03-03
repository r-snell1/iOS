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
    @State private var weather: WeatherResponse?
    @State private var isWeatherFetching: Bool = false
    @State private var isRecording = false
    @State private var permissionGranted = false
    @State private var isShowingPermissionAlert = false
    
    private let speechRecognizer = SpeechRecognizer()
    let geocoder = CLGeocoder()
    let weatherService = WeatherService()

    var body: some View {
        VStack {
            // Text field for location entry
            TextField("Enter a location", text: $locationName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Speech-to-Text Button
            Button(action: toggleRecording) {
                Image(systemName: isRecording ? "mic.fill" : "mic")
                    .font(.largeTitle)
                    .foregroundColor(isRecording ? .red : .blue)
                    .padding()
            }
            
            // Show Weather Button
            Button("Show Weather") {
                fetchWeatherForEnteredLocation()
            }
            .padding()

            // Save Location Button (Only enabled when weather is available)
            Button("Save Location") {
                saveLocation()
            }
            .padding()
            .disabled(weather == nil) // Disable if no weather data

            // Show error message if any
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            // Display weather data if available
            if let weather = weather {
                Text("Location: \(weather.name), \(weather.sys.country)")
                Text(String(format: "Temperature: %.1f°F", weather.main.temp))
                Text("Humidity: \(weather.main.humidity)%")
                Text("Condition: \(weather.weather.first?.description ?? "N/A")")
                Text(String(format:"Wind Speed: %.1f mph at: \(weather.wind.deg)°", weather.wind.speed))
                Text("High: \(String(format: "%.1f°F", weather.main.temp_max)) / Low: \(String(format: "%.1f°F", weather.main.temp_min))")
            }

            // Show loading message if weather data is being fetched
            if isWeatherFetching {
                Text("Fetching weather...")
                    .padding()
            }
        }
        .navigationTitle("Add Location")
        .onAppear {
            speechRecognizer.prepare {granted in
                permissionGranted = granted
                if !granted {
                    isShowingPermissionAlert = true
                }
            }
        }
        .alert("Microphone Access Required", isPresented: $isShowingPermissionAlert) {
            Button("Open Settings", role: .none) {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("To use voice imput, please allow access to your microphone in Settings.")
        }
        .padding()
    }

    // Toggle speech recognition
    private func toggleRecording() {
        if !permissionGranted {
            isShowingPermissionAlert = true
            return
        }
        
        if isRecording {
            speechRecognizer.stopRecording()
            isRecording = false
        } else {
            errorMessage = nil
            speechRecognizer.startRecording { result in
                DispatchQueue.main.async {
                    self.isRecording = false
                    if let result = result, !result.isEmpty {
                        self.locationName = result
                    } else if result == nil {
                        self.errorMessage = "I couldn't understand that. Please try again."
                    }
                }
            }
            isRecording = true
        }
    }
    
    private func validateLocationInput() -> Bool {
        let trimmedLocation = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedLocation.isEmpty {
            errorMessage = "Please enter a location name."
            return false
        }
        
        if trimmedLocation.count < 2 {
            errorMessage = "Location name is too short. Please be more specific."
            return false
        }
        
        return true
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
                  let location = placemark.location,
                  let country = placemark.country else {
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
        guard let weather = weather else {
            errorMessage = "No weather data available to save."
            return
        }

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
            errorMessage = nil
            print("Successfully saved location: \(newLocation.name)")
        } catch {
            errorMessage = "Failed to save location: \(error.localizedDescription)"
            print("Error saving location: \(error)")
        }
    }
}
