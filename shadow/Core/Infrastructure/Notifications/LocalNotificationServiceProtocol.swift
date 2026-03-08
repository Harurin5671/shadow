//
//  LocalNotificationServiceProtocol.swift
//  shadow
//

import Foundation

/// Protocol that abstracts the local notification framework.
protocol LocalNotificationServiceProtocol {
    /// Requests user authorization to show notifications.
    func requestAuthorization() async throws -> Bool
    
    /// Schedules a local notification.
    func scheduleNotification(title: String, body: String, identifier: String, delay: TimeInterval)
    
    /// Clears any pending notifications.
    func removeAllPendingNotifications()
}
