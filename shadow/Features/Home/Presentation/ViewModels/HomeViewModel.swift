//
//  HomeViewModel.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 8/03/26.
//

import Foundation
import SwiftUI

@Observable
final class HomeViewModel {
    
    // MARK: - Singleton
    static let shared = HomeViewModel()
    private init() {
        print("[HomeViewModel] Initializing singleton...")
        setupListeners()
        setupSocketConnectionListener()
        
        // Solo cargar si ya está conectado
        if socket.isConnected {
            loadMyRooms()
        }
    }
    
    // MARK: - Properties
    var rooms: [RoomInfo] = []
    var isLoading: Bool = false
    var currentRoomCode: String? = nil
    
    // MARK: - Private State
    private var isLoadingRooms: Bool = false
    
    // MARK: - Dependencies
    private let socket = SocketService.shared
    
    private func setupSocketConnectionListener() {
        print("[HomeViewModel] Setting up socket connection listener")
        
        // El SocketService ya es @Observable, podemos observar sus cambios
        // Esta función se llamará automáticamente cuando cambie el estado de conexión
        checkConnectionAndLoad()
    }
    
    func checkConnectionAndLoad() {
        if socket.isConnected && rooms.isEmpty && !isLoadingRooms {
            print("[HomeViewModel] Socket connected and no rooms loaded, loading now...")
            loadMyRooms()
        } else if !socket.isConnected && !rooms.isEmpty {
            print("[HomeViewModel] Socket disconnected, clearing rooms...")
            rooms = []
        }
    }
    
    func setCurrentRoom(_ roomCode: String) {
        print("[HomeViewModel] Setting current room to: \(roomCode)")
        currentRoomCode = roomCode
    }
    
    func clearCurrentRoom() {
        print("[HomeViewModel] Clearing current room")
        currentRoomCode = nil
    }
    
    private func setupListeners() {
        print("[HomeViewModel] Setting up listeners for .myRooms event")
        
        // Limpiar handlers existentes si los hay
        socket.off(.myRooms)
        socket.off(.participantJoined)
        socket.off(.participantLeft)
        
        socket.on(.myRooms) { [weak self] data in
            guard let self else { return }
            print("[HomeViewModel] Received .myRooms event with data: \(data)")
            guard let payload = socket.decode(MyRoomsPayload.self, from: data) else {
                print("[HomeViewModel] Failed to decode MyRoomsPayload")
                return
            }
            
            print("[HomeViewModel] Successfully decoded \(payload.rooms.count) rooms")
            DispatchQueue.main.async {
                self.rooms = payload.rooms
                self.isLoading = false
                self.isLoadingRooms = false
                print("[HomeViewModel] Updated rooms array with \(self.rooms.count) items")
            }
        }
        
        socket.on(.participantJoined) { [weak self] data in
            guard let self else { return }
            print("[HomeViewModel] Received .participantJoined event with data: \(data)")
            guard let payload = socket.decode(ParticipantJoinedPayload.self, from: data) else {
                print("[HomeViewModel] Failed to decode ParticipantJoinedPayload")
                return
            }
            
            print("[HomeViewModel] Participant \(payload.alias) joined room \(payload.roomCode), new count: \(payload.participantCount)")
            DispatchQueue.main.async {
                // Actualizar la sala específica usando roomCode del payload
                if let index = self.rooms.firstIndex(where: { $0.code == payload.roomCode }) {
                    let currentRoom = self.rooms[index]
                    self.rooms[index] = RoomInfo(
                        code: currentRoom.code,
                        participantCount: payload.participantCount,
                        createdAt: currentRoom.createdAt,
                        myRole: currentRoom.myRole,
                        isGhost: currentRoom.isGhost,
                        expiresInSeconds: currentRoom.expiresInSeconds
                    )
                    print("[HomeViewModel] Updated participant count for room \(payload.roomCode) to \(payload.participantCount)")
                } else {
                    print("[HomeViewModel] Room \(payload.roomCode) not found in local rooms, refreshing...")
                    self.loadMyRooms()
                }
            }
        }
        
        socket.on(.participantLeft) { [weak self] data in
            guard let self else { return }
            print("[HomeViewModel] Received .participantLeft event with data: \(data)")
            guard let payload = socket.decode(ParticipantLeftPayload.self, from: data) else {
                print("[HomeViewModel] Failed to decode ParticipantLeftPayload")
                return
            }
            
            print("[HomeViewModel] Participant \(payload.alias) left room \(payload.roomCode), new count: \(payload.participantCount)")
            DispatchQueue.main.async {
                // Actualizar la sala específica usando roomCode del payload
                if let index = self.rooms.firstIndex(where: { $0.code == payload.roomCode }) {
                    let currentRoom = self.rooms[index]
                    self.rooms[index] = RoomInfo(
                        code: currentRoom.code,
                        participantCount: payload.participantCount,
                        createdAt: currentRoom.createdAt,
                        myRole: currentRoom.myRole,
                        isGhost: currentRoom.isGhost,
                        expiresInSeconds: currentRoom.expiresInSeconds
                    )
                    print("[HomeViewModel] Updated participant count for room \(payload.roomCode) to \(payload.participantCount)")
                } else {
                    print("[HomeViewModel] Room \(payload.roomCode) not found in local rooms, refreshing...")
                    self.loadMyRooms()
                }
            }
        }
    }
    
    func loadMyRooms(retryCount: Int = 0) {
        // Evitar múltiples llamadas simultáneas
        guard !isLoadingRooms else {
            print("[HomeViewModel] Already loading rooms, skipping...")
            return
        }
        
        print("[HomeViewModel] loadMyRooms() called - requesting rooms from server (retry: \(retryCount))")
        isLoading = true
        isLoadingRooms = true
        socket.emit(.roomGetMyRooms, [:])
        
        // Si es la primera llamada y hay salas creadas recientemente, hacer retry
        if retryCount == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                // Si después de 1 segundo todavía no hay salas, reintentar una vez más
                if self.rooms.isEmpty && self.isLoading == false {
                    print("[HomeViewModel] No rooms found after 1s, retrying...")
                    self.loadMyRooms(retryCount: 1)
                }
            }
        }
    }
}

