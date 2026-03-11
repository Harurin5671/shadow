//
//  CryptoService.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 10/03/26.
//

import CryptoKit
import Foundation

protocol CryptoServiceProtocol {
    // Key Management
    func generatePrivateKey() -> P256.KeyAgreement.PrivateKey
    func savePrivateKey(_ key: P256.KeyAgreement.PrivateKey) -> Bool
    func loadPrivateKey() -> P256.KeyAgreement.PrivateKey?
    func deletePrivateKey() -> Bool

    // ECDH Key Exchange
    func generateSharedSecret(
        privateKey: P256.KeyAgreement.PrivateKey,
        publicKey: P256.KeyAgreement.PublicKey
    ) -> SharedSecret?

    // Room Key Management (AES-256 for chat messages)
    func generateRoomKey() -> SymmetricKey
    func wrapRoomKey(_ roomKey: SymmetricKey, sharedSecret: SharedSecret)
        -> Data?
    func unwrapRoomKey(_ wrappedKey: Data, sharedSecret: SharedSecret)
        -> SymmetricKey?

    // Encryption/Decryption
    func encrypt(_ data: Data, using sharedSecret: SharedSecret) -> Data?
    func decrypt(_ encryptedData: Data, using sharedSecret: SharedSecret)
        -> Data?
    func encryptMessage(_ data: Data, roomKey: SymmetricKey) -> Data?
    func decryptMessage(_ encryptedData: Data, roomKey: SymmetricKey) -> Data?

    // Key Conversion
    func publicKeyFrom(_ privateKey: P256.KeyAgreement.PrivateKey)
        -> P256.KeyAgreement.PublicKey
    func encodePublicKey(_ publicKey: P256.KeyAgreement.PublicKey) -> Data
    func decodePublicKey(_ data: Data) -> P256.KeyAgreement.PublicKey?
}

final class CryptoService: CryptoServiceProtocol {
    static let shared = CryptoService()

    private let storageService: StorageServiceProtocol

    private init(storageService: StorageServiceProtocol = StorageService.shared)
    {
        self.storageService = storageService
    }
    // Fix circular dependency
    //    private init(storageService: StorageServiceProtocol? = nil) {
    //        if let storageService = storageService {
    //            self.storageService = storageService
    //        } else {
    //            self.storageService = StorageService.shared
    //        }
    //    }

    // MARK: - Constants
    private enum HKDFSalt {
        // Para derivar la wrapping key (wrap/unwrap room key via ECDH)
        static let keyWrapping = Data("shadow.e2ee.keyWrapping.v1".utf8)

        // Para encrypt/decrypt directo con shared secret
        static let directEncrypt = Data("shadow.e2ee.directEncrypt.v1".utf8)
    }

    // MARK: - Key Management
    func generatePrivateKey() -> P256.KeyAgreement.PrivateKey {
        return P256.KeyAgreement.PrivateKey()
    }

    func savePrivateKey(_ key: P256.KeyAgreement.PrivateKey) -> Bool {
        return storageService.saveToKeychain(
            key.rawRepresentation,
            forKey: .privateKey
        )
    }

    func loadPrivateKey() -> P256.KeyAgreement.PrivateKey? {
        guard let keyData = storageService.loadFromKeychain(forKey: .privateKey)
        else {
            return nil
        }

        return try? P256.KeyAgreement.PrivateKey(rawRepresentation: keyData)
    }

    func deletePrivateKey() -> Bool {
        return storageService.deleteFromKeychain(forKey: .privateKey)
    }

    // MARK: - ECDH Key Exchange
    func generateSharedSecret(
        privateKey: P256.KeyAgreement.PrivateKey,
        publicKey: P256.KeyAgreement.PublicKey
    ) -> SharedSecret? {
        return try? privateKey.sharedSecretFromKeyAgreement(with: publicKey)
    }

    // MARK: - Room Key Management (AES-256 for chat messages)
    func generateRoomKey() -> SymmetricKey {
        return SymmetricKey(size: .bits256)
    }

    func wrapRoomKey(_ roomKey: SymmetricKey, sharedSecret: SharedSecret)
        -> Data?
    {
        let wrappingKey = deriveKey(
            from: sharedSecret,
            salt: HKDFSalt.keyWrapping
        )
        let roomKeyData = roomKey.withUnsafeBytes { Data($0) }
        return try? AES.GCM.seal(roomKeyData, using: wrappingKey).combined

        //        let wrappingKey = sharedSecret.hkdfDerivedSymmetricKey(
        //            using: SHA256.self,
        //            salt: HKDFSalt.keyWrapping,
        //            sharedInfo: Data(),
        //            outputByteCount: 32
        //        )
        //
        //        let roomKeyData = roomKey.withUnsafeBytes { Data($0) }
        //        let sealedBox = try? AES.GCM.seal(roomKeyData, using: wrappingKey)
        //        return sealedBox?.combined
    }

