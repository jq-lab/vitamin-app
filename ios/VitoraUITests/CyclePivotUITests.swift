import XCTest

final class CyclePivotUITests: XCTestCase {
    @MainActor
    func testCycleHomeIsLongHorizonRhythmAndEnergyDynamics() {
        let app = launchPivotApp()

        app.buttons["tab.cycle"].tap()

        XCTAssertTrue(app.otherElements["cycle.pivot.surface"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["周期回顾"].exists)
        XCTAssertTrue(app.staticTexts["复盘成长 · 洞察规律"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["cycle.review.insights"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["cycle.growth.album"].exists)
        XCTAssertFalse(app.staticTexts["30 天成长册"].exists)
        XCTAssertFalse(app.staticTexts["成长册已更新 5月8日 的理解"].exists)
        XCTAssertTrue(app.staticTexts["这 30 天，Vitora 看见的三件事"].exists)
        XCTAssertTrue(app.buttons["cycle.review.tab.week"].exists)
        XCTAssertTrue(app.buttons["cycle.review.tab.trend"].exists)
        XCTAssertTrue(app.buttons["cycle.review.tab.cycle"].exists)
        XCTAssertTrue(app.staticTexts["低谷集中窗口"].exists)
        XCTAssertTrue(app.staticTexts["14:00-16:00"].exists)
        app.buttons["cycle.review.tab.trend"].tap()
        XCTAssertTrue(app.staticTexts["月内低谷"].waitForExistence(timeout: 2))
        app.buttons["cycle.review.tab.cycle"].tap()
        XCTAssertTrue(app.staticTexts["当前阶段"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["cycle.energy.card"].exists)
        XCTAssertTrue(app.buttons["cycle.insight.tab.regularity"].exists)
        XCTAssertTrue(app.buttons["cycle.insight.tab.support"].exists)
        XCTAssertTrue(app.buttons["cycle.insight.tab.adjustment"].exists)
        app.buttons["cycle.insight.tab.support"].tap()
        XCTAssertTrue(app.staticTexts["轻量运动"].waitForExistence(timeout: 2))
        if !app.buttons["cycle.insight.open"].exists {
            app.swipeDown()
        }
        app.buttons["cycle.insight.open"].tap()
        XCTAssertTrue(app.otherElements["cycle.insight.detail.sheet"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["今天怎么联动"].exists)
        app.buttons["关闭"].tap()
        XCTAssertTrue(app.buttons["cycle.settings.open"].exists)
        XCTAssertTrue(app.buttons["cycle.share.open"].exists)
        app.buttons["cycle.settings.open"].tap()
        XCTAssertTrue(app.otherElements["support.settings.panel"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["我的"].exists)
        app.buttons["support.close"].tap()
        XCTAssertFalse(app.staticTexts["周期日历"].exists)
        XCTAssertFalse(app.staticTexts["当前周期阶段与今天"].exists)
    }

    @MainActor
    func testCycleShareButtonPresentsNativeShareSheet() {
        let app = launchPivotApp()

        app.buttons["tab.cycle"].tap()
        XCTAssertTrue(app.buttons["cycle.share.open"].waitForExistence(timeout: 5))
        app.buttons["cycle.share.open"].tap()

        let identifiedSheet = app.otherElements["cycle.share.sheet"]
        let nativeSheet = app.sheets.firstMatch
        XCTAssertTrue(
            identifiedSheet.waitForExistence(timeout: 3) || nativeSheet.waitForExistence(timeout: 3),
            "Cycle share should present the native iOS share sheet."
        )
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
