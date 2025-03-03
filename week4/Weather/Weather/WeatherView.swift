//
//  ContentView.swift
//  Weather
//
//  Created by Ryan A Snell on 2/18/25.
//

import SwiftUI
import SwiftData
import CoreLocation

struct WeatherView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var locationManager = LocationManager()
    @State private var weather: WeatherResponse?
    @State private var errorMessage: String?

    let weatherService = WeatherService()

    var body: some View {
        NavigationView {
            VStack {
                if let location = locationManager.currentLocation {
                    Text(NSLocalizedString("Current Location:", comment: "Current Location:"))
                    Text("Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude)")
                        .font(.headline)
                    
                    if let weather = weather {
                        Text("Location: \(weather.name) \(weather.sys.country)")
                        Text(String(format: "Temperature: %.1f°F", weather.main.temp))
                        Text("Humidity: \(weather.main.humidity)%")
                        Text("Condition: \(weather.weather.first?.description ?? "N/A")")
                        Text(String(format:"Wind Speed: %.1f mph at: \(weather.wind.deg)°", weather.wind.speed))
                        Text("High: \(String(format: "%.1f°F", weather.main.temp_max)) / Low: \(String(format: "%.1f°F", weather.main.temp_min))")
                    } else {
                        Text(NSLocalizedString("Fetching weather...", comment: "fetching weather"))
                    }
                    
                    Button("Refresh Weather") {
                        fetchWeather()
                    }
                    .padding()
                    Button("Save Location") {
                        saveLocation()
                        print()
                    }
                    .padding()
                    .disabled(weather == nil)
                } else {
                    Text(NSLocalizedString("Fetching location...", comment: "fetching location"))
                }
//                NavigationLink(NSLocalizedString("Weather Outlook", comment: "weather outlook"), destination: OutlookView())
//                    .padding()

                NavigationLink(NSLocalizedString("Enter Location Manually", comment: "enter location manually"), destination: ManualLocationEntryView())
                    .padding()

                NavigationLink(NSLocalizedString("View Saved Locations", comment: "view saved locations"), destination: LocationHistoryView())
                    .padding()
            }
            .navigationTitle(NSLocalizedString("Weather App", comment: "weather app title"))
            .onAppear {
                fetchWeather()
            }
        }
    }

    private func fetchWeather() {
        guard let location = locationManager.currentLocation else { return }
        weatherService.fetchWeather(latitude: location.coordinate.latitude,
                                    longitude: location.coordinate.longitude) { response in
            self.weather = response
            if response == nil {
                self.errorMessage = "Failed to fetch weather data"
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

        modelContext.insert(newLocation)

        do {
            try modelContext.save()
            errorMessage = nil // Clear any previous error
        } catch {
            errorMessage = "Failed to save location: \(error.localizedDescription)"
        }
    }
}// end struct

#Preview {
    WeatherView()
        .modelContainer(for: SavedLocationModel.self, inMemory: true)
}
