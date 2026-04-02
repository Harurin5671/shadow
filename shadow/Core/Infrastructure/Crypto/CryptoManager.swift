//
//  CryptoManager.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 10/03/26.
//

import Foundation
import CryptoKit

// CryptoManager: Orquesta todo el flujo E2EE
// Maneja key exchange, room keys y encriptación de mensajes

@Observable
final class CryptoManager {
    static let shared = CryptoManager()

    private let crypto: CryptoServiceProtocol
    private let storage: StorageServiceProtocol
    private let socket: SocketServiceProtocol

    private var currentRoomCode: String?
    private var myAlias: String?
    private var isCreator: Bool = false
    
    // MARK: - Public Getters
    var currentAlias: String? {
        return myAlias
    }

    // IDs de listeners para cleanup
    private var participantJoinedId: UUID?
    private var keyReceiveId: UUID?
    private var roomKeyReceiveId: UUID?
    
    // Agregar propiedad en CryptoManager
    private var creatorSocketId: String? = nil

    init(
        crypto: CryptoServiceProtocol = CryptoService.shared,
        storage: StorageServiceProtocol = StorageService.shared,
        socket: SocketServiceProtocol = SocketService.shared
    ) {
        self.crypto = crypto
        self.storage = storage
        self.socket = socket
        setupListeners()
    }

    deinit {
        teardownListeners()
    }

    // MARK: - Listeners

    private func setupListeners() {

        // ── Creador: alguien se unió → compartir roomKey ──────────────────
        participantJoinedId = socket.on(.participantJoined) { [weak self] data in
            guard let self,
                  self.isCreator,
                  let roomCode = self.currentRoomCode else { return }

            guard let payload = self.socket.decode(ParticipantJoinedPayload.self, from: data),
                  let publicKeyB64 = payload.publicKey,
                  let publicKeyData = Data(base64Encoded: publicKeyB64),
                  let participantPublicKey = self.crypto.decodePublicKey(publicKeyData) else {
                print("[CryptoManager] ❌ participant:joined sin publicKey — no se puede compartir roomKey")
                return
            }

            self.shareRoomKey(
                roomCode: roomCode,
                withPublicKey: participantPublicKey,
                toSocketId: payload.socketId
            )
        }

        // ── Participante: recibe publicKey de otros (broadcast) ───────────
        // Solo relevante si en el futuro queremos P2P completo.
        // Por ahora el flujo usa room:key:receive directamente.
        keyReceiveId = socket.on(.keyReceive) { [weak self] data in
            guard self != nil else { return }
            print("[CryptoManager] key:receive recibido — ignorado (flujo usa room:key:receive)")
        }

        // ── Participante: recibe la roomKey encriptada del creador ─────────
        roomKeyReceiveId = socket.on(.roomKeyReceive) { [weak self] data in
            guard let self,
                  let roomCode = self.currentRoomCode else { return }

            guard let payload = self.socket.decode(RoomKeyReceivePayload.self, from: data),
                  let wrappedKeyData = Data(base64Encoded: payload.wrappedRoomKey) else {
                print("[CryptoManager] ❌ room:key:receive — payload inválido")
                return
            }

            self.unwrapAndStoreRoomKey(
                wrappedKeyData: wrappedKeyData,
                roomCode: roomCode,
                senderAlias: payload.senderAlias
            )
        }
    }

    private func teardownListeners() {
        if let id = participantJoinedId { socket.off(.participantJoined, id: id) }
        if let id = keyReceiveId        { socket.off(.keyReceive, id: id) }
        if let id = roomKeyReceiveId    { socket.off(.roomKeyReceive, id: id) }
    }

    // MARK: - Creator Flow

