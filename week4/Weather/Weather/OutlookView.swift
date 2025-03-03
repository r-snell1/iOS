//
//  OutlookView.swift
//  Weather
//
//  Created by Ryan A Snell on 3/3/25.
//

import SwiftUI

struct OutlookView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var locationManager = LocationManager()
    @State private var forecast: [DailyWeather] = []
    @State private var errorMessage: String?

    let weatherService = OutlookWeatherService()
    
    var body: some View {
        NavigationView {
            VStack {
                if let location = locationManager.currentLocation {
                    Text(NSLocalizedString("Current Location:", comment: "Current Location:"))
                    Text("Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude)")
                        .font(.headline)
                    
                    if forecast.isEmpty {
                        Text(NSLocalizedString("Fetching weather...", comment: "fetching weather"))
                    } else {
                        List(forecast, id: \.dt) { day in
                            VStack(alignment: .leading) {
                                Text(formattedDate(from: day.dt))
                                    .font(.headline)

                                Text("High: \(String(format: "%.1f°F", day.temp.max)) / Low: \(String(format: "%.1f°F", day.temp.min))")
                                
                                Text("Condition: \(day.weather.first?.description ?? "N/A")")
                            }
                            .padding()
                        }
                    }
                    
                    Button("Refresh Weather") {
                        fetchWeather()
                    }
                    .padding()
                } else {
                    Text(NSLocalizedString("Fetching location...", comment: "fetching location"))
                }
            }
            .navigationTitle("Weather Outlook")
            .onAppear {
                fetchWeather()
            }
        }
    }
    
    private func fetchWeather() {
        guard let location = locationManager.currentLocation else { return }
        weatherService.fetchWeather(latitude: location.coordinate.latitude,
                                    longitude: location.coordinate.longitude) { response in
            if let response = response {
                self.forecast = response.daily
            } else {
                self.errorMessage = "Failed to fetch weather data"
            }
        }
    }
    
    private func formattedDate(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}// end struct
