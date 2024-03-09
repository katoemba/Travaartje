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

struct ConnectCell: View {
    @ObservedObject var setting: Setting
    @State var enabled: Bool = false
    @State var showWebView: Bool = false
    @ObservedObject var settingsModel: SettingsModel
    
    var body: some View {
        Button(action: {
            self.settingsModel.authorize()
        }) {
            VStack(alignment: .center) {
                Image("btn_strava_connectwith_orange_svg")                
            }
        }
        .buttonStyle(BorderlessButtonStyle())
        .font(.body)
        .foregroundColor(.white)
        .sheet(isPresented: self.$showWebView) {
            NavigationView {
                if self.setting.url != nil {
                    WebView(request: URLRequest(url: self.setting.url!))
                        .navigationBarTitle("", displayMode: .inline)
                        .navigationBarItems(
                            trailing:
                            Button("Done") {
                                self.showWebView = false
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

struct ConnectCell_Previews: PreviewProvider {
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
