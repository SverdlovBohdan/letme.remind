//
//  letme_remindTests.swift
//  letme.remindTests
//
//  Created by Bohdan Sverdlov on 02.09.2023.
//

import XCTest
import Mockingbird
@testable import letme_remind

class NotificationsTests: XCTestCase {
    struct TestError: Error {}
    
    var notificationCenterMock: NotificationCenterAdapterMock!
    var notifications: Notifications!
    
    fileprivate func setAuthorizationStatus(status: UNAuthorizationStatus) async {
        let settingsMock: NotificationSettingsAdapterMock = mock(NotificationSettingsAdapter.self)
        given(settingsMock.authorizationStatus).willReturn(status)
        given(await notificationCenterMock.notificationSettings()).willReturn(settingsMock)
    }
    
    override func setUpWithError() throws {
        notificationCenterMock = mock(NotificationCenterAdapter.self)
        notifications = Notifications(notificationCenter: notificationCenterMock)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}

class NotificationsTests_PedingNotitifications: NotificationsTests {
    func testProvidesPedingNotitifications() async throws {
        let expectedId: String = "test"
        let expectedPendingNotifications: [UNNotificationRequest] = [.init(identifier: expectedId,
                                                                           content: .init(),
                                                                           trigger: nil)]
        given(await notificationCenterMock.pendingNotificationRequests()).willReturn(expectedPendingNotifications)
        let pendingNotifications = await notifications.pendingNotifications()
        
        XCTAssertFalse(pendingNotifications.isEmpty)
        XCTAssertEqual(expectedId, pendingNotifications[0].identifier)
    }
}

class NotificationsTests_PermissionProviding: NotificationsTests {
    func testProvidesGrantedPermissionIfUserAllowsNotifications() async {
        await setAuthorizationStatus(status: .notDetermined)
        given(await notificationCenterMock.requestAuthorization(options: any())).willReturn(true)
        let result: Bool = await notifications.isLocalNotificationPermissionsGranted()
        XCTAssertTrue(result)
    }
    
    func testProvidesDeniedPermissionIfUserDisablesNotifications() async {
        given(await notificationCenterMock.requestAuthorization(options: any())).willReturn(false)
        await setAuthorizationStatus(status: .notDetermined)
        let result: Bool = await notifications.isLocalNotificationPermissionsGranted()
        XCTAssertFalse(result)
    }
    
    func testProvidesDeniedPermissionIfRequestAuthorizationThrowsException() async {
        given(await notificationCenterMock.requestAuthorization(options: any())).will { _ in
            throw TestError()
        }
        await setAuthorizationStatus(status: .notDetermined)
        let result: Bool = await notifications.isLocalNotificationPermissionsGranted()
        XCTAssertFalse(result)
    }
    
    func testProvidesGrantedPermissionIfStateIsEphemeral() async {
        await setAuthorizationStatus(status: .ephemeral)
        let result: Bool = await notifications.isLocalNotificationPermissionsGranted()
        XCTAssertTrue(result)
    }
    
    func testProvidesGrantedPermissionIfStateIsAuttorized() async {
        await setAuthorizationStatus(status: .authorized)
        let result: Bool = await notifications.isLocalNotificationPermissionsGranted()
        XCTAssertTrue(result)
    }
    
    func testProvidesGrantedPermissionIfStateIsProvisional() async {
        await setAuthorizationStatus(status: .provisional)
        let result: Bool = await notifications.isLocalNotificationPermissionsGranted()
        XCTAssertTrue(result)
    }
    
    func testProvidesDeniedPermission() async {
        await setAuthorizationStatus(status: .denied)
        let result: Bool = await notifications.isLocalNotificationPermissionsGranted()
        XCTAssertFalse(result)
    }
}

class NotificationsTests_Schedule: NotificationsTests {
    private func expectSuccess(_ result: Result<Void, ScheduleError>) {
        switch result {
        case .failure(_):
            XCTFail("Expect success reuslt")
        default:
            break
        }
    }
    
    private func expectFailure(_ result: Result<Void, ScheduleError>, with error: ScheduleError) {
        switch result {
        case .success(_):
            XCTFail("Unexpected schedule() result")
        case .failure(let failureError):
            XCTAssertEqual(failureError, error)
        }
    }
    
    func testFailsIfPermissionIsNotGranted() async {
        await setAuthorizationStatus(status: .denied)
        let result = await notifications.schedule(note: .makeTestNote(), when: .within7Days)
        expectFailure(result, with: .nopermissions)
    }
    
    func testFailsIfUnableToAddNotificationRequest() async {
        given(await notificationCenterMock.add(any())).will { _ in
            throw TestError()
        }
        await setAuthorizationStatus(status: .authorized)
        let result = await notifications.schedule(note: .makeTestNote(), when: .within7Days)
        expectFailure(result, with: .failed)
    }
    
    private func expectSuccessfulSchedule(_ note: Note, when: WhenToRemind) async -> Void {
        await setAuthorizationStatus(status: .authorized)
        let result = await notifications.schedule(note: note, when: when)
        expectSuccess(result)
    }
    
    func testCanSchedule7daysNote() async {
        let expected = Note.makeTestNote()
        await expectSuccessfulSchedule(expected, when: .within7Days)
        
        verify(await notificationCenterMock.add(any(where: { [expected] value in
            let isNoteDataValid = value.content.title == expected.title &&
                                  value.content.body == expected.content
            let isTriggerValid = value.trigger! is UNTimeIntervalNotificationTrigger
            //TODO: Check date shifting
            return value.identifier == expected.id.uuidString && isNoteDataValid && isTriggerValid
        }))).wasCalled()
    }
    
    func testCanSchedule30daysNote() async {
        let expected = Note.makeTestNote()
        await expectSuccessfulSchedule(expected, when: .within30Days)
        
        verify(await notificationCenterMock.add(any(where: { [expected] value in
            let isNoteDataValid = value.content.title == expected.title &&
                                  value.content.body == expected.content
            let isTriggerValid = value.trigger! is UNTimeIntervalNotificationTrigger
            //TODO: Check date shifting
            return value.identifier == expected.id.uuidString && isNoteDataValid && isTriggerValid
        }))).wasCalled()
    }
    
    func testCanScheduleInThisMonth() async {
        let expected = Note.makeTestNote()
        await expectSuccessfulSchedule(expected, when: .inThisMonth)
        
        verify(await notificationCenterMock.add(any(where: { [expected] value in
            let isNoteDataValid = value.content.title == expected.title &&
                                  value.content.body == expected.content
            let isTriggerValid = value.trigger! is UNCalendarNotificationTrigger
            //TODO: Check date shifting
            return value.identifier == expected.id.uuidString && isNoteDataValid && isTriggerValid
        }))).wasCalled()
    }
    
    func testCanScheduleRandom() async {
        let expected = Note.makeTestNote()
        await expectSuccessfulSchedule(expected, when: .someday)
        
        verify(await notificationCenterMock.add(any(where: { [expected] value in
            let isNoteDataValid = value.content.title == expected.title &&
                                  value.content.body == expected.content
            let isTriggerValid = value.trigger! is UNCalendarNotificationTrigger
            //TODO: Check date shifting
            return value.identifier == expected.id.uuidString && isNoteDataValid && isTriggerValid
        }))).wasCalled()
    }
}
