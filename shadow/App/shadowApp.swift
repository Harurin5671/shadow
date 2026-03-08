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
    private let diContainer = DIContainer.shared
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(router)
                .environment(diContainer.socketService)
                .environment(diContainer.roomRepository)
                .preferredColorScheme(ColorScheme.dark)
                .task {
                    diContainer.socketService.connect(url: "http://localhost:3000")
                }
        }
    }
}
