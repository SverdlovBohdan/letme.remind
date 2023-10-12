//
//  letme_remindTests.swift
//  letme.remindTests
//
//  Created by Bohdan Sverdlov on 02.09.2023.
//

import XCTest
import Mockingbird
@testable import letme_remind

final class NotificationsTests: XCTestCase {
    struct TestError: Error {}
    
    var notificationCenterMock: NotificationCenterAdapterMock!
    var notifications: Notifications!
    
    override func setUpWithError() throws {
        notificationCenterMock = mock(NotificationCenterAdapter.self)
        notifications = Notifications(notificationCenter: notificationCenterMock)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
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
    
    private func setAuthorizationStatus(status: UNAuthorizationStatus) async {
        let settingsMock: NotificationSettingsAdapterMock = mock(NotificationSettingsAdapter.self)
        given(settingsMock.authorizationStatus).willReturn(status)
        given(await notificationCenterMock.notificationSettings()).willReturn(settingsMock)
    }
    
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
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
