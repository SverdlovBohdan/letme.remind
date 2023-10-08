//
//  Notifications.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 02.09.2023.
//

import NotificationCenter
import os

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

protocol LocalNotificationPermissionsProvider {
    func isLocalNotificationPermissionsGranted() async -> Bool
}

protocol LocalNotificationScheduler {
    func schedule(note: Note, when: WhenToRemind) async -> Result<Void, ScheduleError>
}

protocol LocalNotificationProvider {
    func pendingNotifications() async -> [UNNotificationRequest]
}

class Notifications: LocalNotificationPermissionsProvider, LocalNotificationScheduler,
                     LocalNotificationProvider {
    static private let SECONDS_IN_DAY: TimeInterval = 86_400
    
    private var notificationCenter: UNUserNotificationCenter =
        Environment.forceResolve(type: UNUserNotificationCenter.self)
    
    private var logger: Logger =
        Environment.forceResolve(type: Logger.self, arg1: String(describing: Notifications.self))
    
    private func requestLocalNotificationPermissions() async -> UNAuthorizationStatus {
        var permissionsState: UNAuthorizationStatus = .notDetermined
        
        do {
            permissionsState = try await notificationCenter
                .requestAuthorization(options: [.alert, .sound]) ? .authorized : .denied
        } catch(let error) {
            logger.warning("requestAuthorization() exception. permissionsState is .Unknown now. \(error.localizedDescription)")
        }
        
        return permissionsState
    }
    
    func pendingNotifications() async -> [UNNotificationRequest] {
        let notifications = await notificationCenter.pendingNotificationRequests()
        return notifications
    }
    
    func isLocalNotificationPermissionsGranted() async -> Bool {
        let settings = await notificationCenter.notificationSettings()
        
        logger.info("Local Notifications status: \(settings.authorizationStatus.rawValue)")
        
        var permissionsState: UNAuthorizationStatus = settings.authorizationStatus
        if permissionsState == .notDetermined {
            permissionsState = await requestLocalNotificationPermissions()
        }
        
        return permissionsState == .ephemeral || permissionsState == .authorized || permissionsState == .provisional
    }
    
    func schedule(note: Note, when: WhenToRemind) async -> Result<Void, ScheduleError> {
        assert(!note.title.isEmpty || !note.content.isEmpty)
        
        let notificationContent: UNMutableNotificationContent = UNMutableNotificationContent()
        notificationContent.title = note.title.isEmpty ? "Kindly reminder" : note.title
        notificationContent.body = note.content
        
        var trigger: UNNotificationTrigger? = nil
        
        switch when {
        case .within7Days:
            let randomShiftedTimeInterval: TimeInterval = getRandom7DayShift() * Notifications.SECONDS_IN_DAY
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: randomShiftedTimeInterval,
                                                        repeats: false)
        case .within30Days:
            let randomShiftedTimeInterval: TimeInterval = getRandom30DayShift() * Notifications.SECONDS_IN_DAY
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: randomShiftedTimeInterval,
                                                        repeats: false)
        case .inThisMonth:
            let monthInterval: DateInterval = Calendar.current.dateInterval(of: .month, for: Date())!
            let lastDayInMonth: Int = Calendar.current.component(
                .day, from: Calendar.current.date(byAdding: .day, value: -1, to: monthInterval.end)!)
            
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            
            let currentDay: Int = Calendar.current.component(.day, from: Date())
            dateComponents.day = Int.random(in: currentDay...lastDayInMonth)
            
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        case .someday:
            let randomDate = Calendar.current.date(byAdding: .day, value: getRandomYearShift(), to: Date())!
            trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.day, .month, .year], from: randomDate), repeats: false)
        }
        
        let isPermissionsGranted: Bool = await isLocalNotificationPermissionsGranted()
        if !isPermissionsGranted {
            logger.notice("No persmissions for note making.")
            return .failure(.nopermissions)
        }
        
        let result = await performSchedule(for: note.id.uuidString, content: notificationContent, trigger: trigger)
        return result
    }
    
    private func getRandom7DayShift() -> Double {
        return Double(Int.random(in: 1...7))
    }
    
    private func getRandom30DayShift() -> Double {
        return Double(Int.random(in: 1...30))
    }
    
    private func getRandomYearShift() -> Int {
        return Int.random(in: 1...365)
    }
    
    private func performSchedule(for id: String, content: UNMutableNotificationContent,
                                 trigger: UNNotificationTrigger?) async -> Result<Void, ScheduleError> {
        let request: UNNotificationRequest = UNNotificationRequest(identifier: id,
                                                                   content: content,
                                                                   trigger: trigger)
        do {
            try await notificationCenter.add(request)
        } catch {
            logger.error("NotificaitonCenter.add() exception. \(id) has been skipped")
            return .failure(.failed)
        }
        
        return .success(())
    }
}

#if DEBUG
extension Notifications {
    static let standart: Notifications = {
        return Notifications()
    }()
}

extension Notifications {
    func scheduleTestNotification(note: Note) {
        Task {
            let notificationContent: UNMutableNotificationContent = UNMutableNotificationContent()
            notificationContent.title = note.title
            notificationContent.body = note.content
            
            let trigger: UNNotificationTrigger =  UNTimeIntervalNotificationTrigger(timeInterval: 3,
                                                                                    repeats: false)
            let _ = await performSchedule(for: note.id.uuidString, content: notificationContent, trigger: trigger)
        }
    }
}
#endif
