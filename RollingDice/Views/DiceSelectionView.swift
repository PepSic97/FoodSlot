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
    @State private var die = Die(sides: 6, faceTexts: Array(repeating: "", count: 6))

    let availableDice = [4, 6, 8, 10, 12, 20]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                diceSelectTextView()
                pickerSelectionView()
                buttonView()
            }
            .padding()
            .navigationDestination(isPresented: $navigate) {
                TextInputView(die: $die)
            }
        }
    }
}

//MARK: Views
extension DiceSelectionView {
    @ViewBuilder
    private func diceSelectTextView() -> some View {
        Text("Scegli il tipo di dado")
            .font(.title)
    }
    
    @ViewBuilder
    private func pickerSelectionView() -> some View {
        Picker("Tipo di dado", selection: $selectedSides) {
            ForEach(availableDice, id: \.self) { sides in
                Text("d\(sides)").tag(sides)
            }
        }
        .pickerStyle(.wheel)
        .frame(height: 150)

    }
    
    @ViewBuilder
    private func buttonView() -> some View {
        Button("Avanti") {
            die = Die(sides: selectedSides, faceTexts: Array(repeating: "", count: selectedSides))
            navigate = true
        }
        .buttonStyle(.borderedProminent)
    }
}

