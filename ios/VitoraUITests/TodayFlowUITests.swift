import XCTest

final class TodayFlowUITests: XCTestCase {
    @MainActor
    func testTodayLowDataFirstOpenShowsStateAndNextStep() {
        let app = launchCompletedOnboarding(lowData: true)

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["低数据模式"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.cycle.phase.strip"].exists)
        XCTAssertTrue(app.staticTexts["Vitora 今日建议"].exists)
        XCTAssertTrue(app.staticTexts["睡眠偏短，HRV 还在恢复，下午更容易掉电。"].exists)
        XCTAssertTrue(app.buttons["today.status.card"].exists)
    }

    @MainActor
    func testEnergyBowlDataReplacesPullEnergyReveal() {
        let app = launchCompletedOnboarding(lowData: true)

        XCTAssertTrue(app.otherElements["today.energy.bowl"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["today.energy.score"].exists)
        XCTAssertTrue(app.staticTexts["能量低"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.cycle.phase.strip"].exists)
        XCTAssertTrue(app.staticTexts["排卵期"].exists)
        XCTAssertTrue(app.staticTexts["黄体期 D18"].exists)
        XCTAssertTrue(app.staticTexts["月经期"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["today.analysis.signal.chips"].exists)
        XCTAssertFalse(app.staticTexts["实时预测"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["today.realtime.chart"].exists)
        XCTAssertTrue(app.buttons["today.evidence.open"].exists)
        XCTAssertTrue(app.staticTexts["查看数据"].exists)
        XCTAssertFalse(app.buttons["查看依据"].exists)
        XCTAssertFalse(app.staticTexts["轻轻下拉，可以随时查看今日能量球"].exists)

        app.buttons["today.evidence.open"].tap()
        XCTAssertTrue(app.otherElements["today.bodyFactors.detail.sheet"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["今日分析"].exists)
        XCTAssertTrue(app.staticTexts["综合实时预测"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.realtime.chart"].exists)
        XCTAssertTrue(app.staticTexts["睡眠"].exists)
        XCTAssertTrue(app.staticTexts["7.2h"].exists)
        XCTAssertTrue(app.staticTexts["HRV"].exists)
        XCTAssertTrue(app.staticTexts["48ms"].exists)
        XCTAssertTrue(app.staticTexts["心率"].exists)
        XCTAssertTrue(app.staticTexts["72bpm"].exists)
        XCTAssertTrue(app.staticTexts["周期"].exists)
        XCTAssertTrue(app.staticTexts["D18"].exists)
        app.buttons["关闭"].tap()
        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testTodayAnalysisSheetShowsUsefulSummaryForRichData() {
        let app = launchCompletedOnboarding(lowData: false)

        app.buttons["today.suggestion.try"].tap()

        XCTAssertTrue(app.staticTexts["今日分析"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.otherElements["today.score.card"].exists)
        XCTAssertTrue(app.staticTexts["68"].exists)
        XCTAssertTrue(app.staticTexts["/ 100"].exists)
        XCTAssertTrue(app.staticTexts["为什么扣分"].exists)
        XCTAssertTrue(app.staticTexts["今天怎么补充"].exists)
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
