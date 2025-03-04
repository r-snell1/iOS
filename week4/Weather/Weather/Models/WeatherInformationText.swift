//
//  WeatherInformationText.swift
//  Weather
//
//  Created by Ryan A Snell on 3/3/25.
//

import SwiftUI

struct WeatherInformationText: View {
    let weather: WeatherResponse
        
    var body: some View {
        VStack {
            Text("Location: \(weather.name) \(weather.sys.country)")
            Text(String(format: "Temperature: %.1f°F", weather.main.temp))
            Text("Humidity: \(weather.main.humidity)%")
            Text("Condition: \(weather.weather.first?.description ?? "N/A")")
            Text(String(format:"Wind Speed: %.1f mph at: \(weather.wind.deg)°", weather.wind.speed))
            Text("High: \(String(format: "%.1f°F", weather.main.temp_max)) / Low: \(String(format: "%.1f°F", weather.main.temp_min))")
        }// end vstack
    }// end body
}// end struct
