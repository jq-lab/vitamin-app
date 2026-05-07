import XCTest
@testable import Vitora

final class OnboardingDomainTests: XCTestCase {
    func testAppGateRequiresOnboardingWithoutProfile() {
        let service = AppGateService()

        XCTAssertEqual(service.resolveGate(profile: nil, dataSource: .notAsked()), .needsOnboarding)
    }

    func testCompletionWithSkippedHealthKitAllowsLowDataMainTabs() {
        let service = OnboardingService()
        let completion = service.complete(
            draft: OnboardingDraft(
                displayLabel: "  小维  ",
                focusAreas: [.energy],
                dataSourceAuthorization: DataSourceAuthorization(state: .skipped)
            ),
            completedAt: Date(timeIntervalSince1970: 1_800_000_000)
        )

        XCTAssertEqual(completion.profile.displayLabel, "小维")
        XCTAssertEqual(completion.context.dataSourceAuthorization.state, .skipped)
        XCTAssertEqual(completion.gateState, .lowDataReady)
        XCTAssertTrue(completion.gateState.allowsMainTabs)
        XCTAssertTrue(completion.context.supportsLowDataMode)
    }

    func testCompletionWithAuthorizedHealthKitIsReadyForToday() {
        let service = OnboardingService()
        let completion = service.complete(
            draft: OnboardingDraft(
                displayLabel: "Luna",
                focusAreas: [.energy, .sleep],
                dataSourceAuthorization: DataSourceAuthorization(state: .authorized)
            ),
            completedAt: Date(timeIntervalSince1970: 1_800_000_000)
        )

        XCTAssertEqual(completion.context.focusAreas, [.energy, .sleep])
        XCTAssertEqual(completion.gateState, .readyForToday)
        XCTAssertFalse(completion.context.supportsLowDataMode)
    }

    func testHealthKitOptionalChoiceCanSkipWithoutBlockingCompletion() {
        let healthKitClient = DefaultHealthKitClient()
        let skipped = healthKitClient.apply(choice: .skip)
        let draft = OnboardingDraft(displayLabel: "小维", dataSourceAuthorization: skipped)

        XCTAssertTrue(draft.isReadyForCompletion)
        XCTAssertEqual(skipped.state, .skipped)
        XCTAssertTrue(skipped.keepsAppUsable)
    }
}
