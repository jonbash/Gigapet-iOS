//
//  FoodEntry+Convenience.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import CoreData

extension FoodEntry {
    convenience init(
        category: FoodCategory,
        timestamp: Date = Date(),
        uuid: UUID = UUID(),
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext
    ) {
        self.init(context: context)
        self.foodCategory = category.rawValue
        self.timestamp = timestamp
        self.uuid = uuid
    }
}
