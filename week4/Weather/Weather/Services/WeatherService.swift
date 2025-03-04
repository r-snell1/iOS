//
//  WeatherService.swift
//  Weather
//
//  Created by Ryan A Snell on 2/18/25.
//

import Foundation

class WeatherService {
    private let apiKey: String = Bundle.main.infoDictionary?["apiKey"] as? String ?? ""
    private let apiURL: String = Bundle.main.infoDictionary?["apiURL"] as? String ?? ""
    private var units: String = ""
    
    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (WeatherResponse?) -> Void) {
        let units = Locale.current.measurementSystem == .metric ? "metric" : "imperial"
        

        let urlString = "\(String(describing: apiURL))?lat=\(latitude)&lon=\(longitude)&appid=\(String(describing: apiKey))&units=\(units)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }// end guarded let

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
            }// end guarded let

            do {
                let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedData)
                }
            } catch {
                print("Failed to decode Weather API response: \(error)")
                completion(nil)
            }// end do catch
        }.resume()
    }// end func
}// end class
