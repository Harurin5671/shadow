//
//  KeychainService.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 10/03/26.
//

import Foundation
import Security

enum KeychainKey {
    case privateKey
    case roomKey(String)
    case publicKey(String)
    
    var rawValue: String {
        switch self {
        case .privateKey:
            return "shadow.privateKey"
        case .roomKey(let code):
            return "shadow.roomKey.\(code)"
        case .publicKey(let identifier):
            return "shadow.publicKey.\(identifier)"
        }
    }
}

protocol KeychainServiceProtocol {
    func save(_ data: Data, forKey key: KeychainKey) -> Bool
    func load(forKey key: KeychainKey) -> Data?
    func delete(forKey key: KeychainKey) -> Bool
}

final class KeychainService: KeychainServiceProtocol {
    static let shared = KeychainService()
    
    private init() {}
    
    private let service = "com.shadow.app"
    
    func save(_ data: Data, forKey key: KeychainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing key first
        SecItemDelete(query as CFDictionary)
        
        // Add new key
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func load(forKey key: KeychainKey) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        
        return data
    }
    
    func delete(forKey key: KeychainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
