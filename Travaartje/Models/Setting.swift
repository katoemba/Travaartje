//
//  Setting.swift
//  Travaartje
//
//  Created by Berrie Kremers on 16/08/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import Foundation
import StravaCombine

public class Setting: ObservableObject, Identifiable {
    public enum Action: Equatable {
        case openURL(URL)
        case openStrava
        case showAccount(Athlete)
        case connectAccount
        case toggle
    }
    let action: Action
    let identifier: String
    let icon: String
    let label: String

    public init(identifier: String, icon: String, label: String, action: Action) {
        self.identifier = identifier
        self.icon = icon
        self.label = label
        self.action = action
    }
}
