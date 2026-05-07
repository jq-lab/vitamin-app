import XCTest

final class HealthKitOptionalUITests: XCTestCase {
    @MainActor
    func testSkippingHealthKitStillShowsAllPrimaryTabs() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()

        let nameField = app.textFields["onboarding.identity.name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("Vitora")

        app.buttons["onboarding.identity.continue"].tap()
        XCTAssertTrue(app.buttons["onboarding.healthkit.skip"].waitForExistence(timeout: 3))
        app.buttons["onboarding.healthkit.skip"].tap()
        app.buttons["onboarding.context.continue"].tap()
        app.buttons["onboarding.ready.enterToday"].tap()

        XCTAssertTrue(app.buttons["tab.today"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tab.vitora"].exists)
        XCTAssertTrue(app.buttons["tab.cycle"].exists)
    }

    @MainActor
    func testDenyingHealthKitStillShowsLowDataToday() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()

        let nameField = app.textFields["onboarding.identity.name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("小维")

        app.buttons["onboarding.identity.continue"].tap()
        XCTAssertTrue(app.buttons["onboarding.healthkit.deny"].waitForExistence(timeout: 3))
        app.buttons["onboarding.healthkit.deny"].tap()
        app.buttons["onboarding.context.continue"].tap()
        app.buttons["onboarding.ready.enterToday"].tap()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["低数据模式"].exists)
    }
}
