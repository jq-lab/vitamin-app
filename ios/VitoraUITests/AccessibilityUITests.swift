import XCTest

final class AccessibilityUITests: XCTestCase {
    @MainActor
    func testPrimarySurfacesExposeAccessibleLabelsAndTouchTargets() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        assertMinimumTouchTarget(app.buttons["tab.today"], name: "Today tab")
        assertMinimumTouchTarget(app.buttons["tab.vitora"], name: "Vitora tab")
        assertMinimumTouchTarget(app.buttons["tab.cycle"], name: "Cycle tab")
        assertMinimumTouchTarget(app.buttons["today.status.card"], name: "Today status card")
        XCTAssertFalse(app.buttons["today.status.card"].label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 3))
        assertMinimumTouchTarget(app.buttons["vitora.input.plus"], name: "Vitora input plus")
        assertMinimumTouchTarget(app.buttons["vitora.input.voice"], name: "Vitora voice")
        assertMinimumTouchTarget(app.buttons["vitora.input.send"], name: "Vitora send")
        XCTAssertEqual(app.buttons["vitora.input.voice"].label, "语音记录")
        XCTAssertEqual(app.buttons["vitora.input.send"].label, "发送给 Vitora")

        app.buttons["tab.cycle"].tap()
        XCTAssertTrue(app.staticTexts["当前周期阶段与今天"].waitForExistence(timeout: 3))
        assertMinimumTouchTarget(app.buttons["cycle.phase.card"], name: "Cycle phase card")
        assertMinimumTouchTarget(app.buttons["cycle.energy.card"], name: "Cycle energy card")
        assertMinimumTouchTarget(app.buttons["cycle.settings.open"], name: "Cycle settings")

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
        XCTAssertLessThan(inputFrame.maxY, tabFrame.minY, "Vitora input dock should not be covered by the tab bar under large text.")

        app.buttons["tab.cycle"].tap()
        XCTAssertTrue(app.buttons["cycle.energy.card"].waitForExistence(timeout: 3))
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
        app.swipeDown()
        XCTAssertTrue(app.otherElements["today.energy.reveal.header"].waitForExistence(timeout: 3))
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 3))

        app.buttons["today.calibration.tell"].tap()
        XCTAssertTrue(app.staticTexts["Vitora 浮层 · 来源：今日状态"].waitForExistence(timeout: 4))
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
