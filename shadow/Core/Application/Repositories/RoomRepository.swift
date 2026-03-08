//
//  RoomRepository.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 8/03/26.
//

import Foundation

/// Defines the contract for fetching and managing rooms
protocol RoomRepositoryProtocol {
    var rooms: [RoomInfo] { get }
    var isLoading: Bool { get }
    
    func loadMyRooms()
    func startListening()
    func stopListening()
    
    func removeRoom(withCode code: String)
    func insertRoom(_ room: RoomInfo, at index: Int)
}

@Observable
final class RoomRepository: RoomRepositoryProtocol {
    private let socketService: SocketServiceProtocol
    
    var rooms: [RoomInfo] = []
    var isLoading: Bool = false
    private var isLoadingRooms: Bool = false
    
    init(socketService: SocketServiceProtocol) {
        self.socketService = socketService
    }
    
    // MARK: - Public API
    func loadMyRooms() {
        guard !isLoadingRooms else { return }
        
        isLoading = true
        isLoadingRooms = true
        socketService.emit(.roomGetMyRooms, [:])
        
        // Timeout / retry mechanism
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            if self.rooms.isEmpty && self.isLoading == false {
                self.isLoading = true
                self.isLoadingRooms = true
                self.socketService.emit(.roomGetMyRooms, [:])
            }
        }
    }
    
    func startListening() {
        // Clear existing handlers before adding new ones
        stopListening()
        
        socketService.on(.myRooms) { [weak self] data in
            guard let self = self else { return }
            guard let payload = self.socketService.decode(MyRoomsPayload.self, from: data) else { return }
            
            DispatchQueue.main.async {
                self.rooms = payload.rooms
                self.isLoading = false
                self.isLoadingRooms = false
            }
        }
        
        socketService.on(.participantJoined) { [weak self] data in
            guard let self = self else { return }
            guard let payload = self.socketService.decode(ParticipantJoinedPayload.self, from: data) else { return }
            
            self.updateParticipantCount(roomCode: payload.roomCode, newCount: payload.participantCount)
        }
        
        socketService.on(.participantLeft) { [weak self] data in
            guard let self = self else { return }
            guard let payload = self.socketService.decode(ParticipantLeftPayload.self, from: data) else { return }
            
            self.updateParticipantCount(roomCode: payload.roomCode, newCount: payload.participantCount)
        }
    }
    
    func stopListening() {
        socketService.off(.myRooms)
        socketService.off(.participantJoined)
        socketService.off(.participantLeft)
    }
    
    func removeRoom(withCode code: String) {
        DispatchQueue.main.async {
            self.rooms.removeAll { $0.code == code }
        }
    }
    
    func insertRoom(_ room: RoomInfo, at index: Int) {
        DispatchQueue.main.async {
            self.rooms.insert(room, at: index)
        }
    }
    
    // MARK: - Private Helpers
    private func updateParticipantCount(roomCode: String, newCount: Int) {
        DispatchQueue.main.async {
            guard let index = self.rooms.firstIndex(where: { $0.code == roomCode }) else {
                // If we don't know the room, we might want to reload all rooms
                self.loadMyRooms()
                return
            }
            
            let currentRoom = self.rooms[index]
            self.rooms[index] = RoomInfo(
                code: currentRoom.code,
                participantCount: newCount,
                createdAt: currentRoom.createdAt,
                myRole: currentRoom.myRole,
                isGhost: currentRoom.isGhost,
                expiresInSeconds: currentRoom.expiresInSeconds
            )
        }
    }
}