    /// Llamar justo después de que el servidor confirme room:created
    func setupAsCreator(for roomCode: String, alias: String) {
        print("[CryptoManager] 🏠 Setting up as CREATOR for room: \(roomCode)")

        currentRoomCode = roomCode
        myAlias = alias
        isCreator = true

        // Generar o cargar clave ECDH
        let privateKey = crypto.loadPrivateKey() ?? crypto.generatePrivateKey()
        guard crypto.savePrivateKey(privateKey) else {
            print("[CryptoManager] ❌ Failed to save private key")
            return
        }

        // Generar room key simétrica AES-256 — solo el creador la genera
        let roomKey = crypto.generateRoomKey()
        let roomKeyData = roomKey.withUnsafeBytes { Data($0) }
        guard storage.saveToKeychain(roomKeyData, forKey: .roomKey(roomCode)) else {
            print("[CryptoManager] ❌ Failed to save room key")
            return
        }

        print("[CryptoManager] ✅ Creator setup complete — roomKey generated and stored")
    }

    /// Emitir publicKey al room para que participantes puedan hacer ECDH con nosotros
    func emitMyPublicKey(for roomCode: String, alias: String) {
        guard let privateKey = crypto.loadPrivateKey() else {
            print("[CryptoManager] ❌ No private key found")
            return
        }

        myAlias = alias
        currentRoomCode = roomCode

        let publicKeyB64 = crypto.encodePublicKey(privateKey.publicKey).base64EncodedString()

        socket.emit(.keyExchange, [
            "roomCode": roomCode,
            "publicKey": publicKeyB64,
            "participantAlias": alias,
        ])

        print("[CryptoManager] 📡 Public key emitted to room \(roomCode) as \(alias)")
    }

    // MARK: - Participant Flow

    /// Llamar cuando room:joined confirma que entramos a la sala
    /// - creatorSocketId: socketId del creador (para identificarlo)
    /// - creatorPublicKeyB64: publicKey del creador en base64 (viene en room:joined)
    func setupAsParticipant(
        for roomCode: String,
        alias: String,
        creatorSocketId: String?,
        creatorPublicKeyB64: String?
    ) {
        print("[CryptoManager] 👤 Setting up as PARTICIPANT for room: \(roomCode)")

        currentRoomCode = roomCode
        myAlias = alias
        isCreator = false
        self.creatorSocketId = creatorSocketId

        // Generar o cargar clave ECDH
        let privateKey = crypto.loadPrivateKey() ?? crypto.generatePrivateKey()
        guard crypto.savePrivateKey(privateKey) else {
            print("[CryptoManager] ❌ Failed to save private key")
            return
        }

        // Guardar publicKey del creador para poder hacer ECDH cuando llegue la roomKey
        if let creatorB64 = creatorPublicKeyB64,
           let creatorData = Data(base64Encoded: creatorB64),
           let creatorId = creatorSocketId {
            _ = storage.saveToKeychain(creatorData, forKey: .publicKey(creatorId))
            _ = storage.saveToKeychain(creatorData, forKey: .publicKey("currentRoomCreator"))
            print("[CryptoManager] 💾 Creator public key stored — socketId: \(creatorId)")
        }

        // Emitir nuestra publicKey al room para que el creador haga el wrap
        let publicKeyB64 = crypto.encodePublicKey(privateKey.publicKey).base64EncodedString()

        socket.emit(.keyExchange, [
            "roomCode": roomCode,
            "publicKey": publicKeyB64,
            "participantAlias": alias,
        ])

        print("[CryptoManager] ✅ Participant setup complete — public key sent")
    }

    // MARK: - Message Encryption / Decryption

    func encryptMessage(_ message: String, for roomCode: String) -> String? {
        guard let roomKeyData = storage.loadFromKeychain(forKey: .roomKey(roomCode)) else {
            print("[CryptoManager] ❌ No roomKey for \(roomCode) — message NOT encrypted")
            return nil
        }
        let roomKey = SymmetricKey(data: roomKeyData)
        let messageData = Data(message.utf8)

        guard let encrypted = crypto.encryptMessage(messageData, roomKey: roomKey) else {
            print("[CryptoManager] ❌ Encryption failed")
            return nil
        }

        return encrypted.base64EncodedString()
    }

    func decryptMessage(_ encryptedPayload: String, for roomCode: String) -> String? {
        guard let roomKeyData = storage.loadFromKeychain(forKey: .roomKey(roomCode)) else {
            print("[CryptoManager] ❌ No roomKey for \(roomCode) — cannot decrypt")
            return nil
        }
        let roomKey = SymmetricKey(data: roomKeyData)

        guard let encryptedData = Data(base64Encoded: encryptedPayload),
              let decrypted = crypto.decryptMessage(encryptedData, roomKey: roomKey),
              let text = String(data: decrypted, encoding: .utf8) else {
            print("[CryptoManager] ❌ Decryption failed")
            return nil
        }

        return text
    }

