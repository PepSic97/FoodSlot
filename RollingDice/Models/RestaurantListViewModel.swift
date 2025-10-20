//
//  RestaurantListViewModel.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 13/10/25.
//

import Foundation
import CoreLocation
import MapKit

@MainActor
class RestaurantListViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchNearbyRestaurants(food: String, location: CLLocation) async {
        isLoading = true
        errorMessage = nil

        // ✅ Reset risultati solo dopo aver impostato il loading
        restaurants = []

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = food
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )

        let search = MKLocalSearch(request: request)

        do {
            let response = try await search.start()
            let items = response.mapItems

            if items.isEmpty {
                errorMessage = nil // nessun errore, solo lista vuota
            }

            restaurants = items.compactMap { item in
                Restaurant(
                    name: item.name ?? "Sconosciuto",
                    address: item.placemark.title ?? "Indirizzo non disponibile",
                    rating: Double.random(in: 3.5...5.0) // rating fittizio
                )
            }

        } catch {
            errorMessage = "Errore durante la ricerca dei ristoranti."
        }

        isLoading = false
    }
}

struct Restaurant: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let rating: Double
}
