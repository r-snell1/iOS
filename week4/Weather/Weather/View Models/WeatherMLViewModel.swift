//
//  WeatherMLViewModel.swift
//  Weather
//
//  Created by Ryan A Snell on 3/4/25.
//


import SwiftUI

class WeatherMLViewModel: ObservableObject {
    private let mlModel = WeatherMLModel()
    
    @Published var predictedTrend: String = "Unknown"
    
    func updatePrediction(temperature: Double, humidity: Double, windSpeed: Double) {
        if let trend = mlModel.predictWeatherTrend(temperature: temperature, humidity: humidity, windSpeed: windSpeed) {
            DispatchQueue.main.async {
                self.predictedTrend = trend
            }
        }
    }
}
