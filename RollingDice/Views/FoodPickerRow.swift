//
//  FoodPickerRow.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 20/10/25.
//

import SwiftUI

struct FoodPickerRow: View {
    let label: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 100, alignment: .leading)
                .font(.subheadline)

            Spacer()

            Picker(selection: $selection, label: Text(selection.isEmpty ? "Scegli" : selection)) {
                ForEach(options, id: \.self) { food in
                    Text(food).tag(food)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .tint(.blue)
        }
        .padding(.horizontal)
    }
}
