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
    
    private var notificationCenter: UNUserNotificationCenter =
        Environment.forceResolve(type: UNUserNotificationCenter.self)

    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        notificationCenter.delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        writeToUnhandledNotes(id: notification.request.identifier)
        return [.badge, .sound]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        if let note = notesReader.one(by: response.notification.request.identifier,
                                      from: notesPersistenceBinding.makeNotesToRemindPersistenceBinding()),
           response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            writeToUnhandledNotes(note)
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
    
    private func writeToUnhandledNotes(_ note: Note) {
        notesWriter.write(note, to: notesPersistenceBinding.makeUnhandledNotesPersistenceBinding())
    }
}
