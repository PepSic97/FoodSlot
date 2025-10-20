//
//  RestaurantListView.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 13/10/25.
//

import SwiftUI
import CoreLocation

struct RestaurantListView: View {
    @StateObject private var viewModel = RestaurantListViewModel()
    @StateObject private var locationManager = LocationManager()
    let food: String

    // 🔹 Serve per non mostrare “nessun ristorante” prima che la ricerca sia partita
    @State private var hasLoadedOnce = false

    var body: some View {
        VStack {
            Text("Ristoranti con \(food)")
                .font(.largeTitle)
                .padding(.top)

            Group {
                if viewModel.isLoading || !hasLoadedOnce {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Sto cercando i ristoranti...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)

                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 10) {
                        Text("⚠️ \(error)")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Riprova") {
                            retryFetch()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 50)

                } else if viewModel.restaurants.isEmpty {
                    VStack(spacing: 12) {
                        Text("😔 Nessun ristorante trovato")
                            .font(.headline)
                        Button("Riprova") {
                            retryFetch()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 50)

                } else {
                    List(viewModel.restaurants) { restaurant in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(restaurant.name)
                                .font(.headline)
                            Text(restaurant.address)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("⭐️ \(String(format: "%.1f", restaurant.rating))")
                                .font(.footnote)
                                .foregroundColor(.orange)
                        }
                        .padding(.vertical, 5)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .animation(.easeInOut, value: viewModel.isLoading)
        }
        .onAppear {
            startSearchIfNeeded()
        }
        .onChange(of: locationManager.lastLocation) { _, newLocation in
            if let location = newLocation {
                Task {
                    await viewModel.fetchNearbyRestaurants(food: food, location: location)
                    hasLoadedOnce = true
                }
            }
        }
    }

    private func startSearchIfNeeded() {
        guard !viewModel.isLoading else { return }

        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestPermission()
        } else if let location = locationManager.lastLocation {
            Task {
                await viewModel.fetchNearbyRestaurants(food: food, location: location)
                hasLoadedOnce = true
            }
        } else {
            locationManager.requestLocation()
        }
    }

    private func retryFetch() {
        if let location = locationManager.lastLocation {
            Task {
                await viewModel.fetchNearbyRestaurants(food: food, location: location)
                hasLoadedOnce = true
            }
        } else {
            locationManager.requestLocation()
        }
    }
}
