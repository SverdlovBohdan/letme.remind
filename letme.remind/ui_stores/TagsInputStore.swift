//
//  TagsInputStore.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 20.10.2023.
//

import Foundation

enum TagsInputAction: CustomStringConvertible {
    case addNewTag
    case removeTag(String)
    
    var description: String {
        switch self {
        case .addNewTag:
            return "addNewTag"
        case .removeTag(_):
            return "removeTag"
        }
    }
}

struct TagsInputViewState {
    var tags: [String] = .init()
    var inputTag: String = ""
    
    init() {}
    
    init(tags: [String], inputTag: String) {
        self.tags = tags
        self.inputTag = inputTag
    }
}

typealias TagsInputStore = UiStore<TagsInputAction, TagsInputViewState>

func tagsInputReducer(currentState: inout TagsInputViewState,
                      action: TagsInputAction) {
    switch action {
    case .addNewTag:
        if !currentState.inputTag.isEmpty && !currentState.tags.contains(where: { item in
            item == currentState.inputTag
        }) {
            currentState.tags.append(currentState.inputTag)
            currentState.inputTag.removeAll()
        }
    case .removeTag(let tag):
        currentState.tags.removeAll { item in
            item == tag
        }
    }
}

extension UiStore where State == TagsInputViewState, Action == TagsInputAction {
    static func makeDefault() -> TagsInputStore {
        return TagsInputStore(initialState: .init(), reducer: tagsInputReducer)
    }
}
