//
//  UNNotificationCenter+NotificationAdapter.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 11.10.2023.
//

import Foundation
import NotificationCenter

protocol NotificationCenterAdapter {
    var delegate: UNUserNotificationCenterDelegate? { get set }
    
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func pendingNotificationRequests() async -> [UNNotificationRequest]
    func notificationSettings() async -> NotificationSettingsAdapter
    func add(_ request: UNNotificationRequest) async throws
}

extension UNUserNotificationCenter: NotificationCenterAdapter {
    func notificationSettings() async -> NotificationSettingsAdapter {
        let settings: UNNotificationSettings = await notificationSettings()
        return settings
    }
}
