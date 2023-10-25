//
//  NoteFilter.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 25.10.2023.
//

import Foundation
import SwiftUI

protocol NoteFilter {
    func filter(by searchText: String, notesPayloadBinding: Binding<Data>) -> Notes
}
