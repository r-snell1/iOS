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
                        WeatherInformationText(weather: weather)
                    } else {
                        Text(NSLocalizedString("Fetching weather...", comment: "fetching weather"))
                    }
                    
                    Button("Refresh Weather") {
                        fetchWeather()
                    }
                    .padding()
                    Button("Save Location") {
                        saveLocation()
                    }
                    .padding()
                    .disabled(weather == nil)
                } else {
                    Text(NSLocalizedString("Fetching location...", comment: "fetching location"))
                }

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
    }// end body

    private func fetchWeather() {
        guard let location = locationManager.currentLocation else { return }
        weatherService.fetchWeather(latitude: location.coordinate.latitude,
                                    longitude: location.coordinate.longitude) { response in
            self.weather = response
            if response == nil {
                self.errorMessage = "Failed to fetch weather data"
            }
        }
    }// end func
    
    private func saveLocation() {
        guard let weather = weather else {
            errorMessage = "No weather data available to save."
            return
        }// end guarded let

        let result = locationManager.saveWeatherLocation(weather, to: modelContext)
        if !result.success {
            errorMessage = result.message
        } else {
            errorMessage = nil
        }// end if else
    }// end func
}// end struct

#Preview {
    WeatherView()
        .modelContainer(for: SavedLocationModel.self, inMemory: true)
}// end preview
