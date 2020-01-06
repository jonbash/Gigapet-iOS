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

    // MARK: - Representation

    struct Representation: Codable {
        var foodCategory: FoodCategory
        var timestamp: Date
        var uuid: UUID

        enum CodingKeys: CodingKey {
            case foodCategory
            case timestamp
            case uuid
        }

        init(
            foodCategory: FoodCategory,
            timestamp: Date = Date(),
            uuid: UUID = UUID()
        ) {
            self.foodCategory = foodCategory
            self.timestamp = timestamp
            self.uuid = uuid
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            guard let category = FoodCategory(rawValue: try container
                .decode(String.self, forKey: .foodCategory))
                else { throw NetworkError.dataCodingError(specifically: NSError()) }
            guard let uuid = UUID(uuidString:
                try container.decode(String.self, forKey: .uuid))
                else { throw NetworkError.dataCodingError(specifically: NSError()) }

            self.foodCategory = category
            self.timestamp = try container.decode(Date.self, forKey: .timestamp)
            self.uuid = uuid
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(foodCategory.rawValue, forKey: .foodCategory)
            try container.encode(timestamp, forKey: .timestamp)
            try container.encode(uuid, forKey: .uuid)
        }
    }

    // MARK: - Init

    convenience init(
        from representation: Representation,
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext
    ) {
        self.init(context: context)
        self.foodCategory = representation.foodCategory.rawValue
        self.timestamp = representation.timestamp
        self.uuid = representation.uuid
    }
}
