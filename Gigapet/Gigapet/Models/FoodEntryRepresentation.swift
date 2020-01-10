//
//  FoodEntryRepresentation.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import CoreData
import NetworkHandler

// MARK: - Representation

struct FoodEntryRepresentation: Codable {
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
        case identifier = "id"
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
        guard let dateAsDouble: Double = {
            if let dateAsString = try? container.decode(String.self, forKey: .dateFed) {
                return Double(dateAsString)
            } else {
                return try? container.decode(Double.self, forKey: .dateFed)
            }
        }() else {
            throw NetworkError.dataCodingError(specifically: GigapetError(
                text: "Failed to initialize number from encoded date"))
        }

        self.foodCategory = FoodCategory(rawValue: categoryString) ?? .treats
        self.foodName = try container.decode(String.self, forKey: .foodName)
        self.foodAmount = try container.decode(Int.self, forKey: .foodAmount)
        self.dateFed = Date(timeIntervalSince1970: dateAsDouble)

        self.identifier = try? container.decode(Int.self, forKey: .identifier)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let dateAsDouble = dateFed.timeIntervalSince1970

        try container.encode(foodCategory.rawValue, forKey: .foodCategory)
        try container.encode(foodName, forKey: .foodName)
        try container.encode(foodAmount, forKey: .foodAmount)
        try container.encode(dateAsDouble, forKey: .dateFed)
    }
}

// MARK: - Computed / Init / Update

extension FoodEntry {
    var representation: FoodEntryRepresentation? {
        guard let categoryString = self.foodCategory,
            let category = FoodCategory(rawValue: categoryString),
            let foodName = self.foodName,
            let dateFed = self.dateFed
            else { return nil }

        let foodAmount = Int(self.foodAmount)
        let identifier = (self.identifier == FoodEntry.nilID) ? nil : Int(self.identifier)

        return FoodEntryRepresentation(
            foodCategory: category,
            foodName: foodName,
            foodAmount: foodAmount,
            dateFed: dateFed,
            identifier: identifier)
    }

    convenience init(
        from representation: FoodEntryRepresentation,
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext
    ) {
        self.init(context: context)
        self.update(from: representation, context: context)
    }

    func update(
        from representation: FoodEntryRepresentation,
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext
    ) {
        self.foodCategory = representation.foodCategory.rawValue
        self.foodName = representation.foodName
        self.foodAmount = Int64(representation.foodAmount)
        self.dateFed = representation.dateFed

        if let identifier = representation.identifier {
            self.identifier = Int64(identifier)
        } else {
            self.identifier = FoodEntry.nilID
        }
    }
}
