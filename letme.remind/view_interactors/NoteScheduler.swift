//
//  NoteScheduler.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 25.10.2023.
//

import Foundation
import SwiftUI

protocol NoteScheduler {
    func scheduleNote(note: Note, when: WhenToRemind) async -> Result<Void, ScheduleError>

    func rescheduleNote(note: Note, oldNote: Note, when: WhenToRemind) async -> Result<Void, ScheduleError>
}
