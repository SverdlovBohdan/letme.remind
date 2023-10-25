//
//  ArchiveNoteFilter.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 25.10.2023.
//

import Foundation
import SwiftUI

class DefaultArchiveNotesFilter: NoteFilter {
    private var notesReader: NotesReader = AppEnvironment.forceResolve(type: NotesReader.self)
    
    func filter(by searchText: String, notesPayloadBinding: Binding<Data>) -> Notes {
        let archiveNotes: Notes = notesReader.read(from: notesPayloadBinding)
        
        if searchText.isEmpty {
            return archiveNotes
        } else {
            return archiveNotes.filter { note in
                note.title.lowercased().contains(searchText.lowercased()) || note.tags.contains { tag in
                    return tag.lowercased().contains(searchText.lowercased())
                }
            }
        }
    }
}
