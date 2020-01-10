//
//  Objects+Equatable.swift
//  GigapetTests
//
//  Created by Jon Bash on 2020-01-09.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
@testable import Gigapet

// MARK: - FoodEntryRep

extension FoodEntryRepresentation: Equatable {
    public static func == (
        _ lhs: FoodEntryRepresentation,
        _ rhs: FoodEntryRepresentation
    ) -> Bool {
        let identifierBasicallyEqual = (
            lhs.identifier == rhs.identifier ||
            lhs.identifier == nil ||
            rhs.identifier == nil)
        return (identifierBasicallyEqual &&
            lhs.foodName == rhs.foodName &&
            lhs.foodCategory == rhs.foodCategory &&
            lhs.foodAmount == rhs.foodAmount &&
            lhs.dateFed == rhs.dateFed)
    }
}

// MARK: - UserInfo

extension UserInfo: Equatable {
    public static func == (lhs: UserInfo, rhs: UserInfo) -> Bool {
        return lhs.id == rhs.id &&
            lhs.petname == rhs.petname &&
            lhs.token == rhs.token
    }
}
