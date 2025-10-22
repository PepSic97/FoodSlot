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
    
    @Published var currentLoadingMessage: String = "Sto cercando i ristoranti..."
    private let loadingMessages = [
        "Sto cercando i ristoranti...",
        "Controllo i migliori posti nelle vicinanze...",
        "Quasi fatto, sto trovando qualcosa di buono...",
        "Affamato? Un attimo e ci siamo...",
        "Sto preparando la lista perfetta per te..."
    ]
    
    private var messageTimer: Timer?
    private var currentMessageIndex = 0

    // MARK: - Ricerca ristoranti
    func fetchNearbyRestaurants(food: String, location: CLLocation, radiusKm: Double) async {
        startLoadingMessages()
        isLoading = true
        errorMessage = nil
        restaurants = []

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = food
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radiusKm * 1000,
            longitudinalMeters: radiusKm * 1000
        )

        let search = MKLocalSearch(request: request)

        do {
            let response = try await search.start()
            let items = response.mapItems

            if items.isEmpty {
                errorMessage = nil
            }

            let sorted = items.sorted {
                guard let loc1 = $0.placemark.location, let loc2 = $1.placemark.location else { return false }
                return location.distance(from: loc1) < location.distance(from: loc2)
            }

            restaurants = sorted.compactMap { item in
                Restaurant(
                    name: item.name ?? "Sconosciuto",
                    address: item.placemark.title ?? "Indirizzo non disponibile"
                )
            }

        } catch {
            errorMessage = "Errore durante la ricerca dei ristoranti."
        }

        isLoading = false
        stopLoadingMessages()
    }

    // MARK: - Gestione messaggi dinamici
    private func startLoadingMessages() {
        //stopLoadingMessages()

        currentMessageIndex = 0
        currentLoadingMessage = loadingMessages[currentMessageIndex]

        messageTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.currentMessageIndex = (self.currentMessageIndex + 1) % self.loadingMessages.count
                self.currentLoadingMessage = self.loadingMessages[self.currentMessageIndex]
            }
        }
        RunLoop.main.add(messageTimer!, forMode: .common)
    }

    private func stopLoadingMessages() {
        messageTimer?.invalidate()
        messageTimer = nil
    }
}

struct Restaurant: Identifiable {
    let id = UUID()
    let name: String
    let address: String
}
