import XCTest

final class VitoraAssistantSurfaceUITests: XCTestCase {
    @MainActor
    func testVitoraTabIsAssistantSurfaceNotEmptyChat() {
        let app = launchPivotApp()

        app.buttons["tab.vitora"].tap()

        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["可以直接问"].exists)
        XCTAssertTrue(app.staticTexts["快捷上下文"].exists)
        XCTAssertTrue(app.textFields.element(boundBy: 0).exists)
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
