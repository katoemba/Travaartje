//
//  SceneDelegate.swift
//  Travaartje
//
//  Created by Berrie Kremers on 17/07/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import UIKit
import SwiftUI
import HealthKit

public var gWindow: UIWindow?
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        if let windowScene = scene as? UIWindowScene {
            gWindow = UIWindow(windowScene: windowScene)
        }

        // Create the SwiftUI view that provides the window contents.
        let workoutModel = AppDelegate.shared.workoutModel
        let settingsModel = AppDelegate.shared.settingsModel
        let onboardingModel = AppDelegate.shared.onboardingModel
        let contentView = RootView(onboardingModel: onboardingModel,
                                   settingsModel: settingsModel,
                                   workoutModel: workoutModel)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    // MARK: Handle URL for Strava authentication
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first,
            let code = URLComponents(string: urlContext.url.absoluteString)?.queryItems?.filter({$0.name == "code"}).first?.value else { return }
            
        AppDelegate.shared.stravaOAuth.processCode(code)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        AppDelegate.shared.workoutModel.reloadHealthKitWorkouts()
        AppDelegate.shared.stravaOAuth.refreshTokenIfNeeded()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

struct SettingsModelKey: EnvironmentKey {
    static let defaultValue: SettingsModel = AppDelegate.shared.settingsModel
}

struct WorkoutModelKey: EnvironmentKey {
    static let defaultValue: WorkoutModel = AppDelegate.shared.workoutModel
}

struct OnboardingModelKey: EnvironmentKey {
    static let defaultValue: OnboardingModel = AppDelegate.shared.onboardingModel
}

extension EnvironmentValues {
    var settingsModel: SettingsModel {
        get { self[SettingsModelKey.self] }
    }
    var workoutModel: WorkoutModel {
        get { self[WorkoutModelKey.self] }
    }
    var onboardingModel: OnboardingModel {
        get { self[OnboardingModelKey.self] }
    }
}
