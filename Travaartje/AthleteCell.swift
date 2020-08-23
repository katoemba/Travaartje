//
//  AthleteCell.swift
//  Travaartje
//
//  Created by Berrie Kremers on 17/08/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import SwiftUI
import Combine
import StravaCombine
import KingfisherSwiftUI
import os

struct AthleteCell: View {
    @State var athlete: Athlete
    @State var showDetails: Bool = false
    @Environment(\.settingsModel) var settingsModel: SettingsModel

    var body: some View {
        HStack(alignment: .center, spacing: 10.0) {
            Spacer()
                .frame(width: 0.0)
            
            KFImage(URL(string: self.athlete.profile_medium)!)
                .onSuccess { r in
                    // r: RetrieveImageResult
                    print("success: \(r)")
            }
            .onFailure { e in
                // e: KingfisherError
                print("failure: \(e)")
            }
            .placeholder {
                // Placeholder while downloading.
                Image(systemName: "arrow.2.circlepath.circle")
                    .font(.largeTitle)
                    .opacity(0.3)
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 60.0, height: 60.0)
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 10.0) {
                Text(self.athlete.firstname + " " + self.athlete.lastname)
                    .accessibility(identifier: "NameLabel")
                Text(self.athlete.city + ", " + self.athlete.country)
                    .accessibility(identifier: "LocationLabel")
            }
            
            Spacer()
        }
        .font(.body)
        .foregroundColor(.white)
        .padding(.vertical, 15.0)
        .background(RoundedRectangle(cornerRadius: 10.0).foregroundColor(.blue))
        .onTapGesture {
            self.settingsModel.deauthorize()
        }
    }
    
    
    //        Button(action: {
    //            self.showDetails = true
    //        }) {
    //            HStack(alignment: .center, spacing: 10.0) {
    //                Spacer()
    //                    .frame(width: 0.0)
    //
    //                KFImage(URL(string: self.athlete.profile_medium)!)
    //                    .onSuccess { r in
    //                        // r: RetrieveImageResult
    //                        print("success: \(r)")
    //                    }
    //                    .onFailure { e in
    //                        // e: KingfisherError
    //                        print("failure: \(e)")
    //                    }
    //                    .placeholder {
    //                        // Placeholder while downloading.
    //                        Image(systemName: "arrow.2.circlepath.circle")
    //                            .font(.largeTitle)
    //                            .opacity(0.3)
    //                    }
    //                    .frame(width: 60.0, height: 60.0)
    //                    .scaledToFit()
    //                    .cornerRadius(10)
    //
    //                Text(self.athlete.firstname + " " + self.athlete.lastname)
    //                    .accessibility(identifier: "NameLabel")
    //
    //                Spacer()
    //            }
    //        }
    //        .buttonStyle(BorderlessButtonStyle())
    //        .font(.body)
    //        .foregroundColor(.white)
    //        .padding(.vertical, 15.0)
    //        .background(RoundedRectangle(cornerRadius: 10.0).foregroundColor(.blue))
    //        .sheet(isPresented: self.$showDetails) {
    //            NavigationView {
    //                if self.url != nil {
    //                    WebView(request: URLRequest(url: self.url!))
    //                        .navigationBarTitle("Info", displayMode: .inline)
    //                        .navigationBarItems(
    //                            trailing:
    //                            Button("Done") {
    //                                self.showDetails = false
    //                            }
    //                        )
    //                }
    //                else {
    //                    EmptyView()
    //                }
    //            }
    //        }
}

struct UserCell_Previews: PreviewProvider {
    static let athlete = Athlete(id: 1, username: "Fast Abdi", firstname: "Abdi", lastname: "Nageeye", city: "Nijmegen", country: "The Netherlands", profile_medium: "https://www.wereldvanculturen.nl/wp-content/uploads/2019/03/Abdi-Nageeye-Atleet-zonder-grenzen-1.jpg", profile: "")
    static let localizations = Bundle.main.localizations.map(Locale.init).filter { $0.identifier != "base" }
    
    static var previews: some View {
        Group {
            ForEach(localizations, id: \.identifier) { locale in
                AthleteCell(athlete: athlete)
                    .previewLayout(PreviewLayout.fixed(width: 400, height: 100))
                    .padding()
                    .environment(\.locale, locale)
                    .previewDisplayName(Locale.current.localizedString(forIdentifier: locale.identifier))
            }
        }
    }
}
