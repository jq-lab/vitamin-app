import XCTest

final class ContextualVitoraSheetUITests: XCTestCase {
    @MainActor
    func testTodayCalibrationOpensContextualSheetAndUnderstandingState() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["today.calibration.tell"].exists)
        app.buttons["global.record.quick"].tap()

        XCTAssertTrue(app.staticTexts["告诉 Vitora"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["来源：快捷记录"].exists)
        XCTAssertFalse(app.otherElements["global.vitora.dock"].exists)

        let input = app.textFields.element(boundBy: 0)
        XCTAssertTrue(input.exists)
        input.tap()
        input.typeText("昨晚醒了两次")
        app.buttons["vitora.input.send"].tap()

        XCTAssertTrue(app.staticTexts["Vitora 理解为"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["影响因素"].exists)
        XCTAssertTrue(app.staticTexts["置信度"].exists)
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
