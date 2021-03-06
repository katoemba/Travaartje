//
//  HealthKitCombineMock.swift
//  Travaartje
//
//  Created by Berrie Kremers on 24/07/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import Foundation
import HealthKit
import Combine
import HealthKitCombine
import CoreLocation

#if targetEnvironment(simulator)
class HealthKitCombineMock: HKHealthStoreCombine {
    public var shouldAuthorizeResult = true
    public var authorizationResult = true
    public var error: Error?
    public var locationSamples = [CLLocation]()
    public var heartRateSamples = [HKQuantitySample]()
    public var newWorkoutSubject = PassthroughSubject<HKWorkout, Error>()

    public var hkWorkouts = [HKWorkout]()
    
    func shouldAuthorize() -> AnyPublisher<Bool, Error> {
        shouldAuthorize(includeSharePermission: false)
    }

    func shouldAuthorize(includeSharePermission: Bool) -> AnyPublisher<Bool, Error> {
        Just(shouldAuthorizeResult)
            .tryMap { (result) -> Bool in
                guard error == nil else { throw error! }
                return result
            }
            .eraseToAnyPublisher()
    }
    
    
    func authorize() -> AnyPublisher<Bool, Error> {
        authorize(requestSharePermission: false)
    }

    func authorize(requestSharePermission: Bool) -> AnyPublisher<Bool, Error> {
        Just(authorizationResult)
            .tryMap { (result) -> Bool in
                guard error == nil else { throw error! }
                return result
            }
            .eraseToAnyPublisher()
    }

    func startObservingNewWorkouts() -> AnyPublisher<HKWorkout, Error> {
        newWorkoutSubject.eraseToAnyPublisher()
    }
    
    func stopObservingNewWorkouts() {
    }
    
    func workouts(_ limit: Int) -> AnyPublisher<[HKWorkout], Error> {
        Just(hkWorkouts)
            .tryMap { (workouts) -> [HKWorkout] in
                guard error == nil else { throw error! }
                return workouts
            }
            .eraseToAnyPublisher()
    }
    
    func workouts(_ ids: [UUID]) -> AnyPublisher<[HKWorkout], Error> {
        let filteredWorkouts = hkWorkouts.filter({ (workout) -> Bool in
            ids.contains(workout.uuid)
        })
        return Just(filteredWorkouts)
            .tryMap { (workouts) -> [HKWorkout] in
                guard error == nil else { throw error! }
                return workouts
            }
            .eraseToAnyPublisher()
    }
    
    func workout(_ id: UUID) -> AnyPublisher<HKWorkout, Error> {
        let filteredWorkouts = hkWorkouts.filter({ (workout) -> Bool in
            id == workout.uuid
        })
        return Just(filteredWorkouts)
            .tryMap { (workouts) -> HKWorkout in
                guard error == nil else { throw error! }
                guard workouts.count > 0 else { throw HealthKitCombineError(kind: .noDataFound, errorCode: "Workout with id \(id) not found") }
                return workouts[0]
            }
            .eraseToAnyPublisher()
    }
    
    func workoutDetails(_ workout: HKWorkout) -> AnyPublisher<WorkoutDetails, Error> {
        let workoutDetails = WorkoutDetails(workout: workout, locationSamples: locationSamples, heartRateSamples: heartRateSamples)
        return CurrentValueSubject<WorkoutDetails, Error>(workoutDetails)
            .eraseToAnyPublisher()
    }
}
#endif
