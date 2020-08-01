//
//  Workout+GPX.swift
//  Travaartje
//
//  Created by Berrie Kremers on 26/07/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import Foundation
import Combine
import HealthKit
import HealthKitCombine
import HCKalmanFilter
import CoreLocation
import CoreGPX

extension Workout {
    var gpxRoute: AnyPublisher<GPXRoot, Error> {
        CurrentValueSubject<Workout, Error>(self)
            .tryMap({ (workout) -> HKWorkout in
                guard let workout = workout.workout else { throw HealthKitCombineError.init(kind: .noDataFound, errorCode: "No workouts found") }
                return workout
            })
            .flatMap { workout in
                return workout.workoutWithDetails
                    .mapError { error -> Error in
                           error
                    }
            }
            .map({ workoutDetails in
                WorkoutDetails(workout: workoutDetails.workout, locationSamples: self.applyHalman(workoutDetails.locationSamples), heartRateSamples: workoutDetails.heartRateSamples)
            })
            .map({ (workoutDetails) -> GPXRoot in
                let root = GPXRoot(withExtensionAttributes: [:], schemaLocation: "")
                root.creator = "Apple Watch with barometer"
                let metadata = GPXMetadata()
                metadata.time = workoutDetails.workout.startDate
                root.metadata = metadata

                let heartRateUnit = HKUnit(from: "count/min")
                let distanceCorrection = self.calculateDistanceCorrection(workoutDetails.locationSamples, workoutDistance: workoutDetails.workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0)
                var heartRateIndex = 0
                var distance = 0.0
                var previousLocation: CLLocation? = nil
                
                let segment = GPXTrackSegment()
                for location in workoutDetails.locationSamples {
                    let trackPoint = GPXTrackPoint(location)
                    let gpxExtensions = GPXExtensions()
                    if let previousLocation = previousLocation {
                        distance += location.distance(from: previousLocation) * distanceCorrection
                    }
                    gpxExtensions.append(at: nil, contents: ["distance": "\(distance)"])

                    if workoutDetails.heartRateSamples.count > 0 {
                        // Find the next heart rate sample just prior to the date of the location timestamp
                        while heartRateIndex + 1 < workoutDetails.heartRateSamples.count,
                            workoutDetails.heartRateSamples[heartRateIndex + 1].startDate <= location.timestamp {
                                heartRateIndex += 1
                        }
                        gpxExtensions.append(at: nil, contents: ["heartrate": "\(Int(workoutDetails.heartRateSamples[heartRateIndex].quantity.doubleValue(for: heartRateUnit)))"])
                    }
                    trackPoint.extensions = gpxExtensions
                    segment.add(trackpoint: trackPoint)
                    
                    previousLocation = location
                }

                let track = GPXTrack()
                track.add(trackSegment: segment)
                root.add(track: track)
                return root
            })
            .eraseToAnyPublisher()
    }
    
    private func applyHalman(_ samples: [CLLocation]) -> [CLLocation] {
        guard samples.count > 0 else { return [] }
        
        var firstItem = true
        let hcKalmanFilter = HCKalmanAlgorithm(initialLocation: samples[0])

        return samples.map { (sample) -> CLLocation in
            if firstItem {
                firstItem = false
                return sample
            }
            else {
                return hcKalmanFilter.processState(currentLocation: sample)
            }
        }
    }
    
    private func calculateDistanceCorrection(_ samples: [CLLocation], workoutDistance: Double) -> Double {
        guard samples.count > 1 else { return 1.0 }
        
        // Add up the distances between all locations.
        return workoutDistance / samples.reduce((samples[0], 0.0)) { ($1, $0.1 + $1.distance(from: $0.0)) }.1
    }
}

extension GPXTrackPoint {
    convenience init(_ location: CLLocation) {
        self.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        elevation = location.altitude
        time = location.timestamp
    }
}
