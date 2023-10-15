//
//  ArchiveView.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 15.09.2023.
//

import SwiftUI

struct ArchiveView: View {
    @AppStorage(NotesPersitenceKeys.notesArchive) private var notesArchivePayload: Data = Data()
    
    private var notesReader: NotesReader = Environment.forceResolve(type: NotesReader.self)
    private var notesWriter: NotesWriter = Environment.forceResolve(type: NotesWriter.self)
    
    private var archiveNotes: Notes {
        notesReader.read(from: $notesArchivePayload)
    }
    
    @ViewBuilder private var content: some View {
        if notesReader.count($notesArchivePayload) != 0 {
            //TODO: Search
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
            Text(String(localized: "Archive is empty"))
                .foregroundStyle(.secondary)
        }
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle(String(localized: "Archive"))
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView()
    }
}
