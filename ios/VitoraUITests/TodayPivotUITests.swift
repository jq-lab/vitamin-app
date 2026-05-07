import XCTest

final class TodayPivotUITests: XCTestCase {
    @MainActor
    func testTodayUsesStateFactorsSuggestionWithoutStandaloneRecordSection() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["today.status.card"].exists)
        XCTAssertTrue(app.staticTexts["身体要素"].exists)
        XCTAssertTrue(app.buttons["today.bodyFactors.card"].exists)
        XCTAssertTrue(app.staticTexts["Vitora 今日建议"].exists)
        XCTAssertTrue(app.buttons["today.suggestion.card"].exists)
        XCTAssertFalse(app.staticTexts["今日记录"].exists)
        XCTAssertFalse(app.staticTexts["AI管家已生成今日建议"].exists)
    }

    @MainActor
    func testTodayCalendarIsTopEntry() {
        let app = launchPivotApp()

        app.buttons["today.top.context"].tap()
        XCTAssertTrue(app.staticTexts["周期日历"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["周期日历"].exists)
        XCTAssertTrue(app.staticTexts["Vitora 今日建议已参考黄体期和睡眠变化。"].exists)
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
