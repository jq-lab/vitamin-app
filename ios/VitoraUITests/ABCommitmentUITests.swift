import XCTest

final class ABCommitmentUITests: XCTestCase {
    @MainActor
    func testSelectingABCreatesDurableIntentionAndReminderPreference() {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-vitoraUITestCompletedOnboarding",
            "-vitoraUITestRichToday",
        ]
        app.launch()

        app.buttons["today.suggestion.try"].tap()

        XCTAssertTrue(app.staticTexts["两个可选方向"].waitForExistence(timeout: 3))
        app.buttons["today.ab.choice.a"].tap()

        XCTAssertTrue(app.staticTexts["今天的小尝试"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["提前加餐 + 短走动"].exists)
        XCTAssertTrue(app.staticTexts["晚间会用这个选择做一次轻复盘"].exists)
        XCTAssertTrue(app.switches["today.reminder.toggle"].exists)

        app.switches["today.reminder.toggle"].tap()
        XCTAssertTrue(app.staticTexts["已准备轻提醒"].waitForExistence(timeout: 3))

        app.buttons["today.analysis.close"].tap()
        XCTAssertTrue(app.staticTexts["今天的小尝试"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["提前加餐 + 短走动"].exists)
    }

    @MainActor
    func testNotSuitableFeedbackDoesNotCreatePressureCopy() {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-vitoraUITestCompletedOnboarding",
            "-vitoraUITestRichToday",
        ]
        app.launch()

        app.buttons["today.suggestion.try"].tap()
        XCTAssertTrue(app.staticTexts["两个可选方向"].waitForExistence(timeout: 3))
        app.buttons["today.ab.notSuitable"].tap()

        XCTAssertTrue(app.staticTexts["今天先不选也可以"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["未完成"].exists)
        XCTAssertFalse(app.staticTexts["连续"].exists)
    }
}
