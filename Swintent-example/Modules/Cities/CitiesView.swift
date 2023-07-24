//
//  CitiesView.swift
//  Swintent-example
//
//  Created by Kamil Zaborowski on 23/07/2023.
//

import SwiftUI
import Swintent

struct CitiesViewState {
    var cities: [City]?
    var selectedCountryFilter: String?
    var countryFilterKeys: [String] = []
    var errorMessage: String?
}

extension CitiesViewState {
    var errorPresented: Bool {
        errorMessage != nil
    }
    
    var interactionsDisabled: Bool {
        cities == nil
    }
}

enum CitiesViewAction {
    case onAppear
    case selectCountryFilter(String?)
    case errorClosed
}

class CitiesViewViewModel: ViewModel {
    @Published var state: CitiesViewState
    
    private let citiesService: CitiesService
    
    init(citiesService: CitiesService) {
        self.state = CitiesViewState()
        self.citiesService = citiesService
    }
    
    @MainActor
    func trigger(_ action: CitiesViewAction) async {
        do {
            switch action {
            case .onAppear:
                try await reload()
            case .errorClosed:
                state.errorMessage = nil
                try await reload()
            case .selectCountryFilter(let country):
                state.selectedCountryFilter = country
                try await reload(countryFilter: country)
            }
        } catch {
            print(error.localizedDescription)
            state.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    private func reload(countryFilter: String? = nil) async throws {
        state.cities = nil
        var cities = try await citiesService.getCities()
        state.countryFilterKeys = Set(cities.map({ $0.country })).sorted()
        if let countryFilter {
            cities = cities.filter({ $0.country == countryFilter })
        }
        cities = cities.sorted(by: \.city)
        state.cities = cities
    }
}

struct CitiesView: View {
    
    @StateObject var viewModel: AnyViewModelOf<CitiesViewViewModel>
    private let citiesService: CitiesService
    
    init(citiesService: CitiesService) {
        self.citiesService = citiesService
        _viewModel = CitiesViewViewModel(citiesService: citiesService).eraseToStateObject()
    }
    
    var body: some View {
        VStack {
            header()
            ZStack {
                if let cities = viewModel.state.cities {
                    cityListView(cities)
                } else {
                    ProgressView()
                }
            }
            .frame(maxHeight: .infinity)
        }
        .disabled(viewModel.state.interactionsDisabled)
        .alert(viewModel.state.errorMessage ?? "", isPresented: viewModel.binding(\.errorPresented, input: .errorClosed)) {
            Button("Reload", role: .cancel, action: {})
        }
        .onAppear {
            viewModel.trigger(.onAppear)
        }
    }
    
    @ViewBuilder
    func header() -> some View {
        HStack {
            Spacer()
            Picker("Type", selection: viewModel.binding(\.selectedCountryFilter, input: { .selectCountryFilter($0) })) {
                Text("All").tag(nil as String?)
                ForEach(viewModel.state.countryFilterKeys, id: \.self) { country in
                    Text(country).tag(country as String?)
                }
            }
        }
        .padding(.horizontal)
    }
             
    @ViewBuilder
    func cityListView(_ cities: [City]) -> some View {
        List(cities) { city in
            NavigationLink {
                CityDetailsView(cityId: city.id, citiesService: citiesService)
            } label: {
                cityView(city)
            }
        }
    }
    
    @ViewBuilder
    func cityView(_ city: City) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(city.city)
            Text(city.country)
        }
    }
}

struct CitiesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CitiesView(citiesService: MockCitiesService(randomlyFail: false))
        }
    }
}
