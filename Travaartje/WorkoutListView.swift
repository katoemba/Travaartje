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
    @ObservedObject var workoutModel: WorkoutModel
    @ObservedObject var settingsModel: SettingsModel
    @State var showSettings = false

    var body: some View {
        NavigationView {
            List(workoutModel.workouts) { workout in
                WorkoutCell(workout: workout, workoutModel: self.workoutModel)
            }
            .navigationBarTitle("Travaartje")
            .navigationBarItems(
                trailing:
                Button(action: {
                    print("Show settings right")
                    self.showSettings = true
                }) {
                    Image(systemName: "gear")
                        .font(.title)
                }
                .accessibility(identifier: "Settings")
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
                })

            .onAppear(perform: {
                UITableView.appearance().separatorStyle = .none
                UITableViewCell.appearance().selectionStyle = .none
            })
        }
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutModel = AppDelegate.shared.workoutModel
        let settingsModel = AppDelegate.shared.settingsModel
        return WorkoutListView(workoutModel: workoutModel, settingsModel: settingsModel)
    }
}
