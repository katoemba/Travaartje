//
//  AppDelegate.swift
//  Travaartje
//
//  Created by Berrie Kremers on 17/07/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import UIKit
import HealthKit
import CoreLocation
import Combine
import CoreData
import HealthKitCombine


@UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {
    private var authCancellable: AnyCancellable?
    private var newWorkoutsCancellable: AnyCancellable?
    private var workoutModel: WorkoutModel?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        workoutModel = WorkoutModel(context: persistentContainer.viewContext)
        authCancellable = HKHealthStore().authorize()
            .sink(receiveCompletion: { (finished) in
                switch finished {
                case .finished:
                    print("Authorization completed")
                case let .failure(error):
                    print("Authorization failed \(error)")
                }
            }, receiveValue: { (result) in
                print("Authorization result \(result)")
            })
        
        workoutModel?.reloadHealthKitWorkouts()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    #if targetEnvironment(simulator)
    lazy var healthKitStoreCombine: HKHealthStoreCombine = {
        let healthKitMock = HealthKitCombineMock()
        let runDate = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2020, month: 5, day: 17, hour: 14, minute: 7, second: 58).date!
        let rideDate = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2020, month: 5, day: 17, hour: 08, minute: 58, second: 23).date!
        healthKitMock.hkWorkouts = [HKWorkout(activityType: .running, start: runDate, end: runDate.addingTimeInterval(4040), workoutEvents: nil, totalEnergyBurned: nil, totalDistance: HKQuantity(unit: .meter(), doubleValue: 8765.9), metadata: nil),
                                    HKWorkout(activityType: .cycling, start: rideDate, end: rideDate.addingTimeInterval(1000), workoutEvents: nil, totalEnergyBurned: nil, totalDistance: HKQuantity(unit: .meter(), doubleValue: 5609.0), metadata: nil)]
        return healthKitMock
    }()
    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
        return managedObjectModel
    }()
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "Travaartje", managedObjectModel: self.managedObjectModel)
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.shouldAddStoreAsynchronously = false
            
            container.persistentStoreDescriptions = [description]
            container.loadPersistentStores { (description, error) in
                // Check if the data store is in memory
                precondition( description.type == NSInMemoryStoreType )
                                            
                // Check if creating container wrong
                if let error = error {
                    fatalError("Create an in-mem coordinator failed \(error)")
                }
            }
            return container
        }()
    #else
    lazy var healthKitStoreCombine: HKHealthStoreCombine = {
        HKHealthStore()
    }()
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Travaartje")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    #endif

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
