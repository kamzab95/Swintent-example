//
//  TransactionsService.swift
//  Swintent-example
//
//  Created by Kamil Zaborowski on 23/07/2023.
//

import Foundation

protocol CitiesService {
    func getCities() async throws -> [City]
    func getCity(id: String) async throws -> City
}
