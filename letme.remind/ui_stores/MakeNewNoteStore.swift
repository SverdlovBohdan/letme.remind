//
//  MakeNewNoteStore.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 23.09.2023.
//

enum MakeNewNoteAction {
    case validate
    case fillBy(Note)
}

struct MakeNewNoteState {
    var isValid: Bool = false
    var title: String = ""
    var content: String = ""
}

typealias MakeNewNoteStore = UiStore<MakeNewNoteAction, MakeNewNoteState>

func makeNewNoteReducer(currentState: inout MakeNewNoteState,
                         action: MakeNewNoteAction) {
    switch action {
    case .validate:
        currentState.isValid = !currentState.title.isEmpty || !currentState.content.isEmpty
        
    case .fillBy(let note):
        currentState.title = note.title
        currentState.content = note.content
        currentState.isValid = true
    }
}

extension UiStore where State == MakeNewNoteState, Action == MakeNewNoteAction {
    static func makeDefault() -> MakeNewNoteStore {
        return MakeNewNoteStore(initialState: .init(), reducer: makeNewNoteReducer)
    }
}
