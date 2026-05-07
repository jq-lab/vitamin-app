import XCTest

final class ContextualVitoraSheetUITests: XCTestCase {
    @MainActor
    func testTodayCalibrationOpensContextualSheetAndUnderstandingState() {
        let app = launchPivotApp()

        app.buttons["today.calibration.tell"].tap()

        XCTAssertTrue(app.staticTexts["Vitora 浮层 · 来源：今日状态"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Vitora 浮层 · 来源：今日状态"].exists)

        let input = app.textFields.element(boundBy: 0)
        XCTAssertTrue(input.exists)
        input.tap()
        input.typeText("昨晚醒了两次")
        app.buttons["vitora.input.send"].tap()

        XCTAssertTrue(app.staticTexts["Vitora 理解为"].waitForExistence(timeout: 3))
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
