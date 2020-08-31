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
import StravaCombine
import SwiftUI

class TravaartjeTests: XCTestCase {
    var cancellable: AnyCancellable?
    var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let context = AppDelegate.shared.persistentContainer.viewContext
        let healthKitStoreCombine = AppDelegate.shared.healthKitStoreCombine
        let stravaOAuth = AppDelegate.shared.stravaOAuth
        let model = WorkoutModel(context: context, healthStoreCombine: healthKitStoreCombine, stravaOAuth: stravaOAuth)

        // Reset the models after each test, as this data carries over into subsequent tests.
        for workout in model.workouts {
            workout.state = .new
            workout.uploadResult = ""
            workout.stravaId = 0
        }
    }

    func testWorkoutModel() {
        let context = AppDelegate.shared.persistentContainer.viewContext
        let healthKitStoreCombine = AppDelegate.shared.healthKitStoreCombine
        let stravaOAuth = AppDelegate.shared.stravaOAuth
        let model = WorkoutModel(context: context, healthStoreCombine: healthKitStoreCombine, stravaOAuth: stravaOAuth)

        var workouts = [Workout]()
        let expectation = self.expectation(description: "Load workouts")
        model.reloadHealthKitWorkouts()
        model.$workouts
            .sink {
                workouts = $0
                expectation.fulfill()
            }
            .store(in: &cancellables)
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

    func testWorkoutModelLimit() {
        let context = AppDelegate.shared.persistentContainer.viewContext
        let healthKitStoreCombine = AppDelegate.shared.healthKitStoreCombine
        let stravaOAuth = AppDelegate.shared.stravaOAuth
        let model = WorkoutModel(context: context, limit: 1, healthStoreCombine: healthKitStoreCombine, stravaOAuth: stravaOAuth)

        var workouts = [Workout]()
        let expectation = self.expectation(description: "Load workouts")
        model.reloadHealthKitWorkouts()
        model.$workouts
            .sink {
                workouts = $0
                expectation.fulfill()
            }
            .store(in: &cancellables)
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
    
    func testLoggedInSettingsModel() {
        let athlete = Athlete(id: 1, username: "Fast Abdi", firstname: "Abdi", lastname: "Nageeye", city: "Nijmegen", country: "The Netherlands", profile_medium: "https://www.wereldvanculturen.nl/wp-content/uploads/2019/03/Abdi-Nageeye-Atleet-zonder-grenzen-1.jpg", profile: "https://www.wereldvanculturen.nl/wp-content/uploads/2019/03/Abdi-Nageeye-Atleet-zonder-grenzen-1.jpg")
        let stravaToken = StravaToken(access_token: "123", expires_at: Date(timeIntervalSinceNow: 3600).timeIntervalSince1970, refresh_token: "456", athlete: athlete)
        let stravaOAuth = StravaOAuthMock(token: stravaToken)
        let model = SettingsModel(stravaOAuth: stravaOAuth)
        
        var settings = [Setting]()
        let expectation = self.expectation(description: "Fetch settings")
        cancellable = model.$settings
            .filter { $0.count > 0 }
            .sink {
                settings = $0
                expectation.fulfill()
            }
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertGreaterThan(settings.count, 0)
        
        if settings.count > 0 {
            if case let .showAccount(settingsAthlete) = settings[0].action {
                XCTAssertEqual(settingsAthlete.id, athlete.id)
            }
            else {
                XCTAssert(false, "First setting has invalid type")
            }
        }
    }

    func testLoggedOffSettingsModel() {
        let stravaOAuth = StravaOAuthMock(token: nil)
        let model = SettingsModel(stravaOAuth: stravaOAuth)
        
        var settings = [Setting]()
        let expectation = self.expectation(description: "Fetch settings")
        cancellable = model.$settings
            .filter { $0.count > 0 }
            .sink {
                settings = $0
                expectation.fulfill()
            }
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertGreaterThan(settings.count, 0)
        
        if settings.count > 0 {
            XCTAssertEqual(settings[0].action, Setting.Action.connectAccount)
        }
    }

    func testURLsInSettingsModel() {
        let athlete = Athlete(id: 1, username: "Fast Abdi", firstname: "Abdi", lastname: "Nageeye", city: "Nijmegen", country: "The Netherlands", profile_medium: "https://www.wereldvanculturen.nl/wp-content/uploads/2019/03/Abdi-Nageeye-Atleet-zonder-grenzen-1.jpg", profile: "")
        let stravaToken = StravaToken(access_token: "123", expires_at: Date(timeIntervalSinceNow: 3600).timeIntervalSince1970, refresh_token: "456", athlete: athlete)
        let stravaOAuth = StravaOAuthMock(token: stravaToken)
        let model = SettingsModel(stravaOAuth: stravaOAuth)
        
        var settings = [Setting]()
        let expectation = self.expectation(description: "Fetch settings")
        cancellable = model.$settings
            .filter { $0.count > 0 }
            .sink {
                settings = $0
                expectation.fulfill()
            }
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertGreaterThan(settings.count, 0)
        
        if settings.count > 0 {
            for setting in settings {
                if setting.identifier == "News" {
                    if case let .openURL(faq) = setting.action {
                        XCTAssertEqual(faq, URL(string: "https://www.travaartje.net/whats-new")!)
                    }
                    else {
                        XCTAssert(false, "Faq setting has invalid type")
                    }
                }
                else if setting.identifier == "FAQ" {
                    if case let .openURL(faq) = setting.action {
                        XCTAssertEqual(faq, URL(string: "https://www.travaartje.net/faq")!)
                    }
                    else {
                        XCTAssert(false, "Faq setting has invalid type")
                    }
                }
                else if setting.identifier == "Privacy" {
                    if case let .openURL(faq) = setting.action {
                        XCTAssertEqual(faq, URL(string: "https://www.travaartje.net/privacy")!)
                    }
                    else {
                        XCTAssert(false, "Privacy setting has invalid type")
                    }
                }
                else if setting.identifier == "Acknowledgements" {
                    if case let .openURL(faq) = setting.action {
                        XCTAssertEqual(faq, URL(string: "https://www.travaartje.net/acknowledgements")!)
                    }
                    else {
                        XCTAssert(false, "Acknowledgements setting has invalid type")
                    }
                }
            }
        }
    }

    func testLoginLogoutSequence() {
        let stravaOAuth = StravaOAuthMock(token: nil)
        let model = SettingsModel(stravaOAuth: stravaOAuth)
        
        let notAuthorizedExpection = self.expectation(description: "Not authorized")
        let authorizedExpection = self.expectation(description: "Authorized")
        let deauthorizedExpection = self.expectation(description: "Deauthorized")
        var count = 0

        model.$settings
            .filter { $0.count > 0 }
            .sink {
                if $0[0].action == .connectAccount {
                    if count == 0 {
                        notAuthorizedExpection.fulfill()
                    }
                    else {
                        deauthorizedExpection.fulfill()
                    }
                }
                else if case .showAccount(_) = $0[0].action {
                    authorizedExpection.fulfill()
                }
                count += 1
            }
            .store(in: &cancellables)

        let athlete = Athlete(id: 1, username: "Fast Abdi", firstname: "Abdi", lastname: "Nageeye", city: "Nijmegen", country: "The Netherlands", profile_medium: "https://www.wereldvanculturen.nl/wp-content/uploads/2019/03/Abdi-Nageeye-Atleet-zonder-grenzen-1.jpg", profile: "https://www.wereldvanculturen.nl/wp-content/uploads/2019/03/Abdi-Nageeye-Atleet-zonder-grenzen-1.jpg")
        stravaOAuth.stravaToken = StravaToken(access_token: "123", expires_at: Date(timeIntervalSinceNow: 3600).timeIntervalSince1970, refresh_token: "456", athlete: athlete)
        model.authorize()
        wait(for: [notAuthorizedExpection, authorizedExpection], timeout: 1.0)

        model.deauthorize()
        wait(for: [deauthorizedExpection], timeout: 1.0)
    }
    
    func testLoggedOfUpload() {
        let context = AppDelegate.shared.persistentContainer.viewContext
        let healthKitStoreCombine = AppDelegate.shared.healthKitStoreCombine
        let stravaOAuth = StravaOAuthMock(token: nil)
        let model = WorkoutModel(context: context, healthStoreCombine: healthKitStoreCombine, stravaOAuth: stravaOAuth)

        let notAuthorizedExpectation = expectation(description: "Not authorized")

        model.upload(model.workouts[0])
            .sink { (uploadStatus) in
                if uploadStatus.state == Workout.State.failed {
                    notAuthorizedExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [notAuthorizedExpectation], timeout: 1.0)
    }
}
