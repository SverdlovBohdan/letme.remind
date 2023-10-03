//
//  UiStore.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 07.09.2023.
//

import SwiftUI

@MainActor
class UiStore<Action, State>: ObservableObject {
    @Published var state: State
    
    private var reduce: (inout State, Action) -> Void
    
    init(initialState: State, reducer: @escaping (inout State, Action) -> Void) {
        self.state = initialState
        self.reduce = reducer
    }
    
    func dispatch(action: Action) {
        reduce(&state, action)
    }
}
