//
//  TextInputView.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//


import SwiftUI

struct TextInputView: View {
    @Binding var wheel: Wheel
    @StateObject private var foodViewModel = FoodViewModel()
    @State private var navigateToWheel = false
    @State private var localSelections: [String]
    
    init(wheel: Binding<Wheel>) {
        self._wheel = wheel
        self._localSelections = State(initialValue: wheel.wrappedValue.options)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            textInputTitleView()
            textInputBodyView()
            textInputButtonView()
            Spacer()
        }
        .onAppear {
            foodViewModel.loadFoodsIfNeeded()
            syncArraysIfNeeded()
        }
        .navigationDestination(isPresented: $navigateToWheel) {
            WheelView(options: wheel.options)
        }
    }
}

// MARK: - Views
extension TextInputView {
    @ViewBuilder
    private func textInputTitleView() -> some View {
        Text("Scegli un cibo per ogni spicchio della ruota")
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding(.top)
    }
    
    @ViewBuilder
    private func textInputBodyView() -> some View {
        if localSelections.count == wheel.options.count {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<wheel.options.count, id: \.self) { index in
                        FoodPickerRow(
                            label: "Opzione \(index + 1)",
                            selection: Binding(
                                get: { localSelections[index] },
                                set: { newValue in
                                    localSelections[index] = newValue
                                    wheel.options[index] = newValue
                                }
                            ),
                            options: foodViewModel.localFoodList
                        )
                    }
                }
                .padding(.vertical)
            }
        } else {
            ProgressView("Caricamento...")
                .onAppear { syncArraysIfNeeded() }
        }
    }
    
    @ViewBuilder
    private func textInputButtonView() -> some View {
        Button("Vai alla ruota") {
            navigateToWheel = true
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
}

// MARK: - Functions
extension TextInputView {
    private func syncArraysIfNeeded() {
        if wheel.options.count != localSelections.count {
            localSelections = wheel.options
        }
        if let first = foodViewModel.localFoodList.first {
            for i in 0..<wheel.options.count {
                if wheel.options[i].isEmpty {
                    wheel.options[i] = first
                    localSelections[i] = first
                }
            }
        }
    }
}
