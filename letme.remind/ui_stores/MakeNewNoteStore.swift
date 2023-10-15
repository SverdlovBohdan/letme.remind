//
//  MakeNewNoteStore.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 23.09.2023.
//

enum MakeNewNoteAction: CustomStringConvertible {
    case validate
    case fillBy(Note)
    case setColorTag(String?)
    
    var description: String {
        switch self {
        case .validate:
            return "validate"
        case .fillBy(_):
            return "fillBy"
        case .setColorTag(_):
            return "setColorTag"
        }
    }
}

struct MakeNewNoteState {
    var isValid: Bool = false
    var title: String = ""
    var content: String = ""
    var colorTag: String?
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
        
    case .setColorTag(let tag):
        currentState.colorTag = tag
    }
}

extension UiStore where State == MakeNewNoteState, Action == MakeNewNoteAction {
    static func makeDefault() -> MakeNewNoteStore {
        return MakeNewNoteStore(initialState: .init(), reducer: makeNewNoteReducer)
    }
}
