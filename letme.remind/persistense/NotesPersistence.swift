//
//  NotesPersistence.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 20.09.2023.
//

import Foundation
import SwiftUI
import os

class NotesPersistence: NotesWriter, NotesReader, NotesPersistenceBindings {
    //TODO: Hide under adapter interface
    private var decoder: JSONDecoder = .init()
    private var encoder: JSONEncoder = .init()
    
    private var userDefaults: UserDefaultsAdapter = Environment.forceResolve(type: UserDefaultsAdapter.self)
    
    private var logger: Logger =
        Environment.forceResolve(type: Logger.self, arg1: String(describing: NotesPersistence.self))
    
    init() {}
    
    init(decoder: JSONDecoder, encoder: JSONEncoder, userDefaults: UserDefaultsAdapter) {
        self.decoder = decoder
        self.encoder = encoder
        self.userDefaults = userDefaults
    }
    
    func write(_ note: Note, to notes: Binding<Data>) {
        var persistedNotes: Notes = read(from: notes)
        persistedNotes.append(note)
        
        if let data = try? encoder.encode(persistedNotes) {
            logger.info("\(note.id) has been written")
            notes.wrappedValue = data
        }
    }
    
    func remove(_ note: Note, from notes: Binding<Data>) {
        var persistedNotes: Notes = read(from: notes)
        
        if let index = persistedNotes.firstIndex(where: { item in
            return note.id == item.id
        }) {
            persistedNotes.remove(at: index)
            if let data = try? encoder.encode(persistedNotes) {
                logger.info("\(note.id) has been removed")
                notes.wrappedValue = data
            }
        }
    }

    func read(from notes: Binding<Data>) -> Notes {
        
        if let persistedNotes = try? decoder.decode(Notes.self, from: notes.wrappedValue) {
            return persistedNotes
        }
        
        logger.notice("No persisted notes")
        return Notes()
    }
    
    func one(by id: String, from notesData: Binding<Data>) -> Note? {
        let notes = read(from: notesData)
        return notes.first { note in
            note.id.uuidString == id
        }
    }
    
    func count(_ notes: Binding<Data>) -> Int {
        return read(from: notes).count
    }
    
    func makeNotesToRemindPersistenceBinding() -> Binding<Data> {
        return Binding {
            return self.userDefaults.data(forKey: NotesPersitenceKeys.notesToRemindKey) ?? Data()
        } set: { value in
            self.userDefaults.setValue(value, forKey: NotesPersitenceKeys.notesToRemindKey)
        }
    }
    
    func makeUnhandledNotesPersistenceBinding() -> Binding<Data> {
        return Binding {
            return self.userDefaults.data(forKey: NotesPersitenceKeys.unhandledNotes) ?? Data()
        } set: { value in
            self.userDefaults.setValue(value, forKey: NotesPersitenceKeys.unhandledNotes)
        }
    }
    
    func makeNotesArchivePersistenceBinding() -> Binding<Data> {
        return Binding {
            return self.userDefaults.data(forKey: NotesPersitenceKeys.notesArchive) ?? Data()
        } set: { value in
            self.userDefaults.setValue(value, forKey: NotesPersitenceKeys.notesArchive)
        }
    }
}
