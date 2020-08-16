//
//  WorkoutDetailView.swift
//  Travaartje
//
//  Created by Berrie Kremers on 21/07/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import SwiftUI

struct WorkoutDetailView: View {
    @State var workout: Workout
    
    var body: some View {
        Form {
            TextField("Name", text: $workout.name)
                .accessibility(identifier: "Name")
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Description", text: $workout.descr)
                .accessibility(identifier: "Description")
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Toggle("Commute", isOn: $workout.commute)
                .accessibility(identifier: "Commute")
        }
        .navigationBarTitle(Text("Workout Details"))
    }
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let model = (UIApplication.shared.delegate as! AppDelegate).workoutModel
        return WorkoutDetailView(workout: model.workouts[0])
    }
}
