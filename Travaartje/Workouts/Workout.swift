//
//  Workout.swift
//
//
//  Created by Berrie Kremers on 19/07/2020.
//

import UIKit
import Combine
import HealthKit
import CoreData

@objc(Workout)
public class Workout: NSManagedObject, Identifiable {
    @NSManaged public var healthKitId: UUID
    @NSManaged private var status: String
    @NSManaged public var name: String
    @NSManaged public var descr: String
    @NSManaged public var commute: Bool
    @NSManaged public var workoutDate: Date
    @NSManaged public var stravaId: Int
    @NSManaged public var uploadDate: Date
    @NSManaged public var uploadResult: String
    @NSManaged public var hasRoute: Bool

    @Published public var workout: HKWorkout?
}

extension Workout {
    public enum State: String {
        case new = "New"
        case generatingFile = "Generating File"
        case uploadingFile = "Uploading File"
        case stravaProcessing = "Processing by Strava"
        case uploaded = "Uploaded"
        case failed = "Failed"
    }

    public var state: State {
        get {
            return State(rawValue: status)!
        }
        set {
            status = newValue.rawValue
        }
    }
    
    public var stateIcon: String {
        switch state {
        case .new:
            return "star"
        case .generatingFile, .uploadingFile, .stravaProcessing:
            return "arrow.right.arrow.left.circle"
        case .failed:
            return "exclamationmark.triangle"
        case .uploaded:
            return "checkmark.circle"
        }
    }
    
    public var type: String {
        guard let workout = workout else { return "Unknown" }
        
        return workout.type
    }
    
    public var date: String {
        guard let workout = workout else { return "Unknown" }

        return workout.date
    }
    
    public var distance: String {
        guard let workout = workout else { return "Unknown" }

        return workout.distance
    }
    
    public var duration: String {
        guard let workout = workout else { return "Unknown" }
        
        return workout.durationString
    }
}

extension Workout {
    convenience init(context: NSManagedObjectContext, workout: HKWorkout) {
        self.init(context: context)
        self.workout = workout
    }

    convenience init(context: NSManagedObjectContext, healthKitId: UUID) {
        self.init(context: context)
        self.healthKitId = healthKitId
    }
}

extension Workout {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workout> {
        return NSFetchRequest<Workout>(entityName: "Workout")
    }
}

extension HKWorkout {
    public var type: String {
        switch workoutActivityType {
        case .running:
            return "Run"
        case .swimming:
            return "Swim"
        case .cycling:
            return "Ride"
        case .downhillSkiing:
            return "Skiing"
        case .crossCountrySkiing:
            return "Skiing"
        case .rowing:
            return "Rowing"
        case .skatingSports:
            return "Skating"
        case .soccer:
            return "Soccer"
        case .snowboarding:
            return "Snowboard"
        case .surfingSports:
            return "Surfing"
        case .hiking:
            return "Hike"
        case .walking:
            return "Walk"
        case .wheelchairRunPace:
            return "Weelchair"
        case .crossTraining:
            return "Crossfit"
        case .climbing:
            return "Rock Climb"
        case .sailing:
            return "Sail"
        case .yoga:
            return "Yoga"
        case .paddleSports:
            return "Paddle"
        case .golf:
            return "Golf"
        default:
            return "Other"
        }
    }
    
    public var date: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true

        return formatter.string(from: startDate)
    }
    
    public var distance: String {
        let km = totalDistance?.doubleValue(for: .meterUnit(with: .kilo)) ?? 0.0
        return String(format: "%.1f km", km)
    }
    
    public var durationString: String {
        let hours = Int(duration / 3600.0)
        let minutes = Int((duration - Double(hours) * 3600.0) / 60.0)
        let seconds = Int(duration - Double(hours) * 3600.0 - Double(minutes) * 60.0)

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

}
