//
//  NotesReader.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 20.09.2023.
//

import SwiftUI

protocol NotesReader {
    func read(from notesData: Binding<Data>) -> Notes
    func one(by id: String, from notesData: Binding<Data>) -> Note?
    func count(_ notes: Binding<Data>) -> Int
}
