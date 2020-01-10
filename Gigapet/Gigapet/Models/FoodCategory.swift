//
//  FoodCategory.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit

enum FoodCategory: String, CaseIterable {
    case fruit
    case vegetable
    case wholeGrains = "Whole Grains"
    case meat
    case dairy
    case fatsAndOils = "Fats & Oils"
    case treats

    var color: UIColor {
        switch self {
        case .fruit: return .cyan
        case .vegetable: return .green
        case .wholeGrains: return .brown
        case .meat: return .red
        case .dairy: return .yellow
        case .fatsAndOils: return .orange
        case .treats: return .magenta
        }
    }

    var shortText: String {
        switch self {
        case .fruit: return "fruit"
        case .vegetable: return "veg"
        case .wholeGrains: return "grain"
        case .meat: return "meat"
        case .dairy: return "dairy"
        case .fatsAndOils: return "fat"
        case .treats: return "treat"
        }
    }
}
