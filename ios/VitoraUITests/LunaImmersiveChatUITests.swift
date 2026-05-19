import XCTest

final class LunaImmersiveChatUITests: XCTestCase {
    @MainActor
    func testVitoraAssistantSurfaceSupportsInputVoiceAndContext() {
        let app = launchCompletedOnboarding()

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 5))

        XCTAssertFalse(app.staticTexts["可以直接问"].exists)
        XCTAssertFalse(app.staticTexts["Vitora 理解为"].exists)
        XCTAssertTrue(app.otherElements["vitora.chat.manager.topics"].exists)
        XCTAssertTrue(app.buttons["vitora.chat.topic.睡眠"].waitForExistence(timeout: 2))
        app.buttons["vitora.chat.topic.睡眠"].tap()

        let input = app.textFields.element(boundBy: 0)
        XCTAssertTrue(input.waitForExistence(timeout: 3))
        input.tap()
        input.typeText("下午有点累")

        XCTAssertTrue(app.buttons["vitora.input.voice"].exists)
        XCTAssertTrue(app.buttons["vitora.input.send"].exists)
        app.buttons["vitora.input.send"].tap()

        XCTAssertTrue(app.staticTexts["更新后的判断"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.otherElements["primary.tabbar"].exists)
        XCTAssertTrue(app.otherElements["global.vitora.dock"].exists)
        XCTAssertFalse(app.buttons["tab.vitora.embedded"].exists)
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
