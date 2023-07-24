//
//  MockCitiesService.swift
//  Swintent-example
//
//  Created by Kamil Zaborowski on 23/07/2023.
//

import Foundation

class MockCitiesService: CitiesService {
    private var cities = [City]()
    private let randomlyFail: Bool
    
    init(randomlyFail: Bool = true) {
        self.randomlyFail = randomlyFail
        loadData()
    }
    
    // Implement the getTransactions() method
    func getCities() async throws -> [City] {
        try await addDelay()
        try maybeThrowError()
        
        return cities
    }
    
    func getCity(id: String) async throws -> City {
        try await addDelay()
        try maybeThrowError()
        
        guard let city = cities.first(where: { $0.id == id }) else {
            throw NSError(domain: "MockCitiesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Transaction not found"])
        }
        
        return city
    }
    
    private func loadData() {
        let fileURL = Bundle.main.url(forResource: "cities", withExtension: "json")!
        let jsonData = try! Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let citiesRoot = try! decoder.decode(CitiesRoot.self, from: jsonData)
        cities = citiesRoot.cities
    }
    
    // Adds an artificial delay to simulate network latency
    private func addDelay() async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000 * 2)
    }
    
    // Randomly decides whether to throw an error or not
    private func maybeThrowError() throws {
        guard randomlyFail else {
            return
        }
        let random = Int.random(in: 0...4) // 20% chance of throwing an error
        if random == 0 {
            throw NSError(domain: "MockCitiesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Random error occurred"])
        }
    }
}
