//
//  UiStore.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 07.09.2023.
//

import SwiftUI
import Foundation
import os

@dynamicMemberLookup
@MainActor
class UiStore<Action, State>: ObservableObject where Action: CustomStringConvertible {
    @Published var state: State
    
    private var reduce: (inout State, Action) -> Void
    
    private var logger: Logger =
        Environment.forceResolve(type: Logger.self, arg1: String(describing: UiStore<Action, State>.self))
    
    init(initialState: State, reducer: @escaping (inout State, Action) -> Void) {
        self.state = initialState
        self.reduce = reducer
    }
    
    func dispatch(action: Action) {
        logger.debug("Dispatch \(action)")
        reduce(&state, action)
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<State, T>) -> T {
        get { return state[keyPath: keyPath] }
        set { state[keyPath: keyPath] = newValue }
    }
 }
