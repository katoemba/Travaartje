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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10.0) {
                ForEach(settingsModel.settings, id: \.self.identifier) { setting in
                    if setting.athlete != nil {
                        AthleteCell(athlete: setting.athlete!)
                    }
                    else {
                        SettingCell(setting: setting)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let model = AppDelegate.shared.settingsModel
    
    static var previews: some View {
        return SettingsView(settingsModel: model)
    }
}
