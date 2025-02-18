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
    @StateObject private var locationManager = LocationManager()
    @State private var weather: WeatherResponse?
    @State private var errorMessage: String?

    let weatherService = WeatherService()

    var body: some View {
        NavigationView {
            VStack {
                if let location = locationManager.currentLocation {
                    Text("Current Location:")
                    Text("Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude)")
                        .font(.headline)
                    
                    if let weather = weather {
                        Text("Location: \(weather.name) \(weather.sys.country)")
                        Text(String(format: "Temperature: %.1f°F", weather.main.temp))
                        Text("Humidity: \(weather.main.humidity)%")
                        Text("Condition: \(weather.weather.first?.description ?? "N/A")")
                    } else {
                        Text("Fetching weather...")
                    }
                    
                    Button("Refresh Weather") {
                        fetchWeather()
                    }
                    .padding()
                } else {
                    Text("Fetching location...")
                }

                NavigationLink("Enter Location Manually", destination: ManualLocationEntryView())
                    .padding()

                NavigationLink("View Saved Locations", destination: LocationHistoryView())
                    .padding()
            }
            .navigationTitle("Weather App")
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
}
#Preview {
    WeatherView()
        .modelContainer(for: Item.self, inMemory: true)
}
