//
//  TextInputView.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//


import SwiftUI

struct TextInputView: View {
    @Binding var die: Die
    @StateObject private var foodViewModel = FoodViewModel()
    @State private var navigateToDiceRoll = false
    @State private var localSelections: [String]

    // 🔹 Inizializziamo localSelections in base al dado ricevuto
    init(die: Binding<Die>) {
        self._die = die
        self._localSelections = State(initialValue: die.wrappedValue.faceTexts)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Scegli un cibo per ogni faccia del d\(die.sides)")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.top)

            if localSelections.count == die.sides {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(0..<die.sides, id: \.self) { index in
                            FoodPickerRow(
                                label: "Faccia \(index + 1)",
                                selection: Binding(
                                    get: {
                                        localSelections[index]
                                    },
                                    set: { newValue in
                                        localSelections[index] = newValue
                                        die.faceTexts[index] = newValue
                                    }
                                ),
                                options: foodViewModel.localFoodList
                            )
                        }
                    }
                    .padding(.vertical)
                }
            } else {
                // In caso di desincronizzazione temporanea, mostra un caricamento
                ProgressView("Caricamento...")
                    .onAppear {
                        syncArraysIfNeeded()
                    }
            }

            Button("Lancia il dado") {
                navigateToDiceRoll = true
            }
            .buttonStyle(.borderedProminent)
            .padding()

            Spacer()
        }
        .onAppear {
            foodViewModel.loadFoodsIfNeeded()
            syncArraysIfNeeded()
        }
        .navigationDestination(isPresented: $navigateToDiceRoll) {
            DiceRollView(die: die)
        }
    }

    // 🔹 Sincronizza la lunghezza di die.faceTexts e localSelections
    private func syncArraysIfNeeded() {
        if die.faceTexts.count != die.sides {
            die.faceTexts = Array(repeating: "", count: die.sides)
        }
        if localSelections.count != die.sides {
            localSelections = die.faceTexts
        }

        // Imposta default se vuoti
        if let firstFood = foodViewModel.localFoodList.first {
            for i in 0..<die.sides {
                if die.faceTexts[i].isEmpty {
                    die.faceTexts[i] = firstFood
                    localSelections[i] = firstFood
                }
            }
        }
    }
}
