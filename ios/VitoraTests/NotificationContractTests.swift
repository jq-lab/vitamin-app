import XCTest
@testable import Vitora

final class NotificationContractTests: XCTestCase {
    func testIntentionCanExistWithoutNotificationPermission() {
        let intention = DailyIntention(day: Date(timeIntervalSince1970: 0), choice: .a, state: .active)
        let scheduler = InMemoryNotificationScheduler(permissionState: .denied)
        let reminder = scheduler.schedule(type: .intentionReminder, intentionID: intention.id, at: Date(timeIntervalSince1970: 3600))

        XCTAssertEqual(intention.state, .active)
        XCTAssertEqual(reminder.state, .notScheduledPermissionMissing)
    }

    func testPayloadDoesNotContainSensitiveValues() {
        let payload = NotificationPayload.generic(type: .eveningReview)

        XCTAssertFalse(payload.containsSensitiveValues)
    }

    func testCancelAllMarksPendingRemindersCanceled() {
        let scheduler = InMemoryNotificationScheduler(permissionState: .authorized)
        _ = scheduler.schedule(type: .intentionReminder, intentionID: UUID(), at: Date(timeIntervalSince1970: 3600))

        scheduler.cancelAll()

        XCTAssertTrue(scheduler.allInstances().allSatisfy { $0.state == .canceled })
    }
}
