//
//  letme_remindApp.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 02.09.2023.
//

import SwiftUI
import UserNotifications
import os


@main
struct letme_remindApp: App {
    @UIApplicationDelegateAdaptor(LetMeRemindAppDelegate.self) var appDelegate
    @StateObject var navigationStore: NavigationStore = .makeDefault()
    
    init() {        
        Environment.shared.register(NotificationCenterAdapter.self) { _ in
            return UNUserNotificationCenter.current()
        }
        .inObjectScope(.container)
        
        Environment.shared.register(UserDefaultsAdapter.self) { _ in
            return UserDefaults.standard
        }
        .inObjectScope(.container)
        
        Environment.shared.register(NotesWriter.self) { _ in
            return NotesPersistence()
        }
        .inObjectScope(.container)
        .implements(NotesReader.self, NotesPersistenceBindings.self)
        
        Environment.shared.register(LocalNotificationPermissionsProvider.self) { _ in
            return Notifications()
        }
        .inObjectScope(.container)
        .implements(LocalNotificationScheduler.self)
        .implements(LocalNotificationProvider.self)
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(navigationStore)
                .onAppear(perform: {
                    appDelegate.setNavigationStore(navigationStore)
                })
        }
    }
}
