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
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let run = app.tables.cells.element(boundBy: 0)
        XCTAssertEqual(run.staticTexts["WorkoutType"].label, "Run")
        XCTAssertEqual(run.staticTexts["WorkoutAction"].label, "Send")
        run.staticTexts["WorkoutAction"].tap()
        XCTAssertEqual(run.staticTexts["WorkoutAction"].label, "Send Again")
        run.staticTexts["WorkoutAction"].tap()
        XCTAssertEqual(run.staticTexts["WorkoutAction"].label, "Retry")
        run.staticTexts["WorkoutAction"].tap()
        XCTAssertEqual(run.staticTexts["WorkoutAction"].label, "Retry")
        
        let ride = app.tables.cells.element(boundBy: 1)
        XCTAssertEqual(ride.staticTexts["WorkoutType"].label, "Ride")
    }

    func testWorkoutListDutch() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(nl)", "-AppleLocale", "nl_NL"]
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let run = app.tables.cells.element(boundBy: 0)
        XCTAssertEqual(run.staticTexts["WorkoutType"].label, "Loopje")
        XCTAssertEqual(run.staticTexts["WorkoutAction"].label, "Verzend")
        run.staticTexts["WorkoutAction"].tap()
        XCTAssertEqual(run.staticTexts["WorkoutAction"].label, "Verzend opnieuw")
        run.staticTexts["WorkoutAction"].tap()
        XCTAssertEqual(run.staticTexts["WorkoutAction"].label, "Probeer opnieuw")
        
        let ride = app.tables.cells.element(boundBy: 1)
        XCTAssertEqual(ride.staticTexts["WorkoutType"].label, "Rit")
    }
    
    func testWorkoutDetails() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        let run = app.tables.cells.element(boundBy: 0)
        run.staticTexts["Details"].tap()
        
        XCTAssertEqual(app.tables.textFields["Name"].placeholderValue, "Name")
        XCTAssertEqual(app.tables.textFields["Description"].placeholderValue, "Description")
        
        app.tables.textFields["Name"].tap()
        app.tables.textFields["Name"].typeText("My Run")
        app.tables.textFields["Description"].tap()
        app.tables.textFields["Description"].typeText("My Description")
        
        app.buttons["Travaartje"].tap()

        run.staticTexts["Details"].tap()
        
        XCTAssertEqual(app.tables.textFields["Name"].value as? String, "My Run")
        XCTAssertEqual(app.tables.textFields["Description"].value as? String, "My Description")
    }

    func testWorkoutDetailsDutch() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(nl)", "-AppleLocale", "nl_NL"]
        app.launch()

        let run = app.tables.cells.element(boundBy: 0)
        run.staticTexts["Details"].tap()
        
        XCTAssertEqual(app.tables.textFields["Name"].placeholderValue, "Naam")
        XCTAssertEqual(app.tables.textFields["Description"].placeholderValue, "Beschrijving")
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
