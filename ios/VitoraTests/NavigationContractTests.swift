import XCTest
@testable import Vitora

final class NavigationContractTests: XCTestCase {
    func testPrimaryTabsAreExactlyTodayVitoraCycle() {
        XCTAssertEqual(PrimaryTab.allCases, [.today, .vitora, .cycle])
    }

    func testLightDrawerRoutesAreExactlyP0SupportRoutes() {
        XCTAssertEqual(SupportRoute.p0Routes.count, 6)
        XCTAssertEqual(SupportRoute.p0Routes, [.profile, .dataSources, .nutrition, .reminders, .dataExport, .privacyAndAccountRemoval])
    }

    func testContextualPresentationsHaveExitPaths() {
        XCTAssertTrue(ContextualPresentation.allCases.allSatisfy(\.hasExitPath))
    }

    func testNavigationStateHidesTabsBeforeOnboarding() {
        var state = NavigationState(gate: .needsOnboarding)
        XCTAssertTrue(state.visibleTabs.isEmpty)

        state.completeOnboarding(lowData: true)
        XCTAssertEqual(state.visibleTabs, [.today, .vitora, .cycle])
        XCTAssertEqual(state.gate, .lowDataReady)
    }
}
