//
//  StorageService.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 10/03/26.
//

import Foundation

protocol StorageServiceProtocol {
    // UserDefaults - Non-sensitive data
    func hasSeenOnboarding() -> Bool
    func setOnboardingCompleted(_ completed: Bool)
    func resetOnboarding()
    
    // Keychain - Sensitive data
    func saveToKeychain(_ data: Data, forKey key: KeychainKey) -> Bool
    func loadFromKeychain(forKey key: KeychainKey) -> Data?
    func deleteFromKeychain(forKey key: KeychainKey) -> Bool
}

final class StorageService: StorageServiceProtocol {
    static let shared = StorageService()
    
    private let localStorageService: LocalStorageServiceProtocol
    private let keychainService: KeychainServiceProtocol
    
    private init(
        localStorageService: LocalStorageServiceProtocol = LocalStorageService.shared,
        keychainService: KeychainServiceProtocol = KeychainService.shared
    ) {
        self.localStorageService = localStorageService
        self.keychainService = keychainService
    }
    
    // MARK: - UserDefaults Operations (Non-sensitive data)
    func hasSeenOnboarding() -> Bool {
        return localStorageService.hasSeenOnboarding()
    }
    
    func setOnboardingCompleted(_ completed: Bool) {
        localStorageService.setOnboardingCompleted(completed)
    }
    
    func resetOnboarding() {
        localStorageService.resetOnboarding()
    }
    
    // MARK: - Keychain Operations (Sensitive data)
    func saveToKeychain(_ data: Data, forKey key: KeychainKey) -> Bool {
        return keychainService.save(data, forKey: key)
    }
    
    func loadFromKeychain(forKey key: KeychainKey) -> Data? {
        return keychainService.load(forKey: key)
    }
    
    func deleteFromKeychain(forKey key: KeychainKey) -> Bool {
        return keychainService.delete(forKey: key)
    }
}
