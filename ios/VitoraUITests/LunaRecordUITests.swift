import XCTest

final class LunaRecordUITests: XCTestCase {
    @MainActor
    func testVitoraSurfaceCanSendNaturalLanguageContext() {
        let app = launchCompletedOnboarding()

        app.buttons["tab.vitora"].tap()

        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["可以直接问"].exists)

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

        app.buttons["today.calibration.tell"].tap()

        XCTAssertTrue(app.staticTexts["Vitora 浮层 · 来源：今日状态"].waitForExistence(timeout: 4))
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
