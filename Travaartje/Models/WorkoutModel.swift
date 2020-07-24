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
    private var hkWorkoutsCancellable: AnyCancellable?
    private var storedWorkoutsCancellable: AnyCancellable?
    private var context: NSManagedObjectContext?
    private var healthStoreCombine: HKHealthStoreCombine
    private var limit: Int

    public init(context: NSManagedObjectContext,
                limit: Int = 10,
                healthStoreCombine: HKHealthStoreCombine = HKHealthStore()) {
        self.context = context
        self.healthStoreCombine = healthStoreCombine
        self.limit = limit
        fetchStoredWorkouts()
        reloadHealthKitWorkouts()        
    }
    
    private func fetchStoredWorkouts() {
        guard let context = context else { return }
        
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.fetchLimit = limit
        request.sortDescriptors = [NSSortDescriptor(key: "workoutDate", ascending: false)]
        do {
            let storedWorkouts = try context.fetch(request)
            storedWorkoutsCancellable = healthStoreCombine.workouts(storedWorkouts.map({ $0.healthKitId}))
                .replaceError(with: [])
                .sink { (workouts) in
                    for workout in workouts {
                        if let storedWorkout = storedWorkouts.first(where: { $0.healthKitId == workout.uuid }) {
                            storedWorkout.workout = workout
                        }
                    }
                    self.workouts = storedWorkouts
                }
        }
        catch {
            print(error)
        }
    }
    
    func reloadHealthKitWorkouts() {
        guard let context = context else { return }
        
        hkWorkoutsCancellable = healthStoreCombine.workouts(limit)
            .replaceError(with: [])
            .removeDuplicates()
            .sink { (workouts) in
                var newWorkoutFound = false
                for workout in workouts {
                    let fetchWorkout = NSFetchRequest<Workout>(entityName: "Workout")
                    fetchWorkout.predicate = NSPredicate(format: "healthKitId == %@", workout.uuid as CVarArg)
                    do {
                        let storedWorkouts = try context.fetch(fetchWorkout)
                        if storedWorkouts.count == 0 {
                            let newWorkout = Workout(context: context, workout: workout)
                            newWorkout.healthKitId = workout.uuid
                            newWorkout.workoutDate = workout.startDate
                            newWorkout.state = .new
                            newWorkout.commute = false
                            newWorkout.stravaId = 0
                            
                            newWorkoutFound = true
                        }
                    }
                    catch {
                        print(error)
                    }
                }

                if newWorkoutFound {
                    do {
                        try context.save()
                        self.fetchStoredWorkouts()
                    } catch {
                    }
                }
        }
    }

    func save() {
        guard let context = context else { return }
        
        if context.hasChanges {
            try? context.save()
        }
    }
}
