//
//  GigapetTests.swift
//  GigapetTests
//
//  Created by Jon Bash on 2020-01-05.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import XCTest
@testable import Gigapet

class GigapetTests: XCTestCase {
    lazy var entryController = FoodEntryController(user: user)
    var user = UserInfo(id: 1, token: "testToken", petname: "Kilmonger")
    var entryRep = FoodEntryRepresentation(
        foodCategory: .dairy,
        foodName: "Milk",
        foodAmount: 3,
        dateFed: Date(timeIntervalSinceReferenceDate: 0),
        identifier: 7)
    lazy var entryRepData: Data? = try? self.encodeEntryRep()
    var context = CoreDataStack.shared.container.newBackgroundContext()
    lazy var returnData: Data? = try? JSONEncoder().encode([entryRep])


    // MARK: - Helpers

    func setUpEntryController(withError: Bool) {
        entryController = FoodEntryController(
            user: user,
            loader: NetworkMockingSession(
                mockData: returnData,
                mockError: withError ? GigapetError(text: "Ruh roh") : nil ))
    }

    func encodeEntryRep() throws -> Data {
        return try JSONEncoder().encode(entryRep)
    }

    func getEntryRepFromData() throws -> FoodEntryRepresentation? {
        guard let data = entryRepData else { return nil }

        return try JSONDecoder().decode(FoodEntryRepresentation.self, from: data)
    }

    func newEntry() -> FoodEntry {
        return FoodEntry(
            category: .meat,
            foodName: "Steak",
            foodAmount: 10,
            dateFed: Date(),
            identifier: 9,
            context: context)
    }

    func requestExpectation() -> XCTestExpectation {
        return expectation(description: "Finished mock network request")
    }
}
