//
//  WeatherService.swift
//  Weather
//
//  Created by Ryan A Snell on 2/18/25.
//

import Foundation

struct WeatherResponse: Codable {
    let name: String
    let sys: Sys
    let main: Main
    let weather: [Weather]
    let visibility: Int
    let wind: Wind
    let coord: Coord

    struct Sys: Codable {
        let country: String
    }

    struct Main: Codable {
        let temp: Double
        let humidity: Int
        let temp_min: Double
        let temp_max: Double
    }

    struct Weather: Codable {
        let description: String
        let main: String
        let icon: String
    }

    struct Wind: Codable {
        let speed: Double
        let deg: Int
    }

    struct Coord: Codable {
        let lon: Double
        let lat: Double
    }
}

class WeatherService {
    private let apiKey = "f47e851a84336835cb599f08fb2fa334"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    private var units: String = ""

    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (WeatherResponse?) -> Void) {
        if Locale.current.measurementSystem == .metric {
                    units = "metric"
                } else {
                    units = "imperial"
                }// end if else

        let urlString = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=\(units)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
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
                let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
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


