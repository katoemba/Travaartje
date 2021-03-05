//
//  AccessibilityWorkoutCell.swift
//  TravaartjeWidgetExtension
//
//  Created by Berrie Kremers on 05/03/2021.
//  Copyright © 2021 Katoemba Software. All rights reserved.
//

import SwiftUI

struct AccessibilityWorkoutCell: View {
    var workoutState: WorkoutState
    
    var icon: Image {
        switch workoutState.state {
        case .new:
            return Image(systemName: "star")
        case .generatingFile, .uploadingFile, .stravaProcessing:
            return Image(systemName: "arrow.right.arrow.left.circle")
        case .failed:
            return Image(systemName: "exclamationmark.triangle")
        case .uploaded:
            return Image(systemName: "checkmark.circle")
        }
    }
    
    var textColor: Color {
        switch workoutState.state {
        case .new, .generatingFile, .uploadingFile, .stravaProcessing:
            return Color("PrimaryTextColor")
        case .failed:
            return .red
        case .uploaded:
            return Color("SecondaryTextColor")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Text(LocalizedStringKey(workoutState.workout.type))
                .accessibility(identifier: "WorkoutType")
                .font(.subheadline)
            
            HStack(alignment: .firstTextBaseline, spacing: 1.0) {
                Text("\(icon)")
                    .font(.subheadline)
                
                Text(LocalizedStringKey(workoutState.state.rawValue))
                    .accessibility(identifier: "WorkoutState")
                    .font(.subheadline)
            }
            
            Text(workoutState.workout.distance)
                .accessibility(identifier: "WorkoutDistance")
                .font(.footnote)
            
            Text(workoutState.workout.durationString)
                .accessibility(identifier: "WorkoutDistance")
                .font(.footnote)
            
            Text(workoutState.workout.date)
                .accessibility(identifier: "WorkoutDate")
                .font(.caption)
        }
        .foregroundColor(textColor)
    }
}
