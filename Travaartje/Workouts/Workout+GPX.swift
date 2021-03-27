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
import StravaCombine

extension Workout {
    public func gpxRoute(applyHallman: Bool = true, healthKitCombine: HKHealthStoreCombine) -> AnyPublisher<GPXRoot, Error> {
        CurrentValueSubject<Workout, Error>(self)
            .tryMap({ (workout) -> HKWorkout in
                guard let workout = workout.workout else { throw HealthKitCombineError.init(kind: .noDataFound, errorCode: "No workouts found") }
                return workout
            })
            .flatMap { workout in
                return healthKitCombine.workoutDetails(workout)
                    .mapError { error -> Error in
                           error
                    }
            }
            .map({ workoutDetails in
                applyHallman
                    ? WorkoutDetails(workout: workoutDetails.workout, locationSamples: self.applyHalman(workoutDetails.locationSamples), heartRateSamples: workoutDetails.heartRateSamples)
                    : workoutDetails
            })
            .map({ (workoutDetails) -> GPXRoot in
                let root = GPXRoot(withExtensionAttributes: [:], schemaLocation: "")
                root.creator = workoutDetails.workout.device?.hardwareVersion ?? "Apple Watch"
                let metadata = GPXMetadata()
                metadata.time = workoutDetails.workout.startDate
                root.metadata = metadata

                let heartRateUnit = HKUnit(from: "count/min")
                let workoutDistance = workoutDetails.workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0
                let distanceCorrection = self.calculateDistanceCorrection(workoutDetails.locationSamples, workoutDistance: workoutDistance)
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
    
    /// A function to generate a file without gps data. It puts in a trackpoint for every 5 seconds.
    /// - Parameter healthKitCombine: an object that conforms to the HKHealthStoreCombine protocol
    /// - Returns: a tcx-formatted Data object
    public func tcxData(healthKitCombine: HKHealthStoreCombine) -> Data {
        guard let hkWorkout = workout else { return Data() }
        
        let dateFormatter = ISO8601DateFormatter()
        let distanceUnit = HKUnit(from: "m")
        let energyUnit = HKUnit(from: "kcal")
        let offset = 0
        var distance = 0.0
        
        var tcxData = Data()
        tcxData.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n".data(using: String.Encoding.utf8)!)
        tcxData.append("<TrainingCenterDatabase xsi:schemaLocation=\"http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd\" xmlns:ns5=\"http://www.garmin.com/xmlschemas/ActivityGoals/v1\" xmlns:ns3=\"http://www.garmin.com/xmlschemas/ActivityExtension/v2\" xmlns:ns2=\"http://www.garmin.com/xmlschemas/UserProfile/v2\" xmlns=\"http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n".data(using: String.Encoding.utf8)!)
        tcxData.append(" <Activities>\n".data(using: String.Encoding.utf8)!)
        tcxData.append("  <Activity Sport=\"\(hkWorkout.stravaActivityType.rawValue)\">\n".data(using: String.Encoding.utf8)!)
        tcxData.append("   <Id>\(dateFormatter.string(from: hkWorkout.startDate.addingTimeInterval(TimeInterval(offset))))</Id>\n".data(using: String.Encoding.utf8)!)
        tcxData.append("   <Lap StartTime=\"\(dateFormatter.string(from: hkWorkout.startDate.addingTimeInterval(TimeInterval(offset))))\">\n".data(using: String.Encoding.utf8)!)
        tcxData.append("    <TotalTimeSeconds>\(Int(hkWorkout.duration))</TotalTimeSeconds>\n".data(using: String.Encoding.utf8)!)
        if let totalDistance = hkWorkout.totalDistance {
            tcxData.append("    <DistanceMeters>\(Int(totalDistance.doubleValue(for: distanceUnit)))</DistanceMeters>\n".data(using: String.Encoding.utf8)!)
        }
        else {
            tcxData.append("    <DistanceMeters>0.0</DistanceMeters>\n".data(using: String.Encoding.utf8)!)
        }
        if let maximumSpeed = hkWorkout.metadata?[HKMetadataKeyMaximumSpeed] {
            tcxData.append("    <MaximumSpeed>\(maximumSpeed)</MaximumSpeed>\n".data(using: String.Encoding.utf8)!)
        }
        
        if let totalEnergyBurned = hkWorkout.totalEnergyBurned {
            tcxData.append("    <Calories>\(Int(totalEnergyBurned.doubleValue(for: energyUnit)))</Calories>\n".data(using: String.Encoding.utf8)!)
        }
        
        let interval = 5
        let distancePer5Seconds = (hkWorkout.totalDistance?.doubleValue(for: distanceUnit) ?? Double(0.0)) / (hkWorkout.duration / Double(interval))
        for sec in 0..<Int(hkWorkout.duration) / interval {
            tcxData.append("     <Trackpoint>\n".data(using: String.Encoding.utf8)!)
            tcxData.append("      <Time>\(dateFormatter.string(from: hkWorkout.startDate.addingTimeInterval(TimeInterval(sec * interval + offset))))</Time>\n".data(using: String.Encoding.utf8)!)
            
            tcxData.append("      <DistanceMeters>\(String(format: "%.1f", distance))</DistanceMeters>\n".data(using: String.Encoding.utf8)!)
            distance = distance + distancePer5Seconds
            
            tcxData.append("     </Trackpoint>\n".data(using: String.Encoding.utf8)!)
        }

        tcxData.append("   </Lap>\n".data(using: String.Encoding.utf8)!)
        tcxData.append("  </Activity>\n".data(using: String.Encoding.utf8)!)
        tcxData.append(" </Activities>\n".data(using: String.Encoding.utf8)!)
        tcxData.append("</TrainingCenterDatabase>\n".data(using: String.Encoding.utf8)!)
        
        return tcxData
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

extension HKWorkout {
    var stravaActivityType: StravaActivityType {
        switch workoutActivityType {
        case .running:
            return .run
        case .cycling:
            return .ride
        case .swimming:
            return .swim
        case .downhillSkiing:
            return .alpineSki
        case .crossCountrySkiing:
            return .backcountrySki
        case .rowing:
            return .rowing
        case .skatingSports:
            return .iceSkate
        case .soccer:
            return .soccer
        case .snowboarding:
            return .snowboard
        case .surfingSports:
            return .surfing
        case .hiking:
            return .hike
        case .walking:
            return .walk
        case .wheelchairRunPace:
            return .wheelchair
        case .crossTraining:
            return .crossfit
        case .climbing:
            return .rockClimbing
        case .sailing:
            return .sail
        case .yoga:
            return .yoga
        case .paddleSports:
            return .standUpPaddling
        case .golf:
            return .golf
        default:
            return .workout
        }
    }
}
