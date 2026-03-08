//
//  SocketEvent.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 6/03/26.
//

import Foundation

// shadow/Core/Infrastructure/Network/SocketEvent.swift
// Todos los eventos Socket.IO tipados.
// Equivalente a un enum de eventos en Flutter con socket_io_client.
//
// Separar los eventos en un enum evita typos en strings
// y hace el codigo mas mantenible.

// MARK: - Eventos que iOS envia al servidor

enum SocketEmitEvent: String {
    // Sala
    case roomCreate   = "room:create"
    case roomJoin     = "room:join"
    case roomGetMyRooms = "room:getMyRooms"
    case roomDestroy  = "room:destroy"

    // Mensajes
    case messageSend  = "message:send"

    // Cifrado
    case keyExchange  = "key:exchange"

    // Seguridad
    case securityAlert   = "security:alert"
    case deadManCheckIn  = "deadman:checkin"
    case deadManWarning  = "deadman:warning"

    // Typing
    case typingStart  = "typing:start"
    case typingStop   = "typing:stop"
}

// MARK: - Eventos que iOS recibe del servidor

enum SocketOnEvent: String {
    // Sala
    case roomCreated      = "room:created"
    case roomJoined       = "room:joined"
    case myRooms          = "room:myRooms"
    case roomDestroyed    = "room:destroyed"
    case roomExpired      = "room:expired"

    // Participantes
    case participantJoined = "participant:joined"
    case participantLeft   = "participant:left"

    // Mensajes
    case messageReceive   = "message:receive"
    case messageSent      = "message:sent"

    // Cifrado
    case keyReceive       = "key:receive"

    // Seguridad
    case securityAlert    = "security:alert"
    case deadManConfirmed = "deadman:confirmed"
    case deadManWarning   = "deadman:warning"

    // Typing
    case typingStart      = "typing:start"
    case typingStop       = "typing:stop"

    // Errores
    case error            = "error"
}

// MARK: - Payloads de respuesta del servidor
// Structs que mapean el JSON que llega del servidor
// Equivalente a los modelos de respuesta en Flutter

struct RoomCreatedPayload: Decodable {
    let code: String
    let socketId: String
    let participantCount: Int
    let createdAt: String
}

struct RoomJoinedPayload: Decodable {
    let code: String
    let socketId: String
    let participantCount: Int
}

struct MyRoomsPayload: Decodable {
    let rooms: [RoomInfo]
    let count: Int
}

struct RoomInfo: Decodable, Identifiable {
    var id: String { code }
    let code: String
    let participantCount: Int
    let createdAt: String
    let myRole: String      // "creator" o "participant"
    let isGhost: Bool
}

struct RoomDestroyedPayload: Decodable {
    let code: String
    let reason: String
    let destroyedAt: String
}

struct ParticipantJoinedPayload: Decodable {
    let alias: String
    let participantCount: Int
}

struct ParticipantLeftPayload: Decodable {
    let alias: String
    let participantCount: Int
}

struct MessageReceivePayload: Decodable {
    let id: String
    let encryptedPayload: String  // base64
    let senderAlias: String
    let sentAt: String
    let burnAfter: Int?
}

struct MessageSentPayload: Decodable {
    let id: String
    let sentAt: String
}

struct KeyReceivePayload: Decodable {
    let fromSocketId: String
    let wrappedKey: String   // base64 — clave cifrada con ECDH
    let publicKey: String    // base64 — clave publica del emisor
}

struct SecurityAlertPayload: Decodable {
    let threatType: String
    let reporterAlias: String
    let detectedAt: String
}

struct SocketErrorPayload: Decodable {
    let code: String
    let message: String
}
