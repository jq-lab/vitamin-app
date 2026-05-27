import XCTest

final class OnboardingLowDataUITests: XCTestCase {
    @MainActor
    func testRegistrationThenChatSetupEntersLowDataToday() {
        let app = launchOnboardingApp()

        XCTAssertTrue(app.staticTexts["选择一种进入方式，稍后 Vitora 会像聊天一样补充最小上下文。"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["onboarding.signIn.apple"].exists)
        XCTAssertTrue(app.buttons["onboarding.signIn.apple"].isEnabled)

        app.buttons["onboarding.signIn.wechat"].tap()
        XCTAssertFalse(app.otherElements["onboarding.chat.setup"].waitForExistence(timeout: 1))

        app.buttons["onboarding.agreement.toggle"].tap()
        XCTAssertTrue(app.buttons["onboarding.signIn.wechat"].isEnabled)
        app.buttons["onboarding.signIn.wechat"].tap()

        XCTAssertTrue(app.otherElements["onboarding.chat.setup"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["了解你的身体节律"].exists)
        XCTAssertTrue(app.staticTexts["先聊聊你的经期吧，最近一次大概什么时候来的？"].exists)
        XCTAssertFalse(app.staticTexts["一般会持续几天？"].exists)

        completePeriodBasicsQuickPath(app)

        // Step 2: Period impact — just continue
        XCTAssertTrue(app.buttons["onboarding.periodImpact.continue"].waitForExistence(timeout: 3))
        app.buttons["onboarding.periodImpact.continue"].tap()

        // Step 3: Exercise — just continue
        XCTAssertTrue(app.buttons["onboarding.exercise.sport.continue"].waitForExistence(timeout: 3))
        app.buttons["onboarding.exercise.sport.continue"].tap()
        XCTAssertTrue(app.buttons["onboarding.exerciseIntensity.flexible"].waitForExistence(timeout: 3))
        app.buttons["onboarding.exerciseIntensity.flexible"].tap()
        XCTAssertTrue(app.buttons["onboarding.exercise.continue"].waitForExistence(timeout: 3))
        app.buttons["onboarding.exercise.continue"].tap()

        // Step 4: Sleep & Goals — answer goals, then skip health kit
        XCTAssertTrue(app.buttons["onboarding.goals.continue"].waitForExistence(timeout: 3))
        app.buttons["onboarding.goals.continue"].tap()
        XCTAssertTrue(app.buttons["onboarding.healthkit.skip"].waitForExistence(timeout: 3))
        app.buttons["onboarding.healthkit.skip"].tap()
        app.buttons["onboarding.sleepAndGoals.continue"].tap()

        // Step 5: Special conditions — select none + continue
        XCTAssertTrue(app.buttons["onboarding.specialCondition.noneSpecial"].waitForExistence(timeout: 3))
        app.buttons["onboarding.specialCondition.noneSpecial"].tap()
        app.buttons["onboarding.specialConditions.continue"].tap()

        // Step 6: Ready — enter
        XCTAssertTrue(app.buttons["onboarding.yourBody.enter"].waitForExistence(timeout: 3))
        app.buttons["onboarding.yourBody.enter"].tap()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["低数据模式"].exists)
    }

    @MainActor
    func testDeviceBindingChoiceIsOptional() {
        let app = launchOnboardingApp()

        app.buttons["onboarding.agreement.toggle"].tap()
        app.buttons["onboarding.signIn.qq"].tap()

        completeRequiredChatQuestionsBeforeDevice(app)
        XCTAssertTrue(app.buttons["onboarding.healthkit.skip"].waitForExistence(timeout: 3))
        app.buttons["onboarding.healthkit.skip"].tap()
        app.buttons["onboarding.sleepAndGoals.continue"].tap()

        // Special conditions
        XCTAssertTrue(app.buttons["onboarding.specialCondition.noneSpecial"].waitForExistence(timeout: 3))
        app.buttons["onboarding.specialCondition.noneSpecial"].tap()
        app.buttons["onboarding.specialConditions.continue"].tap()

        XCTAssertTrue(app.buttons["onboarding.yourBody.enter"].waitForExistence(timeout: 3))
        app.buttons["onboarding.yourBody.enter"].tap()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["低数据模式"].exists)
    }

