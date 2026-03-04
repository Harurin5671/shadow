//
//  AppRouter.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 2/03/26.
//

import SwiftUI

@Observable
final class AppRouter {
    // MARK: - Estado
    var currentScreen: Screen = .onboarding

    enum Screen {
        case onboarding
        case main
    }

    // MARK: - Init
    init() {
        let seen = UserDefaults.standard.bool(
            forKey: "shadow.hasSeenOnboarding"
        )
        currentScreen = seen ? .main : .onboarding
    }

    //MARK: - Acciones
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "shadow.hasSeenOnboarding")
        withAnimation(.easeInOut(duration: 0.35)) {
            currentScreen = .main
        }
    }
    
    func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: "shadow.hasSeenOnboarding")
        withAnimation { currentScreen = .onboarding }
    }
}
