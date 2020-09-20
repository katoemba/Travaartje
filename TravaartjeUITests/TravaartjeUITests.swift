//
//  TravaartjeUITests.swift
//  TravaartjeUITests
//
//  Created by Berrie Kremers on 17/07/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import XCTest

class TravaartjeUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWorkoutList() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-test"]
        app.launchArguments += ["-testWithRoute", "1"]
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let workoutTypePredicate = NSPredicate(format: "identifier == %@", "WorkoutType")
        let workoutActionPredicate = NSPredicate(format: "identifier == %@", "WorkoutAction")
        let workoutDetailsPredicate = NSPredicate(format: "identifier == %@", "WorkoutDetails")

        XCTAssertEqual(app.staticTexts.matching(workoutTypePredicate).element(boundBy: 0).label, "Run")
        XCTAssertEqual(app.buttons.matching(workoutActionPredicate).element(boundBy: 0).label, "Send")
        XCTAssertEqual(app.buttons.matching(workoutDetailsPredicate).element(boundBy: 0).label, "Details")
        XCTAssertFalse(app.staticTexts["NoRouteWarning"].exists)
        app.buttons.matching(workoutActionPredicate).element(boundBy: 0).tap()
        
        XCTAssert(app.buttons["In Progress"].waitForExistence(timeout: 2.0))

        XCTAssert(app.buttons["Send Again"].waitForExistence(timeout: 2.0))

        XCTAssertEqual(app.staticTexts.matching(workoutTypePredicate).element(boundBy: 1).label, "Ride")
    }

    func testWorkoutListDutch() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(nl)", "-AppleLocale", "nl_NL", "-test"]
        app.launchArguments += ["-testWithRoute", "1"]
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let workoutTypePredicate = NSPredicate(format: "identifier == %@", "WorkoutType")
        let workoutActionPredicate = NSPredicate(format: "identifier == %@", "WorkoutAction")
        let workoutDetailsPredicate = NSPredicate(format: "identifier == %@", "WorkoutDetails")

        XCTAssertEqual(app.staticTexts.matching(workoutTypePredicate).element(boundBy: 0).label, "Loopje")
        XCTAssertEqual(app.buttons.matching(workoutActionPredicate).element(boundBy: 0).label, "Verzend")
        XCTAssertEqual(app.buttons.matching(workoutDetailsPredicate).element(boundBy: 0).label, "Details")
        XCTAssertFalse(app.staticTexts["NoRouteWarning"].exists)
        app.buttons.matching(workoutActionPredicate).element(boundBy: 0).tap()

        XCTAssert(app.buttons["Bezig"].waitForExistence(timeout: 2.0))

        XCTAssert(app.buttons["Verzend opnieuw"].waitForExistence(timeout: 2.0))

        XCTAssertEqual(app.staticTexts.matching(workoutTypePredicate).element(boundBy: 1).label, "Rit")
    }
    
    func testNoRouteWorkoutList() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-test"]
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let workoutTypePredicate = NSPredicate(format: "identifier == %@", "WorkoutType")
        
        XCTAssertEqual(app.staticTexts.matching(workoutTypePredicate).element(boundBy: 0).label, "Run")
        XCTAssertEqual(app.staticTexts["NoRouteWarning"].firstMatch.label, "No route data")
    }

    func testWorkoutListEmpty() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-test"]
        app.launchArguments += ["-testNoWorkouts", "1"]
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        XCTAssertTrue(app.staticTexts["No workouts found, did you give Travaartje access to your workouts in the Privacy settings?"].exists)
    }
    
    func testWorkoutDetails() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-test"]
        app.launch()

        let workoutDetailsPredicate = NSPredicate(format: "identifier == %@", "WorkoutDetails")
        let detailsButton = app.buttons.matching(workoutDetailsPredicate).element(boundBy: 0)
        detailsButton.tap()
        
        XCTAssertEqual(app.tables.textFields["Name"].placeholderValue, "Name")
        XCTAssertEqual(app.tables.textFields["Description"].placeholderValue, "Description")
        
        app.tables.textFields["Name"].tap()
        app.tables.textFields["Name"].typeText("My Run")
        app.tables.textFields["Description"].tap()
        app.tables.textFields["Description"].typeText("My Description")
        
        app.buttons["Done"].tap()

        detailsButton.tap()

        XCTAssertEqual(app.tables.textFields["Name"].value as? String, "My Run")
        XCTAssertEqual(app.tables.textFields["Description"].value as? String, "My Description")
    }

    func testWorkoutDetailsDutch() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(nl)", "-AppleLocale", "nl_NL", "-test"]
        app.launch()

        let workoutDetailsPredicate = NSPredicate(format: "identifier == %@", "WorkoutDetails")
        let detailsButton = app.buttons.matching(workoutDetailsPredicate).element(boundBy: 0)
        detailsButton.tap()
        
        XCTAssertEqual(app.tables.textFields["Name"].placeholderValue, "Naam")
        XCTAssertEqual(app.tables.textFields["Description"].placeholderValue, "Beschrijving")
        
        app.buttons["Klaar"].tap()
    }

    func testSettings() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-test"]
        app.launch()

        app.buttons["Settings"].tap()
        
        XCTAssertEqual(app.staticTexts["Settings"].label, "Settings")
        
        app.buttons["Done"].tap()
    }

    func testSettingsDutch() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(nl)", "-AppleLocale", "nl_NL", "-test"]
        app.launch()

        app.buttons["Settings"].tap()
        
        XCTAssertEqual(app.staticTexts["Instellingen"].label, "Instellingen")
        
        app.buttons["Klaar"].tap()
    }

    func testOnboarding() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-test"]
        app.launchArguments += ["-testOnboarding", "1"]
        app.launch()

        XCTAssertTrue(app.buttons["Give HealthKit access"].exists)
        XCTAssertEqual(app.buttons["Give HealthKit access"].isEnabled, true)
        XCTAssertTrue(app.buttons["Connect to Strava"].exists)
        XCTAssertEqual(app.buttons["Connect to Strava"].isEnabled, false)
        XCTAssertTrue(app.buttons["Get started"].exists)
        XCTAssertEqual(app.buttons["Get started"].isEnabled, false)

        app.buttons["Give HealthKit access"].tap()
        
        let isEnabled = NSPredicate(format: "isEnabled == 1")
        let button2Enabled = expectation(for: isEnabled, evaluatedWith: app.buttons["Connect to Strava"], handler: nil)
        wait(for: [button2Enabled], timeout: 2)
        
        XCTAssertEqual(app.buttons["Give HealthKit access"].isEnabled, false)
        XCTAssertEqual(app.buttons["Connect to Strava"].isEnabled, true)
        XCTAssertEqual(app.buttons["Get started"].isEnabled, false)
        app.buttons["Connect to Strava"].tap()

        let button3Enabled = expectation(for: isEnabled, evaluatedWith: app.buttons["Get started"], handler: nil)
        wait(for: [button3Enabled], timeout: 3)

        XCTAssertEqual(app.buttons["Give HealthKit access"].isEnabled, false)
        XCTAssertEqual(app.buttons["Connect to Strava"].isEnabled, false)
        XCTAssertEqual(app.buttons["Get started"].isEnabled, true)
        
        app.buttons["Get started"].tap()
    }


//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
