//
//  WeatherCoordinator.swift
//  Assignment
//
//  Created by Bhargav Bathula on 10/4/24.
//

import UIKit
import SwiftUI

class WeatherCoordinator {
    var navigationController: UINavigationController?
    
    func start() {
        let networkManager = NetworkManager()
        let viewModel = WeatherViewModel(networkManager: networkManager)
        let view = WeatherView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        navigationController = UINavigationController(rootViewController: hostingController)
    }
}
