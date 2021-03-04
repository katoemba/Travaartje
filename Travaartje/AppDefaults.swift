//
//  AppDefaults.swift
//  Travaartje
//
//  Created by Berrie Kremers on 01/09/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import Foundation

class AppDefaults: UserDefaults {
    private static let appDefaultsGroupName = "group.com.katoemba.travaartje"
    static let onboardingRequiredKey = "Travaartje.Onboarding.Required"
    static let lastUploadedWorkout = "Travaartje.Last.Uploaded.Workout"
    static let widgetNotificationShownKey = "Travaartje.Widget.Notification.Shown"

    override static var standard: UserDefaults {
        return UserDefaults.init(suiteName: appDefaultsGroupName)!
    }
}
