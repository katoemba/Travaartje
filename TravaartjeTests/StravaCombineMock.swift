//
//  StravaCombineMock.swift
//  Travaartje
//
//  Created by Berrie Kremers on 14/08/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import Foundation
import Combine
import StravaCombine

#if targetEnvironment(simulator)
class StravaOAuthMock: StravaOAuthProtocol {
    var token: AnyPublisher<StravaToken, Error>
    
    init(token: StravaToken) {
        self.token = CurrentValueSubject<StravaToken, Error>(token)
            .eraseToAnyPublisher()
    }
    
    func deauthorize() {
    }
}

class StravaUploadMock: StravaUploadProtocol {
    func uploadGpx(_ gpxData: Data, activityType: StravaActivityType, accessToken: String) -> AnyPublisher<UploadStatus, Error> {
        let uploadStatus = UploadStatus(id: 1, status: "Your activity is ready.", activity_id: 123)
        return CurrentValueSubject<UploadStatus, Error>(uploadStatus)
            .eraseToAnyPublisher()
    }
}
#endif
