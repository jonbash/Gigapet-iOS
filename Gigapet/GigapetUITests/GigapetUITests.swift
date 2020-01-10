//
//  GigapetUITests.swift
//  GigapetUITests
//
//  Created by Jon Bash on 2020-01-05.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import XCTest

class GigapetUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["UITesting"]
        app.launch()
    }

    func testAuthScreen() {
        let homeNavBar = app.navigationBars["Home"]
        let logOutButton = homeNavBar.buttons["Log Out"]

        if homeNavBar.exists && logOutButton.exists {
            logOutButton.tap()
        }

        let welcomeHeader = app.staticTexts["Welcome to Lambdi Pet"]
        let userNameLabel = app.staticTexts["User Name"]
        let petNameLabel = app.staticTexts["Pet Name"]
        let passwordLabel = app.staticTexts["Password"]

        let userNameField = app.textFields["User Name"]
        let petNameField = app.textFields["Pet Name"]
        let passwordField = app.textFields["Password"]

        let authTypeControl = app.segmentedControls.element
        let loginSegment = authTypeControl.buttons["Log In"]
        let registerSegment = authTypeControl.buttons["Register"]

        XCTAssert(welcomeHeader.exists)
        XCTAssert(userNameLabel.exists)
        XCTAssert(passwordLabel.exists)
        XCTAssert(petNameLabel.exists)

        XCTAssert(authTypeControl.exists)
        XCTAssert(loginSegment.exists)
        XCTAssert(registerSegment.exists)

        XCTAssert(userNameField.exists)
        XCTAssert(petNameField.exists)
        XCTAssert(passwordField.exists)

        loginSegment.tap()

        XCTAssertFalse(petNameLabel.exists && petNameLabel.isHittable)
        XCTAssertFalse(petNameField.exists && petNameField.isHittable)

        userNameField.tap()
        userNameField.typeText("test")
        passwordField.tap()
        passwordField.typeText("password")

        app.buttons.containing(.staticText, identifier: "Log In").element.tap()

        let loggedIn = expectation(
            for: NSPredicate(format: "exists == 1"),
            evaluatedWith: homeNavBar,
            handler: nil)
        wait(for: [loggedIn], timeout: 5)

        XCTAssert(homeNavBar.exists)
    }

    func testExample() {

    }
}
