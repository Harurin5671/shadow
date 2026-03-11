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
    
    private let storageService: StorageServiceProtocol

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
        // Al ir al chat, limpiamos la pila para que al retroceder
        // el usuario siempre regrese al Home, y no al formulario de unirse.
        navigationPath = [.chat(roomCode: roomCode)]
    }
    
    func goToSettings() {
        navigationPath.append(.settings)
    }
    
    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func returnToHome() {
        navigationPath.removeAll()
    }
    
    func showRoomCreation() {
        isShowingRoomCreation = true
    }
    
    func dismissRoomCreation() {
        isShowingRoomCreation = false
    }

    func completeOnboarding() {
        storageService.setOnboardingCompleted(true)
        withAnimation(.easeInOut(duration: 0.35)) {
            currentScreen = .main
        }
    }

    func resetOnboarding() {
        storageService.resetOnboarding()
        withAnimation { currentScreen = .onboarding }
    }
    
    init(storageService: StorageServiceProtocol = DIContainer.shared.storageService) {
        self.storageService = storageService
        let seen = self.storageService.hasSeenOnboarding()
        currentScreen = seen ? .main : .onboarding
    }
}