    func unwrapRoomKey(_ wrappedKey: Data, sharedSecret: SharedSecret)
        -> SymmetricKey?
    {
        let wrappingKey = deriveKey(
            from: sharedSecret,
            salt: HKDFSalt.keyWrapping
        )
        guard let sealedBox = try? AES.GCM.SealedBox(combined: wrappedKey),
            let roomKeyData = try? AES.GCM.open(sealedBox, using: wrappingKey)
        else { return nil }
        return SymmetricKey(data: roomKeyData)
        //        let wrappingKey = sharedSecret.hkdfDerivedSymmetricKey(
        //            using: SHA256.self,
        //            salt: HKDFSalt.keyWrapping,
        //            sharedInfo: Data(),
        //            outputByteCount: 32
        //        )
        //
        //        guard let sealedBox = try? AES.GCM.SealedBox(combined: wrappedKey),
        //            let roomKeyData = try? AES.GCM.open(sealedBox, using: wrappingKey)
        //        else {
        //            return nil
        //        }
        //
        //        return SymmetricKey(data: roomKeyData)
    }

    // MARK: - Encryption/Decryption
    func encrypt(_ data: Data, using sharedSecret: SharedSecret) -> Data? {
        let key = deriveKey(from: sharedSecret, salt: HKDFSalt.directEncrypt)
        return try? AES.GCM.seal(data, using: key).combined
        //        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
        //            using: SHA256.self,
        //            salt: HKDFSalt.directEncrypt,
        //            sharedInfo: Data(),
        //            outputByteCount: 32
        //        )
        //
        //        let sealedBox = try? AES.GCM.seal(data, using: symmetricKey)
        //        return sealedBox?.combined
    }

    func decrypt(_ encryptedData: Data, using sharedSecret: SharedSecret)
        -> Data?
    {
        let key = deriveKey(from: sharedSecret, salt: HKDFSalt.directEncrypt)
        guard let sealedBox = try? AES.GCM.SealedBox(combined: encryptedData)
        else { return nil }
        return try? AES.GCM.open(sealedBox, using: key)
        //        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
        //            using: SHA256.self,
        //            salt: HKDFSalt.directEncrypt,
        //            sharedInfo: Data(),
        //            outputByteCount: 32
        //        )
        //
        //        guard let sealedBox = try? AES.GCM.SealedBox(combined: encryptedData)
        //        else {
        //            return nil
        //        }
        //
        //        return try? AES.GCM.open(sealedBox, using: symmetricKey)
    }

    func encryptMessage(_ data: Data, roomKey: SymmetricKey) -> Data? {
        try? AES.GCM.seal(data, using: roomKey).combined
        //        let sealedBox = try? AES.GCM.seal(data, using: roomKey)
        //        return sealedBox?.combined
    }

    func decryptMessage(_ encryptedData: Data, roomKey: SymmetricKey) -> Data? {
        guard let sealedBox = try? AES.GCM.SealedBox(combined: encryptedData)
        else { return nil }
        return try? AES.GCM.open(sealedBox, using: roomKey)
        //        guard let sealedBox = try? AES.GCM.SealedBox(combined: encryptedData)
        //        else {
        //            return nil
        //        }
        //
        //        return try? AES.GCM.open(sealedBox, using: roomKey)
    }

    // MARK: - Key Conversion
    func publicKeyFrom(_ privateKey: P256.KeyAgreement.PrivateKey)
        -> P256.KeyAgreement.PublicKey
    {
        return privateKey.publicKey
    }

    func encodePublicKey(_ publicKey: P256.KeyAgreement.PublicKey) -> Data {
        // Prefer DER/SPKI representation for interoperability with backend crypto libraries
        // (e.g., Node.js crypto.createPublicKey expects SPKI DER or PEM)
        return publicKey.x963Representation
    }

    func decodePublicKey(_ data: Data) -> P256.KeyAgreement.PublicKey? {
        // Intentar x963 primero (nuestro formato estándar)
        if let key = try? P256.KeyAgreement.PublicKey(x963Representation: data)
        {
            return key
        }
        // Fallback a raw por compatibilidad
        return try? P256.KeyAgreement.PublicKey(rawRepresentation: data)
        //        if let key = try? P256.KeyAgreement.PublicKey(derRepresentation: data) {
        //            return key
        //        }
        //        return try? P256.KeyAgreement.PublicKey(rawRepresentation: data)
    }

    private func deriveKey(from sharedSecret: SharedSecret, salt: Data)
        -> SymmetricKey
    {
        sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: salt,
            sharedInfo: Data(),
            outputByteCount: 32
        )
    }
}
