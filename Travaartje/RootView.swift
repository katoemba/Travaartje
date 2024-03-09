//
//  RootView.swift
//  Travaartje
//
//  Created by Berrie Kremers on 27/08/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import SwiftUI
import Combine

 struct RootView: View {
    @State var cancellables = Set<AnyCancellable>()
    @ObservedObject var onboardingModel: OnboardingModel
    @ObservedObject var settingsModel: SettingsModel
    @ObservedObject var workoutModel: WorkoutModel

    var body: some View {
        NavigationView {
            VStack {
                if onboardingModel.onboardingDone {
                    ZStack {
                        WorkoutListView(settingsModel: settingsModel, workoutModel: workoutModel)
                        
                        if onboardingModel.widgetNotificationShown == false {
                            ToastView(shown: $onboardingModel.widgetNotificationShown, title: LocalizedStringKey("Would you like to upload your workouts even quicker?\n\nCheckout the Travaartje widget that shows your latest workout on your homescreen with the possibility to upload it with 1 click."))
                        }
                    }
                }
                else {
                    OnboardingView(onboardingModel: onboardingModel)
                        .transition(.move(edge: .top))
                }
                Image("api_logo_cptblWith_strava_horiz_light")
            }
        }
    }
}
