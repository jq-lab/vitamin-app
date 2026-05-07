import XCTest
@testable import Vitora

final class EveningReviewServiceTests: XCTestCase {
    func testAvailabilityRequiresSameDayActiveIntention() {
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let intention = DailyIntention(day: day, choice: .a, state: .active)
        let service = EveningReviewService(now: { Date(timeIntervalSince1970: 1_770_020_000) })

        let review = service.availability(
            day: day,
            intention: intention,
            morningSummary: "早上 68% · 能量平稳",
            suggestionSummary: "13:30 前加一小份蛋白"
        )

        XCTAssertEqual(review.status, .available)
        XCTAssertEqual(review.intentionID, intention.id)
        XCTAssertTrue(review.beforeSummary.contains("早上 68%"))
        XCTAssertTrue(review.beforeSummary.contains("13:30 前加一小份蛋白"))

        let rejected = DailyIntention(day: day, choice: .notSuitable, state: .rejected)
        XCTAssertEqual(
            service.availability(day: day, intention: rejected, morningSummary: "早上 68%", suggestionSummary: "轻走 10 分钟").status,
            .unavailable
        )
    }

    func testFeedbackCreatesBeforeAfterReviewWithoutCompletionPressure() {
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let intentionID = UUID()
        let service = EveningReviewService(now: { Date(timeIntervalSince1970: 1_770_020_000) })

        let review = service.submit(
            day: day,
            intentionID: intentionID,
            before: "早上 68% · Vitora 建议低负担补给",
            feedback: .helpful,
            note: "下午确实更稳"
        )

        XCTAssertEqual(review.status, .submitted)
        XCTAssertEqual(review.intentionID, intentionID)
        XCTAssertTrue(review.afterSummary.contains("有帮助"))
        XCTAssertTrue(review.afterSummary.contains("下午确实更稳"))
        XCTAssertTrue(review.comparesSameDayEffect)
        XCTAssertFalse(review.afterSummary.contains("完成"))
    }

    func testLearningSignalDerivesFromReviewAndIntention() throws {
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let intention = DailyIntention(day: day, choice: .b, state: .active)
        let review = EveningReview(
            day: day,
            intentionID: intention.id,
            beforeSummary: "早上 68% · Vitora 建议放轻任务",
            afterSummary: "晚间反馈：有帮助",
            status: .submitted,
            submittedAt: Date(timeIntervalSince1970: 1_770_020_000)
        )
        let service = VitoraLearningSignalService(now: { Date(timeIntervalSince1970: 1_770_020_200) })

        let signal = try XCTUnwrap(service.makeSignal(review: review, intention: intention))

        XCTAssertTrue(signal.sourceIDs.contains(review.id))
        XCTAssertTrue(signal.sourceIDs.contains(intention.id))
        XCTAssertTrue(signal.summary.contains("有帮助"))
        XCTAssertTrue(signal.summary.contains("低负担"))
    }

    func testRepositoryRegistryPersistsReviewAndLearningSignal() throws {
        let registry = RepositoryRegistry.makeDefault()
        let review = EveningReview(
            day: Date(timeIntervalSince1970: 1_770_000_000),
            beforeSummary: "早上 68%",
            afterSummary: "晚间反馈：一般",
            status: .submitted
        )
        let signal = VitoraLearningSignal(sourceIDs: [review.id], summary: "今天反馈一般")

        try registry.eveningReviews.save(review)
        try registry.vitoraLearningSignals.save(signal)

        XCTAssertEqual(try registry.eveningReviews.load(id: review.id), review)
        XCTAssertEqual(try registry.vitoraLearningSignals.load(id: signal.id), signal)
    }
}
