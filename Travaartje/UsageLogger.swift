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
    static func workoutUploaded(uploadParameters: UploadParameters, status: String, error: String = "") {
        MSAnalytics.trackEvent("Upload", withProperties: ["activity": uploadParameters.activityType.rawValue,
                                                          "status": status,
                                                          "error": error])
    }
}
    
