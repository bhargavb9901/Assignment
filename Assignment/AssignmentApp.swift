//
//  AssignmentApp.swift
//  Assignment
//
//  Created by Bhargav Bathula on 10/4/24.
//

import SwiftUI

@main
struct AssignmentApp: App {
    var body: some Scene {
        WindowGroup {
            let networkManager = NetworkManager()
            let viewModel = WeatherViewModel(networkManager: networkManager)
            WeatherView(viewModel: viewModel)
        }
    }
}
