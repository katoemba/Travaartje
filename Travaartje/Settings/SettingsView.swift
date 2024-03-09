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
    @State var sett: Bool = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 10.0) {
                ForEach(settingsModel.settings, id: \.self.identifier) { setting in
                    if setting.athlete != nil {
                        AthleteCell(athlete: setting.athlete!)
                    }
                    else if setting.identifier == "ConnectStrava" {
                        ConnectCell(setting: setting, enabled: true, settingsModel: settingsModel)
                        
                    }
                    else if setting.action == .toggle {
                        SettingCell(setting: setting, enabled: AppDefaults.standard.bool(forKey: setting.identifier))
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
