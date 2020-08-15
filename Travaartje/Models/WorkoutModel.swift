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
import StravaCombine
import CoreGPX

public class WorkoutModel: ObservableObject {
    @Published public var workouts = [Workout]()
    private var context: NSManagedObjectContext?
    private var limit: Int
    private var cancellables: Set<AnyCancellable> = []
    private let healthStoreCombine: HKHealthStoreCombine
    private let stravaAuth: StravaOAuthProtocol
    private let stravaUpload: StravaUploadProtocol

    public init(context: NSManagedObjectContext,
                limit: Int = 10,
                healthStoreCombine: HKHealthStoreCombine = HKHealthStore(),
                stravaOAuth: StravaOAuthProtocol = StravaOAuth(config: StravaConfig.standard, tokenInfo: StravaToken.load(defaults: UserDefaults.standard, key: "StravaToken"), presentationAnchor: gWindow!),
                stravaUpload: StravaUploadProtocol = StravaUpload(StravaConfig.standard)) {
        self.context = context
        self.limit = limit
        self.healthStoreCombine = healthStoreCombine
        self.stravaAuth = stravaOAuth
        self.stravaUpload = stravaUpload
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
            healthStoreCombine.workouts(storedWorkouts.map({ $0.healthKitId}))
                .replaceError(with: [])
                .sink { (workouts) in
                    for workout in workouts {
                        if let storedWorkout = storedWorkouts.first(where: { $0.healthKitId == workout.uuid }) {
                            storedWorkout.workout = workout
                        }
                    }
                    self.workouts = storedWorkouts
                }
                .store(in: &cancellables)
        }
        catch {
            print(error)
        }
    }
    
    func reloadHealthKitWorkouts() {
        guard let context = context else { return }
        
        healthStoreCombine.workouts(limit)
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
            .store(in: &cancellables)
    }
    
    func upload(_ workout: Workout) {
        workout.state = .generatingFile
        workout.uploadResult = ""
        
        workout.gpxRoute(healthKitCombine: healthStoreCombine)
            .flatMap(maxPublishers: .max(1)) { (gpxRoot) -> AnyPublisher<(StravaToken, GPXRoot), Error> in
                workout.state = .uploadingFile
                return self.stravaAuth.token
                    .tryMap { (token) -> (StravaToken, GPXRoot) in
                        (token, gpxRoot)
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap(maxPublishers: .max(1)) { (token, gpxRoot)  in
                self.stravaUpload.uploadGpx(gpxRoot.gpx().data(using: .utf8)!,
                                            activityType: workout.workout?.stravaActivityType ?? .workout,
                                            accessToken: token.access_token)
            }
            .print("\(Date()) routeUpload")
            .sink(receiveCompletion: { (completion) in
                if case let .failure(error) = completion {
                    workout.state = .failed
                    workout.uploadResult = error.localizedDescription
                }
                else {
                    workout.state = .uploaded
                }
            }) { (upload) in
                workout.state = upload.activity_id == nil ? .stravaProcessing : .uploaded
            }
            .store(in: &cancellables)
    }

    func save() {
        guard let context = context else { return }
        
        if context.hasChanges {
            try? context.save()
        }
    }
}
