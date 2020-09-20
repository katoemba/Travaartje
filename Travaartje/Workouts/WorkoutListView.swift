//
//  ContentView.swift
//  Travaartje
//
//  Created by Berrie Kremers on 17/07/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import SwiftUI
import Combine
import HealthKit
import StravaCombine

struct WorkoutListView: View {
    @State var cancellables = Set<AnyCancellable>()
    @ObservedObject var settingsModel: SettingsModel
    @ObservedObject var workoutModel: WorkoutModel
    @State var showSettings = false
    @State var showOnboarding = true
    @State var workoutToShowDetailsFor: Workout? = nil
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10.0) {
                if workoutModel.workouts.count == 0 {
                    Text("No workouts found, did you give Travaartje access to your workouts in the Privacy settings?")
                        .navigationBarTitle("Travaartje")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.all)
                        .background(RoundedRectangle(cornerRadius: 10.0).foregroundColor(.orange))
                }
                else {
                    ForEach(workoutModel.workouts, id: \.self) { workout in
                        WorkoutCell(workout: workout, workoutModel: workoutModel, workoutToShowDetailsFor: $workoutToShowDetailsFor)
                    }
                }
            }
        }
        .padding(.horizontal)
        .navigationBarTitle("Travaartje")
        .navigationBarItems(
            leading:
            Button(action: {
                workoutModel.reloadHealthKitWorkouts()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title)
            }
            .sheet(isPresented: $showSettings) {
                NavigationView {
                    SettingsView(settingsModel: settingsModel)
                        .navigationBarTitle("Settings")
                        .navigationBarItems(
                            trailing:
                            Button("Done") {
                                showSettings = false
                            }
                    )
                }
            }
            .accessibility(identifier: "Reload"),

            trailing:
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gear")
                    .font(.title)
            }
            .accessibility(identifier: "Settings"))
        .onAppear(perform: {
            workoutModel.reloadHealthKitWorkouts()
        })
        .sheet(item: $workoutToShowDetailsFor) { workout in
            NavigationView {
                WorkoutDetailView(workout: workout)
                    .navigationBarItems(
                        trailing:
                        Button("Done") {
                            workoutModel.save()
                            workoutToShowDetailsFor = nil
                        }
                )
            }
        }
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutModel = AppDelegate.shared.workoutModel
        let settingsModel = AppDelegate.shared.settingsModel
        return WorkoutListView(settingsModel: settingsModel, workoutModel: workoutModel)
    }
}
