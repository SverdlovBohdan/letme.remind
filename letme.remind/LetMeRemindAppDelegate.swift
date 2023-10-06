//
//  LetMeRemindAppDelegate.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 03.10.2023.
//

import Foundation
import UserNotifications
import SwiftUI

class LetMeRemindAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private var navigationStore: NavigationStore? = nil
    
    private var notesPersistenceBinding: NotesPersistenceBindings =
        Environment.forceResolve(type: NotesPersistenceBindings.self)
    
    private var notesReader: NotesReader = Environment.forceResolve(type: NotesReader.self)
    private var notesWriter: NotesWriter = Environment.forceResolve(type: NotesWriter.self)

    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        writeToUnhandledNotes(id: notification.request.identifier)
        return [.badge, .sound]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            writeToUnhandledNotes(id: response.notification.request.identifier)
            navigationStore?.dispatch(action: .openNoteView(NoteId(noteId: response.notification.request.identifier)))
        }
    }
    
    func setNavigationStore(_ store: NavigationStore) {
        navigationStore = store
    }
    
    private func writeToUnhandledNotes(id: String) {
        if let note = notesReader.one(by: id, from: notesPersistenceBinding.makeNotesToRemindPersistenceBinding()) {
            notesWriter.write(note, to: notesPersistenceBinding.makeUnhandledNotesPersistenceBinding())
        }
    }
}
