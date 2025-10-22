//
//  OptionCountSelectionView.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//

import SwiftUI

struct OptionCountSelectionView: View {
    @State private var optionCount = 2
    @State private var navigate = false
    @State private var wheel = Wheel(options: Array(repeating: "", count: 2))
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                optionCountTitleView()
                optionCountPickerView()
                optionCountButtonView()
            }
            .padding()
            .navigationDestination(isPresented: $navigate) {
                TextInputView(wheel: $wheel)
            }
        }
    }
}

// MARK: - Views
extension OptionCountSelectionView {
    @ViewBuilder
    private func optionCountTitleView() -> some View {
        Text("Scegli il numero di opzioni")
            .font(.title2)
            .padding(.top)
    }
    
    @ViewBuilder
    private func optionCountPickerView() -> some View {
        Picker("Numero di opzioni", selection: $optionCount) {
            ForEach(2...10, id: \.self) { count in
                Text("\(count)").tag(count)
            }
        }
        .pickerStyle(.wheel)
        .frame(height: 150)
    }
    
    @ViewBuilder
    private func optionCountButtonView() -> some View {
        Button("Avanti") {
            wheel = Wheel(options: Array(repeating: "", count: optionCount))
            navigate = true
        }
        .buttonStyle(.borderedProminent)
    }
}

// MARK: - Model
struct Wheel {
    var options: [String]
}
