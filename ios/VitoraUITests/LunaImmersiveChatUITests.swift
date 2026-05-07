import XCTest

final class LunaImmersiveChatUITests: XCTestCase {
    @MainActor
    func testVitoraAssistantSurfaceSupportsInputVoiceAndContext() {
        let app = launchCompletedOnboarding()

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 5))

        XCTAssertTrue(app.staticTexts["可以直接问"].exists)
        XCTAssertTrue(app.staticTexts["快捷上下文"].exists)
        app.buttons["睡眠"].tap()

        let input = app.textFields.element(boundBy: 0)
        XCTAssertTrue(input.waitForExistence(timeout: 3))
        input.tap()
        input.typeText("下午有点累")

        XCTAssertTrue(app.buttons["vitora.input.voice"].exists)
        XCTAssertTrue(app.buttons["vitora.input.send"].exists)
        app.buttons["vitora.input.send"].tap()

        XCTAssertTrue(app.staticTexts["更新后的判断"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.otherElements["primary.tabbar"].waitForExistence(timeout: 3))
    }

    @MainActor
    private func launchCompletedOnboarding() -> XCUIApplication {
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
