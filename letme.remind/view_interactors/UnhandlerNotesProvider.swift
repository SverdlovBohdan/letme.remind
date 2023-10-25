//
//  UnhandlerNotesProvider.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 25.10.2023.
//

import Foundation

protocol UnhandlerNotesProvider {
    func populateUnhandledNotes() async
}
