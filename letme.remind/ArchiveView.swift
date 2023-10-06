//
//  ArchiveView.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 15.09.2023.
//

import SwiftUI

struct ArchiveView: View {
    @AppStorage(NotesPersitenceKeys.notesArchive) var notesArchivePayload: Data = Data()
    
    // TODO: Use DI
    private var notesReader: NotesReader = NotesPersistence.standart
    private var notesWriter: NotesWriter = NotesPersistence.standart
    
    private var archiveNotes: Notes {
        notesReader.read(from: $notesArchivePayload)
    }
    
    @ViewBuilder var content: some View {
        if notesReader.count($notesArchivePayload) != 0 {
            List {
                ForEach(archiveNotes) { note in
                    NoteRowView(note: note, kind: .archive)
                }
                .onDelete(perform: { indexSet in
                    indexSet.forEach { index in
                        notesWriter.remove(archiveNotes[index], from: $notesArchivePayload)
                    }
                })
            }
            .listStyle(.plain)
            .toolbar {
                EditButton()
            }
        } else {
            Text("Archive is empty")
                .foregroundStyle(.secondary)
        }
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Archive")
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView()
    }
}
