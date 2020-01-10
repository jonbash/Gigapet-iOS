//
//  FoodEntry+Convenience.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import CoreData

extension FoodEntry {
    static let nilID: Int64 = -1

    convenience init(
        category: FoodCategory,
        foodName: String,
        foodAmount: Int,
        dateFed: Date = Date(),
        identifier: Int? = nil,
        context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.foodCategory = category.rawValue
        self.foodName = foodName
        self.foodAmount = Int64(foodAmount)
        self.dateFed = dateFed
        if let identifier = identifier {
            self.identifier = Int64(identifier)
        } else {
            self.identifier = FoodEntry.nilID
        }
    }
}
