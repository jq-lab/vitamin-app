import XCTest

final class PivotNavigationUITests: XCTestCase {
    @MainActor
    func testPrimaryNavigationIsTodayVitoraCycleWithFaceCTA() {
        let app = launchPivotApp()

        XCTAssertTrue(app.buttons["tab.today"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tab.vitora"].exists)
        XCTAssertTrue(app.buttons["tab.cycle"].exists)
        XCTAssertTrue(app.otherElements["tab.vitora.face"].exists)
        XCTAssertFalse(app.buttons["tab.luna"].exists)
    }

    @MainActor
    private func launchPivotApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-vitoraUITestCompletedOnboarding",
            "-vitoraUITestRichToday",
        ]
        app.launch()
        return app
    }
}

