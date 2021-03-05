//
//  TravaartjeWidget.swift
//  TravaartjeWidget
//
//  Created by Berrie Kremers on 28/02/2021.
//  Copyright © 2021 Katoemba Software. All rights reserved.
//

import WidgetKit
import SwiftUI
import HealthKit
import HealthKitCombine
import Combine

struct WorkoutProvider: IntentTimelineProvider {
    typealias Intent = TravaartjeWidgetConfigurationIntent
    
    func placeholder(in context: Context) -> WorkoutEntry {
        return WorkoutEntry.demo(2)
    }
    
    func getStore() -> HKHealthStoreCombine {
        #if targetEnvironment(simulator)
        let hkWorkouts: [HKWorkout] = {
            let runDate = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2020, month: 5, day: 17, hour: 14, minute: 7, second: 58).date!
            let rideDate = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, year: 2020, month: 5, day: 16, hour: 08, minute: 58, second: 23).date!
            return [HKWorkout(activityType: .running, start: runDate, end: runDate.addingTimeInterval(2771), workoutEvents: nil, totalEnergyBurned: nil, totalDistance: HKQuantity(unit: .meter(), doubleValue: 8765.9), metadata: nil),
                    HKWorkout(activityType: .cycling, start: rideDate, end: rideDate.addingTimeInterval(11902), workoutEvents: nil, totalEnergyBurned: nil, totalDistance: HKQuantity(unit: .meter(), doubleValue: 85609.0), metadata: nil)]
        }()

        let healthKitMock = HealthKitCombineMock()
        healthKitMock.hkWorkouts = hkWorkouts
        return healthKitMock
        #else
        return HKHealthStore()
        #endif
    }

    func getSnapshot(for configuration: TravaartjeWidgetConfigurationIntent, in context: Context, completion: @escaping (WorkoutEntry) -> ()) {
        if context.isPreview {
            completion(WorkoutEntry.demo(2))
        }
        else {
            let store = getStore()
            store.workouts(2)
                .map {
                    $0.compactMap { (configuration.showOnlyNewWorkouts == false || WorkoutModel.shared.storedWorkout($0)?.state == .new) ? $0 : nil }
                        .map { WorkoutState(workout: $0, state: WorkoutModel.shared.storedWorkout($0)?.state ?? .new )}
                }
                .sink { (_) in
                } receiveValue: { (workouts) in
                    let entry = WorkoutEntry(date: Date(), workouts: workouts, uploadOnOpen: configuration.uploadOnOpen?.boolValue ?? false)
                    
                    completion(entry)
                }
                .store(in: &WorkoutModel.shared.cancellables)
        }
    }

    func getTimeline(for configuration: TravaartjeWidgetConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let store = getStore()
        store.workouts(2)
            .map {
                $0.compactMap { (configuration.showOnlyNewWorkouts == false || WorkoutModel.shared.storedWorkout($0)?.state == .new) ? $0 : nil }
                    .map { WorkoutState(workout: $0, state: WorkoutModel.shared.storedWorkout($0)?.state ?? .new )}
            }
            .sink { (_) in
            } receiveValue: { (workouts) in
                let entry = WorkoutEntry(date: Date(), workouts: workouts, uploadOnOpen: configuration.uploadOnOpen?.boolValue ?? false)
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 60, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                
                completion(timeline)
            }
            .store(in: &WorkoutModel.shared.cancellables)
    }
}

struct WorkoutState {
    let workout: HKWorkout
    let state: Workout.State
}

struct WorkoutEntry: TimelineEntry {
    let date: Date
    let workouts: [WorkoutState]
    let uploadOnOpen: Bool
    
