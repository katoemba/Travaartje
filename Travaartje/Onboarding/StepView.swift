//
//  StepView.swift
//  Travaartje
//
//  Created by Berrie Kremers on 24/08/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import SwiftUI
import StravaCombine
import HealthKitCombine


struct StepView: View {
    let isActive: Bool
    let step: Int
    let imageSystemName: String
    let text: String
    let descriptiveText: String
    let accessibilityIdentifier: String
    let action: StepAction

    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            Button(action: {
                withAnimation {
                    self.action()
                }
            }) {
                HStack(alignment: .center, spacing: 10.0) {
                    Spacer()
                        .frame(width: 0.0)

                    Image(systemName: imageSystemName)
                        .frame(width: 30.0)
                        .font(.headline)
                    Text(text)
                        .accessibility(identifier: accessibilityIdentifier)

                    Spacer()
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            .font(.body)
            .foregroundColor(.white)
            .padding(.vertical, 15.0)
            .background(RoundedRectangle(cornerRadius: 10.0).foregroundColor(isActive ? .green : .blue))
            .disabled(!isActive)
            .opacity(isActive ? 1.0 : 0.6)
            
            if isActive {
                Text(descriptiveText)
            }
        }
    }
}

struct StepView_Previews: PreviewProvider {
    static var previews: some View {
        return StepView(isActive: true,
                        step: 1,
                        imageSystemName: "1.circle",
                        text: "The first step is the hardest",
                        descriptiveText: "Travaartje needs access to your workout data so it can show your recent workouts. Click the above button to open the configuration screen.",
                        accessibilityIdentifier: "StepLabel") {
        }
    }
}
