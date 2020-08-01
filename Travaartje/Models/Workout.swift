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

    @Published public var workout: HKWorkout?
}

extension Workout {
    public enum State: String {
        case new = "New"
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
        case .failed:
            return "exclamationmark.triangle"
        case .uploaded:
            return "checkmark.circle"
        }
    }
    
    public var type: String {
        guard let workout = workout else { return "Unknown" }
        switch workout.workoutActivityType {
        case .running:
            return "Run"
        case .swimming:
            return "Swim"
        case .cycling:
            return "Ride"
        default:
            return "Other"
        }
    }
    
    public var date: String {
        guard let workout = workout else { return "Unknown" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true

        return formatter.string(from: workout.startDate)
    }
    
    public var distance: String {
        guard let workout = workout else { return "Unknown" }

        let km = workout.totalDistance?.doubleValue(for: .meterUnit(with: .kilo)) ?? 0.0
        return String(format: "%.1f km", km)
    }
    
    public var duration: String {
        guard let workout = workout else { return "Unknown" }

        let hours = Int(workout.duration / 3600.0)
        let minutes = Int((workout.duration - Double(hours) * 3600.0) / 60.0)
        let seconds = Int(workout.duration - Double(hours) * 3600.0 - Double(minutes) * 60.0)

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
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
