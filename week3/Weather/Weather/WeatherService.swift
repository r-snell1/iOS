//
//  WeatherService.swift
//  Weather
//
//  Created by Ryan A Snell on 2/18/25.
//

import Foundation
import CoreLocation

struct WeatherResponse: Codable {
    var name: String
    var sys: Sys
    var main: Main
    let weather: [Weather]
    
    struct Sys: Codable {
        var country: String
    }
    
    struct Main: Codable {
        var temp: Double
        let humidity: Int
    }
    
    struct Weather: Codable {
        let description: String
    }
}

class WeatherService {
    private let apiKey = "f47e851a84336835cb599f08fb2fa334"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (WeatherResponse?) -> Void) {
        let urlString = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
                
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                var decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                
                // Convert the temperature to Fahrenheit
                decodedData.main.temp = self.convertToFahrenheit(decodedData.main.temp)
                
                DispatchQueue.main.async {
                    completion(decodedData)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }

    // Convert Celsius to Fahrenheit
    private func convertToFahrenheit(_ celsius: Double) -> Double {
        return (celsius * 9.0 / 5.0) + 32.0
    }
}
