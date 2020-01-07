//
//  FoodEntry+Representation.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import CoreData
import NetworkHandler

extension FoodEntry {

    // MARK: - Representation Struct

    struct Representation: Codable {
        var foodCategory: FoodCategory
        var foodName: String
        var dateFed: Date
        var foodAmount: Int
        var identifier: Int?

        enum CodingKeys: String, CodingKey {
            case foodCategory = "food_category"
            case foodName = "food_name"
            case dateFed = "date_fed"
            case foodAmount = "food_amount"
            case identifier
        }

        init(
            foodCategory: FoodCategory,
            foodName: String,
            foodAmount: Int,
            dateFed: Date = Date(),
            identifier: Int? = nil
        ) {
            self.foodCategory = foodCategory
            self.foodName = foodName
            self.foodAmount = foodAmount
            self.dateFed = dateFed

            self.identifier = identifier
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let categoryString = try container.decode(String.self, forKey: .foodCategory)

            self.foodCategory = FoodCategory(rawValue: categoryString) ?? .other(categoryString)
            self.foodName = try container.decode(String.self, forKey: .foodName)
            self.foodAmount = try container.decode(Int.self, forKey: .foodAmount)
            self.dateFed = try container.decode(Date.self, forKey: .dateFed)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(foodCategory.rawValue, forKey: .foodCategory)
            try container.encode(foodName, forKey: .foodName)
            try container.encode(foodAmount, forKey: .foodAmount)
            try container.encode(dateFed, forKey: .dateFed)
        }
    }

    // MARK: - Computed / Init

    var representation: Representation? {
        guard let categoryString = self.foodCategory,
            let category = FoodCategory(rawValue: categoryString),
            let foodName = self.foodName,
            let dateFed = self.dateFed
            else { return nil }

        let foodAmount = Int(self.foodAmount)
        let identifier: Int? = self.identifier == -1 ? nil : Int(self.identifier)

        return Representation(
            foodCategory: category,
            foodName: foodName,
            foodAmount: foodAmount,
            dateFed: dateFed,
            identifier: identifier)
    }

    convenience init(
        from representation: Representation,
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext
    ) {
        self.init(context: context)
        self.foodCategory = representation.foodCategory.rawValue
        self.foodName = representation.foodName
        self.foodAmount = Int64(representation.foodAmount)
        self.dateFed = representation.dateFed

        if let identifier = representation.identifier {
            self.identifier = Int64(identifier)
        }
    }
}
