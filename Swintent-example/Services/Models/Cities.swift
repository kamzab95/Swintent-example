//
//  Transaction.swift
//  Swintent-example
//
//  Created by Kamil Zaborowski on 23/07/2023.
//

import Foundation

struct CityData: Codable {
    let areaSqKm: Double
    let populationCount: Int
    
    enum CodingKeys: String, CodingKey {
        case areaSqKm = "area_sq_km"
        case populationCount = "population_count"
    }
}

struct City: Codable, Identifiable {
    let id: String
    let city: String
    let country: String
    let shortDescription: String
    let data: CityData

    enum CodingKeys: String, CodingKey {
        case id
        case city
        case country
        case shortDescription = "short_description"
        case data
    }
}

struct CitiesRoot: Codable {
    let cities: [City]
}
