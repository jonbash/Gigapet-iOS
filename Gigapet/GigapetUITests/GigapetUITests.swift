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

    // MARK: - Tests

    func testLogin() {
        // home screen; log out
        logOutButton.tap()

        // change from register to login mode
        loginSegment.tap()

        XCTAssertFalse(petNameLabel.exists && petNameLabel.isHittable)
        XCTAssertFalse(petNameField.exists && petNameField.isHittable)

        // log in
        userNameField.tap()
        userNameField.typeText("test")
        passwordField.tap()
        passwordField.typeText("password")

        app.buttons.containing(.staticText, identifier: "Log In").element.tap()

        waitForLogin()

        // home screen?
        XCTAssert(amOnHomeScreen)
    }

    func testRegister() {
        logOutButton.tap()

        // register mode
        XCTAssert(welcomeHeader.exists)
        XCTAssert(userNameLabel.exists)
        XCTAssert(passwordLabel.exists)
        XCTAssert(petNameFieldLabel.exists)

        XCTAssert(authTypeControl.exists)
        XCTAssert(loginSegment.exists)
        XCTAssert(registerSegment.exists)

        XCTAssert(userNameField.exists)
        XCTAssert(petNameField.exists)
        XCTAssert(passwordField.exists)

        XCTAssert(signupButton.exists)

        // register
        userNameField.tap()
        userNameField.typeText("testuser")
        petNameField.tap()
        petNameField.typeText("testpet")
        passwordField.tap()
        passwordField.typeText("testpassword")

        signupButton.tap()

        waitForLogin()

        // home screen?
        XCTAssert(homeNavBar.exists)
        XCTAssert(logOutButton.exists)
        XCTAssert(petNameLabel.exists)
        XCTAssert(petImageView.exists)
        XCTAssert(entriesButton.exists)
        XCTAssert(feedButton.exists)
    }

    func testStartOnHomeScreen() {
        XCTAssert(amOnHomeScreen)
    }

    func testFeed() {
        feedButton.tap()

        XCTAssert(foodNameField.exists)
        XCTAssert(datePicker.exists)
        XCTAssert(categoryPicker.exists)
        XCTAssert(quantityField.exists)
        XCTAssert(incrementButton.exists)
        XCTAssert(decrementButton.exists)
        XCTAssert(finalizeFeedButton.exists)
        XCTAssert(foodNameLabel.exists)
        XCTAssert(datePickerLabel.exists)
        XCTAssert(categoryLabel.exists)
        XCTAssert(quantityLabel.exists)

        XCTAssertEqual(quantityFieldValue, "1")

        foodNameField.tap()
        foodNameField.typeText("Entire loaf of bread")
        continueKeyboardKey.tap()
        datePickerDay.adjust(toPickerWheelValue: "Jan 9")
        datepickerHour.adjust(toPickerWheelValue: "3")
        datePickerMinute.adjust(toPickerWheelValue: "14")
        datePickerAMPM.adjust(toPickerWheelValue: "AM")
        categoryPickerWheel.adjust(toPickerWheelValue: "Whole Grains")

        // assert that 1 is minimum, increment works
        decrementButton.tap()
        XCTAssertEqual(quantityFieldValue, "1")
        incrementButton.tap()
        incrementButton.tap()
        incrementButton.tap()
        XCTAssertEqual(quantityFieldValue, "4")

        finalizeFeedButton.tap()

        XCTAssert(amOnHomeScreen)
    }

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
