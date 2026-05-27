import XCTest

final class TodayPivotUITests: XCTestCase {
    @MainActor
    func testTodayUnifiedOrbitDefaultState() {
        let app = launchPivotApp()

        XCTAssertTrue(app.buttons["today.status.card"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["today.pixel.egg"].exists)
        XCTAssertTrue(app.buttons["today.unifiedOrbit.energy"].exists)
        XCTAssertTrue(app.buttons["today.unifiedOrbit.sleep"].exists)
        XCTAssertTrue(app.buttons["today.unifiedOrbit.period"].exists)
        XCTAssertTrue(app.buttons["today.unifiedOrbit.nutrition"].exists)
        XCTAssertTrue(app.buttons["today.unifiedOrbit.quickRecord"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.unifiedOrbit.cycleArc"].exists)
        XCTAssertTrue(app.staticTexts["68"].exists)
        XCTAssertTrue(app.staticTexts["/100"].exists)
        XCTAssertTrue(app.staticTexts["查看分析"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.insight.panel.energy"].exists)

        XCTAssertFalse(app.descendants(matching: .any)["today.cycle.smile.arc"].exists)
        XCTAssertFalse(app.staticTexts["排卵期"].exists)
        XCTAssertFalse(app.staticTexts["月经期"].exists)
        XCTAssertFalse(app.buttons["today.hero.quickRecord"].exists)
        XCTAssertFalse(app.buttons["today.topic.energy"].exists)
        XCTAssertFalse(app.buttons["today.metric.mode.energy"].exists)
        XCTAssertFalse(app.staticTexts["Luna"].exists)
        XCTAssertFalse(app.staticTexts["完成率"].exists)
        XCTAssertFalse(app.staticTexts["连续天数"].exists)
    }

    @MainActor
    func testTodayUnifiedOrbitTopicExpansionSwitchesInsightPanel() {
        let app = launchPivotApp()

        XCTAssertTrue(app.buttons["today.unifiedOrbit.energy"].waitForExistence(timeout: 5))
        app.buttons["today.unifiedOrbit.energy"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["today.insight.panel.energy"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["今日能量"].exists)
        XCTAssertTrue(app.staticTexts["恢复"].exists)
        XCTAssertTrue(app.staticTexts["燃料"].exists)

        app.buttons["today.unifiedOrbit.sleep"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["today.insight.panel.sleep"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["睡眠"].exists)
        XCTAssertTrue(app.staticTexts["7.2h"].exists)

        app.buttons["today.unifiedOrbit.period"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["today.insight.panel.period"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["经期"].exists)
        XCTAssertTrue(app.staticTexts["D18"].exists)
        XCTAssertTrue(app.staticTexts["阶段解释"].exists)

        app.buttons["today.unifiedOrbit.nutrition"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["today.insight.panel.nutrition"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["营养"].exists)
        XCTAssertTrue(app.staticTexts["水 5/8"].exists)
        XCTAssertTrue(app.buttons["today.unifiedOrbit.quickRecord"].exists)
    }

    @MainActor
    func testUnifiedOrbitQuickRecordUsesCurrentExpandedTopicAndDoesNotBecomeCloseButton() {
        let app = launchPivotApp()

        XCTAssertTrue(app.buttons["today.unifiedOrbit.sleep"].waitForExistence(timeout: 5))
        app.buttons["today.unifiedOrbit.sleep"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["today.insight.panel.sleep"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["today.unifiedOrbit.quickRecord"].exists)
        XCTAssertFalse(app.buttons["today.unifiedOrbit.quickRecord"].label.contains("关闭"))

        app.buttons["today.unifiedOrbit.quickRecord"].tap()
        XCTAssertTrue(app.staticTexts["告诉 Vitora"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["来源：睡眠记录"].exists)
        XCTAssertFalse(app.otherElements["global.vitora.dock"].exists)
        XCTAssertEqual(app.buttons["vitora.record.mode.manual"].value as? String, "已选择")
        XCTAssertTrue(app.buttons["vitora.record.category.symptom"].exists)
    }

    @MainActor
    func testEnergyInsightWhyExpandsReasonsAndReminder() {
        let app = launchPivotApp()

        XCTAssertTrue(app.buttons["today.insight.why"].waitForExistence(timeout: 5))
        app.buttons["today.insight.why"].tap()

        XCTAssertTrue(app.staticTexts["昨夜恢复只到 65，午后更容易出现低谷。"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["HRV 比平时低 8%，今天更适合降低刺激。"].exists)
        XCTAssertTrue(app.staticTexts["建议：先补水和已在使用的镁；如果 14:00 后仍明显掉电，安排 15 分钟安静恢复。"].exists)
        XCTAssertTrue(app.buttons["today.insight.reminder"].exists)
    }

    @MainActor
    func testTodayStatusCardOpensUnifiedAnalysis() {
        let app = launchPivotApp()

        XCTAssertTrue(app.buttons["today.status.card"].waitForExistence(timeout: 5))
        app.buttons["today.status.card"].tap()
        XCTAssertTrue(app.otherElements["today.analysis.sheet"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["今日分析"].exists)
        XCTAssertTrue(app.staticTexts["黄体期 Day 18"].exists)
        XCTAssertTrue(app.staticTexts["关键监测项"].exists)
    }

    @MainActor
    func testTodayCalendarIsTopEntry() {
        let app = launchPivotApp()

        app.buttons["today.top.context"].tap()
        XCTAssertTrue(app.staticTexts["周期日历"].waitForExistence(timeout: 3))
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
