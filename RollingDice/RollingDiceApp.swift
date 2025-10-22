//
//  RollingDiceApp.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//

import SwiftUI

@main
struct RollingDiceApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            LandingPageView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
