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

    override func setUp() {
        entryController = FoodEntryController(user: user)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
