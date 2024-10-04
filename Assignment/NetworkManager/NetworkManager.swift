//
//  NetworkManager.swift
//  Assignment
//
//  Created by Bhargav Bathula on 10/4/24.
//

import Foundation
import Combine

protocol NetworkManagerProtocol {
    func getWeather(for city: String) -> AnyPublisher<WeatherData, Error>
    func getWeatherForLocation(lat: Double, lon: Double) -> AnyPublisher<WeatherData, Error>
}

class NetworkManager: NetworkManagerProtocol {
    private let apiKey = "1c3f1d87136fb601cf8d41b3227a47bb"
    
    func getWeather(for city: String) -> AnyPublisher<WeatherData, Error> {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getWeatherForLocation(lat: Double, lon: Double) -> AnyPublisher<WeatherData, Error> {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

}
