//
//  NotesWriter.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 20.09.2023.
//

import SwiftUI

protocol NotesWriter {
    func write(_ note: Note, to notes: Binding<Data>)
    func remove(_ note: Note, from notes: Binding<Data>)
}
