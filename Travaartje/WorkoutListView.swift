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


struct WorkoutListView: View {
    @ObservedObject var workoutModel: WorkoutModel
    
    var body: some View {
        NavigationView {
            List(workoutModel.workouts) { workout in
                WorkoutCell(workout: workout, workoutModel: self.workoutModel)
            }
            .navigationBarTitle("Travaartje")
            .onAppear(perform: {
                UITableView.appearance().separatorStyle = .none
            })
        }
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let healthKitStoreCombine = (UIApplication.shared.delegate as! AppDelegate).healthKitStoreCombine
        let model = WorkoutModel(context: context, healthStoreCombine: healthKitStoreCombine)
        
        return WorkoutListView(workoutModel: model)
    }
}
