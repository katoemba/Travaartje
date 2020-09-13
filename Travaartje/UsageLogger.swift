//
//  UsageLogger.swift
//  Travaartje
//
//  Created by Berrie Kremers on 02/09/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import Foundation
import AppCenter
import AppCenterAnalytics
import StravaCombine

class UsageLogger {
    static func workoutUploadSucceeded(uploadParameters: UploadParameters, hasRoute: Bool) {
        MSAnalytics.trackEvent("Upload Succeeded", withProperties: ["activity": uploadParameters.activityType.rawValue,
                                                                    "gps": hasRoute ? "Yes" : "No"])
    }

    static func workoutUploadFailed(uploadParameters: UploadParameters, hasRoute: Bool, error: String) {
        MSAnalytics.trackEvent("Upload Failed", withProperties: ["activity": uploadParameters.activityType.rawValue,
                                                                 "gps": hasRoute ? "Yes" : "No",
                                                                 "error": error])
    }
    
    static func internalError(location: String, description: String) {
        MSAnalytics.trackEvent("Internal Error", withProperties: ["location": location,
                                                                  "description": description])
    }
}
    
