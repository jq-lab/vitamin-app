import XCTest

final class TodayPivotUITests: XCTestCase {
    @MainActor
    func testTodayUsesEnergyBowlModesSuggestionWithoutStandaloneRecordSection() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["today.status.card"].exists)
        XCTAssertTrue(app.otherElements["today.energy.bowl"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.energy.score"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.energy.water.level"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.energy.intake.animation"].exists)
        XCTAssertTrue(app.staticTexts["能量低"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.cycle.phase.strip"].exists)
        XCTAssertTrue(app.staticTexts["排卵期"].exists)
        XCTAssertTrue(app.staticTexts["黄体期 D18"].exists)
        XCTAssertTrue(app.staticTexts["月经期"].exists)
        XCTAssertFalse(app.staticTexts["卵泡期"].exists)
        XCTAssertFalse(app.staticTexts["黄体期稳稳输出，补镁和蛋白"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["today.analysis.signal.chips"].exists)
        XCTAssertFalse(app.buttons["today.metric.mode.energy"].exists)
        XCTAssertFalse(app.buttons["today.metric.mode.sleepHRV"].exists)
        XCTAssertFalse(app.buttons["today.metric.mode.cycle"].exists)
        XCTAssertFalse(app.buttons["today.metric.mode.heartCycle"].exists)
        XCTAssertFalse(app.buttons["today.metric.mode.hrv"].exists)
        XCTAssertFalse(app.staticTexts["实时预测"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["today.realtime.chart"].exists)
        XCTAssertTrue(app.buttons["today.evidence.open"].exists)
        XCTAssertTrue(app.buttons["查看分析"].exists)
        XCTAssertGreaterThan(app.buttons["today.evidence.open"].frame.midY, app.staticTexts["能量低"].frame.maxY)
        XCTAssertLessThan(abs(app.buttons["today.evidence.open"].frame.midX - app.descendants(matching: .any)["today.energy.score"].frame.midX), 52)
        XCTAssertFalse(app.staticTexts["综合能量用于判断今天适合轻安排还是高强度任务，不是医学预测。"].exists)
        XCTAssertFalse(app.buttons["查看依据"].exists)
        XCTAssertFalse(app.buttons["today.calibration.tell"].exists)
        XCTAssertFalse(app.staticTexts["睡得浅"].exists)
        XCTAssertFalse(app.staticTexts["压力大"].exists)
        XCTAssertFalse(app.staticTexts["辅助你安排今天的轻重节奏，不是医学预测。"].exists)
        XCTAssertFalse(app.staticTexts["趋势辅助预览"].exists)
        XCTAssertFalse(app.staticTexts["轻轻下拉，可以随时查看今日能量球"].exists)
        XCTAssertTrue(app.staticTexts["Vitora 今日建议"].exists)
        XCTAssertFalse(app.buttons["today.growth.feedback"].exists)
        XCTAssertFalse(app.buttons["today.garden.manual.entry"].exists)
        XCTAssertFalse(app.staticTexts["花园手册"].exists)
        XCTAssertFalse(app.staticTexts["昨晚的薄荷芽发芽了"].exists)
        XCTAssertTrue(app.buttons["today.suggestion.card"].exists)
        XCTAssertTrue(app.staticTexts["睡眠偏短，HRV 还在恢复，下午更容易掉电。"].exists)
        XCTAssertTrue(app.staticTexts["监测到"].exists)
        XCTAssertFalse(app.staticTexts["昨晚种子状态：半开"].exists)
        XCTAssertFalse(app.otherElements["today.sleepSeed.card"].exists)
        XCTAssertFalse(app.staticTexts["睡眠偏短，HRV 仍在恢复"].exists)
        XCTAssertFalse(app.staticTexts["下午只保留一件高负担事情"].exists)
        XCTAssertTrue(app.staticTexts["睡眠偏短，HRV 还在恢复，下午更容易掉电。"].exists)
        XCTAssertTrue(app.staticTexts["监测到"].exists)
        XCTAssertTrue(app.staticTexts["睡眠 7.2h"].exists)
        XCTAssertTrue(app.staticTexts["HRV ↓8%"].exists)
        XCTAssertTrue(app.staticTexts["黄体期 D18"].exists)
        XCTAssertTrue(app.staticTexts["吃 + 休息"].exists)
        XCTAssertTrue(app.staticTexts["13:30 前加一份蛋白"].exists)
        XCTAssertTrue(app.staticTexts["午后留 20 分钟安静恢复"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.suggestion.checkmark.0"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.suggestion.checkmark.1"].exists)
        XCTAssertTrue(app.buttons["today.suggestion.try"].exists)
        XCTAssertTrue(app.buttons["today.suggestion.swap"].exists)
        XCTAssertFalse(app.buttons["today.suggestion.detail"].exists)
        XCTAssertFalse(app.buttons["为什么"].exists)
        XCTAssertFalse(app.otherElements["today.monthly.lightPlan"].exists)
        XCTAssertFalse(app.buttons["today.bodyFactors.card"].exists)
        XCTAssertFalse(app.staticTexts["今日记录"].exists)
        XCTAssertFalse(app.staticTexts["AI管家已生成今日建议"].exists)
    }

    @MainActor
    func testTodaySuggestionSwapCyclesCombinationPlans() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["吃 + 休息"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["13:30 前加一份蛋白"].exists)

        app.buttons["today.suggestion.swap"].tap()
        XCTAssertTrue(app.staticTexts["运动 + 吃"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["下午轻走 10 分钟"].exists)
        XCTAssertFalse(app.staticTexts["吃 + 休息"].exists)

        app.buttons["today.suggestion.swap"].tap()
        XCTAssertTrue(app.staticTexts["休息 + 运动"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["先闭眼恢复 8 分钟"].exists)

        app.buttons["today.suggestion.swap"].tap()
        XCTAssertTrue(app.staticTexts["吃 + 休息"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testEnergyBowlTapAndDataButtonOpenAnalysis() {
        let app = launchPivotApp()

        XCTAssertTrue(app.buttons["today.status.card"].waitForExistence(timeout: 5))
        app.buttons["today.status.card"].tap()
        XCTAssertTrue(app.otherElements["today.state.detail.sheet"].waitForExistence(timeout: 3))
        app.buttons["关闭"].tap()

        XCTAssertTrue(app.buttons["today.evidence.open"].waitForExistence(timeout: 3))
        app.buttons["today.evidence.open"].tap()
        XCTAssertTrue(app.otherElements["today.bodyFactors.detail.sheet"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["今日分析"].exists)
        XCTAssertTrue(app.staticTexts["综合能量68%"].exists)
        XCTAssertTrue(app.staticTexts["低谷14:00"].exists)
        XCTAssertTrue(app.staticTexts["负担偏轻"].exists)
        XCTAssertTrue(app.otherElements["today.analysis.realtime.section"].exists)
        XCTAssertTrue(app.staticTexts["综合实时预测"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.realtime.chart"].exists)
        XCTAssertTrue(app.staticTexts["14:00 · 能量低谷"].exists)
        XCTAssertTrue(app.staticTexts["睡眠"].exists)
        XCTAssertTrue(app.staticTexts["7.2h"].exists)
        XCTAssertTrue(app.staticTexts["HRV"].exists)
        XCTAssertTrue(app.staticTexts["48ms"].exists)
        XCTAssertTrue(app.staticTexts["心率"].exists)
        XCTAssertTrue(app.staticTexts["72bpm"].exists)
        XCTAssertTrue(app.staticTexts["周期"].exists)
        XCTAssertTrue(app.staticTexts["D18"].exists)
        XCTAssertTrue(app.staticTexts["综合判断"].exists)
    }

    @MainActor
    func testTodayHomeKeepsSingleEnergyContext() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["黄体期中段 · 今天适合留余量"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["能量低"].exists)
        XCTAssertFalse(app.staticTexts["综合能量 68% · 低谷 14:00"].exists)
        XCTAssertFalse(app.staticTexts["正在看：综合能量"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["today.analysis.signal.chips"].exists)
        XCTAssertFalse(app.buttons["today.metric.mode.energy"].exists)
        XCTAssertFalse(app.buttons["today.metric.mode.sleepHRV"].exists)
        XCTAssertFalse(app.buttons["today.metric.mode.cycle"].exists)
        XCTAssertFalse(app.buttons["today.metric.mode.heartCycle"].exists)
        XCTAssertFalse(app.buttons["today.metric.mode.hrv"].exists)
    }

    @MainActor
    func testTodayCalendarIsTopEntry() {
        let app = launchPivotApp()

        app.buttons["today.top.context"].tap()
        XCTAssertTrue(app.staticTexts["周期日历"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["周期日历"].exists)
        XCTAssertTrue(app.staticTexts["返回 Today 后，背景会跟随当前周期阶段轻柔变色。"].exists)
        app.buttons["today.calendar.day.16"].tap()
        XCTAssertTrue(app.staticTexts["选中：5月16日 · 月经期 Day 1"].exists)
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
