//
//  WorkoutModel.swift
//
//
//  Created by Berrie Kremers on 19/07/2020.
//

import Foundation
import Combine
import HealthKit
import CoreData
import HealthKitCombine


public class WorkoutModel: ObservableObject {
    @Published public var workouts = [Workout]()
    private var context: NSManagedObjectContext
    public var cancellables: Set<AnyCancellable> = []
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public static let shared = WorkoutModel.model()
    private static func model() -> WorkoutModel {
        let container = NSPersistentContainer(name: "Travaartje")
        let storeURL = URL.storeURL(for: "group.com.katoemba.travaartje", databaseName: "Travaartje")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return WorkoutModel(context: container.viewContext)
    }
    
    func storedWorkout(_ workout: HKWorkout) -> Workout? {
        let fetchWorkout = NSFetchRequest<Workout>(entityName: "Workout")
        fetchWorkout.predicate = NSPredicate(format: "healthKitId == %@", workout.uuid as CVarArg)
        do {
            let storedWorkouts = try self.context.fetch(fetchWorkout)
            if storedWorkouts.count > 0 {
                return storedWorkouts[0]
            }
        }
        catch {
        }
        
        return nil
    }
}

extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

extension HKWorkout {
    var state: Workout.State {
        WorkoutModel.shared.storedWorkout(self)?.state ?? .new
    }
}