    func hasRoomKey(for roomCode: String) -> Bool {
        storage.loadFromKeychain(forKey: .roomKey(roomCode)) != nil
    }

    // MARK: - Cleanup

    func cleanupRoom(_ roomCode: String) {
        _ = storage.deleteFromKeychain(forKey: .roomKey(roomCode))
        print("[CryptoManager] 🧹 Cleaned up keys for room: \(roomCode)")
    }

    // MARK: - Private helpers

    /// Creador: hace ECDH con publicKey de B, wrappea la roomKey y la envía
    private func shareRoomKey(
        roomCode: String,
        withPublicKey participantPublicKey: P256.KeyAgreement.PublicKey,
        toSocketId targetSocketId: String
    ) {
        guard let myPrivateKey = crypto.loadPrivateKey() else {
            print("[CryptoManager] ❌ No private key — cannot share roomKey")
            return
        }
        guard let sharedSecret = crypto.generateSharedSecret(
            privateKey: myPrivateKey,
            publicKey: participantPublicKey
        ) else {
            print("[CryptoManager] ❌ ECDH failed")
            return
        }
        guard let roomKeyData = storage.loadFromKeychain(forKey: .roomKey(roomCode)) else {
            print("[CryptoManager] ❌ No roomKey in keychain for \(roomCode)")
            return
        }

        let roomKey = SymmetricKey(data: roomKeyData)
        guard let wrappedKey = crypto.wrapRoomKey(roomKey, sharedSecret: sharedSecret) else {
            print("[CryptoManager] ❌ wrapRoomKey failed")
            return
        }

        socket.emit(.roomKeyShare, [
            "roomCode": roomCode,
            "targetParticipant": targetSocketId,
            "wrappedRoomKey": wrappedKey.base64EncodedString(),
            "senderAlias": myAlias ?? "creator",
        ])

        print("[CryptoManager] ✅ roomKey wrapped and sent to \(targetSocketId)")
    }

    /// Participante: recibe wrappedKey del creador, hace ECDH con su publicKey y desencripta
    private func unwrapAndStoreRoomKey(
        wrappedKeyData: Data,
        roomCode: String,
        senderAlias: String
    ) {
        // Buscar la publicKey del creador que guardamos al hacer join
        // El creador fue guardado con su socketId — necesitamos encontrar la key correcta
        // Intentamos con el senderAlias como fallback si no tenemos el socketId
        let creatorKey: P256.KeyAgreement.PublicKey? = {
            // Buscar por todas las keys de participante guardadas
            // En la práctica solo habrá una (la del creador) cuando somos participante
            let candidates = [self.creatorSocketId, "currentRoomCreator", senderAlias]
                    .compactMap { $0 }
            for candidate in candidates {
                if let data = storage.loadFromKeychain(forKey: .publicKey(candidate)),
                   let key = crypto.decodePublicKey(data) {
                    return key
                }
            }
            return nil
        }()

        guard let creatorPublicKey = creatorKey else {
            print("[CryptoManager] ❌ Creator public key not found — cannot unwrap roomKey")
            return
        }

        guard let myPrivateKey = crypto.loadPrivateKey(),
              let sharedSecret = crypto.generateSharedSecret(
                  privateKey: myPrivateKey,
                  publicKey: creatorPublicKey
              ),
              let roomKey = crypto.unwrapRoomKey(wrappedKeyData, sharedSecret: sharedSecret) else {
            print("[CryptoManager] ❌ Failed to unwrap roomKey")
            return
        }

        let roomKeyData = roomKey.withUnsafeBytes { Data($0) }
        guard storage.saveToKeychain(roomKeyData, forKey: .roomKey(roomCode)) else {
            print("[CryptoManager] ❌ Failed to store roomKey")
            return
        }

        print("[CryptoManager] ✅ roomKey received and stored for \(roomCode) — E2EE ready 🔐")
    }
}
