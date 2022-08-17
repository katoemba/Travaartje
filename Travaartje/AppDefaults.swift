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
    static let skipHeartRateWhenInsufficient = "Travaartje.SkipHeartRateWhenInsufficientMeasurements"

    override static var standard: UserDefaults {
        return UserDefaults.init(suiteName: appDefaultsGroupName)!
    }
}

extension UserDefaults {
    var minimumHeartRateMeasurementsPerMinute: Int {
        if bool(forKey: AppDefaults.skipHeartRateWhenInsufficient) == true {
            // In case the flag is set, require at least an average of 4 heart rate measurements per minute.
            return 4
        }
        
        return 0
    }
}
