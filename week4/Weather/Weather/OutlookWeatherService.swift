//
//  OutlookWeatherService.swift
//  Weather
//
//  Created by Ryan A Snell on 3/3/25.
//

import Foundation

struct ForecastResponse: Codable {
    let daily: [DailyWeather]
}

struct DailyWeather: Codable {
    let dt: Int
    let temp: Temperature
    let weather: [WeatherCondition]
}

struct Temperature: Codable {
    let min: Double
    let max: Double
}

struct WeatherCondition: Codable {
    let description: String
}

class OutlookWeatherService: NSObject {
    private let apiKey = "f47e851a84336835cb599f08fb2fa334"
    private let baseURL = "https://api.openweathermap.org/data/2.5/onecall"
    private var units: String = ""
    
    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (ForecastResponse?) -> Void) {
        if Locale.current.measurementSystem == .metric {
                    units = "metric"
                } else {
                    units = "imperial"
                }// end if else
        
        let urlString = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&exclude=current,minutely,hourly,alerts&appid=\(apiKey)&units=\(units)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Weather API request failed: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received from Weather API")
                completion(nil)
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(ForecastResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedData)
                }
            } catch {
                print("Failed to decode Weather API response: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
