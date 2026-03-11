//
//  LocalStorageService.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 10/03/26.
//

import Foundation

protocol LocalStorageServiceProtocol {
    func hasSeenOnboarding() -> Bool
    func setOnboardingCompleted(_ completed: Bool)
    func resetOnboarding()
}

final class LocalStorageService: LocalStorageServiceProtocol {
    static let shared = LocalStorageService()
    
    private init() {}
    
    // MARK: - Constants
    private enum Keys {
        static let hasSeenOnboarding = "shadow.hasSeenOnboarding"
    }
    
    // MARK: - Onboarding
    func hasSeenOnboarding() -> Bool {
        UserDefaults.standard.bool(forKey: Keys.hasSeenOnboarding)
    }
    
    func setOnboardingCompleted(_ completed: Bool) {
        UserDefaults.standard.set(completed, forKey: Keys.hasSeenOnboarding)
    }
    
    func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: Keys.hasSeenOnboarding)
    }
}
