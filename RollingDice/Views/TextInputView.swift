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

    init(die: Binding<Die>) {
        self._die = die
        self._localSelections = State(initialValue: die.wrappedValue.faceTexts)
    }

    var body: some View {
        VStack(spacing: 16) {
            textInputTitle()
            populateView()
            diceToss()
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

}

extension TextInputView {
    @ViewBuilder
    private func textInputTitle() -> some View {
        Text("Scegli un cibo per ogni faccia del d\(die.sides)")
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding(.top)
    }
    
    @ViewBuilder
    private func populateView() -> some View {
        if localSelections.count == die.sides {
            ScrollView {
                facesInputRow()
            }
        } else {
            progressViewSync()
        }
    }
    
    
    @ViewBuilder
    private func facesInputRow() -> some View {
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
    
    
    @ViewBuilder
    private func progressViewSync() -> some View {
        ProgressView("Caricamento...")
            .onAppear {
                syncArraysIfNeeded()
            }
    }
    
    @ViewBuilder
    private func diceToss() -> some View {
        Button("Lancia il dado") {
            navigateToDiceRoll = true
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
}

//MARK: Functions
extension TextInputView {
    private func syncArraysIfNeeded() {
        if die.faceTexts.count != die.sides {
            die.faceTexts = Array(repeating: "", count: die.sides)
        }
        if localSelections.count != die.sides {
            localSelections = die.faceTexts
        }

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
