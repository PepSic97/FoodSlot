//
//  DiceRollView.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//

import SwiftUI
import CoreData

struct WheelView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var isSpinning = false
    @State private var result: String? = nil
    @State private var hasPlayed = false
    @State private var history: [String] = []

    let options: [String]
    
    @State private var currentIndex = 0
    @State private var timer: Timer? = nil
    @State private var slotColor: Color = .blue
    
    var body: some View {
        VStack(spacing: 20) {
            slotText()
            slotView()
            
            buttonShow()
            if let result = result {
                VStack(spacing: 8) {
                    resultView(result: result)
                    navigateToList(result: result)
                }
                .padding(.top, 6)
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - Views
extension WheelView {
    
    @ViewBuilder
    private func slotText() -> some View {
        Text("Gioca!")
            .font(.largeTitle)
            .bold()
    }
    
    @ViewBuilder
    private func slotView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(slotColor.gradient.opacity(0.9)) // <-- sfumatura leggera
                .frame(width: 160, height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.6), lineWidth: 3)
                )
                .shadow(radius: 8)
                .animation(.easeInOut(duration: 0.25), value: slotColor) // <-- animazione fluida del colore
            
            VStack(spacing: 0) {
                ForEach(displayedOptions(), id: \.self) { item in
                    Text(item)
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 140, height: 40)
                }
            }
            .mask(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .white, location: 0.3),
                        .init(color: .white, location: 0.7),
                        .init(color: .clear, location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipped()
        }
        .frame(height: 120)
    }
    
    
    @ViewBuilder
    private func buttonShow() -> some View {
        if !hasPlayed {
            Button(action: spinSlot) {
                Text(isSpinning ? "Sto girando…" : "Gira la slot")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSpinning ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(isSpinning)
            .padding(.horizontal)
            .transition(.opacity)
            .animation(.easeInOut, value: hasPlayed)
        }
    }
    
    
    @ViewBuilder
    private func resultView(result: String) -> some View {
        Text("Ha vinto: \(result)")
            .font(.title2)
            .bold()
    }
    
    @ViewBuilder
    private func navigateToList(result: String) -> some View {
        NavigationLink("Cerca ristoranti vicini") {
            RestaurantListView(food: result)
        }
        .buttonStyle(.borderedProminent)
    }
}

// MARK: - Functions
extension WheelView {
    private func displayedOptions() -> [String] {
        guard !options.isEmpty else { return [] }
        let prev = (currentIndex - 1 + options.count) % options.count
        let next = (currentIndex + 1) % options.count
        return [options[prev], options[currentIndex], options[next]]
    }
    
    private func spinSlot() {
        guard !options.isEmpty else { return }
        guard !isSpinning else { return }
        guard !hasPlayed else { return }

        isSpinning = true
        hasPlayed = true
        result = nil
        
        let totalSpins = Int.random(in: 35...55)
        var spins = 0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            spins += 1
            currentIndex = (currentIndex + 1) % options.count
            
            // Cambia colore gradualmente
            slotColor = randomBrightColor()
            
            if spins >= totalSpins {
                t.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    finishSpin()
                }
            }
        }
    }
    
    private func finishSpin() {
        let selected = options[currentIndex]
        result = selected
        history.append(selected)
        saveResultToCoreData(selected)
        isSpinning = false
        
        // Colore finale morbido e casuale
        withAnimation(.easeInOut(duration: 0.8)) {
            slotColor = randomBrightColor()
        }
    }
    
    private func saveResultToCoreData(_ value: String) {
        let newResult = RollResult(context: viewContext)
        newResult.timestamp = Date()
        newResult.value = value
        
        do {
            try viewContext.save()
        } catch {
            print("Errore salvataggio risultato: \(error)")
        }
    }
    
    /// Genera un colore casuale vivace ma bilanciato
    private func randomBrightColor() -> Color {
        Color(
            hue: Double.random(in: 0...1),
            saturation: 0.8,
            brightness: 0.9
        )
    }
}
