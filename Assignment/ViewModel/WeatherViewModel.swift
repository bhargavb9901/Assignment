//
//  WeatherViewModel.swift
//  Assignment
//
//  Created by Bhargav Bathula on 10/4/24.
//
import Foundation
import Combine
import CoreLocation

class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var weatherData: WeatherData?
    @Published var errorMessage: String?
    @Published var locationPermissionGranted = false
    @Published var isFetchingLocation = false
    @Published var currentCity: String?

    private var cancellables = Set<AnyCancellable>()
    private let networkManager: NetworkManagerProtocol
    private let locationManager = CLLocationManager()
    private let lastCityKey = "LastCitySearched"

    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationPermission() {
        isFetchingLocation = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation() // Fetch weather after permission is granted
    }

    func fetchWeather(for city: String) {
        networkManager.getWeather(for: city)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            }, receiveValue: { data in
                self.weatherData = data
                self.currentCity = city
                self.saveLastCity(city)
            })
            .store(in: &cancellables)
    }

    func fetchWeatherForLocation(lat: Double, lon: Double) {
        if !isFetchingLocation {
            return
        }
        
        networkManager.getWeatherForLocation(lat: lat, lon: lon)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            }, receiveValue: { data in
                    self.weatherData = data
                    self.currentCity = data.name // Update current city based on location, but don't save
            })
            .store(in: &cancellables)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            fetchWeatherForLocation(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
            locationManager.stopUpdatingLocation()
            isFetchingLocation = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.errorMessage = "Failed to fetch location: \(error.localizedDescription)"
        isFetchingLocation = false
    }

    private func saveLastCity(_ city: String) {
        UserDefaults.standard.set(city, forKey: lastCityKey)
    }

    func loadLastCity() -> String? {
        return UserDefaults.standard.string(forKey: lastCityKey)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            locationPermissionGranted = false
        default:
            break
        }
    }
}
