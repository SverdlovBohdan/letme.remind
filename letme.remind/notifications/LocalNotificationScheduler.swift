//
//  LocalNotificationScheduler.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 10.10.2023.
//

enum ScheduleError: Error {
    case failed
    case nopermissions
}

enum WhenToRemind: String, CaseIterable, Identifiable {
    case within7Days
    case within30Days
    case inThisMonth
    case someday
    
    var id: Self { self }
}

protocol LocalNotificationScheduler {
    func schedule(note: Note, when: WhenToRemind) async -> Result<Void, ScheduleError>
}
