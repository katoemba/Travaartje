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
    
    var body: some View {
        NavigationView {
            List(workoutModel.workouts) { workout in
                WorkoutCell(workout: workout, workoutModel: self.workoutModel)
            }
            .navigationBarTitle("Travaartje")
            .onAppear(perform: {
                UITableView.appearance().separatorStyle = .none
                UITableViewCell.appearance().selectionStyle = .none
            })
        }
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        let model = (UIApplication.shared.delegate as! AppDelegate).workoutModel
        return WorkoutListView(workoutModel: model)
    }
}
