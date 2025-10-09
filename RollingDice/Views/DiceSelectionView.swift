//
//  DiceSelectionView.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//

import SwiftUI

struct DiceSelectionView: View {
    @State private var selectedSides = 6
    @State private var navigate = false

    let availableDice = [4, 6, 8, 10, 12, 20]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Scegli il tipo di dado")
                    .font(.title)
                
                Picker("Tipo di dado", selection: $selectedSides) {
                    ForEach(availableDice, id: \.self) { sides in
                        Text("d\(sides)").tag(sides)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)

                NavigationLink(
                    destination: TextInputView(die: Die(sides: selectedSides, faceTexts: Array(repeating: "", count: selectedSides))),
                    isActive: $navigate
                ) {
                    EmptyView()
                }

                Button("Avanti") {
                    navigate = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}
