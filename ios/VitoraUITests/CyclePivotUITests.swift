import XCTest

final class CyclePivotUITests: XCTestCase {
    @MainActor
    func testCycleHomeShowsFlowerMapAndFolderReport() {
        let app = launchPivotApp()

        app.buttons["tab.cycle"].tap()

        XCTAssertTrue(app.otherElements["cycle.pivot.surface"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["cycle.mapReport.frame"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["cycle.flowerMap"].exists)
        XCTAssertTrue(app.buttons["cycle.review.tab.week"].exists)
        XCTAssertTrue(app.buttons["cycle.review.tab.trend"].exists)
        XCTAssertTrue(app.buttons["cycle.review.tab.recent"].exists)
        XCTAssertTrue(app.buttons["cycle.flowerMap.plantToday"].exists)
        XCTAssertTrue(app.buttons["cycle.flowerMap.remaining"].exists)
        XCTAssertTrue(app.buttons["cycle.flowerMap.handbook"].exists)
        XCTAssertTrue(app.staticTexts["24朵"].exists)
        XCTAssertFalse(app.staticTexts["还差 12 格"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["cycle.flowerMap.summary"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["cycle.flowerMap.progress.current"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["cycle.flowerMap.progress.next"].exists)
        XCTAssertFalse(app.staticTexts["手册"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["cycle.review.insights"].exists)
        XCTAssertFalse(app.staticTexts["周期回顾"].exists)
        XCTAssertFalse(app.staticTexts["复盘成长 · 洞察规律"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["cycle.growth.album"].exists)
        XCTAssertFalse(app.staticTexts["30 天成长册"].exists)
        XCTAssertFalse(app.staticTexts["成长册已更新 5月8日 的理解"].exists)
        XCTAssertFalse(app.staticTexts["这 30 天，Vitora 看见的三件事"].exists)
        XCTAssertTrue(app.staticTexts["本周复盘"].exists)
        XCTAssertTrue(app.staticTexts["影响来源分布"].exists)
        app.buttons["cycle.review.tab.trend"].tap()
        XCTAssertTrue(app.staticTexts["月度综合对比"].waitForExistence(timeout: 2))
        app.buttons["cycle.review.tab.recent"].tap()
        XCTAssertTrue(app.staticTexts["近期能量"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["cycle.energy.card"].exists)
        XCTAssertFalse(app.buttons["cycle.insight.tab.regularity"].exists)
        XCTAssertTrue(app.buttons["cycle.settings.open"].exists)
        XCTAssertTrue(app.buttons["cycle.share.open"].exists)
        app.buttons["cycle.settings.open"].tap()
        XCTAssertTrue(app.otherElements["support.settings.panel"].waitForExistence(timeout: 3))
        app.buttons["support.close"].tap()
        XCTAssertFalse(app.staticTexts["周期日历"].exists)
        XCTAssertFalse(app.staticTexts["当前周期阶段与今天"].exists)
    }

    @MainActor
    func testFlowerMapCoreInteractions() {
        let app = launchPivotApp()

        app.buttons["tab.cycle"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["cycle.flowerMap"].waitForExistence(timeout: 5))

        app.buttons["cycle.flowerMap.plantToday"].tap()
        XCTAssertTrue(app.staticTexts["今日已种下"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["cycle.flowerMap.remaining"].label.contains("11"))
        XCTAssertTrue(app.staticTexts["25朵"].waitForExistence(timeout: 2))

        app.buttons["cycle.flowerMap.city.next"].tap()
        XCTAssertTrue(app.staticTexts["广州"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["下一站还未解锁"].exists)

        app.buttons["cycle.flowerMap.city.current"].tap()
        XCTAssertTrue(app.staticTexts["深圳"].waitForExistence(timeout: 2))

        app.buttons["cycle.review.tab.trend"].tap()
        XCTAssertTrue(app.staticTexts["月度综合对比"].waitForExistence(timeout: 2))
        app.buttons["cycle.review.tab.week"].tap()
        XCTAssertTrue(app.staticTexts["本周复盘"].waitForExistence(timeout: 2))

        app.buttons["cycle.flowerMap.handbook"].tap()
        XCTAssertTrue(app.staticTexts["花朵说明"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testFlowerMapPlantedCountLaunchStates() {
        for count in [0, 8, 24, 36] {
            let app = launchPivotApp(extraArguments: [
                "-vitoraUITestInitialTabCycle",
                "-vitoraUITestCycleFlowerMapPlantedCount",
                "\(count)",
            ])

            XCTAssertTrue(app.descendants(matching: .any)["cycle.flowerMap"].waitForExistence(timeout: 5))
        let remaining = app.buttons["cycle.flowerMap.remaining"]
        XCTAssertTrue(remaining.waitForExistence(timeout: 2))
        XCTAssertTrue(remaining.label.contains("\(max(0, 36 - count))"), "Expected remaining count \(count), got label: \(remaining.label)")

            if count == 36 {
                XCTAssertTrue(app.buttons["cycle.flowerMap.plantToday"].label.contains("城市已点亮"))
            }

            XCTAssertFalse(app.descendants(matching: .any)["cycle.flowerMap.progress.current"].exists)
            XCTAssertFalse(app.descendants(matching: .any)["cycle.flowerMap.progress.next"].exists)
            app.terminate()
        }
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
