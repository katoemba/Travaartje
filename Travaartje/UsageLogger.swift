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
    static func workoutUploadSucceeded(uploadParameters: UploadParameters) {
        MSAnalytics.trackEvent("Upload Succeeded", withProperties: ["activity": uploadParameters.activityType.rawValue])
    }

    static func workoutUploadFailed(uploadParameters: UploadParameters, error: String) {
        MSAnalytics.trackEvent("Upload Failed", withProperties: ["activity": uploadParameters.activityType.rawValue,
                                                                "error": error])
    }
}
    
