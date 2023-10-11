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
        var pendingNotifications = await notifications.pendingNotifications()
        
        XCTAssertFalse(pendingNotifications.isEmpty)
        XCTAssertEqual(expectedId, pendingNotifications[0].identifier)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
