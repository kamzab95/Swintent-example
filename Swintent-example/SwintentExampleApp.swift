//
//  Swintent_exampleApp.swift
//  Swintent-example
//
//  Created by Kamil Zaborowski on 23/07/2023.
//

import SwiftUI

@main
struct SwintentExampleApp: App {
    let citiesService: CitiesService = MockCitiesService()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CitiesView(citiesService: citiesService)
            }
        }
    }
}
