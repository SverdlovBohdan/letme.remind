//
//  UnhandledNoteRowView.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 03.10.2023.
//

import SwiftUI

struct NoteRowView: View {
    enum Kind {
        case unhandled
        case archive
    }
    
    @EnvironmentObject var navigation: NavigationStore
    
    private var dateFormatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    var note: Note
    let kind: Kind
    
    var presentedText: String {
        note.title.isEmpty ? note.content : note.title
    }
    
    var label: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(presentedText)
                    .lineLimit(1)
                    .font(.headline)
                Text(dateFormatter.string(from: note.createdAt))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if kind == .unhandled {
                Spacer()
                Image(systemName: "chevron.right")
                    .padding(.leading)
            }
        }
    }
    
    @ViewBuilder var content: some View {
        if kind == .unhandled {
            Button(action: {
                navigation.dispatch(action: .openNoteView(NoteId(noteId: note.id.uuidString)))
            }, label: {
                label
            })
        } else {
            label
        }
    }
    
    init(note: Note, kind: Kind = .unhandled) {
        self.note = note
        self.kind = kind
    }
    
    var body: some View {
        content
    }
}

#Preview {
    NoteRowView(note: Note.makeTestNote())
        .environmentObject(NavigationStore.makeDefault())
}
