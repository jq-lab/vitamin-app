import XCTest
@testable import Vitora

final class TodayStateServiceTests: XCTestCase {
    func testLowDataStillReturnsUsableTodayState() {
        let service = TodayStateService()
        let day = Date(timeIntervalSince1970: 1_770_000_000)

        let state = service.makeTodayState(day: day, signals: [], cycle: nil, intention: nil)

        XCTAssertEqual(state.status, .lowData)
        XCTAssertEqual(state.nextAction, .recordWithLuna)
        XCTAssertTrue(state.isUsable)
        XCTAssertTrue(state.signals.isEmpty)
    }

    func testSignalsAndCycleProduceReadyTodayState() {
        let service = TodayStateService()
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let signals = [
            HealthSignal(kind: .sleepSummary, day: day, valueCategory: "stable", source: .healthKit),
            HealthSignal(kind: .activeEnergy, day: day, valueCategory: "moderate", source: .healthKit),
        ]
        let cycle = CycleContext(anchorDate: day, cycleDay: 18, summary: "黄体期 Day 18")

        let state = service.makeTodayState(day: day, signals: signals, cycle: cycle, intention: nil)

        XCTAssertEqual(state.status, .ready)
        XCTAssertEqual(state.cycleContextSummary, "黄体期 Day 18")
        XCTAssertEqual(state.signals.count, 2)
        XCTAssertEqual(state.nextAction, .openAnalysis)
    }

    func testReviewReadyIntentionBecomesNextAction() {
        let service = TodayStateService()
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let intention = DailyIntention(day: day, choice: .a, state: .reviewAvailable)

        let state = service.makeTodayState(
            day: day,
            signals: [HealthSignal(kind: .manualSummary, day: day, valueCategory: "noted", source: .manual)],
            cycle: nil,
            intention: intention
        )

        XCTAssertEqual(state.nextAction, .reviewIntention)
        XCTAssertEqual(state.dailyIntentionID, intention.id)
    }

    func testEnergySummaryUsesKnownSignalsWithoutOverclaiming() {
        let service = TodayStateService()
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let state = service.makeTodayState(
            day: day,
            signals: [
                HealthSignal(kind: .sleepSummary, day: day, valueCategory: "stable", source: .healthKit),
                HealthSignal(kind: .heartRateAverage, day: day, valueCategory: "steady", source: .healthKit),
            ],
            cycle: CycleContext(anchorDate: day, cycleDay: 18, summary: "黄体期 Day 18"),
            intention: nil
        )

        let summary = service.makeEnergySummary(for: state)

        XCTAssertEqual(summary.scoreBand, .steady)
        XCTAssertEqual(summary.supportingSignalKinds, [.sleepSummary, .heartRateAverage])
        XCTAssertTrue(summary.explanationSummary.contains("参考"))
    }
}
