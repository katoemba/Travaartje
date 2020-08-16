//
//  WorkoutView.swift
//  Travaartje
//
//  Created by Berrie Kremers on 31/07/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import SwiftUI
import Combine
import HealthKit
import os

extension Workout {
    var stateColor: Color {
        switch state {
        case .new:
            return .blue
        case .generatingFile, .uploadingFile, .stravaProcessing:
            return .purple
        case .uploaded:
            return .green
        case .failed:
            return .red
        }
    }
    
    var action: LocalizedStringKey {
        switch state {
        case .new:
            return "Send"
        case .generatingFile, .uploadingFile, .stravaProcessing:
            return "In Progress"
        case .uploaded:
            return "Send Again"
        case .failed:
            return "Retry"
        }
    }
}

struct WorkoutCell: View {
    @ObservedObject var workout: Workout
    @State private var showUploadResult: Bool = false
    @State private var showDetails: Bool = false
    var workoutModel: WorkoutModel
    @State var cancellables: Set<AnyCancellable> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack(alignment: .center) {
                Text(LocalizedStringKey(workout.type))
                    .accessibility(identifier: "WorkoutType")
                Spacer()
                Text(workout.date)
                    .accessibility(identifier: "WorkoutDate")
            }
            
            HStack(alignment: .center) {
                Text(workout.distance)
                    .accessibility(identifier: "WorkoutDistance")
                Spacer()
                Text(workout.duration)
                    .accessibility(identifier: "WorkoutDuration")
            }
            .font(.system(.title))
            
            HStack(alignment: .center) {
                Image(systemName: workout.stateIcon)
                    .accessibility(identifier: "WorkoutStateIcon")
                
                VStack(alignment: .leading) {
                    Text(LocalizedStringKey(workout.state.rawValue))
                        .accessibility(identifier: "WorkoutState")
                    
                    if workout.uploadResult != "" {
                    Text(workout.uploadResult)
                        .accessibility(identifier: "WorkoutUploadResult")
                        .font(.caption)
                        .lineLimit(2)
                    } else {
                        EmptyView()
                    }
                }
                
                Spacer()
            }
            
            Divider()
                .padding(.horizontal, -10.0)

            HStack() {
                Button(action: {
                    self.showDetails = true
                }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Details")
                    }
                    .padding(8.0)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.15))
                    .cornerRadius(8)
                }
                .accessibility(identifier: "WorkoutDetails")
                .buttonStyle(PlainButtonStyle())
                .sheet(isPresented: self.$showDetails) {
                    NavigationView {
                        WorkoutDetailView(workout: self.workout)
                            .navigationBarItems(
                                trailing:
                                Button("Done") {
                                    self.workoutModel.save()
                                    self.showDetails = false
                                }
                        )
                    }
                }

                Spacer()

                Button(action: {
                    self.workoutModel.upload(self.workout)
                }) {
                    HStack {
                        Image(systemName: "paperplane")
                        Text(workout.action)
                    }
                    .padding(8.0)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.15))
                    .cornerRadius(8)
                }
                .accessibility(identifier: "WorkoutAction")
                .buttonStyle(PlainButtonStyle())
            }
        }
        .foregroundColor(.white)
        .padding(.all, 10.0)
        .background(RoundedRectangle(cornerRadius: 10.0).foregroundColor(workout.stateColor))
    }    
}

struct WorkoutCell_Previews: PreviewProvider {
    static let localizations = Bundle.main.localizations.map(Locale.init).filter { $0.identifier != "base" }
    static let model = (UIApplication.shared.delegate as! AppDelegate).workoutModel

    static var previews: some View {
        Group {
            ForEach(localizations, id: \.identifier) { locale in
                WorkoutCell(workout: model.workouts[0], workoutModel: model)
                    .previewLayout(PreviewLayout.fixed(width: 400, height: 170))
                    .padding()
                    .environment(\.locale, locale)
                    .previewDisplayName(Locale.current.localizedString(forIdentifier: locale.identifier))
            }
        }
    }
}
