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
import Kingfisher
import os

struct AthleteCell: View {
    @State var athlete: Athlete
    @State var showDetails: Bool = false
    @ObservedObject var settingsModel: SettingsModel

    var body: some View {
        HStack(alignment: .center, spacing: 10.0) {
            Spacer()
                .frame(width: 0.0)
            
            KFImage(self.athlete.imageURL)
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
                Text(self.athlete.displayName)
                    .accessibility(identifier: "NameLabel")
                Text(self.athlete.displayLocation)
                    .accessibility(identifier: "LocationLabel")
            }
            
            Spacer()

            Button(action: {
                self.settingsModel.deauthorize()
            }) {
                Image(systemName: "person.crop.circle.badge.xmark")
                    .font(.largeTitle)
            }
            .accessibility(identifier: "Deauthorize")
            .buttonStyle(BorderlessButtonStyle())

            Spacer()
                .frame(width: 0.0)
        }
        .font(.body)
        .foregroundColor(.white)
        .padding(.vertical, 15.0)
        .background(RoundedRectangle(cornerRadius: 10.0).foregroundColor(.blue))
    }
}

struct AthleteCell_Previews: PreviewProvider {
    static let athlete = Athlete(id: 1, username: "Fast Abdi", firstname: "Abdi", lastname: "Nageeye", city: "Nijmegen", country: "The Netherlands", profile_medium: "https://www.wereldvanculturen.nl/wp-content/uploads/2019/03/Abdi-Nageeye-Atleet-zonder-grenzen-1.jpg", profile: "https://www.wereldvanculturen.nl/wp-content/uploads/2019/03/Abdi-Nageeye-Atleet-zonder-grenzen-1.jpg")
    static let localizations = Bundle.main.localizations.map(Locale.init).filter { $0.identifier != "base" }
    
    static var previews: some View {
        Group {
            ForEach(localizations, id: \.identifier) { locale in
                AthleteCell(athlete: athlete, settingsModel: SettingsModel(stravaOAuth: StravaOAuthMock(token: nil)))
                    .previewLayout(PreviewLayout.fixed(width: 400, height: 100))
                    .padding()
                    .environment(\.locale, locale)
                    .previewDisplayName(Locale.current.localizedString(forIdentifier: locale.identifier))
            }
        }
    }
}

extension Athlete {
    var imageURL: URL {
        if let url = URL(string: profile ?? profile_medium ?? "") {
            return url
        }
        else {
            return URL(string: "https://www.travaartje.net")!
        }
    }
    
    var displayName: String {
        if let firstname = firstname {
            if let lastname = lastname {
                return firstname + " " + lastname
            }
            else {
                return firstname
            }
        }
        else {
            if let lastname = lastname {
                return lastname
            }
            else {
                return "---"
            }
        }
    }
    
    var displayLocation: String {
        if let city = city {
            if let country = country {
                return city + ", " + country
            }
            else {
                return city
            }
        }
        else {
            if let country = country {
                return country
            }
            else {
                return "---"
            }
        }
    }
}
