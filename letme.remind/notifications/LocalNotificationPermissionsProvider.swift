//
//  LocalNotificationPermissionsProvider.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 10.10.2023.
//

protocol LocalNotificationPermissionsProvider {
    func isLocalNotificationPermissionsGranted() async -> Bool
}
