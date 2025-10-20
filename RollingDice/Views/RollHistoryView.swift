//
//  ContentView.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//

import SwiftUI
import CoreData

struct RollHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \RollResult.timestamp, ascending: false)], animation: .default)
    private var results: FetchedResults<RollResult>
    
    var body: some View {
        NavigationView {
            Group {
                if results.isEmpty {
                    emptyHistoryView()
                } else {
                    historyView()
                }
            }
            .navigationTitle("Storico Tiri")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    deleteAllToolbar()
                }
            }
        }
    }
}


extension RollHistoryView {
    @ViewBuilder
    private func emptyHistoryView() -> some View {
        VStack {
            Spacer()
            Text("Fai qualche lancio!")
                .font(.title2)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func historyView() -> some View {
        List {
            ForEach(results) { result in
                VStack(alignment: .leading) {
                    Text(result.value ?? "—")
                        .font(.headline)
                    if let date = result.timestamp {
                        Text(date.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteSingle)
        }
    }
    
    @ViewBuilder
    private func deleteAllToolbar() -> some View {
        if !results.isEmpty {
            Button("Cancella tutti") {
                deleteAll()
            }
            .foregroundColor(.red)
        }
    }
}

// MARK: - Functions
extension RollHistoryView {
    private func deleteSingle(at offsets: IndexSet) {
        offsets.forEach { index in
            let result = results[index]
            viewContext.delete(result)
        }
        saveContext()
    }
    
    private func deleteAll() {
        results.forEach { result in
            viewContext.delete(result)
        }
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Errore nel salvataggio del contesto: \(error)")
        }
    }
    
}
