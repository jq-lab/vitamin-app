import XCTest

final class VisualLanguageSmokeTests: XCTestCase {
    @MainActor
    func testAuraGlassAndPixelVitoraSurfacesArePresentAcrossTabs() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Vitora 今日建议"].exists)

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.textFields.element(boundBy: 0).waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Vitora 知道"].exists)

        app.buttons["tab.cycle"].tap()
        XCTAssertTrue(app.staticTexts["当前周期阶段与今天"].waitForExistence(timeout: 3))
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
