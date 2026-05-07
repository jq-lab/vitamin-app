import XCTest
@testable import Vitora

final class NotificationSchedulerTests: XCTestCase {
    func testDisabledPreferenceDoesNotScheduleIntentionReminder() {
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let intention = DailyIntention(day: day, choice: .a, state: .active)
        let preference = ReminderPreference(isEnabled: false, intentionReminderHour: 14)
        let scheduler = InMemoryNotificationScheduler(permissionState: .authorized)

        let reminder = scheduler.scheduleIntentionReminder(for: intention, preference: preference, day: day)

        XCTAssertNil(reminder)
        XCTAssertTrue(scheduler.allInstances().isEmpty)
    }

    func testDeniedPermissionStillReturnsNonBlockingReminderState() {
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let intention = DailyIntention(day: day, choice: .a, state: .active)
        let preference = ReminderPreference(isEnabled: true, intentionReminderHour: 14)
        let scheduler = InMemoryNotificationScheduler(permissionState: .denied)

        let reminder = scheduler.scheduleIntentionReminder(for: intention, preference: preference, day: day)

        XCTAssertEqual(reminder?.state, .notScheduledPermissionMissing)
        XCTAssertEqual(reminder?.intentionID, intention.id)
        XCTAssertEqual(scheduler.allInstances().count, 1)
    }

    func testPayloadDoesNotCarrySensitiveHealthValues() {
        let payload = NotificationPayload.generic(type: .intentionReminder)

        XCTAssertEqual(payload.titleKey, "notification.intention.title")
        XCTAssertEqual(payload.bodyKey, "notification.intention.body")
        XCTAssertFalse(payload.containsSensitiveValues)
    }

    func testPreferenceOffCancelsPendingReminders() {
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let intention = DailyIntention(day: day, choice: .b, state: .active)
        let preference = ReminderPreference(isEnabled: true, intentionReminderHour: 15)
        let scheduler = InMemoryNotificationScheduler(permissionState: .authorized)
        _ = scheduler.scheduleIntentionReminder(for: intention, preference: preference, day: day)

        scheduler.cancelAll()

        XCTAssertTrue(scheduler.allInstances().allSatisfy { $0.state == .canceled })
    }
}
