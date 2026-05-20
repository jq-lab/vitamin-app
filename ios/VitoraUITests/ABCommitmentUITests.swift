import XCTest

final class ABCommitmentUITests: XCTestCase {
    @MainActor
    func testReminderSheetKeepsTodayIntentionAndSelectableTimes() {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-vitoraUITestCompletedOnboarding",
            "-vitoraUITestRichToday",
        ]
        app.launch()

        app.buttons["today.suggestion.remind"].tap()

        XCTAssertTrue(app.staticTexts["设置提醒"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["午间补能"].exists)
        XCTAssertTrue(app.staticTexts["智能提醒"].exists)
        XCTAssertTrue(app.buttons["today.reminder.select.0"].exists)
        XCTAssertTrue(app.buttons["today.reminder.select.1"].exists)
        XCTAssertTrue(app.buttons["today.reminder.save"].exists)

        app.buttons["today.reminder.select.1"].tap()
        app.buttons["today.reminder.save"].tap()
        XCTAssertTrue(app.staticTexts["智能监测"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testReminderFlowDoesNotCreatePressureCopy() {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-vitoraUITestCompletedOnboarding",
            "-vitoraUITestRichToday",
        ]
        app.launch()

        app.buttons["today.suggestion.remind"].tap()
        XCTAssertTrue(app.staticTexts["设置提醒"].waitForExistence(timeout: 3))
        app.buttons["稍后再说"].tap()

        XCTAssertTrue(app.staticTexts["智能监测"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["未完成"].exists)
        XCTAssertFalse(app.staticTexts["连续"].exists)
    }
}
