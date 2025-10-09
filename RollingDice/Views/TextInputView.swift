//
//  TextInputView.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//


import SwiftUI

struct TextInputView: View {
    @State var die: Die
    @State private var navigate = false

    var body: some View {
        VStack {
            Text("Inserisci un testo per ogni faccia")
                .font(.headline)
                .padding(.bottom, 10)

            List(0..<die.sides, id: \.self) { index in
                TextField("Faccia \(index + 1)", text: Binding(
                    get: { die.faceTexts[index] },
                    set: { die.faceTexts[index] = $0 }
                ))
            }

            NavigationLink(
                destination: DiceRollView(die: die),
                isActive: $navigate
            ) { EmptyView() }

            Button("Vai al lancio") {
                navigate = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("d\(die.sides)")
    }
}
