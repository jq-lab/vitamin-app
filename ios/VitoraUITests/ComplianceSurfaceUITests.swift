import XCTest

final class ComplianceSurfaceUITests: XCTestCase {
    @MainActor
    func testCoreSurfacesExposeRequiredComplianceLabels() {
        let app = launchTrustApp()

        XCTAssertTrue(app.buttons["today.suggestion.try"].waitForExistence(timeout: 5))
        app.buttons["today.suggestion.try"].tap()
        XCTAssertTrue(app.staticTexts["本内容仅供生活方式参考，不替代专业意见。"].waitForExistence(timeout: 5))
        app.buttons["关闭"].tap()

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Vitora 的理解来自你提供的数据和记录，可作为生活方式参考。"].exists)

        app.buttons["tab.cycle"].tap()
        app.buttons["cycle.settings.open"].tap()
        XCTAssertTrue(app.otherElements["support.settings.panel"].waitForExistence(timeout: 5))

        app.buttons["support.route.dataSources"].tap()
        XCTAssertTrue(app.staticTexts["当前可用信息较少，你可以继续手动记录，或稍后连接 HealthKit。"].waitForExistence(timeout: 3))

        app.buttons["support.back"].tap()
        app.buttons["support.route.nutrition"].tap()
        XCTAssertTrue(app.staticTexts["Vitora 只记录你已经在使用的内容，不引导你新增或购买。"].waitForExistence(timeout: 3))

        app.buttons["support.back"].tap()
        app.buttons["support.route.dataExport"].tap()
        XCTAssertTrue(app.staticTexts["你可以导出个人数据，也可以移除账号和本地数据。"].waitForExistence(timeout: 3))
    }

    @MainActor
    private func launchTrustApp() -> XCUIApplication {
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
