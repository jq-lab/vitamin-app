import XCTest

final class LegacyLunaTextScanTests: XCTestCase {
    @MainActor
    func testPrimaryPivotSurfacesDoNotShowLegacyLunaText() {
        let app = launchPivotApp()

        assertNoVisibleLegacyLunaText(in: app)

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 3))
        assertNoVisibleLegacyLunaText(in: app)

        app.buttons["tab.cycle"].tap()
        XCTAssertTrue(app.staticTexts["当前周期阶段与今天"].waitForExistence(timeout: 3))
        assertNoVisibleLegacyLunaText(in: app)
    }

    @MainActor
    private func assertNoVisibleLegacyLunaText(in app: XCUIApplication) {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", "Luna")
        XCTAssertFalse(app.staticTexts.containing(predicate).element.exists)
        XCTAssertFalse(app.buttons.containing(predicate).element.exists)
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
