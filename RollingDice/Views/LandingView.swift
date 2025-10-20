//
//  LandingView.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                titleView()
                goToRoll()
                goToHistory()
            }
            .padding()
        }
    }
}

extension LandingView {
    @ViewBuilder
    private func titleView() -> some View {
        Text("🎲 DieApp")
            .font(.largeTitle)
            .bold()
    }
    
    @ViewBuilder
    private func goToRoll() -> some View {
        NavigationLink("Tira un dado") {
            DiceSelectionView()
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
        .font(.title2)
    }
    
    @ViewBuilder
    private func goToHistory() -> some View {
        NavigationLink("Storico Tiri") {
            RollHistoryView()
        }
        .buttonStyle(.bordered)
        .tint(.gray)
        .font(.title2)
    }
}
