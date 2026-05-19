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
                energyWindowPreference: .afternoon,
                guidanceStyle: .gentleSuggestion,
                reminderPreference: .eveningReview,
                dataSourceAuthorization: DataSourceAuthorization(state: .skipped)
            ),
            completedAt: Date(timeIntervalSince1970: 1_800_000_000)
        )

        XCTAssertEqual(completion.profile.displayLabel, "小维")
        XCTAssertEqual(completion.context.energyWindowPreference, .afternoon)
        XCTAssertEqual(completion.context.guidanceStyle, .gentleSuggestion)
        XCTAssertEqual(completion.context.reminderPreference, .eveningReview)
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

    func testOnboardingContextDecodesLegacyPayloadWithCustomizationDefaults() throws {
        let payload = """
        {
          "id": "00000000-0000-0000-0000-000000000001",
          "focusAreas": ["energy"],
          "cycleSummary": "上次月经开始日不确定",
          "dataSourceAuthorization": {
            "id": "00000000-0000-0000-0000-000000000002",
            "source": "healthKit",
            "state": "skipped",
            "updatedAt": 0
          }
        }
        """.data(using: .utf8)!

        let context = try JSONDecoder().decode(OnboardingContext.self, from: payload)

        XCTAssertEqual(context.energyWindowPreference, .unsure)
        XCTAssertEqual(context.guidanceStyle, .explainFirst)
        XCTAssertEqual(context.reminderPreference, .eveningReview)
        XCTAssertEqual(context.dataSourceAuthorization.state, .skipped)
    }
}
