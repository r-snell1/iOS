//
//  MachineLearning.swift
//  Weather
//
//  Created by Ryan A Snell on 3/3/25.
//

import CoreML
import Foundation

class WeatherMLModel {
    private var model: WeatherPredictor?

    init() {
        do {
            self.model = try WeatherPredictor(configuration: .init())
        } catch {
            print("Failed to load model: \(error)")
        }
    }

    func predictWeatherTrend(temperature: Double) -> Double? {
        guard let model = model else { return nil }
        
        let input = WeatherPredictorInput(tmin: <#Double#>, tmax: <#Double#>)
        
        do {
            let prediction = try model.prediction(input: input)
            return prediction.tavg
        } catch {
            print("Prediction error: \(error)")
            return nil
        }
    }
}
