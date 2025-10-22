//
//  LandingView.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//

import SwiftUI

struct LandingPageView: View {
    init() {
        // Imposta il colore blu per la tab bar (accent color)
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }

    var body: some View {
        TabView {
            spinTab()
            historyTab()
        }
        .tint(.blue)
    }
}


extension LandingPageView {
    @ViewBuilder
    private func spinTab() -> some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("🎡 Wheel Food")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Fai girare la ruota e scopri cosa mangiare!")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                NavigationLink("Inizia") {
                    OptionCountSelectionView()
                }
                .buttonStyle(.borderedProminent)
                .font(.title2)
            }
            .padding()
            .navigationTitle("Gira")
        }
        .tabItem {
            Label("Gira", systemImage: "play.circle.fill")
        }

    }
    
    
    @ViewBuilder
    private func historyTab() -> some View {
        NavigationStack {
            RollHistoryView()
                .navigationTitle("Storico")
        }
        .tabItem {
            Label("Storico", systemImage: "clock.fill")
        }

    }
}
