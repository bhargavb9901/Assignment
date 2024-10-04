//
//  WeatherView.swift
//  Assignment
//
//  Created by Bhargav Bathula on 10/4/24.
//

import Foundation
import SwiftUI
import SwiftUI

struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var city: String = ""

    var body: some View {
        VStack {
            if let weather = viewModel.weatherData {
                Text("City: \(weather.name)")
                Text("Temperature: \(weather.main.temp)°C")
                Text("Feels like: \(weather.main.feels_like)°C")
                Text("Description: \(weather.weather.first?.description ?? "")")
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
            }
            
            Button(action: {
                viewModel.requestLocationPermission()
            }) {
                Text("Use Current Location")
            }
            .padding()
            .disabled(viewModel.isFetchingLocation)

            if viewModel.isFetchingLocation {
                ProgressView("Fetching current location...")
            }

            TextField("Enter City", text: $city)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Search") {
                viewModel.fetchWeather(for: city)
            }
            .padding()
        }
        .onAppear {
            if let lastCity = viewModel.loadLastCity() {
                city = lastCity
                viewModel.fetchWeather(for: lastCity)
            }
        }
        .onChange(of: viewModel.currentCity) { newCity in
            if let newCity = newCity {
                city = newCity
            }
        }
    }
}
