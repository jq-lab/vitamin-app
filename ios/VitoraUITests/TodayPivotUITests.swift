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
        XCTAssertTrue(app.staticTexts["查看数据"].exists)
        XCTAssertGreaterThan(app.buttons["today.evidence.open"].frame.midY, app.staticTexts["能量低"].frame.maxY)
        XCTAssertGreaterThan(app.buttons["today.evidence.open"].frame.midX, app.descendants(matching: .any)["today.energy.score"].frame.midX)
        XCTAssertFalse(app.staticTexts["综合能量用于判断今天适合轻安排还是高强度任务，不是医学预测。"].exists)
        XCTAssertFalse(app.buttons["查看依据"].exists)
        XCTAssertFalse(app.buttons["today.calibration.tell"].exists)
        XCTAssertFalse(app.staticTexts["睡得浅"].exists)
        XCTAssertFalse(app.staticTexts["压力大"].exists)
        XCTAssertFalse(app.staticTexts["辅助你安排今天的轻重节奏，不是医学预测。"].exists)
        XCTAssertFalse(app.staticTexts["趋势辅助预览"].exists)
        XCTAssertFalse(app.staticTexts["轻轻下拉，可以随时查看今日能量球"].exists)
        XCTAssertTrue(app.staticTexts["智能监测"].exists)
        XCTAssertTrue(app.staticTexts["身体翻译器正在整理管家方案"].exists)
        XCTAssertFalse(app.buttons["today.growth.feedback"].exists)
        XCTAssertTrue(app.buttons["today.suggestion.card"].exists)
        XCTAssertTrue(app.staticTexts["身体翻译器"].exists)
        XCTAssertTrue(app.staticTexts["正在把今天翻译成管家方案"].exists)
        XCTAssertFalse(app.otherElements["today.openness.panel"].exists)
        XCTAssertFalse(app.staticTexts["开放状态 86 / 100"].exists)
        XCTAssertFalse(app.staticTexts["组合推荐"].exists)
        XCTAssertTrue(app.staticTexts["今日推送"].exists)
        XCTAssertTrue(app.staticTexts["周期建议"].exists)
        XCTAssertTrue(app.staticTexts["午后留余量"].exists)
        XCTAssertTrue(app.staticTexts["黄体期 D18"].exists)
        XCTAssertFalse(app.staticTexts["休息 + 补剂"].exists)
        XCTAssertFalse(app.staticTexts["推荐组合"].exists)
        XCTAssertTrue(app.staticTexts["蛋白"].exists)
        XCTAssertTrue(app.staticTexts["恢复20分钟"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["today.suggestion.checkmark.0"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["today.suggestion.checkmark.1"].exists)
        XCTAssertFalse(app.buttons["today.suggestion.try"].exists)
        XCTAssertTrue(app.buttons["today.suggestion.swap"].exists)
        XCTAssertTrue(app.otherElements["today.suggestion.combination.card"].exists)
        XCTAssertFalse(app.otherElements["today.suggestion.dynamic.sources"].exists)
        XCTAssertFalse(app.buttons["today.suggestion.detail"].exists)
        XCTAssertFalse(app.buttons["为什么"].exists)
        XCTAssertFalse(app.otherElements["today.monthly.lightPlan"].exists)
        XCTAssertFalse(app.buttons["today.bodyFactors.card"].exists)
        XCTAssertFalse(app.staticTexts["今日记录"].exists)
        XCTAssertFalse(app.staticTexts["AI管家已生成今日建议"].exists)
    }

    @MainActor
    func testTodaySuggestionSwapCyclesCombinationPlans() {
        let app = launchPivotApp(extraArguments: ["-vitoraUITestFocusSmartMonitor"])

        XCTAssertTrue(app.staticTexts["今日推送"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["蛋白"].exists)
        XCTAssertTrue(app.staticTexts["午后留余量"].exists)

        app.buttons["today.suggestion.swap"].tap()
        XCTAssertTrue(app.staticTexts["轻走10分钟"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["轻走10分钟"].exists)
        XCTAssertTrue(app.staticTexts["轻动窗口"].exists)
        XCTAssertFalse(app.staticTexts["午后留余量"].exists)

        app.buttons["today.suggestion.swap"].tap()
        XCTAssertTrue(app.staticTexts["闭眼8分钟"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["闭眼8分钟"].exists)
        XCTAssertTrue(app.staticTexts["恢复优先"].exists)

        app.buttons["today.suggestion.swap"].tap()
        XCTAssertTrue(app.staticTexts["午后留余量"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testTodayReminderSheetUsesClearLabelsAndSelectableTimes() {
        let app = launchPivotApp(extraArguments: ["-vitoraUITestFocusSmartMonitor"])

        XCTAssertTrue(app.buttons["today.suggestion.remind"].waitForExistence(timeout: 5))
        app.buttons["today.suggestion.remind"].tap()

        XCTAssertTrue(app.staticTexts["设置提醒"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["午间补能"].exists)
        XCTAssertTrue(app.staticTexts["智能提醒"].exists)
        XCTAssertTrue(app.staticTexts["13:20 加一份蛋白"].exists)
        XCTAssertTrue(app.staticTexts["14:40 安静恢复 20 分钟"].exists)
        XCTAssertTrue(app.staticTexts["（睡眠7.2h / HRV↓8 / 黄体D18；低谷前先补上蛋白，给下午留余量。）"].exists)
        XCTAssertTrue(app.buttons["today.reminder.select.0"].exists)
        XCTAssertTrue(app.buttons["today.reminder.select.1"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.reminder.timeStepper.0"].exists)
        XCTAssertTrue(app.buttons["today.reminder.save"].exists)
        XCTAssertTrue(app.staticTexts["保存智能提醒"].exists)

        app.buttons["today.reminder.select.1"].tap()
        XCTAssertTrue(app.buttons["today.reminder.save"].exists)
    }

    @MainActor
    func testEnergyBowlTapAndDataButtonOpenAnalysis() {
        let app = launchPivotApp()

        XCTAssertTrue(app.buttons["today.status.card"].waitForExistence(timeout: 5))
        app.buttons["today.status.card"].tap()
        XCTAssertTrue(app.otherElements["today.analysis.sheet"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["黄体期 Day 18"].exists)
        XCTAssertTrue(app.staticTexts["今日能量"].exists)
        XCTAssertTrue(app.staticTexts["68"].exists)
        XCTAssertTrue(app.staticTexts["关键监测项"].exists)
        app.buttons["today.analysis.close"].tap()

        XCTAssertTrue(app.buttons["today.evidence.open"].waitForExistence(timeout: 3))
        app.buttons["today.evidence.open"].tap()
        XCTAssertTrue(app.otherElements["today.analysis.sheet"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["今日分析"].exists)
        XCTAssertTrue(app.staticTexts["黄体期 Day 18"].exists)
        XCTAssertTrue(app.otherElements["today.analysis.realtime.section"].exists)
        XCTAssertTrue(app.staticTexts["综合实时预测"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.realtime.chart"].exists)
        XCTAssertTrue(app.staticTexts["14:00 · 能量低谷"].exists)
        XCTAssertTrue(app.staticTexts["晚上睡眠"].exists)
        XCTAssertTrue(app.staticTexts["7.2h"].exists)
        XCTAssertTrue(app.staticTexts["HRV"].exists)
        XCTAssertTrue(app.staticTexts["48ms · ↓8%"].exists)
        XCTAssertTrue(app.staticTexts["今天周期"].exists)
        XCTAssertTrue(app.staticTexts["黄体期 D18"].exists)
        XCTAssertTrue(app.staticTexts["今日推荐"].exists)
        XCTAssertTrue(app.buttons["today.analysis.share"].exists)
        XCTAssertTrue(app.buttons["today.analysis.save"].exists)
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
    private func launchPivotApp(extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-vitoraUITestCompletedOnboarding",
            "-vitoraUITestRichToday",
        ]
        app.launchArguments += extraArguments
        app.launch()
        return app
    }
}
