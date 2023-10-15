//
//  note.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 20.09.2023.
//

import Foundation

struct Note: Codable, Identifiable, Hashable {
    var id = UUID()
    var createdAt: Date = Date()
    var tags: Set<String> = Set<String>()
    
    var title: String
    var content: String
    var color: String?
}

typealias Notes = [Note]

extension Note {
    static func makeTestNote() -> Note {
        return Note(title: UUID().uuidString, content: "Note content")
    }
}
