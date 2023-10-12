//
//  UNNotificationSettings+UNNotificationSettingsAdapter.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 12.10.2023.
//

import Foundation
import NotificationCenter

protocol NotificationSettingsAdapter {
    var authorizationStatus: UNAuthorizationStatus { get }
}

extension UNNotificationSettings: NotificationSettingsAdapter {}
