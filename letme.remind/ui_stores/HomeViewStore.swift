//
//  HomeViewStore.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 11.09.2023.
//
enum HomeViewAction: String, CustomStringConvertible {
    case showLocalNotificationsAlertAreDisabled
    case showMakingNoteView
    case closeMakingNoteView
    
    var description: String {
        return self.rawValue
    }
}

struct HomeViewState {
    var isLocalNotificationsAlertAreDisabledPresented: Bool = false
    var isMakingNoteViewPresented: Bool = false
}

typealias HomeViewStore = UiStore<HomeViewAction, HomeViewState>

func homeViewReducer(currentState: inout HomeViewState,
                     action: HomeViewAction) {
    switch action {
    case .showLocalNotificationsAlertAreDisabled:
        if !currentState.isLocalNotificationsAlertAreDisabledPresented {
            currentState.isLocalNotificationsAlertAreDisabledPresented = true
        }
    case .showMakingNoteView:
        if !currentState.isMakingNoteViewPresented {
            currentState.isMakingNoteViewPresented = true
        }
    
    case .closeMakingNoteView:
        if currentState.isMakingNoteViewPresented {
            currentState.isMakingNoteViewPresented = false
        }
    }
}

extension UiStore where State == HomeViewState, Action == HomeViewAction {
    static func makeDefault() -> HomeViewStore {
        return HomeViewStore(initialState: .init(), reducer: homeViewReducer)
    }
}
