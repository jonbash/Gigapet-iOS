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

    // MARK: - Objects

    func testEncodingEntryRepDoesNotThrow() {
        XCTAssertNoThrow(_ = try encodeEntryRep())
    }

    func testDecodingEntryRep() {
        XCTAssertNotNil(entryRepData)
        XCTAssertNoThrow(try getEntryRepFromData())
        let decodedRep = try? getEntryRepFromData()
        XCTAssertNotNil(decodedRep)
        XCTAssertEqual(entryRep, decodedRep)
    }

    func testEntryRep() {
        let entry = newEntry()
        if let computedRep = entry.representation {
            let newEntry = FoodEntry(from: computedRep, context: context)
            XCTAssertEqual(newEntry.representation, computedRep)
        } else { XCTAssert(false) }
    }

    func testFoodCategoryColor() {
        let category = FoodCategory.vegetable
        XCTAssertEqual(category.color, .green)
    }

    func testPeriodDates() {
        let date = Date()
        let period = EntryDisplayPeriod(type: .day, entries: [], referenceDate: date)
        XCTAssertEqual(date.components(for: .day), period.startDateComponents)
    }

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
