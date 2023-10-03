//
//  letme_remindApp.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 02.09.2023.
//

import SwiftUI
import UserNotifications

class LetMeRemindAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private var navigationStore: NavigationStore? = nil
    
    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        print("### willPresent")
        
        /// FIX: notification is coming during another notification handling
        navigationStore?.dispatch(action: .openNoteView(NoteId(noteId: notification.request.identifier)))
        return [.badge, .sound]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print("### didReceive")
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            navigationStore?.dispatch(action: .openNoteView(NoteId(noteId: response.notification.request.identifier)))
        }
    }
    
    func setNavigationStore(_ store: NavigationStore) {
        navigationStore = store
    }
}

@main
struct letme_remindApp: App {
    @UIApplicationDelegateAdaptor(LetMeRemindAppDelegate.self) var appDelegate
    @StateObject var navigationStore: NavigationStore = .makeDefault()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(navigationStore)
                .onAppear(perform: {
                    appDelegate.setNavigationStore(navigationStore)
                    
                    /// Workaround: cleanup old notifications from db
                })
        }
    }
}
