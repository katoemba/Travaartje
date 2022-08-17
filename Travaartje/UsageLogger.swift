//
//  UsageLogger.swift
//  Travaartje
//
//  Created by Berrie Kremers on 02/09/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import Foundation
import StravaCombine
import FirebaseAnalytics
import FirebaseCrashlytics
import Firebase

class UsageLogger {
    /// Singleton object
    static let shared = UsageLogger()
    
    func initialize() {
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)
    }
    
    private func trackEvent(_ name: String, properties: [String: String] = [:]) {
        Analytics.logEvent(name, parameters: properties)
    }

    func workoutUploadSucceeded(uploadParameters: UploadParameters, hasRoute: Bool, fromWidget: Bool) {
        trackEvent("Upload_Succeeded", properties: ["activity": uploadParameters.activityType.rawValue,
                                                    "gps": hasRoute ? "Yes" : "No",
                                                    "fromWidget": fromWidget ? "Yes" : "No"])
    }
    
    func workoutUploadFailed(uploadParameters: UploadParameters, hasRoute: Bool, fromWidget: Bool, error: String) {
        var processedError = error
        if error.contains("duplicate") {
            processedError = "Duplicate workout"
        }
        trackEvent("Upload_Failed", properties: ["activity": uploadParameters.activityType.rawValue,
                                                 "gps": hasRoute ? "Yes" : "No",
                                                 "fromWidget": fromWidget ? "Yes" : "No",
                                                 "error": processedError])
    }
    
    func internalError(location: String, description: String) {
        trackEvent("Internal_Error", properties: ["location": location,
                                                  "description": description])
    }
}

