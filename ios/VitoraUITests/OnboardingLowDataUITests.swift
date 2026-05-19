import XCTest

final class OnboardingLowDataUITests: XCTestCase {
    @MainActor
    func testSkipHealthKitEntersLowDataTodayAfterCustomization() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()

        let nameField = app.textFields["onboarding.identity.name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("小维")

        app.buttons["onboarding.identity.continue"].tap()
        XCTAssertTrue(app.buttons["onboarding.context.continue"].waitForExistence(timeout: 3))

        XCTAssertTrue(app.staticTexts["定制 Vitora 的初始理解"].exists)
        XCTAssertTrue(app.buttons["onboarding.focus.sleep"].waitForExistence(timeout: 3))
        app.buttons["onboarding.focus.sleep"].tap()
        if !app.buttons["onboarding.energyWindow.afternoon"].waitForExistence(timeout: 1) {
            app.swipeUp()
        }
        XCTAssertTrue(app.buttons["onboarding.energyWindow.afternoon"].waitForExistence(timeout: 3))
        app.buttons["onboarding.energyWindow.afternoon"].tap()

        let gentleSuggestion = app.buttons["onboarding.guidance.gentleSuggestion"]
        if !gentleSuggestion.waitForExistence(timeout: 1) {
            app.swipeUp()
        }
        if !gentleSuggestion.waitForExistence(timeout: 1) {
            app.swipeDown()
        }
        XCTAssertTrue(gentleSuggestion.waitForExistence(timeout: 3))
        gentleSuggestion.tap()
        XCTAssertTrue(app.buttons["onboarding.reminder.eveningReview"].waitForExistence(timeout: 3))
        app.buttons["onboarding.reminder.eveningReview"].tap()

        XCTAssertFalse(app.buttons["onboarding.context.continue"].isEnabled)
        XCTAssertTrue(app.staticTexts["请选择是否连接 HealthKit；也可以直接跳过，App 仍可用。"].exists)

        XCTAssertTrue(app.buttons["onboarding.healthkit.skip"].waitForExistence(timeout: 3))
        app.buttons["onboarding.healthkit.skip"].tap()
        XCTAssertTrue(app.buttons["onboarding.context.continue"].isEnabled)
        app.buttons["onboarding.context.continue"].tap()

        let enterToday = app.buttons["onboarding.ready.enterToday"]
        XCTAssertTrue(enterToday.waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any)["onboarding.ready.summary"].exists)
        XCTAssertTrue(app.staticTexts["定制完成"].exists)
        XCTAssertTrue(app.staticTexts["睡眠"].exists)
        XCTAssertTrue(app.staticTexts["下午"].exists)
        XCTAssertTrue(app.staticTexts["给轻建议"].exists)
        XCTAssertTrue(app.staticTexts["晚间轻复盘"].exists)
        XCTAssertTrue(app.staticTexts["先用低数据开始"].exists)
        enterToday.tap()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["低数据模式"].exists)
    }

    @MainActor
    func testOnboardingContinueButtonsExposeRequiredStates() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()

        XCTAssertTrue(app.buttons["onboarding.identity.continue"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["onboarding.identity.continue"].isEnabled)
        XCTAssertTrue(app.staticTexts["先给 Vitora 一个称呼，再继续定制。"].exists)

        let nameField = app.textFields["onboarding.identity.name"]
        nameField.tap()
        nameField.typeText("小维")
        XCTAssertTrue(app.buttons["onboarding.identity.continue"].isEnabled)
        app.buttons["onboarding.identity.continue"].tap()

        XCTAssertTrue(app.buttons["onboarding.context.continue"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["onboarding.context.continue"].isEnabled)

        app.buttons["onboarding.healthkit.skip"].tap()
        XCTAssertTrue(app.buttons["onboarding.context.continue"].isEnabled)
    }

    @MainActor
    func testReadySummaryCanReturnToCustomization() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()

        let nameField = app.textFields["onboarding.identity.name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("小维")

        app.buttons["onboarding.identity.continue"].tap()
        XCTAssertTrue(app.buttons["onboarding.healthkit.skip"].waitForExistence(timeout: 3))
        app.buttons["onboarding.healthkit.skip"].tap()
        app.buttons["onboarding.context.continue"].tap()

        XCTAssertTrue(app.descendants(matching: .any)["onboarding.ready.summary"].waitForExistence(timeout: 3))
        app.buttons["onboarding.ready.editCustomization"].tap()
        XCTAssertTrue(app.staticTexts["定制 Vitora 的初始理解"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testZZCaptureOnboardingScreensWhenRequested() throws {
        let screenshotDirectory = "/private/tmp/vitora-onboarding-screenshots"

        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()

        XCTAssertTrue(app.textFields["onboarding.identity.name"].waitForExistence(timeout: 5))
        waitForAnimationsToSettle()
        try saveScreenshot(named: "01-onboarding-identity", in: screenshotDirectory)

        let nameField = app.textFields["onboarding.identity.name"]
        nameField.tap()
        nameField.typeText("小维")
        app.buttons["onboarding.identity.continue"].tap()

        XCTAssertTrue(app.buttons["onboarding.context.continue"].waitForExistence(timeout: 3))
        waitForAnimationsToSettle()
        try saveScreenshot(named: "02-onboarding-customization", in: screenshotDirectory)

        app.buttons["onboarding.healthkit.skip"].tap()
        app.buttons["onboarding.context.continue"].tap()

        XCTAssertTrue(app.descendants(matching: .any)["onboarding.ready.summary"].waitForExistence(timeout: 3))
        waitForAnimationsToSettle()
        try saveScreenshot(named: "03-onboarding-ready", in: screenshotDirectory)
    }

    private func waitForAnimationsToSettle() {
        RunLoop.current.run(until: Date().addingTimeInterval(0.8))
    }

    @MainActor
    private func saveScreenshot(named name: String, in directory: String) throws {
        let directoryURL = URL(fileURLWithPath: directory, isDirectory: true)
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )

        let screenshotURL = directoryURL.appendingPathComponent("\(name).png")
        try XCUIScreen.main.screenshot().pngRepresentation.write(to: screenshotURL)
    }
}
