import XCTest

final class OnboardingLowDataUITests: XCTestCase {
    @MainActor
    func testSkipHealthKitEntersLowDataToday() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()

        let nameField = app.textFields["onboarding.identity.name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("小维")

        app.buttons["onboarding.identity.continue"].tap()

        let skipButton = app.buttons["onboarding.healthkit.skip"]
        XCTAssertTrue(skipButton.waitForExistence(timeout: 3))
        skipButton.tap()
        app.buttons["onboarding.context.continue"].tap()

        let enterToday = app.buttons["onboarding.ready.enterToday"]
        XCTAssertTrue(enterToday.waitForExistence(timeout: 3))
        enterToday.tap()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["低数据模式"].exists)
    }
}
