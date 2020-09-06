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
    @State private var noRouteAlert = false
    
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
                
                if !workout.hasRoute {
                    Image(systemName: "exclamationmark.triangle")
                        .accessibility(identifier: "WorkoutStateIcon")
                        .foregroundColor(.yellow)

                    Text("No route data")
                        .foregroundColor(.yellow)
                        .accessibility(identifier: "NoRouteWarning")
                }
            }
            
            Divider()
                .padding(.horizontal, -10.0)

            HStack() {
                Button(action: {
                    self.showDetails = true
                }) {
                    HStack {
                        Image(systemName: "pencil.circle")
                        Text("Details")
                    }
                    .padding(8.0)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.15))
                    .cornerRadius(8)
                }
                .accessibility(identifier: "WorkoutDetails")
                .buttonStyle(BorderlessButtonStyle())
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
                    if self.workout.hasRoute {
                        self.workoutModel.upload(self.workout)
                            .sink {
                                self.workout.state = $0.state
                                self.workout.uploadResult = $0.uploadResult
                            }
                            .store(in: &self.cancellables)
                    }
                    else {
                        self.noRouteAlert = true
                    }
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
                .alert(isPresented: $noRouteAlert) { () -> Alert in
                    let yesButton = Alert.Button.default(Text("Yes")) {
                        self.noRouteAlert = false
                        self.workoutModel.upload(self.workout)
                            .sink {
                                self.workout.state = $0.state
                                self.workout.uploadResult = $0.uploadResult
                            }
                            .store(in: &self.cancellables)
                    }
                    let noButton = Alert.Button.cancel(Text("No")) {
                        self.noRouteAlert = false
                    }
                    return Alert(title: Text("No route data"), message: Text("Travaartje could not find route data for this workout. Do you want to upload it without a route?"), primaryButton: noButton, secondaryButton: yesButton)
                }
                .accessibility(identifier: "WorkoutAction")
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .foregroundColor(.white)
        .padding(.all, 10.0)
        .background(RoundedRectangle(cornerRadius: 10.0).foregroundColor(workout.stateColor))
        .onTapGesture {
            if self.workout.stravaId != 0, let url = URL(string: "strava://activities/\(self.workout.stravaId)") {
                UIApplication.shared.open(url)
            }
        }
    }
}

struct WorkoutCell_Previews: PreviewProvider {
    static let localizations = Bundle.main.localizations.map(Locale.init).filter { $0.identifier != "base" }
    static let model = AppDelegate.shared.workoutModel

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
