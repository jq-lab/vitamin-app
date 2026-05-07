import XCTest
@testable import Vitora

@MainActor
final class PerformanceSmokeTests: XCTestCase {
    func testLaunchEnvironmentSmokePerformance() {
        measure(metrics: [XCTClockMetric()]) {
            _ = AppEnvironment(arguments: [
                "Vitora",
                "-vitoraUITestCompletedOnboarding",
                "-vitoraUITestRichToday",
                "-vitoraUITestReviewAvailable",
            ])
        }
    }

    func testTabSwitchingAndSheetPresentationSmokePerformance() {
        let environment = AppEnvironment(arguments: [
            "Vitora",
            "-vitoraUITestCompletedOnboarding",
            "-vitoraUITestRichToday",
            "-vitoraUITestReviewAvailable",
        ])

        measure(metrics: [XCTClockMetric()]) {
            for _ in 0..<80 {
                environment.selectTab(.today)
                environment.openVitoraContext(sourceTitle: "今日状态", sourceSummary: "68% · 14:00 可能低谷", prompt: "校准今天状态。")
                environment.dismissPresentation()
                environment.selectTab(.vitora)
                environment.openEveningReview()
                environment.dismissPresentation()
                environment.selectTab(.cycle)
            }
        }
    }

    func testEnergyRevealDomainSmokePerformance() {
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let stateService = TodayStateService()
        let ritualService = EnergyRitualService()
        let signals = [
            HealthSignal(kind: .sleepSummary, day: day, valueCategory: "stable", source: .healthKit),
            HealthSignal(kind: .heartRateVariability, day: day, valueCategory: "slightly-low", source: .healthKit),
            HealthSignal(kind: .activeEnergy, day: day, valueCategory: "moderate", source: .healthKit),
        ]

        measure(metrics: [XCTClockMetric()]) {
            for _ in 0..<200 {
                let state = stateService.makeTodayState(day: day, signals: signals, cycle: nil, intention: nil)
                let summary = stateService.makeEnergySummary(for: state)
                _ = ritualService.openingState(day: day, hasCompletedOrSkipped: false)
                _ = ritualService.start(day: day)
                _ = ritualService.finish(day: day, summary: summary)
            }
        }
    }
}
