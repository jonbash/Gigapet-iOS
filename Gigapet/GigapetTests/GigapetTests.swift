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

    // MARK: - Setup

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

    override func tearDown() {
        super.tearDown()
        entryController.deleteAllLocalEntries()
    }

    // MARK: - Object Tests

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

    // MARK: - Entry Controller Tests

    func testAddingEntry() {
        setUpEntryController(withError: false)
        let expectation = requestExpectation()

        entryController.addEntry(
            category: entryRep.foodCategory,
            foodName: entryRep.foodName,
            foodAmount: entryRep.foodAmount
        ) { error in
            XCTAssertNil(error)
            if let decodedRep = try? self.getEntryRepFromData() {
                XCTAssertEqual(decodedRep, self.entryRep)
            } else { XCTAssert(false) }

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testUpdateEntry() {
        setUpEntryController(withError: false)
        let entry = newEntry()
        let oldEntryRep = entry.representation
        let expectation = requestExpectation()

        entryController.updateFoodEntry(
            entry,
            withCategory: entryRep.foodCategory,
            foodName: entryRep.foodName,
            foodAmount: entryRep.foodAmount,
            timestamp: entryRep.dateFed
        ) { error in
            XCTAssertNil(error)
            if let decodedRep = try? self.getEntryRepFromData() {
                XCTAssertEqual(decodedRep, self.entryRep)
                XCTAssertNotEqual(oldEntryRep, decodedRep)
            } else { XCTAssert(false) }

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testDeleteEntry() {
        setUpEntryController(withError: false)
        let entry = newEntry()
        let expectation = requestExpectation()

        entryController.deleteFoodEntry(entry) { error in
            XCTAssertNil(error)
            XCTAssertNil(entry.managedObjectContext)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    // MARK: - Misc Tests

    func testKeychain() {
        let authController = AuthController()
        let putInfoInKeychain = {
            try authController.putUserInfoInKeychain(self.user)
        }
        let getInfoFromKeychain = {
            try authController.fetchCurrentUserInfo()
        }
        XCTAssertNoThrow(putInfoInKeychain)
        try? putInfoInKeychain()
        XCTAssertNoThrow(getInfoFromKeychain)
        if let fetchedInfo = try? getInfoFromKeychain() {
            XCTAssertEqual(fetchedInfo, user)
        } else {
            XCTAssert(false)
        }
    }

    func testCoreDataStackEmptySave() {
        XCTAssertNoThrow(try CoreDataStack.shared.save(in: context))
    }

    // MARK: - Helper Methods

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
        return expectation(description: "Finished mock network request - \(Date())")
    }
}
