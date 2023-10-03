//
//  UnhandledNoteRowView.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 03.10.2023.
//

import SwiftUI

struct UnhandledNoteRowView: View {
    @EnvironmentObject var navigation: NavigationStore
    
    private var dateFormatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    var note: Note
    
    var presentedText: String {
        note.title.isEmpty ? note.content : note.title
    }
    
    init(note: Note) {
        self.note = note
    }
    
    var body: some View {
        Button(action: {
            navigation.dispatch(action: .openNoteView(NoteId(noteId: note.id.uuidString)))
        }, label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(presentedText)
                        .lineLimit(1)
                        .font(.headline)
                    Text(dateFormatter.string(from: note.createdAt))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                // TODO: light/dark thems handling
                .foregroundStyle(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .padding(.leading)
            }
        })
    }
}

#Preview {
    UnhandledNoteRowView(note: Note.makeTestNote())
        .environmentObject(NavigationStore.makeDefault())
}
