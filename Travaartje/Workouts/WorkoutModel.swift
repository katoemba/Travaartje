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
import WidgetKit

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
    
    @Published public private(set) var canUpload: Bool = false
    
    public init(context: NSManagedObjectContext,
                limit: Int = 50,
                healthStoreCombine: HKHealthStoreCombine = HKHealthStore(),
                stravaOAuth: StravaOAuthProtocol,
                stravaUploadFactory: @escaping StravaUploadFactory = { StravaUpload(StravaConfig.standard) }) {
        self.context = context
        self.limit = limit
        self.healthStoreCombine = healthStoreCombine
        self.stravaAuth = stravaOAuth
        self.stravaUploadFactory = stravaUploadFactory
        stravaAuth.token
            .map { $0 != nil }
            .assign(to: \.canUpload, on: self)
            .store(in: &cancellables)
        fetchStoredWorkouts()
        reloadHealthKitWorkouts()        
    }
    
    private func fetchStoredWorkouts() {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        let limit = self.limit
        // Fetch some extra stored workouts to compensate for deleted workouts
        // The real limit will be re-applied at the end
        request.fetchLimit = limit + 10
        request.sortDescriptors = [NSSortDescriptor(key: "workoutDate", ascending: false)]
        do {
            let storedWorkouts = try context.fetch(request)
            healthStoreCombine.workouts(storedWorkouts.map({ $0.healthKitId}))
                .replaceError(with: [])
                .map({ (workouts) -> [Workout] in
                    for workout in workouts {
                        if let storedWorkout = storedWorkouts.first(where: { $0.healthKitId == workout.uuid }) {
                            storedWorkout.workout = workout
                        }
                    }
                    return Array(storedWorkouts.compactMap { $0.workout == nil ? nil : $0 }.prefix(limit))
                })
                .assign(to: \.workouts, on: self)
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
            .receive(on: RunLoop.main)
            .sink { (workouts) in
                var newWorkoutFound = false
                for workout in workouts {
                    let fetchWorkout = NSFetchRequest<Workout>(entityName: "Workout")
                    fetchWorkout.predicate = NSPredicate(format: "healthKitId == %@", workout.uuid as CVarArg)
                    do {
                        let storedWorkouts = try self.context.fetch(fetchWorkout)
                        var workoutToCheck: Workout? = nil
                        if storedWorkouts.count == 0 {
                            let newWorkout = Workout(context: self.context, workout: workout)
                            newWorkout.healthKitId = workout.uuid
                            newWorkout.workoutDate = workout.startDate
                            newWorkout.state = .new
                            newWorkout.commute = false
                            newWorkout.stravaId = 0
                            
                            newWorkoutFound = true
                            workoutToCheck = newWorkout
                        }
                        else if storedWorkouts[0].hasRoute == false {
                            workoutToCheck = storedWorkouts[0]
                        }

                        if let workoutToCheck = workoutToCheck {
                            self.healthStoreCombine.workoutDetails(workout)
                                .receive(on: RunLoop.main)
                                .map { $0.locationSamples.count > 0 }
                                .sink(receiveCompletion: { (_) in
                                }, receiveValue: { (hasRoute) in
                                    workoutToCheck.hasRoute = hasRoute
                                    self.save()
                                    self.fetchStoredWorkouts()
                                })
                                .store(in: &self.cancellables)
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
    
    /// Return the number of workouts found in HealthKit, and not yet loaded into Travaartje. This can be used to show a badge for the number of new workouts
    /// - Returns: A publisher for the number of new workouts. Will publish 0 in case an error occurs.
    func newHealthKitWorkoutCount() -> AnyPublisher<Int, Never> {
        healthStoreCombine.workouts(limit)
            .replaceError(with: [])
            .removeDuplicates()
            .map { (workouts) in
                var newWorkoutCount = 0
                for workout in workouts {
                    let fetchWorkout = NSFetchRequest<Workout>(entityName: "Workout")
                    fetchWorkout.predicate = NSPredicate(format: "healthKitId == %@", workout.uuid as CVarArg)
                    do {
                        let storedWorkouts = try self.context.fetch(fetchWorkout)
                        if storedWorkouts.count == 0 {
                            newWorkoutCount += 1
                        }
                    }
                    catch {
                        print(error)
                    }
                }
                
                return newWorkoutCount
            }
            .replaceError(with: 0)
            .eraseToAnyPublisher()
    }
    
    func upload(_ workout: Workout, fromWidget: Bool = false, minimumHeartRatePerMinute: Int) -> AnyPublisher<UploadStatus, Never> {
        let uploadStatusSubject = PassthroughSubject<UploadStatus, Never>()
        let uploadParameters = UploadParameters(activityType: workout.workout?.stravaActivityType ?? .workout,
        name: workout.name,
        description: workout.descr,
        commute: workout.commute,
        trainer: false,
        private: false)
        
        workout.state = .generatingFile
        workout.uploadResult = ""
        uploadStatusSubject.send(UploadStatus(workout))
        
        var dataPublished: AnyPublisher<(Data, DataType), Error>
        
        stravaAuth.refreshTokenIfNeeded()
        if workout.hasRoute {
            dataPublished = workout.gpxRoute(healthKitCombine: healthStoreCombine, minimumHeartRatePerMinute: minimumHeartRatePerMinute)
                .map { ($0.gpx().data(using: .utf8)!, .gpx) }
                .eraseToAnyPublisher()
        }
        else {
            let dataSubject = CurrentValueSubject<(Data, DataType), Error>((workout.tcxData(healthKitCombine: healthStoreCombine), .tcx))
            
            dataPublished = dataSubject
                .eraseToAnyPublisher()
        }
        
        dataPublished
            .subscribe(on: RunLoop.main)
            .flatMap(maxPublishers: .max(1)) { (data, dataType) -> AnyPublisher<(StravaToken, Data, DataType), Error> in
                workout.state = .uploadingFile
                return self.stravaAuth.token
                    .tryMap { (token) -> (StravaToken, Data, DataType) in
                        if let token = token {
                            return (token, data, dataType)
                        }
                        throw StravaCombineError.uploadFailed(NSLocalizedString("Travaartje is not connected to your Strava account. You can do this on the settings page.", comment: ""))
                }
                .eraseToAnyPublisher()
        }
        .first()
        .flatMap(maxPublishers: .max(1)) { (token, data, dataType)  in
            return self.stravaUploadFactory().uploadData(data: data,
                                                         dataType: dataType,
                                                         uploadParameters: uploadParameters,
                                                         accessToken: token.access_token)
        }
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { (completion) in
            if case let .failure(error) = completion {
                workout.state = .failed
                workout.uploadResult = error.localizedDescription
                UsageLogger.shared.workoutUploadFailed(uploadParameters: uploadParameters, hasRoute: workout.hasRoute, fromWidget: fromWidget, error: error.localizedDescription)
            }
            else {
                workout.state = .uploaded
                UsageLogger.shared.workoutUploadSucceeded(uploadParameters: uploadParameters, hasRoute: workout.hasRoute, fromWidget: fromWidget)
            }
            self.save()
            
            uploadStatusSubject.send(UploadStatus(workout))
            uploadStatusSubject.send(completion: .finished)
        }) { (upload) in
            workout.state = upload.activity_id == nil ? .stravaProcessing : .uploaded
            if let activity_id = upload.activity_id {
                workout.stravaId = activity_id
            }
            self.save()
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadTimelines(ofKind: "com.katoemba.travaartje-widget")
            }

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
