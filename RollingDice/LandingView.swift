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
                Text("🎲 DieApp")
                    .font(.largeTitle)
                    .bold()

                NavigationLink("Tira un dado") {
                    DiceSelectionView()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .font(.title2)

                NavigationLink("Storico Tiri") {
                    RollHistoryView()
                }
                .buttonStyle(.bordered)
                .tint(.gray)
                .font(.title2)

                Spacer()
            }
            .padding()
        }
    }
}
