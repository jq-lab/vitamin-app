import XCTest

final class CyclePivotUITests: XCTestCase {
    @MainActor
    func testCycleHomeIsLongHorizonRhythmAndEnergyDynamics() {
        let app = launchPivotApp()

        app.buttons["tab.cycle"].tap()

        XCTAssertTrue(app.otherElements["cycle.pivot.surface"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["cycle.phase.card"].exists)
        XCTAssertTrue(app.buttons["cycle.energy.card"].exists)
        XCTAssertTrue(app.buttons["cycle.settings.open"].exists)
        XCTAssertFalse(app.staticTexts["周期日历"].exists)
    }

    @MainActor
    func testCycleEnergyDetailShowsTrendExploration() {
        let app = launchPivotApp()

        app.buttons["tab.cycle"].tap()
        app.buttons["cycle.energy.card"].tap()

        XCTAssertTrue(app.staticTexts["能量动态"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["本周平均 62% · 较上周 ↑5%"].exists)
        XCTAssertTrue(app.staticTexts["Vitora 本周看到"].exists)
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
