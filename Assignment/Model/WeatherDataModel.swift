//
//  WeatherDataModel.swift
//  Assignment
//
//  Created by Bhargav Bathula on 10/4/24.
//

import Foundation

struct WeatherData: Codable {
    let main: Main
    let weather: [Weather]
    let name: String
    
    struct Main: Codable {
        let temp: Double
        let feels_like: Double
        let humidity: Int
    }

    struct Weather: Codable {
        let description: String
        let icon: String
    }
}
