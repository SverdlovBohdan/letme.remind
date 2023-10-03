//
//  NotesPersistence.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 20.09.2023.
//

import Foundation
import SwiftUI

struct NotesPersistence: NotesWriter, NotesReader {
    private let decoder: JSONDecoder = .init()
    private let encoder: JSONEncoder = .init()
    
    func write(_ note: Note, to notes: Binding<Data>) {
        var persistedNotes: Notes = read(from: notes)
        persistedNotes.append(note)
                
        if let data = try? encoder.encode(persistedNotes) {
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
                notes.wrappedValue = data
            }
        }
    }
    
    /// TODO(BoSv): change return type to Result<Int, ErrorString>
    func read(from notes: Binding<Data>) -> Notes {
        
        if let persistedNotes = try? decoder.decode(Notes.self, from: notes.wrappedValue) {
            return persistedNotes
        }
        
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
}

extension NotesPersistence {
    static let standart: NotesPersistence = {
        return NotesPersistence()
    }()
}
