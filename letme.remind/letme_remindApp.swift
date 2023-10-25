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
    
    init() {        
        AppEnvironment.shared.register(NotificationCenterAdapter.self) { _ in
            return UNUserNotificationCenter.current()
        }
        .inObjectScope(.container)
        
        AppEnvironment.shared.register(UserDefaultsAdapter.self) { _ in
            return UserDefaults.standard
        }
        .inObjectScope(.container)
        
        AppEnvironment.shared.register(PickerColorsProvider.self) { _ in
            return PickerColors()
        }
        .inObjectScope(.container)
        
        AppEnvironment.shared.register(NotesWriter.self) { _ in
            return NotesPersistence()
        }
        .inObjectScope(.container)
        .implements(NotesReader.self, NotesPersistenceBindings.self)
        
        AppEnvironment.shared.register(LocalNotificationPermissionsProvider.self) { _ in
            return Notifications()
        }
        .inObjectScope(.container)
        .implements(LocalNotificationScheduler.self)
        .implements(LocalNotificationProvider.self)
        
        AppEnvironment.shared.register(NoteFilter.self) { _ in
            DefaultArchiveNotesFilter()
        }
        .inObjectScope(.container)
    }
    
    var body: some Scene {
        WindowGroup {
            MainView { store in
                appDelegate.setNavigationStore(store)
            }
        }
    }
}
