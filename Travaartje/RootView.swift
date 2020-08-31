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

    var body: some View {
        NavigationView {
            if onboardingModel.onboardingDone {
                WorkoutListView()
            }
            else {
                OnboardingView(onboardingModel: onboardingModel)
                    .transition(.move(edge: .top))
            }
        }
    }
}