    static func demo(_ numberOfWorkouts: Int) -> WorkoutEntry {
        var workoutStates = [WorkoutState]()
        if numberOfWorkouts > 0 {
            workoutStates.append(WorkoutState(workout: HKWorkout(activityType: .running,
                                                                 start: Date(timeIntervalSinceNow: -(60.0 * 45.0 + 17.0)),
                                                                 end: Date(),
                                                                 duration: 60.0 * 45.0 + 17.0,
                                                                 totalEnergyBurned: nil,
                                                                 totalDistance: HKQuantity(unit: .meter(), doubleValue: 8691.0),
                                                                 metadata: nil), state: .new))
        }
        if numberOfWorkouts == 2 {
            workoutStates.append(WorkoutState(workout: HKWorkout(activityType: .cycling,
                                                                 start: Date(timeIntervalSinceNow: -(3600.0 * 23.0 + 60.0 * 115.0 + 29.0)),
                                                                 end: Date(timeIntervalSinceNow: -(3600.0 * 23.0)),
                                                                 duration: 60.0 * 115.0 + 29.0,
                                                                 totalEnergyBurned: nil,
                                                                 totalDistance: HKQuantity(unit: .meter(), doubleValue: 37105.0),
                                                                 metadata: nil), state: .uploaded))
        }
        
        return WorkoutEntry(date: Date(),
                     workouts: workoutStates,
                     uploadOnOpen: false)
    }
}

struct TravaartjeWidgetEntryView : View {
    var entry: WorkoutProvider.Entry
    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        ZStack {
            Color("BackgroundColor")
            
            VStack(alignment: .center) {
                if entry.workouts.count == 0 {
                    Text("\(Image(systemName: "star"))")
                        .font(.title)
                        .foregroundColor(Color("PrimaryTextColor"))
                    
                    Text(LocalizedStringKey("No new workouts"))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .font(.headline)
                        .foregroundColor(Color("PrimaryTextColor"))
                        .frame(height: 60.0)
                }
                else {
                    if sizeCategory > .extraExtraLarge {
                        AccessibilityWorkoutCell(workoutState: entry.workouts[0])
                    }
                    else {
                        if entry.workouts.count == 1 {
                            WorkoutCell(workoutState: entry.workouts[0])
                        }
                        else {
                            Spacer()
                                .padding(.vertical, 3.0)

                            WorkoutCell(workoutState: entry.workouts[0])

                            Divider()
                                .background(Color("SecondaryTextColor"))

                            WorkoutCell(workoutState: entry.workouts[1])

                            Spacer()
                                .padding(.vertical, 3.0)
                        }
                    }
                }
            }
            .padding(.all, 10.0)
        }
        .widgetURL(URL(string: "widget://travaartje-upload-newest-workout?upload=\(entry.uploadOnOpen)"))
    }
}

@main
struct TravaartjeWidget: Widget {
    let kind: String = "com.katoemba.travaartje-widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: TravaartjeWidgetConfigurationIntent.self, provider: WorkoutProvider()) { entry in
            TravaartjeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Travaartje")
        .description(LocalizedStringKey("Show new workouts and upload them with 1 click."))
        .supportedFamilies([.systemSmall])
    }
}

struct TravaartjeWidget_Previews: PreviewProvider {
    static var previews: some View {
        TravaartjeWidgetEntryView(entry: WorkoutEntry.demo(0))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        TravaartjeWidgetEntryView(entry: WorkoutEntry.demo(0))
            .environment(\.sizeCategory, .accessibilityLarge)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        TravaartjeWidgetEntryView(entry: WorkoutEntry.demo(1))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        TravaartjeWidgetEntryView(entry: WorkoutEntry.demo(2))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        TravaartjeWidgetEntryView(entry: WorkoutEntry.demo(2))
            .environment(\.sizeCategory, .extraExtraLarge)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        TravaartjeWidgetEntryView(entry: WorkoutEntry.demo(2))
            .environment(\.sizeCategory, .extraExtraExtraLarge)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        TravaartjeWidgetEntryView(entry: WorkoutEntry.demo(2))
            .environment(\.sizeCategory, .accessibilityLarge)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        TravaartjeWidgetEntryView(entry: WorkoutEntry.demo(2))
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
