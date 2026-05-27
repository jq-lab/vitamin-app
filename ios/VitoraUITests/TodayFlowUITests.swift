import XCTest

final class TodayFlowUITests: XCTestCase {
    @MainActor
    func testTodayLowDataFirstOpenShowsStateAndNextStep() {
        let app = launchCompletedOnboarding(lowData: true)

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["低数据模式"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.cycle.phase.strip"].exists)
        XCTAssertTrue(app.staticTexts["智能监测"].exists)
        XCTAssertTrue(app.staticTexts["下午更容易掉电，先补给再安排一段安静恢复。"].exists)
        XCTAssertTrue(app.buttons["today.status.card"].exists)
    }

    @MainActor
    func testEnergyBowlDataReplacesPullEnergyReveal() {
        let app = launchCompletedOnboarding(lowData: true)

        XCTAssertTrue(app.otherElements["today.energy.bowl"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["today.energy.score"].exists)
        XCTAssertTrue(app.staticTexts["能量低"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.cycle.phase.strip"].exists)
        XCTAssertFalse(app.staticTexts["排卵期"].exists)
        XCTAssertFalse(app.staticTexts["月经期"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["today.analysis.signal.chips"].exists)
        XCTAssertFalse(app.staticTexts["实时预测"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["today.realtime.chart"].exists)
        XCTAssertTrue(app.buttons["today.evidence.open"].exists)
        XCTAssertTrue(app.staticTexts["查看数据"].exists)
        XCTAssertFalse(app.buttons["查看依据"].exists)
        XCTAssertFalse(app.staticTexts["轻轻下拉，可以随时查看今日能量球"].exists)

        app.buttons["today.evidence.open"].tap()
        XCTAssertTrue(app.otherElements["today.analysis.sheet"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["今日分析"].exists)
        XCTAssertTrue(app.staticTexts["黄体期 Day 18"].exists)
        XCTAssertTrue(app.staticTexts["综合实时预测"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.realtime.chart"].exists)
        XCTAssertTrue(app.staticTexts["晚上睡眠"].exists)
        XCTAssertTrue(app.staticTexts["7.2h"].exists)
        XCTAssertTrue(app.staticTexts["HRV"].exists)
        XCTAssertTrue(app.staticTexts["48ms · ↓8%"].exists)
        XCTAssertTrue(app.staticTexts["今天周期"].exists)
        XCTAssertTrue(app.staticTexts["黄体期 D18"].exists)
        XCTAssertTrue(app.staticTexts["今日推荐"].exists)
        app.buttons["today.analysis.close"].tap()
        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testTodayAnalysisSheetShowsUsefulSummaryForRichData() {
        let app = launchCompletedOnboarding(lowData: false)

        app.buttons["today.evidence.open"].tap()

        XCTAssertTrue(app.staticTexts["今日分析"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.otherElements["today.score.card"].exists)
        XCTAssertTrue(app.staticTexts["黄体期 Day 18"].exists)
        XCTAssertTrue(app.staticTexts["68"].exists)
        XCTAssertTrue(app.staticTexts["为什么是这个分数"].exists)
        XCTAssertTrue(app.staticTexts["关键监测项"].exists)
        XCTAssertTrue(app.staticTexts["今日推荐"].exists)
        XCTAssertTrue(app.buttons["today.analysis.close"].exists)
        XCTAssertFalse(app.staticTexts["高级分析"].exists)
    }

    @MainActor
    func testSmartMonitorTabsSwitchBetweenPushAndLog() {
        let app = launchCompletedOnboarding(lowData: false, focusSmartMonitor: true)

        XCTAssertTrue(app.otherElements["today.suggestion.combination.card"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["today.suggestion.push.pane"].exists)

        app.buttons["today.suggestion.log"].tap()
        XCTAssertTrue(app.otherElements["today.suggestion.cycleLog.pane"].waitForExistence(timeout: 2))

        app.buttons["today.suggestion.push"].tap()
        XCTAssertTrue(app.otherElements["today.suggestion.push.pane"].waitForExistence(timeout: 2))
    }

    @MainActor
    private func launchCompletedOnboarding(lowData: Bool, focusSmartMonitor: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-vitoraUITestCompletedOnboarding",
            lowData ? "-vitoraUITestLowDataToday" : "-vitoraUITestRichToday",
        ]
        if focusSmartMonitor {
            app.launchArguments.append("-vitoraUITestFocusSmartMonitor")
        }
        app.launch()
        return app
    }
}
