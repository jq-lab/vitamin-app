import XCTest
@testable import Vitora

final class LunaHomeServiceTests: XCTestCase {
    func testLowDataHomeInvitesRecordWithoutBlockingUse() {
        let state = LunaHomeService().makeState(today: .lowData(), intention: nil, review: nil)

        XCTAssertTrue(state.isLowData)
        XCTAssertEqual(state.prompt, "今天发生了什么呢？")
        XCTAssertTrue(state.contextSummary.contains("信息还不多"))
        XCTAssertTrue(state.contextDetail.contains("记录"))
    }

    func testActiveIntentionAddsReviewCueToContext() {
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let today = TodayState(day: day, status: .ready, cycleContextSummary: "黄体期 Day 18", signals: [
            HealthSignal(kind: .sleepSummary, day: day, valueCategory: "stable", source: .healthKit),
        ], nextAction: .reviewIntention)
        let intention = DailyIntention(day: day, choice: .a, state: .active)

        let state = LunaHomeService().makeState(today: today, intention: intention, review: nil)

        XCTAssertFalse(state.isLowData)
        XCTAssertTrue(state.contextSummary.contains("小尝试"))
        XCTAssertTrue(state.contextDetail.contains("回看"))
    }

    func testConfirmedRecentRecordAppearsOnHome() {
        let recordID = UUID()
        let recent = ParsedUnderstanding(recordID: recordID, summary: "能量记录：下午有点累", isUserConfirmed: true)

        let state = LunaHomeService().makeState(today: nil, intention: nil, review: nil, recentRecord: recent)

        XCTAssertEqual(state.recentRecordSummary, "能量记录：下午有点累")
    }
}
