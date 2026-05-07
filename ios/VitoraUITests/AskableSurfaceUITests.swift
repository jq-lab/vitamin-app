import XCTest

final class AskableSurfaceUITests: XCTestCase {
    @MainActor
    func testSingleTapOpensDetailAndLongPressRevealsVitoraActions() {
        let app = launchPivotApp()

        app.buttons["today.status.card"].tap()
        XCTAssertTrue(app.otherElements["today.state.detail.sheet"].waitForExistence(timeout: 3))
        app.buttons["关闭"].tap()

        let statusCard = app.buttons["today.status.card"]
        XCTAssertTrue(statusCard.waitForExistence(timeout: 3))
        statusCard.press(forDuration: 0.8)

        XCTAssertTrue(app.buttons["问 Vitora 为什么"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["告诉 Vitora 这里不准"].exists)
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

