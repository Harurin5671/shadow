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
    
    // MARK: - Dependencies
    private let roomRepository: RoomRepositoryProtocol
    private let socketService: SocketServiceProtocol
    
    // MARK: - Properties
    var currentRoomCode: String? = nil
    
    // Forward properties from the repository to the view
    var rooms: [RoomInfo] { roomRepository.rooms }
    var isLoading: Bool { roomRepository.isLoading }
    
    // MARK: - Initializer
    init(roomRepository: RoomRepositoryProtocol, socketService: SocketServiceProtocol) {
        print("[HomeViewModel] Initialized instance.")
        self.roomRepository = roomRepository
        self.socketService = socketService
    }
    
    func onAppear() {
        print("[HomeViewModel] onAppear called")
        setupSocketConnectionListener()
        roomRepository.startListening()
        
        // Solo cargar si ya está conectado
        if socketService.isConnected {
            roomRepository.loadMyRooms()
        }
    }
    
    func onDisappear() {
        print("[HomeViewModel] onDisappear called")
        roomRepository.stopListening()
    }
    
    private func setupSocketConnectionListener() {
        print("[HomeViewModel] Setting up socket connection listener")
        checkConnectionAndLoad()
    }
    
    func checkConnectionAndLoad() {
        if socketService.isConnected && rooms.isEmpty && !isLoading {
            print("[HomeViewModel] Socket connected and no rooms loaded, loading now...")
            roomRepository.loadMyRooms()
        } else if !socketService.isConnected && !rooms.isEmpty {
            print("[HomeViewModel] Socket disconnected, views will update according to repository state.")
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
    
    func loadMyRooms() {
        roomRepository.loadMyRooms()
    }
    
    func removeRoom(withCode code: String) {
        roomRepository.removeRoom(withCode: code)
    }
    
    func insertRoom(_ room: RoomInfo, at index: Int) {
        roomRepository.insertRoom(room, at: index)
    }
}

