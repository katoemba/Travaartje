//
//  OnboardingModel.swift
//  Travaartje
//
//  Created by Berrie Kremers on 25/08/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import Foundation
import Combine
import HealthKitCombine
import HealthKit
import SwiftUI

typealias StepAction = () -> (Void)
struct OnboardingStep: Identifiable {
    let id = UUID()
    let step: Int
    let isActive: Bool
    let imageSystemName: String
    let text: String
    let descriptiveText: String
    let accessibilityIdentifier: String
    let action: StepAction
}

class OnboardingModel: ObservableObject {    
    private var settingsModel: SettingsModel
    @Published var onboardingDone = AppDefaults.standard.bool(forKey: AppDefaults.onboardingRequiredKey) {
        didSet {
            AppDefaults.standard.set(onboardingDone, forKey: AppDefaults.onboardingRequiredKey)
            if onboardingDone {
                // Don't show the widget toaster when onboarding is done.
                widgetNotificationShown = true
            }
        }
    }
    @Published var widgetNotificationShown = AppDefaults.standard.bool(forKey: AppDefaults.widgetNotificationShownKey) {
        didSet {
            AppDefaults.standard.set(widgetNotificationShown, forKey: AppDefaults.widgetNotificationShownKey)
        }
    }

    private let activeStepSubject = CurrentValueSubject<Int, Never>(1)
    private let stepsSubject = PassthroughSubject<[OnboardingStep], Never>()
    @Published var steps = [OnboardingStep]()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(settingsModel: SettingsModel) {
        self.settingsModel = settingsModel
        Publishers.CombineLatest(activeStepSubject, stepsSubject)
            .map { (activeStep, steps) -> [OnboardingStep] in
                steps.map { (step) -> OnboardingStep in
                    OnboardingStep(step: step.step,
                                   isActive: step.step == activeStep,
                                   imageSystemName: step.imageSystemName,
                                   text: step.text,
                                   descriptiveText: step.descriptiveText,
                                   accessibilityIdentifier: step.accessibilityIdentifier,
                                   action: step.action)
                }
        }
        .assign(to: \.steps, on: self)
        .store(in: &cancellables)
        
        stepsSubject.send([OnboardingStep(step: 1,
                                          isActive: false,
                                          imageSystemName: "1.circle",
                                          text: NSLocalizedString("Give HealthKit access", comment: ""),
                                          descriptiveText: NSLocalizedString("Travaartje needs access to your workout data so it can show your recent workouts. Click the above button to open the configuration screen (this may take a few seconds).", comment: ""),
                                          accessibilityIdentifier: "StepLabel",
                                          action: {
                                            self.healthKitAuthorization()
                                                .receive(on: RunLoop.main)
                                                .sink { (authorized) in
                                                    if authorized {
                                                        withAnimation {
                                                            self.activeStepSubject.send(2)
                                                        }
                                                    }
                                            }
                                            .store(in: &self.cancellables)
        }),
                           OnboardingStep(step: 2,
                                          isActive: false,
                                          imageSystemName: "2.circle",
                                          text: NSLocalizedString("Connect to Strava", comment: ""),
                                          descriptiveText: NSLocalizedString("Travaartje needs to be authorized before it can upload workouts to Strava. Click the button above to go to Strava to provide this authorization.", comment: ""),
                                          accessibilityIdentifier: "StepLabel",
                                          action: {
                                            self.settingsModel.authorize()
                                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000),
                                                                          execute: {
                                                                            withAnimation {
                                                                                self.activeStepSubject.send(3)
                                                                            }
                                            })
                           }),
                           OnboardingStep(step: 3,
                                          isActive: false,
                                          imageSystemName: "3.circle",
                                          text: NSLocalizedString("Get started", comment: ""),
                                          descriptiveText: NSLocalizedString("All set, let's get started!\n\nOh, and if you're running iOS 14 or later, don't forget to checkout the Travaartje widget that shows your latest workout on your homescreen with the possibility to upload them with 1 click.", comment: ""),
                                          accessibilityIdentifier: "StepLabel",
                                          action: {
                                            withAnimation {
                                                self.onboardingDone = true
                                            }
                           })])
        
        #if !targetEnvironment(simulator)
        HKHealthStore().shouldAuthorize()
            .receive(on: RunLoop.main)
            .replaceError(with: false)
            .map { $0 == true ? 1 : 2 }
            .sink(receiveValue: { (step) in
                self.activeStepSubject.send(step)
            })
            .store(in: &cancellables)
        #endif
    }
    
    func healthKitAuthorization() -> AnyPublisher<Bool, Never> {
        #if !targetEnvironment(simulator)
        return HKHealthStore().authorize()
            .receive(on: RunLoop.main)
            .replaceError(with: false)
            .eraseToAnyPublisher()
        #else
        return Just(true)
            .eraseToAnyPublisher()
        #endif
    }
}
