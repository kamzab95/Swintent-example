//
//  CityDetails.swift
//  Swintent-example
//
//  Created by Kamil Zaborowski on 23/07/2023.
//

import SwiftUI
import Swintent

struct CityDetailsState {
    var city: City?
    var errorMessage: String?
}

extension CityDetailsState {
    var errorPresented: Bool {
        errorMessage != nil
    }
}

enum CityDetailsAction {
    case onAppear
    case errorClosed
}

class CityDetailsViewModel: ViewModel {
    @Published var state: CityDetailsState
    
    private let citiesService: CitiesService
    private let cityId: City.ID
    
    init(cityId: City.ID, citiesService: CitiesService) {
        self.cityId = cityId
        self.citiesService = citiesService
        self.state = CityDetailsState()
    }
    
    func trigger(_ action: CityDetailsAction) async {
        do {
            switch action {
            case .onAppear:
                try await loadData()
            case .errorClosed:
                state.errorMessage = nil
            }
        } catch {
            state.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func loadData() async throws {
        let city = try await citiesService.getCity(id: cityId)
        state.city = city
    }
}

struct CityDetailsView: View {
    @StateObject var viewModel: AnyViewModelOf<CityDetailsViewModel>
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(cityId: City.ID, citiesService: CitiesService) {
        _viewModel = CityDetailsViewModel(cityId: cityId,
                                          citiesService: citiesService).eraseToStateObject()
        
    }
    
    var body: some View {
        ZStack {
            if let city = viewModel.state.city {
                cityView(city)
            } else {
                ProgressView()
            }
        }
        .alert(viewModel.state.errorMessage ?? "", isPresented: viewModel.binding(\.errorPresented, input: nil)) {
            Button("Cancel", role: .cancel, action: {
                self.presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            viewModel.trigger(.onAppear)
        }
    }
    
    @ViewBuilder
    func cityView(_ city: City) -> some View {
        Form {
            Text(city.city)
            row("Description", value: city.shortDescription)
            row("Area", value: "\(city.data.areaSqKm) km²")
            row("Population", value: "\(city.data.populationCount)")
        }
    }
    
    @ViewBuilder
    func row(_ title: LocalizedStringKey, value: String) -> some View {
        Section(header: Text(title)) {
            Text(value)
        }
    }
}

struct CityDetails_Previews: PreviewProvider {
    static var previews: some View {
        CityDetailsView(cityId: "2", citiesService: MockCitiesService(randomlyFail: false))
    }
}
