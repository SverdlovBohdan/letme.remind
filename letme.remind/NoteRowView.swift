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
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var navigation: NavigationStore
    
    private let padding: CGFloat = 6
    private let strokePadding: CGFloat = 2
    
    private var colorsProvider: PickerColorsProvider =
    AppEnvironment.forceResolve(type: PickerColorsProvider.self)
    
    private var dateFormatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    private var presentedTitle: String {
        note.title.isEmpty ? note.content : note.title
    }
    
    private var label: some View {
        return HStack {
            VStack(alignment: .leading) {
                Text(presentedTitle)
                    .lineLimit(1)
                    .font(.headline)
                
                if !note.content.isEmpty {
                    Text(note.content)
                        .lineLimit(3)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if !note.tags.isEmpty {
                    ScrollView(.horizontal) {
                        HStack(spacing: 0) {
                            ForEach(note.tags.sorted(), id: \.self) { tag in
                                Text(tag)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .padding(.all, padding)
                                    .capsuleBackgroundWithRespectToPickedColor(note.color != nil ?
                                                                               colorsProvider.getColor(by: note.color!)
                                                                               : colorsProvider.getUnpickableColor(),
                                                                               colorsProvider: colorsProvider)
                                    .padding(.all, strokePadding)
                            }
                        }
                    }
                }
                
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
    
    @ViewBuilder private var content: some View {
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
    
    var note: Note
    let kind: Kind
    
    init(note: Note, kind: Kind = .unhandled) {
        self.note = note
        self.kind = kind
    }
    
    var body: some View {
        content
    }
}

#Preview {
    List {
        NoteRowView(note: Note.makeTestNote(), kind: .archive)
            .environmentObject(NavigationStore.makeDefault())
        NoteRowView(note: Note.makeTestNote())
            .environmentObject(NavigationStore.makeDefault())
        NoteRowView(note: Note(title: "Title", content: ""))
            .environmentObject(NavigationStore.makeDefault())
        NoteRowView(note: Note(tags: ["adasd", "23123", "asdasdas"], title: "Title", content: String(repeating: "a", count: 100),
                               color: Color.green.description))
        NoteRowView(note: Note(tags: ["adasd", "23123", "asdasdas"], title: "Title", content: String(repeating: "a", count: 100),
                               color: Color.white.description))
        .environmentObject(NavigationStore.makeDefault())
    }
    .listStyle(.plain)
}
