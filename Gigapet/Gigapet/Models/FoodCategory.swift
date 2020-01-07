//
//  FoodCategory.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

enum FoodCategory {
    case fruit
    case vegetable
    case wholeGrains
    case meat
    case dairy
    case fatsAndOils
    case treats
    case other(String)

    var rawValue: String {
        switch self {
        case .fruit: return "fruit"
        case .vegetable: return "vegetable"
        case .wholeGrains: return "wholeGrains"
        case .meat: return "meat"
        case .dairy: return "dairy"
        case .fatsAndOils: return "fatsAndOils"
        case .treats: return "treats"
        case .other(let type): return type
        @unknown default: fatalError("Unknown food category")
        }
    }

    init?(rawValue: String) {
        if let possibleValue = PossibleValue(rawValue: rawValue) {
            switch possibleValue {
            case .fruit: self = .fruit
            case .vegetable: self = .vegetable
            case .wholeGrains: self = .wholeGrains
            case .meat: self = .meat
            case .dairy: self = .dairy
            case .fatsAndOils: self = .fatsAndOils
            case .treats: self = .treats
            }
        } else {
            self = .other(rawValue)
        }
    }

    private enum PossibleValue: String {
        case fruit
        case vegetable
        case wholeGrains
        case meat
        case dairy
        case fatsAndOils
        case treats
    }
}
