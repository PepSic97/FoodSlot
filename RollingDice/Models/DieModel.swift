//
//  DieModel.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//

import Foundation

struct Die {
    var sides: Int
    var faceTexts: [String]

    init(sides: Int, faceTexts: [String]? = nil) {
        self.sides = sides
        if let ft = faceTexts, ft.count == sides {
            self.faceTexts = ft
        } else {
            self.faceTexts = Array(repeating: "", count: sides)
        }
    }
}
