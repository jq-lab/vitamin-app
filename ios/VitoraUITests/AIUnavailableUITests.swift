import XCTest

final class AIUnavailableUITests: XCTestCase {
    @MainActor
    func testAIUnavailableFallbackIsVisibleAndInputRemainsUsable() {
        let app = launchAIUnavailableApp()

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.staticTexts["Vitora 暂时无法生成新回复，你仍可以保存记录。"].waitForExistence(timeout: 5))

        let input = app.textFields["vitora.input.text"]
        XCTAssertTrue(input.exists)
        input.tap()
        input.typeText("我今天有点累")
        app.buttons["vitora.input.send"].tap()

        XCTAssertTrue(app.staticTexts["Vitora 暂时无法生成新回复，你仍可以保存记录。"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["你刚刚说的内容已经保留在本地输入流里，稍后可以再让 Vitora 理解。"].waitForExistence(timeout: 3))
    }

    @MainActor
    private func launchAIUnavailableApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-vitoraUITestCompletedOnboarding",
            "-vitoraUITestRichToday",
            "-vitoraUITestAIUnavailable",
        ]
        app.launch()
        return app
    }
}
