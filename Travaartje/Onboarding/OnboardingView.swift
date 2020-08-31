//
//  OnboardingView.swift
//  Travaartje
//
//  Created by Berrie Kremers on 24/08/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import SwiftUI
import Combine
import StravaCombine
import HealthKitCombine


struct OnboardingView: View {
    @ObservedObject var onboardingModel: OnboardingModel

    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
            VStack(alignment: .leading, spacing: 10.0) {
                Text("Travaartje lets you upload workouts that you recorded with the Workout app on your AppleWatch or iPhone to Strava in the easiest possible way.")
                
                Text("We will now guide you through the setup process in a few simple steps, so that you can get started.")

                ForEach(onboardingModel.steps) { step in
                    Spacer()
                        .frame(height: 10.0)

                    StepView(isActive: step.isActive,
                             step: step.step,
                             imageSystemName: step.imageSystemName,
                             text: step.text,
                             descriptiveText: step.descriptiveText,
                             accessibilityIdentifier: step.accessibilityIdentifier,
                             action: step.action)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitle("Welcome")
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var onboardingModel = AppDelegate.shared.onboardingModel
    static var previews: some View {
        return OnboardingView(onboardingModel: onboardingModel)
    }
}
