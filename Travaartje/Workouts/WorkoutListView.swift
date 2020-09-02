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
    
    var noWorkouts: Bool {
        workoutModel.workouts.count == 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            if self.noWorkouts {
                List {
                    Text("No workouts found, did you give Travaartje access to your workouts in the Privacy settings?")
                        .navigationBarTitle("Travaartje")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.all)
                        .background(RoundedRectangle(cornerRadius: 10.0).foregroundColor(.orange))
                }
                .onAppear(perform: {
                    self.workoutModel.reloadHealthKitWorkouts()
                    UITableView.appearance().separatorStyle = .none
                    UITableViewCell.appearance().selectionStyle = .none
                })
                .navigationBarTitle("Travaartje")
            }
            else {
                List(workoutModel.workouts) { workout in
                    WorkoutCell(workout: workout, workoutModel: self.workoutModel)
                }
                .navigationBarTitle("Travaartje")
                .navigationBarItems(
                    leading:
                    Button(action: {
                        self.workoutModel.reloadHealthKitWorkouts()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                    }
                    .accessibility(identifier: "Reload"),

                    trailing:
                    Button(action: {
                        self.showSettings = true
                    }) {
                        Image(systemName: "gear")
                            .font(.title)
                    }
                    .accessibility(identifier: "Settings"))
                .onAppear(perform: {
                    self.workoutModel.reloadHealthKitWorkouts()
                    UITableView.appearance().separatorStyle = .none
                    UITableViewCell.appearance().selectionStyle = .none
                })
                    .sheet(isPresented: self.$showSettings) {
                        NavigationView {
                            SettingsView(settingsModel: self.settingsModel)
                                .navigationBarTitle("Settings")
                                .navigationBarItems(
                                    trailing:
                                    Button("Done") {
                                        self.showSettings = false
                                    }
                            )
                        }
                }
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
