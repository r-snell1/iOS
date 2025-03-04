//
//  WeatherResponse.swift
//  Weather
//
//  Created by Ryan A Snell on 3/4/25.
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
}// end struct
