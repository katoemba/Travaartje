//
//  ToastView.swift
//  Travaartje
//
//  Created by Berrie Kremers on 04/03/2021.
//  Copyright © 2021 Katoemba Software. All rights reserved.
//

import Foundation
import SwiftUI

struct ToastView: View {
    @Binding var shown: Bool
    let toastColor = Color(.black)
    let backgroundColor = Color(.sRGB, white: 0.0, opacity: 0.5)
    let title: LocalizedStringKey
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
                .frame(height: 150.0)
            
            Text(title)
                .padding(.all, 20.0)
                .frame(width: 300.0, alignment: .center)
                .foregroundColor(.white)
                .background(toastColor)
                .cornerRadius(20.0)

            Spacer()
                .frame(height: 30.0)

            Button(action: { shown = true }, label: {
                Text(LocalizedStringKey("Close"))
                    .frame(width: 300.0, height: 40.0, alignment: .center)
                    .foregroundColor(.white)
                    .background(toastColor)
                    .cornerRadius(20.0)
            })

            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(backgroundColor)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ToastView_Previews: PreviewProvider {
    @State static var shown: Bool = false
    static var previews: some View {
        return ToastView(shown: $shown, title: "Let's show some interesting text here to preview the toaster.")
    }
}
