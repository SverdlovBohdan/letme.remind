//
//  NoteInteractor.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 25.10.2023.
//

import Foundation
import SwiftUI

class NoteInteractor: NoteArchiver, NoteScheduler, UnhandlerNotesProvider {
    private var notesWriter: NotesWriter = AppEnvironment.forceResolve(type: NotesWriter.self)
    private var notesReader: NotesReader = AppEnvironment.forceResolve(type: NotesReader.self)
    private var notifications: LocalNotificationScheduler =
        AppEnvironment.forceResolve(type: LocalNotificationScheduler.self)
    private var notificationsProvider: LocalNotificationProvider =
        AppEnvironment.forceResolve(type: LocalNotificationProvider.self)
    private var persistenceBindings: NotesPersistenceBindings =
        AppEnvironment.forceResolve(type: NotesPersistenceBindings.self)
    
    private func clearNoteFromUserCurrentStorages(note: Note) {
        notesWriter.remove(note, from: persistenceBindings.makeNotesToRemindPersistenceBinding())
        notesWriter.remove(note, from: persistenceBindings.makeUnhandledNotesPersistenceBinding())
    }
    
    func addToArchive(_ note: Note) {
        clearNoteFromUserCurrentStorages(note: note)
        notesWriter.write(note, to: persistenceBindings.makeNotesArchivePersistenceBinding())
    }
    
    func scheduleNote(note: Note, when: WhenToRemind) async -> Result<Void, ScheduleError> {
        let result = await notifications.schedule(note: note, when: when)
        
        switch result {
        case .success(_):
            notesWriter.write(note,to: persistenceBindings.makeNotesToRemindPersistenceBinding())
        case .failure(_):
            break
        }
        
        return result
    }
    
    func rescheduleNote(note: Note, oldNote: Note, when: WhenToRemind) async -> Result<Void, ScheduleError> {
        let result = await scheduleNote(note: note, when: when)
        
        switch result {
        case .success(_):
            clearNoteFromUserCurrentStorages(note: oldNote)
        case .failure(_):
            break
        }
        
        return result
    }
    
    func populateUnhandledNotes() async {
        let pendingNotifications = await notificationsProvider.pendingNotifications()
        guard !pendingNotifications.isEmpty else { return }
        
        let unhandledNotesBinding = persistenceBindings.makeUnhandledNotesPersistenceBinding()
        let allNotes = notesReader.read(from: persistenceBindings.makeNotesToRemindPersistenceBinding())
        let unhandledNotes = notesReader.read(from: unhandledNotesBinding)
        
        let firedButNotInUnhandledNotes = allNotes.filter { item in
            let isPendingNote = pendingNotifications.contains { notificationRequest in
                return notificationRequest.identifier == item.id.uuidString
            }
            let inUnhandledNotes = unhandledNotes.contains { unhandledNote in
                return unhandledNote.id == item.id
            }
            
            return !isPendingNote && !inUnhandledNotes
        }
        
        if !firedButNotInUnhandledNotes.isEmpty {
            firedButNotInUnhandledNotes.forEach { note in
                notesWriter.write(note, to: unhandledNotesBinding)
            }
        }
    }
}
