import XCTest

final class TodayFlowUITests: XCTestCase {
    @MainActor
    func testTodayLowDataFirstOpenShowsStateAndNextStep() {
        let app = launchCompletedOnboarding(lowData: true)

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["低数据模式"].exists)
        XCTAssertTrue(app.staticTexts["身体要素"].exists)
        XCTAssertTrue(app.staticTexts["Vitora 今日建议"].exists)
        XCTAssertTrue(app.buttons["today.status.card"].exists)
    }

    @MainActor
    func testEnergyRitualCanCompleteOrSkipWithoutBlockingToday() {
        let app = launchCompletedOnboarding(lowData: true)

        app.swipeDown()
        XCTAssertTrue(app.otherElements["today.energy.reveal.header"].waitForExistence(timeout: 3))
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testTodayAnalysisSheetShowsUsefulSummaryForRichData() {
        let app = launchCompletedOnboarding(lowData: false)

        app.buttons["today.suggestion.try"].tap()

        XCTAssertTrue(app.staticTexts["今日分析"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["关键支撑"].exists)
        XCTAssertTrue(app.staticTexts["今天可以轻轻试"].exists)
        XCTAssertTrue(app.buttons["today.analysis.close"].exists)
        XCTAssertFalse(app.staticTexts["高级分析"].exists)
    }

    @MainActor
    private func launchCompletedOnboarding(lowData: Bool) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-vitoraUITestCompletedOnboarding",
            lowData ? "-vitoraUITestLowDataToday" : "-vitoraUITestRichToday",
        ]
        app.launch()
        return app
    }
}
