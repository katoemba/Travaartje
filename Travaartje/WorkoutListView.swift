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
    @Environment(\.settingsModel) var settingsModel: SettingsModel
    @ObservedObject var workoutModel = AppDelegate.shared.workoutModel
    @State var showSettings = false
    @State var showOnboarding = true
    
    var body: some View {
        List(workoutModel.workouts) { workout in
            WorkoutCell(workout: workout, workoutModel: self.workoutModel)
        }
        .navigationBarTitle("Travaartje")
        .navigationBarItems(
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

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        //        let workoutModel = AppDelegate.shared.workoutModel
        //        let settingsModel = AppDelegate.shared.settingsModel
        return WorkoutListView()
    }
}
