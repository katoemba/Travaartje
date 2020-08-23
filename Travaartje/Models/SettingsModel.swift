//
//  SettingsModel.swift
//  Travaartje
//
//  Created by Berrie Kremers on 16/08/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import Foundation
import Combine
import StravaCombine

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
                    updatedSettings.append(Setting(identifier: "Account", icon: "person.crop.circle", label: "Show Account", action: .showAccount(athlete)))
                }
                else {
                    updatedSettings.append(Setting(identifier: "ConnectStrava", icon: "person.crop.circle", label: "Connect your Strava account", action: .connectAccount))
                }
                updatedSettings.append(Setting(identifier: "AutomaticUpload", icon: "bolt.badge.a.fill", label: "Upload on open", action: .toggle))
                updatedSettings.append(Setting(identifier: "FollowOnStrava", icon: "person.crop.circle.badge.plus", label: "Follow the author on Strava", action: .openStrava))
                updatedSettings.append(Setting(identifier: "FAQ", icon: "questionmark.circle", label: "Frequently asked questions", action: .openURL(URL(string: "https://www.travaartje.net/faq")!)))
                updatedSettings.append(Setting(identifier: "Privacy", icon: "hand.raised", label: "Privacy", action: .openURL(URL(string: "https://www.travaartje.net/privacy")!)))
                updatedSettings.append(Setting(identifier: "Acknowledgements", icon: "hand.thumbsup", label: "Acknowledgements", action: .openURL(URL(string: "https://www.travaartje.net/acknowledgements")!)))
                
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
        stravaAuth.authorize()
    }

    func deauthorize() {
        stravaAuth.deauthorize()
    }
}

extension StravaToken {
    private static var tokenKey: String {
        "Travaartje.Token"
    }
    
    public static func load(defaults: UserDefaults = UserDefaults.standard) -> StravaToken? {
        if let data = UserDefaults.standard.value(forKey: StravaToken.tokenKey) as? Data {
            return try? PropertyListDecoder().decode(StravaToken.self, from: data)
        }
        return nil
    }

    static func clear(defaults: UserDefaults = UserDefaults.standard) {
        defaults.removeObject(forKey: StravaToken.tokenKey)
    }
    
    func store(defaults: UserDefaults = UserDefaults.standard) {
        defaults.set(try? PropertyListEncoder().encode(self), forKey: StravaToken.tokenKey)
    }
}
