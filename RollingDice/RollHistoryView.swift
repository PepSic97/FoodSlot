//
//  ContentView.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//

import SwiftUI
import CoreData

struct RollHistoryView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \RollResult.timestamp, ascending: false)],
        animation: .default
    ) private var results: FetchedResults<RollResult>

    var body: some View {
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
        }
        .navigationTitle("Storico Tiri")
    }
}
