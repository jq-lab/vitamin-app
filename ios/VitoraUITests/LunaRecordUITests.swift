import XCTest

final class LunaRecordUITests: XCTestCase {
    @MainActor
    func testVitoraSurfaceCanSendNaturalLanguageContext() {
        let app = launchCompletedOnboarding()

        app.buttons["tab.vitora"].tap()

        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["可以直接问"].exists)
        XCTAssertFalse(app.staticTexts["Vitora 理解为"].exists)

        let input = app.textFields.element(boundBy: 0)
        XCTAssertTrue(input.waitForExistence(timeout: 3))
        input.tap()
        input.typeText("昨晚睡得浅")

        app.buttons["vitora.input.send"].tap()
        XCTAssertTrue(app.staticTexts["更新后的判断"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testTodayCalibrationOpensContextualVitoraSheet() {
        let app = launchCompletedOnboarding()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["today.calibration.tell"].exists)
        app.buttons["global.record.quick"].tap()

        XCTAssertTrue(app.staticTexts["告诉 Vitora"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["来源：快捷记录"].exists)
        XCTAssertFalse(app.otherElements["global.vitora.dock"].exists)
    }

    @MainActor
    private func launchCompletedOnboarding(aiUnavailable: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-vitoraUITestCompletedOnboarding",
            "-vitoraUITestRichToday",
        ]
        if aiUnavailable {
            app.launchArguments.append("-vitoraUITestAIUnavailable")
        }
        app.launch()
        return app
    }
}
