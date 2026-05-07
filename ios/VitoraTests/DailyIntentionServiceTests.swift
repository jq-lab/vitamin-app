import XCTest
@testable import Vitora

final class DailyIntentionServiceTests: XCTestCase {
    func testSelectingOptionCreatesActiveDurableIntentionForSameDay() {
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let optionSet = ABOptionSet(day: day, options: [
            .init(label: .a, title: "提前加餐 + 短走动", contextSummary: "能量平稳", reminderHint: "中午前后"),
            .init(label: .b, title: "保留安静专注", contextSummary: "能量平稳", reminderHint: "下午前段"),
        ])
        let service = DailyIntentionService(now: { Date(timeIntervalSince1970: 1_770_001_200) })

        let intention = service.select(option: optionSet.options[0], from: optionSet, day: day)

        XCTAssertEqual(intention.choice, .a)
        XCTAssertEqual(intention.state, .active)
        XCTAssertEqual(intention.optionSetID, optionSet.id)
        XCTAssertTrue(intention.canOpenEveningReview)
        XCTAssertEqual(intention.selectedAt, Date(timeIntervalSince1970: 1_770_001_200))
    }

    func testNotSuitableCreatesRejectedFeedbackWithoutReviewPressure() {
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let optionSetID = UUID()
        let service = DailyIntentionService(now: { Date(timeIntervalSince1970: 1_770_001_200) })

        let intention = service.reject(day: day, optionSetID: optionSetID)

        XCTAssertEqual(intention.choice, .notSuitable)
        XCTAssertEqual(intention.state, .rejected)
        XCTAssertEqual(intention.optionSetID, optionSetID)
        XCTAssertFalse(intention.canOpenEveningReview)
    }

    func testCommitSchedulesReminderOnlyWhenPreferenceIsEnabled() {
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let optionSet = ABOptionSet(day: day, options: [
            .init(label: .b, title: "保留安静专注", contextSummary: "能量平稳", reminderHint: "下午前段"),
        ])
        let preference = ReminderPreference(isEnabled: true, intentionReminderHour: 15, reviewReminderHour: 21)
        let scheduler = InMemoryNotificationScheduler(permissionState: .authorized)
        let service = DailyIntentionService(now: { Date(timeIntervalSince1970: 1_770_001_200) })

        let commitment = service.commit(
            option: optionSet.options[0],
            from: optionSet,
            preference: preference,
            scheduler: scheduler,
            day: day
        )

        XCTAssertEqual(commitment.intention.choice, .b)
        XCTAssertEqual(commitment.intention.state, .active)
        XCTAssertEqual(commitment.reminder?.state, .scheduled)
        XCTAssertEqual(commitment.reminder?.intentionID, commitment.intention.id)
        XCTAssertTrue(commitment.makesReviewReachable)
    }
}
