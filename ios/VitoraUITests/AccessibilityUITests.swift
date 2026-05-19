import XCTest

final class AccessibilityUITests: XCTestCase {
    @MainActor
    func testPrimarySurfacesExposeAccessibleLabelsAndTouchTargets() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        assertMinimumTouchTarget(app.buttons["tab.today"], name: "Today tab")
        assertMinimumTouchTarget(app.buttons["tab.vitora"], name: "Vitora tab")
        assertMinimumTouchTarget(app.buttons["tab.cycle"], name: "Cycle tab")
        assertMinimumTouchTarget(app.buttons["global.record.quick"], name: "Global quick record")
        assertMinimumTouchTarget(app.buttons["today.status.card"], name: "Today status card")
        XCTAssertFalse(app.buttons["today.status.card"].label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        XCTAssertFalse(app.otherElements["vitora.input.dock"].exists)
        XCTAssertFalse(app.textFields["vitora.input.text"].exists)

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["vitora.input.plus"].exists)
        assertMinimumTouchTarget(app.buttons["vitora.input.voice"], name: "Vitora voice")
        assertMinimumTouchTarget(app.buttons["vitora.input.send"], name: "Vitora send")
        XCTAssertEqual(app.buttons["vitora.input.voice"].label, "语音记录")
        XCTAssertEqual(app.buttons["vitora.input.send"].label, "发送给 Vitora")

        app.buttons["tab.cycle"].tap()
        XCTAssertTrue(app.staticTexts["周期回顾"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.otherElements["vitora.input.dock"].exists)
        XCTAssertFalse(app.textFields["vitora.input.text"].exists)
        assertMinimumTouchTarget(app.buttons["cycle.review.tab.week"], name: "Cycle review week tab")
        assertMinimumTouchTarget(app.buttons["cycle.energy.card"], name: "Cycle energy card")
        assertMinimumTouchTarget(app.buttons["cycle.settings.open"], name: "Cycle settings")
        assertMinimumTouchTarget(app.buttons["cycle.share.open"], name: "Cycle share")

        app.buttons["cycle.settings.open"].tap()
        XCTAssertTrue(app.otherElements["support.settings.panel"].waitForExistence(timeout: 3))
        assertMinimumTouchTarget(app.buttons["support.close"], name: "Support close")
        for identifier in [
            "support.route.profile",
            "support.route.dataSources",
            "support.route.nutrition",
            "support.route.reminders",
            "support.route.dataExport",
            "support.route.privacyAndAccountRemoval",
        ] {
            assertMinimumTouchTarget(app.buttons[identifier], name: identifier)
        }
    }

    @MainActor
    func testDynamicTypeKeepsMainNavigationInputAndSheetsUsable() {
        let app = launchPivotApp(extraArguments: ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryXXXL"])

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        app.buttons["today.status.card"].tap()
        XCTAssertTrue(app.staticTexts["今日状态详情"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["today.state.askVitora"].exists)
        app.buttons["关闭"].tap()

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.textFields["vitora.input.text"].waitForExistence(timeout: 3))
        let inputFrame = app.textFields["vitora.input.text"].frame
        let tabFrame = app.otherElements["primary.tabbar"].frame
        let recordFrame = app.buttons["global.record.quick"].frame
        XCTAssertLessThan(tabFrame.maxY, inputFrame.minY, "Global tab switcher should stay above the input field under large text.")
        XCTAssertLessThan(recordFrame.maxY, inputFrame.minY, "Quick record should stay above the input field under large text.")
        XCTAssertLessThan(tabFrame.maxX, recordFrame.minX, "Tab switcher and quick record should not overlap under large text.")
        XCTAssertTrue(app.otherElements["global.vitora.dock"].frame.contains(inputFrame), "Vitora input field should remain inside the global dock under large text.")

        app.buttons["tab.cycle"].tap()
        XCTAssertTrue(app.buttons["cycle.energy.card"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.otherElements["vitora.input.dock"].exists)
        XCTAssertFalse(app.textFields["vitora.input.text"].exists)
    }

    @MainActor
    func testReduceMotionAndTransparencyPathKeepsCoreInteractionsAvailable() {
        let app = launchPivotApp(
            extraArguments: [
                "-UIAccessibilityReduceMotionEnabled", "YES",
                "-UIAccessibilityReduceTransparencyEnabled", "YES",
            ]
        )

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["today.cycle.phase.strip"].exists)
        XCTAssertFalse(app.staticTexts["实时预测"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["today.realtime.chart"].exists)
        app.buttons["today.evidence.open"].tap()
        XCTAssertTrue(app.otherElements["today.bodyFactors.detail.sheet"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["今日分析"].exists)
        XCTAssertTrue(app.staticTexts["综合实时预测"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["today.realtime.chart"].exists)
        XCTAssertTrue(app.staticTexts["睡眠"].exists)
        XCTAssertTrue(app.staticTexts["7.2h"].exists)
        app.buttons["关闭"].tap()

        app.buttons["global.record.quick"].tap()
        XCTAssertTrue(app.staticTexts["告诉 Vitora"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["来源：快捷记录"].exists)
        XCTAssertFalse(app.otherElements["global.vitora.dock"].exists)
        XCTAssertTrue(app.buttons["vitora.context.close"].exists)
    }

    @MainActor
    private func launchPivotApp(extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-vitoraUITestCompletedOnboarding",
            "-vitoraUITestRichToday",
            "-vitoraUITestReviewAvailable",
        ]
        app.launchArguments += extraArguments
        app.launch()
        return app
    }

    @MainActor
    private func assertMinimumTouchTarget(_ element: XCUIElement, name: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element.exists, "\(name) should exist.", file: file, line: line)
        XCTAssertGreaterThanOrEqual(element.frame.width, 44, "\(name) width should be at least 44pt.", file: file, line: line)
        XCTAssertGreaterThanOrEqual(element.frame.height, 44, "\(name) height should be at least 44pt.", file: file, line: line)
    }
}
