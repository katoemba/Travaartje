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
    struct UploadStatus {
        let state: Workout.State
        let uploadResult: String
        
        init(_ workout: Workout) {
            state = workout.state
            uploadResult = workout.uploadResult
        }
    }

    public typealias StravaUploadFactory = () -> (StravaUploadProtocol)
    @Published public var workouts = [Workout]()
    private var context: NSManagedObjectContext
    private var limit: Int
    private var cancellables: Set<AnyCancellable> = []
    private let healthStoreCombine: HKHealthStoreCombine
    private let stravaAuth: StravaOAuthProtocol
    private let stravaUploadFactory: StravaUploadFactory

    public init(context: NSManagedObjectContext,
                limit: Int = 10,
                healthStoreCombine: HKHealthStoreCombine = HKHealthStore(),
                stravaOAuth: StravaOAuthProtocol,
                stravaUploadFactory: @escaping StravaUploadFactory = { StravaUpload(StravaConfig.standard) }) {
        self.context = context
        self.limit = limit
        self.healthStoreCombine = healthStoreCombine
        self.stravaAuth = stravaOAuth
        self.stravaUploadFactory = stravaUploadFactory
        fetchStoredWorkouts()
        reloadHealthKitWorkouts()        
    }
    
    private func fetchStoredWorkouts() {
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
        healthStoreCombine.workouts(limit)
            .replaceError(with: [])
            .removeDuplicates()
            .sink { (workouts) in
                var newWorkoutFound = false
                for workout in workouts {
                    let fetchWorkout = NSFetchRequest<Workout>(entityName: "Workout")
                    fetchWorkout.predicate = NSPredicate(format: "healthKitId == %@", workout.uuid as CVarArg)
                    do {
                        let storedWorkouts = try self.context.fetch(fetchWorkout)
                        if storedWorkouts.count == 0 {
                            let newWorkout = Workout(context: self.context, workout: workout)
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
                    self.save()
                    self.fetchStoredWorkouts()
                }
            }
            .store(in: &cancellables)
    }
    
    func upload(_ workout: Workout) -> AnyPublisher<UploadStatus, Never> {
        let uploadStatusSubject = PassthroughSubject<UploadStatus, Never>()
        
        workout.state = .generatingFile
        workout.uploadResult = ""
        uploadStatusSubject.send(UploadStatus(workout))
        
        workout.gpxRoute(healthKitCombine: healthStoreCombine)
            .subscribe(on: RunLoop.main)
            .flatMap(maxPublishers: .max(1)) { (gpxRoot) -> AnyPublisher<(StravaToken, GPXRoot), Error> in
                workout.state = .uploadingFile
                return self.stravaAuth.token
                    .tryMap { (token) -> (StravaToken, GPXRoot) in
                        if let token = token {
                            return (token, gpxRoot)
                        }
                        throw StravaCombineError.uploadFailed(NSLocalizedString("Travaartje is not connected to your Strava account. You can do this on the settings page.", comment: ""))
                    }
                    .eraseToAnyPublisher()
            }
            .first()
            .flatMap(maxPublishers: .max(1)) { (token, gpxRoot)  in
                self.stravaUploadFactory().uploadGpx(gpxRoot.gpx().data(using: .utf8)!,
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
                self.save()
                
                uploadStatusSubject.send(UploadStatus(workout))
                uploadStatusSubject.send(completion: .finished)
            }) { (upload) in
                workout.state = upload.activity_id == nil ? .stravaProcessing : .uploaded
                self.save()
                
                uploadStatusSubject.send(UploadStatus(workout))
            }
            .store(in: &cancellables)
        
        return uploadStatusSubject.eraseToAnyPublisher()
    }

    func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
