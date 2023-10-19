//
//  NavigationStore.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 02.10.2023.
//

import Foundation
import SwiftUI
import UserNotifications

struct NoteId: Codable, Hashable {
    var noteId: String
}

enum NavigationAction: CustomStringConvertible {
    case openNoteView(NoteId)
    case openRootView
    
    var description: String {
        switch self {
        case .openNoteView(_):
            return "openNoteView"
        case .openRootView:
            return "openNoteView"
        }
    }
}

struct NavigationState {
    var navigationPath: NavigationPath = NavigationPath()
}

typealias NavigationStore = UiStore<NavigationAction,
                                    NavigationState>

func navigationReducer(currentState: inout NavigationState,
                       action: NavigationAction) {
    switch action {
    case .openNoteView(let noteId):
        if currentState.navigationPath.isEmpty {
            currentState.navigationPath = NavigationPath([noteId])
        }
        
    case .openRootView:
        currentState.navigationPath.removeLast(currentState.navigationPath.count)
    }
}

extension UiStore where State == NavigationState, Action == NavigationAction {
    static func makeDefault() -> NavigationStore {
        return NavigationStore(initialState: .init(), reducer: navigationReducer)
    }
}
