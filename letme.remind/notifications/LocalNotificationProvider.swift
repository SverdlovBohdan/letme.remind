//
//  LocalNotificationProvider.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 10.10.2023.
//

import UserNotifications

protocol LocalNotificationProvider {
    func pendingNotifications() async -> [UNNotificationRequest]
}
