//
//  SettingView.swift
//  Travaartje
//
//  Created by Berrie Kremers on 16/08/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import SwiftUI
import Combine
import os

struct SettingCell: View {
    @ObservedObject var setting: Setting
    @State var enabled: String = "checkmark.circle"
    @State var showDetails: Bool = false
    @Environment(\.settingsModel) var settingsModel: SettingsModel
    
    private var url: URL? {
        if case let .openURL(url) = setting.action {
            return url
        }
        return nil
    }

    var body: some View {
        Button(action: {
            self.enabled = self.enabled == "circle" ? "checkmark.circle" : "circle"
            if self.url != nil {
                self.showDetails = true
            }
            else if self.setting.action == .connectAccount {
                self.settingsModel.authorize()
            }
        }) {
            HStack(alignment: .center, spacing: 10.0) {
                Spacer()
                    .frame(width: 0.0)

                Image(systemName: setting.icon)
                    .frame(width: 30.0)
                Text(setting.label)
                    .accessibility(identifier: "SettingLabel")

                Spacer()
                
                if self.setting.action == .toggle {
                    Image(systemName: self.enabled)
                } else {
                    EmptyView()
                }

                Spacer()
                    .frame(width: 0.0)
            }
        }
        .buttonStyle(BorderlessButtonStyle())
        .font(.body)
        .foregroundColor(.white)
        .padding(.vertical, 15.0)
        .background(RoundedRectangle(cornerRadius: 10.0).foregroundColor(.blue))
        .sheet(isPresented: self.$showDetails) {
            NavigationView {
                if self.url != nil {
                    WebView(request: URLRequest(url: self.url!))
                        .navigationBarTitle("Info", displayMode: .inline)
                        .navigationBarItems(
                            trailing:
                            Button("Done") {
                                self.showDetails = false
                            }
                        )
                }
                else {
                    EmptyView()
                }
            }
        }
    }
}

struct SettingCell_Previews: PreviewProvider {
    static let model = AppDelegate.shared.settingsModel
    static let localizations = Bundle.main.localizations.map(Locale.init).filter { $0.identifier != "base" }

    static var previews: some View {
        Group {
            ForEach(localizations, id: \.identifier) { locale in
                SettingCell(setting: model.settings[0])
                    .previewLayout(PreviewLayout.fixed(width: 400, height: 100))
                    .padding()
                    .environment(\.locale, locale)
                    .previewDisplayName(Locale.current.localizedString(forIdentifier: locale.identifier))
            }
        }
    }
}
