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
    @State private var searchRadius: Double = 2
    @State private var visibleCount = 10
    
    let food: String
    
    var body: some View {
        VStack {
            restaurantsTitle()
            radiusSelector()
            groupListLoading()
        }
        .onAppear {
            startSearchIfNeeded()
        }
        .onChange(of: locationManager.lastLocation) { _, newLocation in
            fetchingNearbyRestaurants(newLocation: newLocation)
        }
        .onChange(of: searchRadius) { _, _ in
            retryFetch()
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
    private func radiusSelector() -> some View {
        VStack(spacing: 4) {
            HStack {
                Text("Raggio di ricerca: \(Int(searchRadius)) km")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            
            Slider(value: $searchRadius, in: 1...10, step: 1)
                .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func restaurantsProgressView() -> some View {
        VStack(spacing: 16) {
            ProgressView()
            Text(viewModel.currentLoadingMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 250)
                .animation(.easeInOut(duration: 0.5), value: viewModel.currentLoadingMessage)
        }
        .padding(.top, 50)
    }

    @ViewBuilder
    private func groupListLoading() -> some View {
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
        List {
            ForEach(Array(viewModel.restaurants.prefix(visibleCount))) { restaurant in
                VStack(alignment: .leading, spacing: 5) {
                    Text(restaurant.name)
                        .font(.headline)
                    Text(restaurant.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
            }
            
            if visibleCount < viewModel.restaurants.count {
                HStack {
                    Spacer()
                    ProgressView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                visibleCount += 10
                            }
                        }
                    Spacer()
                }
            }
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
                await viewModel.fetchNearbyRestaurants(food: food, location: location, radiusKm: searchRadius)
                hasLoadedOnce = true
            }
        } else {
            locationManager.requestLocation()
        }
    }
    
    private func retryFetch() {
        if let location = locationManager.lastLocation {
            Task {
                await viewModel.fetchNearbyRestaurants(food: food, location: location, radiusKm: searchRadius)
                hasLoadedOnce = true
            }
        } else {
            locationManager.requestLocation()
        }
    }
    
    private func fetchingNearbyRestaurants(newLocation: CLLocation?) {
        if let location = newLocation {
            Task {
                await viewModel.fetchNearbyRestaurants(food: food, location: location, radiusKm: searchRadius)
                hasLoadedOnce = true
            }
        }
    }
}
