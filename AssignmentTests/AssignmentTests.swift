//
//  AssignmentTests.swift
//  AssignmentTests
//
//  Created by Bhargav Bathula on 10/4/24.
//

import XCTest
@testable import Assignment
import Combine

final class AssignmentTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    let sampleWeatherData = WeatherData(
        main: WeatherData.Main(temp: 22.5, feels_like: 20.0, humidity: 50),
        weather: [WeatherData.Weather(description: "Clear sky", icon: "01d")],
        name: "New York"
    )
    
    func testFetchWeatherSuccess() {
        let service = MockWeatherService(result: .success(sampleWeatherData))
        let viewModel = WeatherViewModel(networkManager: service)
        let expectation = XCTestExpectation(description: "Weather data fetched successfully")
        viewModel.fetchWeather(for: "New York")
        viewModel.$weatherData
            .dropFirst()
            .sink { weatherData in
                if weatherData != nil {
                    XCTAssertEqual(weatherData?.name, "New York")
                    XCTAssertEqual(weatherData?.main.temp, 22.5)
                    XCTAssertEqual(weatherData?.weather.first?.description, "Clear sky")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchWeatherInvalidCityName() {
            let service = MockWeatherService(result: .failure(URLError(.cannotFindHost)))
        let viewModel = WeatherViewModel(networkManager: service)

            let expectation = XCTestExpectation(description: "Weather fetch failed with invalid city name")
            viewModel.fetchWeather(for: "Invalid City")
            viewModel.$errorMessage
                .dropFirst()
                .sink { errorMessage in
                    if let errorMessage = errorMessage {
                        XCTAssertEqual(errorMessage, URLError(.cannotFindHost).localizedDescription)
                        XCTAssertNil(viewModel.weatherData)
                        expectation.fulfill()
                    }
                }
                .store(in: &cancellables)
            wait(for: [expectation], timeout: 5.0)
        }
    
}

class MockWeatherService: NetworkManagerProtocol {
    func getWeatherForLocation(lat: Double, lon: Double) -> AnyPublisher<Assignment.WeatherData, any Error> {
        return result
            .publisher
            .eraseToAnyPublisher()
    }
    
    var result: Result<WeatherData, Error>
    
    init(result: Result<WeatherData, Error>) {
        self.result = result
    }
    
    func getWeather(for city: String) -> AnyPublisher<WeatherData, Error> {
        return result
            .publisher
            .eraseToAnyPublisher()
    }
}
