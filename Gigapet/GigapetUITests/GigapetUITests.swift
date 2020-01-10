//
//  GigapetUITests.swift
//  GigapetUITests
//
//  Created by Jon Bash on 2020-01-05.
//  Copyright © 2020 Jon Bash. All rights reserved.
//
// ↓ ↓ ↓ must disable force_cast rule for testing certain things! ↓ ↓ ↓
// swiftlint:disable force_cast

import XCTest

class GigapetUITests: XCTestCase {

    // MARK: - Setup

    var app: XCUIApplication!

    // login/register screen
    lazy var welcomeHeader = app.staticTexts["Welcome to Lambdi Pet"]
    lazy var userNameLabel = app.staticTexts["User Name"]
    lazy var petNameFieldLabel = app.staticTexts["Pet Name"]
    lazy var passwordLabel = app.staticTexts["Password"]

    lazy var userNameField = app.textFields["User Name"]
    lazy var petNameField = app.textFields["Pet Name"]
    lazy var passwordField = app.textFields["Password"]

    lazy var authTypeControl = app.segmentedControls.element
    lazy var loginSegment = authTypeControl.buttons["Log In"]
    lazy var registerSegment = authTypeControl.buttons["Register"]

    lazy var signupButton = app.buttons["Sign Up"]

    // home screen
    lazy var homeNavBar = app.navigationBars["Home"]
    lazy var logOutButton = homeNavBar.buttons["Log Out"]

    lazy var petNameLabel = app.staticTexts["Kilmonger"]
    lazy var petImageView = app.images["PetImageView"]
    lazy var feedButton = app.buttons["Feed My Pet"]
    lazy var entriesButton = app.buttons["See Entries"]

    var amOnHomeScreen: Bool {
        homeNavBar.exists &&
            logOutButton.exists &&
            petNameLabel.exists &&
            petImageView.exists &&
            entriesButton.exists &&
            feedButton.exists
    }

    // feed screen
    lazy var foodNameField = app.textFields["ex: Bananas"]
    lazy var continueKeyboardKey = app.buttons["continue"]
    lazy var datePicker = app.datePickers.element
    lazy var datePickerWheels = datePicker.pickerWheels
    lazy var datePickerDay = datePickerWheels.element(boundBy: 0)
    lazy var datepickerHour = datePickerWheels.element(boundBy: 1)
    lazy var datePickerMinute = datePickerWheels.element(boundBy: 2)
    lazy var datePickerAMPM = datePickerWheels.element(boundBy: 3)
    lazy var categoryPicker = app.pickers["FeedCategoryPicker"]
    lazy var categoryPickerWheel = categoryPicker.pickerWheels.element
    lazy var quantityField = app.textFields["FeedQuantityField"]
    lazy var incrementButton = app.buttons["+"]
    lazy var decrementButton = app.buttons["–"]
    lazy var finalizeFeedButton = app.buttons["Feed My Pet!"]

    var quantityFieldValue: String { quantityField.value as! String }

    lazy var foodNameLabel = app.staticTexts["Food"]
    lazy var datePickerLabel = app.staticTexts["Date/Time Fed"]
    lazy var categoryLabel = app.staticTexts["Category"]
    lazy var quantityLabel = app.staticTexts["Quantity"]

    // entries screen

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["UITesting"]
        app.launch()

        signInIfNeeded()
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


    // MARK: - Helper Methods

    func signInIfNeeded() {
        if !app.navigationBars["Home"].exists {
            app.segmentedControls.buttons["Log In"].tap()
            userNameField.tap()
            userNameField.typeText("test")
            passwordField.tap()
            passwordField.typeText("password")
            app.buttons.containing(.staticText, identifier: "Log In").element.tap()

            waitForLogin()
        }
    }

    func waitForLogin() {
        let loggedIn = expectation(
            for: NSPredicate(format: "exists == 1"),
            evaluatedWith: homeNavBar,
            handler: nil)
        wait(for: [loggedIn], timeout: 5)
    }
}
