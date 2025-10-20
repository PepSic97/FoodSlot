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
    @State private var hasLoadedOnce = false
    let food: String
    
    var body: some View {
        VStack {
            restaurantsTitle()
            Group {
                if viewModel.isLoading || !hasLoadedOnce {
                    restaurantsProgressView()
                } else if let error = viewModel.errorMessage {
                    restaurantsErrorView(error: error)
                } else if viewModel.restaurants.isEmpty {
                    restaurantsEmptyView()
                } else {
                    restaurantsListView()
                }
            }
            .animation(.easeInOut, value: viewModel.isLoading)
        }
        .onAppear {
            startSearchIfNeeded()
        }
        .onChange(of: locationManager.lastLocation) { _, newLocation in
            fetchingNearbyRestaurants(newLocation: newLocation)
        }
    }
}

//MARK: Views
extension RestaurantListView {
    @ViewBuilder
    private func restaurantsTitle() -> some View {
        Text("Ristoranti con \(food)")
            .font(.largeTitle)
            .padding(.top)
    }
    
    @ViewBuilder
    private func restaurantsProgressView() -> some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Sto cercando i ristoranti...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 50)
    }
    
    @ViewBuilder
    private func restaurantsErrorView(error: String) -> some View {
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
        
    }
    
    @ViewBuilder
    private func restaurantsEmptyView() -> some View {
        VStack(spacing: 12) {
            Text("😔 Nessun ristorante trovato")
                .font(.headline)
            Button("Riprova") {
                retryFetch()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 50)
    }
    
    @ViewBuilder
    private func restaurantsListView() -> some View {
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



//MARK: Functions
extension RestaurantListView {
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
    
    private func fetchingNearbyRestaurants(newLocation: CLLocation?) {
        if let location = newLocation {
            Task {
                await viewModel.fetchNearbyRestaurants(food: food, location: location)
                hasLoadedOnce = true
            }
        }
    }
    
}
