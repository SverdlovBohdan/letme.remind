//
//  ArchiveView.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 15.09.2023.
//

import SwiftUI

struct ArchiveView: View {
    @AppStorage(NotesPersitenceKeys.notesArchive) private var notesArchivePayload: Data = Data()
    @State private var searchText: String = ""
    
    private var notesReader: NotesReader = AppEnvironment.forceResolve(type: NotesReader.self)
    private var notesWriter: NotesWriter = AppEnvironment.forceResolve(type: NotesWriter.self)
    private var archiveNotesFilter: NoteFilter = AppEnvironment.forceResolve(type: NoteFilter.self)
    
    private var archiveNotes: Notes {
        notesReader.read(from: $notesArchivePayload)
    }
    
    private var searchResult: Notes {
        archiveNotesFilter.filter(by: searchText, notesPayloadBinding: $notesArchivePayload)
    }
    
    @ViewBuilder private var content: some View {
        if notesReader.count($notesArchivePayload) != 0 {
            List {
                ForEach(searchResult) { note in
                    NoteRowView(note: note, kind: .archive)
                }
                .onDelete(perform: { indexSet in
                    indexSet.forEach { index in
                        notesWriter.remove(searchResult[index], from: $notesArchivePayload)
                    }
                })
            }
            .animation(.bouncy, value: searchResult)
            .searchable(text: $searchText)
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
