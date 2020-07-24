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

extension Workout {
    var stateColor: Color {
        switch state {
        case .new:
            return .blue
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
        case .uploaded:
            return "Send Again"
        case .failed:
            return "Retry"
        }
    }
}

struct WorkoutCell: View {
    @ObservedObject var workout: Workout
    var workoutModel: WorkoutModel
    
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
            
            Text(LocalizedStringKey(workout.state.rawValue))
                .accessibility(identifier: "WorkoutState")

            Rectangle()
                .frame(height: 1.0)
            
            HStack(alignment: .center) {
                Text("Details")
                
                Spacer()
                Rectangle()
                    .frame(width: 1.0)
                Spacer()
                
                Text(workout.action)
                    .onTapGesture {
                        self.workout.state = self.workout.state == .new ? .uploaded : .failed
                        self.workoutModel.save()
                    }
                    .accessibility(identifier: "WorkoutAction")
            }
        }
        .foregroundColor(.white)
        .padding(.all, 10.0)
        .background(RoundedRectangle(cornerRadius: 10.0).foregroundColor(workout.stateColor))
    }
}

struct WorkoutListView: View {
    @ObservedObject var workoutModel: WorkoutModel
    
    var body: some View {
        NavigationView {
            List(workoutModel.workouts) { workout in
                ZStack {
                    WorkoutCell(workout: workout, workoutModel: self.workoutModel)
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        EmptyView()
                    }.buttonStyle(PlainButtonStyle())
                }
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
