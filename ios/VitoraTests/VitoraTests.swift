import XCTest
@testable import Vitora

@MainActor
final class VitoraTests: XCTestCase {
    func testAppEnvironmentStartsAtOnboarding() {
        let environment = AppEnvironment()
        XCTAssertEqual(environment.route, .onboarding)
    }

    func testCompletingOnboardingRoutesToToday() {
        let environment = AppEnvironment()
        environment.completeOnboarding()
        XCTAssertEqual(environment.route, .today)
    }
}
