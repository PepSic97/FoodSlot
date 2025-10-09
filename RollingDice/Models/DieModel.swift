//
//  DieModel.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//

import Foundation

struct Die: Identifiable, Codable {
    let id = UUID()
    let sides: Int
    var faceTexts: [String]
}
