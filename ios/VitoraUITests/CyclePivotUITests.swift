import XCTest

final class CyclePivotUITests: XCTestCase {
    @MainActor
    func testCycleHomeShowsEnergyCalendarMetricAndBottomReportTabs() {
        let app = launchPivotApp()

        app.buttons["tab.cycle"].tap()

        XCTAssertTrue(app.otherElements["cycle.pivot.surface"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["cycle.energyDashboard.frame"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["cycle.energyCalendar.card"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["cycle.energyCalendar.strip"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["cycle.energyMetric.card"].exists)
        XCTAssertTrue(app.staticTexts["6.5"].exists)
        XCTAssertTrue(app.buttons["cycle.review.tab.week"].exists)
        XCTAssertTrue(app.buttons["cycle.review.tab.trend"].exists)
        XCTAssertTrue(app.buttons["cycle.review.tab.recent"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["cycle.review.insights"].exists)
        XCTAssertTrue(app.staticTexts["本周复盘"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["cycle.flowerMap"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["cycle.mapReport.frame"].exists)
        XCTAssertFalse(app.staticTexts["周期回顾"].exists)
        XCTAssertFalse(app.staticTexts["复盘成长 · 洞察规律"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["cycle.growth.album"].exists)
        XCTAssertFalse(app.staticTexts["30 天成长册"].exists)
        XCTAssertFalse(app.staticTexts["手册"].exists)
        XCTAssertFalse(app.staticTexts["还差 12 格"].exists)
        XCTAssertFalse(app.buttons["cycle.energy.card"].exists)
        XCTAssertFalse(app.buttons["cycle.insight.tab.regularity"].exists)
        XCTAssertTrue(app.buttons["cycle.settings.open"].exists)
        XCTAssertTrue(app.buttons["cycle.share.open"].exists)

        app.buttons["cycle.review.tab.trend"].tap()
        XCTAssertTrue(app.staticTexts["月度综合对比"].waitForExistence(timeout: 2))
        app.buttons["cycle.review.tab.recent"].tap()
        XCTAssertTrue(app.staticTexts["近期能量"].waitForExistence(timeout: 2))

        app.buttons["cycle.settings.open"].tap()
        XCTAssertTrue(app.otherElements["support.settings.panel"].waitForExistence(timeout: 3))
        app.buttons["support.close"].tap()
        XCTAssertFalse(app.staticTexts["周期日历"].exists)
        XCTAssertFalse(app.staticTexts["当前周期阶段与今天"].exists)
    }

    @MainActor
    func testEnergyCalendarExpandsAndKeepsReportTabsWorking() {
        let app = launchPivotApp()

        app.buttons["tab.cycle"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["cycle.energyCalendar.card"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.descendants(matching: .any)["cycle.energyCalendar.month"].exists)

        app.buttons["cycle.energyCalendar.toggle"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["cycle.energyCalendar.month"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["2026年5月"].exists)
        XCTAssertTrue(app.buttons["cycle.energyCalendar.month.day.15"].exists)
        app.buttons["cycle.energyCalendar.month.day.15"].tap()
        XCTAssertTrue(app.staticTexts["15日能量"].waitForExistence(timeout: 2))

        app.buttons["cycle.review.tab.week"].tap()
        XCTAssertTrue(app.staticTexts["本周复盘"].waitForExistence(timeout: 2))
        app.buttons["cycle.review.tab.trend"].tap()
        XCTAssertTrue(app.staticTexts["月度综合对比"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCycleShareButtonPresentsPreviewSheet() {
        let app = launchPivotApp()

        app.buttons["tab.cycle"].tap()
        XCTAssertTrue(app.buttons["cycle.share.open"].waitForExistence(timeout: 5))
        app.buttons["cycle.share.open"].tap()

        XCTAssertTrue(app.staticTexts["Vitora 分享卡片预览"].waitForExistence(timeout: 3))
        app.buttons["关闭预览"].tap()
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
