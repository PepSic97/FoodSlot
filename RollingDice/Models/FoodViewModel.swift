//
//  FoodViewModel.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 10/10/25.
//

import Foundation

@MainActor
class FoodViewModel: ObservableObject {
    @Published var localFoodList: [String] = []

    func loadFoodsIfNeeded() {
        if localFoodList.isEmpty {
            localFoodList = [
                "Pizza", "Pasta", "Hamburger", "Sushi", "Tacos",
                "Kebab", "Insalata", "Gelato", "Steak", "Ramen",
                "Paella", "Falafel"
            ]
        }
    }
}
