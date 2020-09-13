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
    
    private let tokenSubject: CurrentValueSubject<StravaToken?, Never>
    var stravaToken: StravaToken?
    var token: AnyPublisher<StravaToken?, Never> {
        tokenSubject.eraseToAnyPublisher()
    }
    
    init(token: StravaToken?) {
        stravaToken = token
        tokenSubject = CurrentValueSubject<StravaToken?, Never>(token)
    }
    
    func authorize() -> AnyPublisher<StravaToken?, StravaCombineError> {
        tokenSubject.send(stravaToken)
        return PassthroughSubject<StravaToken?, StravaCombineError>().eraseToAnyPublisher()
    }
    
    func processCode(_ code: String) {
    }
    
    func deauthorize() {
        tokenSubject.send(nil)
    }

    func refreshTokenIfNeeded() {
        if let tokenInfo = tokenSubject.value, Date(timeIntervalSince1970: tokenInfo.expires_at) <= Date() {
            tokenSubject.send(StravaToken(access_token: tokenInfo.access_token,
                                          expires_at: tokenInfo.expires_at + 6*3600,
                                          refresh_token: tokenInfo.refresh_token,
                                          athlete: tokenInfo.athlete))
        }
    }
}

class StravaUploadMock: StravaUploadProtocol {
    typealias UploadValidator = (Data, DataType, UploadParameters) -> (Void)
    private let statusSubject = PassthroughSubject<UploadStatus, Error>()
    var uploadValidator: UploadValidator = { (_, _, _) in }
    var activity_id = 123

    func uploadData(data: Data, dataType: DataType, uploadParameters: UploadParameters, accessToken: String) -> AnyPublisher<UploadStatus, Error> {
        uploadValidator(data, dataType, uploadParameters)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100),
                                      execute: {
                                        let uploadStatus = UploadStatus(id: 1, status: "Uploading.", activity_id: nil)
                                        self.statusSubject.send(uploadStatus)
        })

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1600),
                                      execute: {
                                        let uploadStatus = UploadStatus(id: 1, status: "Your activity is ready.", activity_id: self.activity_id)
                                        self.statusSubject.send(uploadStatus)
        })

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1610),
                                      execute: {
                                        self.statusSubject.send(completion: .finished)
        })

        return statusSubject.eraseToAnyPublisher()
    }
}
#endif
