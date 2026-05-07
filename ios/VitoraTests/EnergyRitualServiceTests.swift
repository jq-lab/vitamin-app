import XCTest
@testable import Vitora

final class EnergyRitualServiceTests: XCTestCase {
    func testOpeningStateIsDueOnlyWhenNotHandledToday() {
        let service = EnergyRitualService()
        let day = Date(timeIntervalSince1970: 1_770_000_000)

        XCTAssertEqual(service.openingState(day: day, hasCompletedOrSkipped: false).state, .due)
        XCTAssertEqual(service.openingState(day: day, hasCompletedOrSkipped: true).state, .notDue)
    }

    func testStartReturnsRunningState() {
        let service = EnergyRitualService()
        let day = Date(timeIntervalSince1970: 1_770_000_000)

        let result = service.start(day: day)

        XCTAssertEqual(result.state, .running)
        XCTAssertNil(result.energySummary)
        XCTAssertNil(result.completedAt)
    }

    func testFinishWithSummaryCompletesAndCarriesResult() {
        let service = EnergyRitualService()
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let summary = EnergySummary(day: day, scoreBand: .steady, explanationSummary: "基于可用信息的生活方式参考。")

        let result = service.finish(day: day, summary: summary)

        XCTAssertEqual(result.state, .completed)
        XCTAssertEqual(result.energySummary, summary)
        XCTAssertNotNil(result.completedAt)
    }

    func testSkipDoesNotRequireEnergySummary() {
        let service = EnergyRitualService()
        let day = Date(timeIntervalSince1970: 1_770_000_000)

        let result = service.skip(day: day)

        XCTAssertEqual(result.state, .skipped)
        XCTAssertNil(result.energySummary)
        XCTAssertNotNil(result.completedAt)
    }
}
