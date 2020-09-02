//
//  SettingsView.swift
//  Travaartje
//
//  Created by Berrie Kremers on 16/08/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import SwiftUI
import StravaCombine

struct SettingsView: View {
    @ObservedObject var settingsModel: SettingsModel

    var body: some View {
        List(settingsModel.settings) { setting in
            if setting.athlete != nil {
                AthleteCell(athlete: setting.athlete!)
            }
            else {
                SettingCell(setting: setting)
            }
        }
        .onAppear(perform: {
            UITableView.appearance().separatorStyle = .none
            UITableViewCell.appearance().selectionStyle = .none
        })
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let model = AppDelegate.shared.settingsModel
    
    static var previews: some View {
        return SettingsView(settingsModel: model)
    }
}
