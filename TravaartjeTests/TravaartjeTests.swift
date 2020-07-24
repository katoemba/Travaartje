//
//  TravaartjeTests.swift
//  TravaartjeTests
//
//  Created by Berrie Kremers on 17/07/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import XCTest
@testable import Travaartje
import HealthKit
import CoreData
import Combine

class TravaartjeTests: XCTestCase {
    var cancellable: AnyCancellable?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testModel() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let healthKitStoreCombine = (UIApplication.shared.delegate as! AppDelegate).healthKitStoreCombine
        let model = WorkoutModel(context: context, healthStoreCombine: healthKitStoreCombine)

        var workouts = [Workout]()
        let expectation = self.expectation(description: "Load workouts")
        model.reloadHealthKitWorkouts()
        cancellable = model.$workouts
            .sink {
                workouts = $0
                expectation.fulfill()
            }
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertEqual(workouts.count, 2)
        
        if workouts.count == 2 {
            let run = workouts[0]
            XCTAssertEqual(run.state, .new)
            XCTAssertEqual(run.type, "Run")
            XCTAssertEqual(run.distance, "8.8 km")
            XCTAssertEqual(run.duration, "1:07:20")
            XCTAssertEqual(run.date, "May 17, 2020 at 2:07 PM")

            let ride = workouts[1]
            XCTAssertEqual(ride.state, .new)
            XCTAssertEqual(ride.type, "Ride")
            XCTAssertEqual(ride.distance, "5.6 km")
            XCTAssertEqual(ride.duration, "16:40")
            XCTAssertEqual(ride.date, "May 17, 2020 at 8:58 AM")
        }
    }

    func testModelLimit() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let healthKitStoreCombine = (UIApplication.shared.delegate as! AppDelegate).healthKitStoreCombine
        let model = WorkoutModel(context: context, limit: 1, healthStoreCombine: healthKitStoreCombine)

        var workouts = [Workout]()
        let expectation = self.expectation(description: "Load workouts")
        model.reloadHealthKitWorkouts()
        cancellable = model.$workouts
            .sink {
                workouts = $0
                expectation.fulfill()
            }
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertEqual(workouts.count, 1)
        
        if workouts.count == 1 {
            let run = workouts[0]
            XCTAssertEqual(run.state, .new)
            XCTAssertEqual(run.type, "Run")
            XCTAssertEqual(run.distance, "8.8 km")
            XCTAssertEqual(run.duration, "1:07:20")
            XCTAssertEqual(run.date, "May 17, 2020 at 2:07 PM")
        }
    }
}
