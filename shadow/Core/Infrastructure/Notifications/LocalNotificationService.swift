//
//  LocalNotificationService.swift
//  shadow
//

import Foundation
import UserNotifications

/// Concrete implementation of local notifications using UNUserNotificationCenter.
final class LocalNotificationService: NSObject, LocalNotificationServiceProtocol, UNUserNotificationCenterDelegate {
    
    private let center = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        center.delegate = self
    }
    
    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await center.requestAuthorization(options: options)
    }
    
    func scheduleNotification(title: String, body: String, identifier: String = UUID().uuidString, delay: TimeInterval = 0.1) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = delay > 0 ? UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false) : nil
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("[LocalNotificationService] Error scheduling notification: \(error)")
            } else {
                print("[LocalNotificationService] Notification scheduled: \(title)")
            }
        }
    }
    
    func removeAllPendingNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Present notification even if the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // En iOS 14+, usamos .banner y .sound
        completionHandler([.banner, .sound])
    }
}
