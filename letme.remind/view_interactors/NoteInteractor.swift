//
//  NoteInteractor.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 25.10.2023.
//

import Foundation
import SwiftUI

class NoteInteractor: NoteArchiver, NoteScheduler {
    private var notesWriter: NotesWriter = AppEnvironment.forceResolve(type: NotesWriter.self)
    private var notifications: LocalNotificationScheduler =
        AppEnvironment.forceResolve(type: LocalNotificationScheduler.self)
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
}
