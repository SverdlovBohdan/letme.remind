//
//  NotesPersistenceBindings.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 06.10.2023.
//

import SwiftUI

protocol NotesPersistenceBindings {
    func makeNotesToRemindPersistenceBinding() -> Binding<Data>
    func makeUnhandledNotesPersistenceBinding() -> Binding<Data>
    func makeNotesArchivePersistenceBinding() -> Binding<Data>
}
