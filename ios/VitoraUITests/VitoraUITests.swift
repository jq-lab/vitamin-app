import XCTest

final class VitoraUITests: XCTestCase {
    @MainActor
    func testAppLaunchesToOnboardingShell() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Vitora"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testDefaultLaunchUsesChineseFallbackStrings() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Vitora"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["先认识 Vitora"].exists)
        XCTAssertFalse(app.staticTexts["onboarding.identity.title"].exists)
    }
}
