//
//  WebView.swift
//  Travaartje
//
//  Created by Berrie Kremers on 17/08/2020.
//  Copyright © 2020 Katoemba Software. All rights reserved.
//

import SwiftUI
import WebKit

struct WebView : UIViewRepresentable {
    let request: URLRequest
    
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
}

struct WebView_Previews : PreviewProvider {
    static var previews: some View {
        WebView(request: URLRequest(url: URL(string: "https://www.travaartje.net")!))
    }
}
