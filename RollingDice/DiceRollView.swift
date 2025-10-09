//
//  DiceRollView.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//

import SwiftUI

import CoreData

struct DiceRollView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isRolling = false
    @State private var hasRolled = false
    @State private var result: String?

    var die: Die

    var body: some View {
        VStack {
            // ... la tua vista 3D del dado ...
            if let result = result {
                Text("Risultato: \(result)")
                    .font(.title)
                    .padding()
            }

            Button("Tira il dado") {
                guard !hasRolled else { return } // ✅ evita tiri multipli
                rollDie()
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .disabled(hasRolled)
        }
    }

    private func rollDie() {
        isRolling = true

        // Simula un piccolo ritardo per l’animazione
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let randomIndex = Int.random(in: 0..<die.faceTexts.count)
            let selectedFace = die.faceTexts[randomIndex]
            result = selectedFace
            hasRolled = true
            saveResult(selectedFace)
        }
    }

    private func saveResult(_ value: String) {
        let newResult = RollResult(context: viewContext)
        newResult.value = value
        newResult.timestamp = Date()

        do {
            try viewContext.save()
        } catch {
            print("Errore nel salvataggio del risultato: \(error)")
        }
    }
}

