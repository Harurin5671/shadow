//
//  shadowApp.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 1/03/26.
//

import SwiftUI

@main
struct shadowApp: App {
    @State private var router = AppRouter()
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(router)
                .environment(SocketService.shared)
                .preferredColorScheme(ColorScheme.dark)
                .task {
                    SocketService.shared.connect(url: "http://localhost:3000")
                }
        }
    }
}
