import XCTest

final class HealthKitOptionalUITests: XCTestCase {
    @MainActor
    func testSkippingHealthKitStillShowsAllPrimaryTabs() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()

        XCTAssertTrue(app.staticTexts["选择一种进入方式，稍后 Vitora 会像聊天一样补充最小上下文。"].waitForExistence(timeout: 5))
        app.buttons["onboarding.agreement.toggle"].tap()
        app.buttons["onboarding.signIn.local"].tap()

        completeRequiredChatQuestionsBeforeDevice(app)
        XCTAssertTrue(app.buttons["onboarding.healthkit.skip"].waitForExistence(timeout: 3))
        app.buttons["onboarding.healthkit.skip"].tap()
        XCTAssertTrue(app.buttons["onboarding.sleepAndGoals.continue"].waitForExistence(timeout: 3))
        app.buttons["onboarding.sleepAndGoals.continue"].tap()
        XCTAssertTrue(app.buttons["onboarding.specialCondition.noneSpecial"].waitForExistence(timeout: 3))
        app.buttons["onboarding.specialCondition.noneSpecial"].tap()
        app.buttons["onboarding.specialConditions.continue"].tap()
        XCTAssertTrue(app.buttons["onboarding.yourBody.enter"].waitForExistence(timeout: 3))
        app.buttons["onboarding.yourBody.enter"].tap()

        XCTAssertTrue(app.buttons["tab.today"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tab.vitora"].exists)
        XCTAssertTrue(app.buttons["tab.cycle"].exists)
    }

    @MainActor
    func testDenyingHealthKitStillShowsLowDataToday() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()

        XCTAssertTrue(app.staticTexts["选择一种进入方式，稍后 Vitora 会像聊天一样补充最小上下文。"].waitForExistence(timeout: 5))
        app.buttons["onboarding.agreement.toggle"].tap()
        app.buttons["onboarding.signIn.apple"].tap()

        completeRequiredChatQuestionsBeforeDevice(app)
        XCTAssertTrue(app.buttons["onboarding.healthkit.skip"].waitForExistence(timeout: 3))
        app.buttons["onboarding.healthkit.skip"].tap()
        XCTAssertTrue(app.buttons["onboarding.sleepAndGoals.continue"].waitForExistence(timeout: 3))
        app.buttons["onboarding.sleepAndGoals.continue"].tap()
        XCTAssertTrue(app.buttons["onboarding.specialCondition.noneSpecial"].waitForExistence(timeout: 3))
        app.buttons["onboarding.specialCondition.noneSpecial"].tap()
        app.buttons["onboarding.specialConditions.continue"].tap()
        XCTAssertTrue(app.buttons["onboarding.yourBody.enter"].waitForExistence(timeout: 3))
        app.buttons["onboarding.yourBody.enter"].tap()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["低数据模式"].exists)
    }

    @MainActor
    private func completeRequiredChatQuestionsBeforeDevice(_ app: XCUIApplication) {
        XCTAssertTrue(app.buttons["onboarding.periodDate.unsure"].waitForExistence(timeout: 3))
        app.buttons["onboarding.periodDate.unsure"].tap()
        XCTAssertTrue(app.buttons["onboarding.periodDuration.unsure"].waitForExistence(timeout: 3))
        app.buttons["onboarding.periodDuration.unsure"].tap()
        XCTAssertTrue(app.buttons["onboarding.cycleLength.unsure"].waitForExistence(timeout: 3))
        app.buttons["onboarding.cycleLength.unsure"].tap()
        XCTAssertTrue(app.buttons["onboarding.flowAmount.varies"].waitForExistence(timeout: 3))
        app.buttons["onboarding.flowAmount.varies"].tap()
        XCTAssertTrue(app.buttons["onboarding.dysmenorrhea.none"].waitForExistence(timeout: 3))
        app.buttons["onboarding.dysmenorrhea.none"].tap()
        XCTAssertTrue(app.buttons["onboarding.periodBasics.continue"].waitForExistence(timeout: 3))
        app.buttons["onboarding.periodBasics.continue"].tap()

        // Period impact — continue
        if app.buttons["onboarding.periodImpact.continue"].waitForExistence(timeout: 3) {
            app.buttons["onboarding.periodImpact.continue"].tap()
        }
        XCTAssertTrue(app.buttons["onboarding.exercise.sport.continue"].waitForExistence(timeout: 3))
        app.buttons["onboarding.exercise.sport.continue"].tap()
        XCTAssertTrue(app.buttons["onboarding.exerciseIntensity.flexible"].waitForExistence(timeout: 3))
        app.buttons["onboarding.exerciseIntensity.flexible"].tap()
        XCTAssertTrue(app.buttons["onboarding.exercise.continue"].waitForExistence(timeout: 3))
        app.buttons["onboarding.exercise.continue"].tap()
        XCTAssertTrue(app.buttons["onboarding.goals.continue"].waitForExistence(timeout: 3))
        app.buttons["onboarding.goals.continue"].tap()
    }
}
