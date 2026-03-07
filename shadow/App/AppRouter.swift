//
//  AppRouter.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 2/03/26.
//

import SwiftUI

@Observable
final class AppRouter {
    var currentScreen: Screen = .onboarding
    var navigationPath: [Destination] = []
    var isShowingRoomCreation: Bool = false

    enum Screen {
        case onboarding
        case main
    }

    enum Destination: Hashable {
        case roomJoin
        case chat(roomCode: String)
        case settings
    }
    
    func goToRoomJoin() {
        navigationPath.append(.roomJoin)
    }
    
    func goToChat(roomCode: String) {
        navigationPath.append(.chat(roomCode: roomCode))
    }
    
    func goToSettings() {
        navigationPath.append(.settings)
    }
    
    func goBack() {
        navigationPath.removeLast()
    }
    
    func showRoomCreation() {
        isShowingRoomCreation = true
    }
    
    func dismissRoomCreation() {
        isShowingRoomCreation = false
    }

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
    
    init() {
        let seen = UserDefaults.standard.bool(
            forKey: "shadow.hasSeenOnboarding"
        )
        currentScreen = seen ? .main : .onboarding
    }
}
