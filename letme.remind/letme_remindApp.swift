//
//  letme_remindApp.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 02.09.2023.
//

import SwiftUI


@main
struct letme_remindApp: App {
    @UIApplicationDelegateAdaptor(LetMeRemindAppDelegate.self) var appDelegate
    @StateObject var navigationStore: NavigationStore = .makeDefault()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(navigationStore)
                .onAppear(perform: {
                    appDelegate.setNavigationStore(navigationStore)
                })
        }
    }
}
