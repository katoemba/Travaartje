//
//  SettingsModel.swift
//  Travaartje
//
//  Created by Berrie Kremers on 16/08/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import Foundation
import UIKit
import Combine
import StravaCombine
import KeychainAccess

public class SettingsModel: ObservableObject {
    @Published public var settings = [Setting]()
    private let stravaAuth: StravaOAuthProtocol
    private var cancellables = Set<AnyCancellable>()

    init(stravaOAuth: StravaOAuthProtocol) {
        stravaAuth = stravaOAuth
        
        stravaAuth.token
            .receive(on: RunLoop.main)
            .sink { (stravaToken) in
                var updatedSettings = [Setting]()
                
                if let athlete = stravaToken?.athlete {
                    updatedSettings.append(Setting(identifier: "Account", icon: "person.crop.circle.badge.plus", label: NSLocalizedString("Strava account", comment: ""), action: .showAccount(athlete)))
                }
                else {
                    updatedSettings.append(Setting(identifier: "ConnectStrava", icon: "person.crop.circle.badge.plus", label: NSLocalizedString("Connect your Strava account", comment: ""), action: .connectAccount))
                }
                updatedSettings.append(Setting(identifier: "AutomaticUpload", icon: "heart.circle", label: "Heartrate", action: .toggle))
                updatedSettings.append(Setting(identifier: "FollowOnStrava", icon: "eye", label: NSLocalizedString("Follow the developer on Strava", comment: ""), action: .openStrava))
                updatedSettings.append(Setting(identifier: "New", icon: "tray.full", label: NSLocalizedString("What's new", comment: ""), action: .openURL(URL(string: "https://www.travaartje.net/whats-new")!)))
                updatedSettings.append(Setting(identifier: "FAQ", icon: "questionmark.circle", label: NSLocalizedString("Frequently asked questions", comment: ""), action: .openURL(URL(string: "https://www.travaartje.net/faq")!)))
                updatedSettings.append(Setting(identifier: "Open source", icon: "cloud", label: NSLocalizedString("Open source", comment: ""), action: .openURL(URL(string: "https://www.travaartje.net/open-source")!)))

                var components = URLComponents(string: "https://www.travaartje.net/report-a-problem")
                components?.queryItems = [URLQueryItem(name: "device", value: UIDevice.current.model),
                                          URLQueryItem(name: "iosversion", value: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"),
                                          URLQueryItem(name: "appversion", value: "\(Bundle.main.releaseVersionNumberPretty):\(Bundle.main.buildVersionNumber ?? "0")"),
                                          URLQueryItem(name: "screensize", value: "\(UIScreen.main.bounds.width)x\(UIScreen.main.bounds.height)")]
                if let url = components?.url {
                    updatedSettings.append(Setting(identifier: "Report a problem", icon: "exclamationmark.bubble", label: NSLocalizedString("Report a problem", comment: ""), action: .openURL(url)))
                }
                updatedSettings.append(Setting(identifier: "Privacy", icon: "hand.raised", label: NSLocalizedString("Privacy", comment: ""), action: .openURL(URL(string: "https://www.travaartje.net/privacy")!)))
                updatedSettings.append(Setting(identifier: "Acknowledgements", icon: "hand.thumbsup", label: NSLocalizedString("Acknowledgements", comment: ""), action: .openURL(URL(string: "https://www.travaartje.net/acknowledgements")!)))
                updatedSettings.append(Setting(identifier: "Version", icon: "info.circle", label: "Travaartje \(Bundle.main.releaseVersionNumberPretty), build \(Bundle.main.buildVersionNumber ?? "0")", action: .info))

                self.settings = updatedSettings
            }
            .store(in: &cancellables)
        
        stravaAuth.token
            .sink { (stravaToken) in
                if let stravaToken = stravaToken {
                    stravaToken.store()
                }
                else {
                    StravaToken.clear()
                }
            }
            .store(in: &cancellables)
    }
    
    func authorize() {
        stravaAuth.authorize(presentationAnchor: gWindow!)
            .sink(receiveCompletion: { (result) in
                switch result {
                case let .failure(error):
                    switch error {
                    case let .authorizationFailed(location, description):
                        UsageLogger.internalError(location: location, description: "Authorization failed: " + description)
                    default:
                        UsageLogger.internalError(location: "authorize", description: "Unexpected error")
                    }
                case .finished:
                    break
                }
            }) { (_) in
            }
            .store(in: &cancellables)
    }

    func deauthorize() {
        stravaAuth.deauthorize()
    }
}

extension StravaToken {
    private static var tokenKey: String {
        "Travaartje.Token"
    }
    private static var keychain: Keychain {
        Keychain(service: "com.katoemba.Travaartje")
    }
    
    static func load() -> StravaToken? {
        if let data = try? keychain.getData(tokenKey) {
            return try? PropertyListDecoder().decode(StravaToken.self, from: data)
        }
        return nil
    }

    static func clear() {
        try? keychain.remove(tokenKey)
    }
    
    func store() {
        if let data = try? PropertyListEncoder().encode(self) {
            try? StravaToken.keychain.set(data, key: StravaToken.tokenKey)
        }
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var releaseVersionNumberPretty: String {
        return "v\(releaseVersionNumber ?? "0.0")"
    }
}