    @MainActor
    func testZZCaptureOnboardingScreensWhenRequested() throws {
        let screenshotDirectory = "/private/tmp/vitora-onboarding-screenshots"
        let app = launchOnboardingApp()

        XCTAssertTrue(app.staticTexts["选择一种进入方式，稍后 Vitora 会像聊天一样补充最小上下文。"].waitForExistence(timeout: 5))
        waitForAnimationsToSettle()
        try saveScreenshot(named: "01-onboarding-registration", in: screenshotDirectory)

        app.buttons["onboarding.agreement.toggle"].tap()
        app.buttons["onboarding.signIn.apple"].tap()

        XCTAssertTrue(app.otherElements["onboarding.chat.setup"].waitForExistence(timeout: 3))
        waitForAnimationsToSettle()
        try saveScreenshot(named: "02-onboarding-chat-setup", in: screenshotDirectory)

        completeRequiredChatQuestionsBeforeDevice(app)
        app.buttons["onboarding.healthkit.skip"].tap()
        app.buttons["onboarding.sleepAndGoals.continue"].tap()

        XCTAssertTrue(app.buttons["onboarding.specialCondition.noneSpecial"].waitForExistence(timeout: 3))
        app.buttons["onboarding.specialCondition.noneSpecial"].tap()
        app.buttons["onboarding.specialConditions.continue"].tap()

        XCTAssertTrue(app.buttons["onboarding.yourBody.enter"].waitForExistence(timeout: 3))
        app.buttons["onboarding.yourBody.enter"].tap()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        waitForAnimationsToSettle()
        try saveScreenshot(named: "03-onboarding-enters-today", in: screenshotDirectory)
    }

    @MainActor
    private func launchOnboardingApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()
        return app
    }

    private func waitForAnimationsToSettle() {
        RunLoop.current.run(until: Date().addingTimeInterval(0.8))
    }

    @MainActor
    private func completePeriodBasicsQuickPath(_ app: XCUIApplication) {
        XCTAssertTrue(app.buttons["onboarding.periodDate.unsure"].waitForExistence(timeout: 3))
        app.buttons["onboarding.periodDate.unsure"].tap()

        XCTAssertTrue(app.staticTexts["一般会持续几天？"].waitForExistence(timeout: 3))
        app.buttons["onboarding.periodDuration.unsure"].tap()

        XCTAssertTrue(app.staticTexts["两次经期之间大概隔多久？"].waitForExistence(timeout: 3))
        app.buttons["onboarding.cycleLength.unsure"].tap()

        XCTAssertTrue(app.staticTexts["经期量通常更接近哪一种？"].waitForExistence(timeout: 3))
        app.buttons["onboarding.flowAmount.varies"].tap()

        XCTAssertTrue(app.staticTexts["会痛经吗？我只用它来调整提醒力度。"].waitForExistence(timeout: 3))
        app.buttons["onboarding.dysmenorrhea.none"].tap()
    }

    @MainActor
    private func completeRequiredChatQuestionsBeforeDevice(_ app: XCUIApplication) {
        // Period basics — fast path
        completePeriodBasicsQuickPath(app)

        // Wait for periodBasics continue and tap
        if app.buttons["onboarding.periodBasics.continue"].waitForExistence(timeout: 5) {
            app.buttons["onboarding.periodBasics.continue"].tap()
        }

        // Period impact — continue
        if app.buttons["onboarding.periodImpact.continue"].waitForExistence(timeout: 3) {
            app.buttons["onboarding.periodImpact.continue"].tap()
        }

        // Exercise — answer one prompt at a time
        if app.buttons["onboarding.exercise.sport.continue"].waitForExistence(timeout: 3) {
            app.buttons["onboarding.exercise.sport.continue"].tap()
        }
        if app.buttons["onboarding.exerciseIntensity.flexible"].waitForExistence(timeout: 3) {
            app.buttons["onboarding.exerciseIntensity.flexible"].tap()
        }
        if app.buttons["onboarding.exercise.continue"].waitForExistence(timeout: 3) {
            app.buttons["onboarding.exercise.continue"].tap()
        }
        if app.buttons["onboarding.goals.continue"].waitForExistence(timeout: 3) {
            app.buttons["onboarding.goals.continue"].tap()
        }
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
