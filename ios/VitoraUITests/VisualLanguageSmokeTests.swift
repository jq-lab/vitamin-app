import XCTest

final class VisualLanguageSmokeTests: XCTestCase {
    @MainActor
    func testAuraGlassAndPixelVitoraSurfacesArePresentAcrossTabs() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["premium.aura.background.today"].exists)
        XCTAssertTrue(app.staticTexts["Vitora 今日建议"].exists)

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.textFields.element(boundBy: 0).waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any)["premium.aura.background.vitora"].exists)
        XCTAssertTrue(app.staticTexts["Vitora 知道"].exists)

        app.buttons["tab.cycle"].tap()
        XCTAssertTrue(app.staticTexts["周期回顾"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any)["premium.aura.background.cycle"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["cycle.review.insights"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["cycle.growth.album"].exists)
    }

    @MainActor
    func testZZCapturePremiumAuraScreensWhenRequested() throws {
        let defaultScreenshotDirectory = "/Users/youxiang/Desktop/奇妙种子/vitamin-app/ios/QA/Screenshots/ImplementationV1/PremiumAura-20260518"
        let screenshotDirectory = ProcessInfo.processInfo.environment["VITORA_PREMIUM_AURA_SCREENSHOT_DIR"] ?? defaultScreenshotDirectory
        let markerPath = "\(screenshotDirectory)/.capture-enabled"

        guard ProcessInfo.processInfo.environment["VITORA_PREMIUM_AURA_SCREENSHOT_DIR"] != nil ||
                FileManager.default.fileExists(atPath: markerPath)
        else {
            throw XCTSkip("Set VITORA_PREMIUM_AURA_SCREENSHOT_DIR or create \(markerPath) to capture premium aura screenshots.")
        }

        let app = launchPivotApp(extraArguments: ["-vitoraUITestReviewAvailable"])

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        waitForAnimationsToSettle()
        try saveScreenshot(named: "01-premium-aura-today", in: screenshotDirectory)

        app.buttons["today.evidence.open"].tap()
        XCTAssertTrue(app.otherElements["today.bodyFactors.detail.sheet"].waitForExistence(timeout: 3))
        waitForAnimationsToSettle()
        try saveScreenshot(named: "02-premium-aura-today-analysis", in: screenshotDirectory)
        app.buttons["today.detail.close"].tap()

        XCTAssertTrue(app.buttons["today.top.context"].waitForExistence(timeout: 3))
        app.buttons["today.top.context"].tap()
        XCTAssertTrue(app.otherElements["today.calendar.sheet"].waitForExistence(timeout: 3))
        waitForAnimationsToSettle()
        try saveScreenshot(named: "03-premium-aura-cycle-calendar", in: screenshotDirectory)
        app.buttons["today.detail.close"].tap()

        XCTAssertTrue(app.buttons["global.record.quick"].waitForExistence(timeout: 3))
        app.buttons["global.record.quick"].tap()
        XCTAssertTrue(app.staticTexts["告诉 Vitora"].waitForExistence(timeout: 4))
        waitForAnimationsToSettle()
        try saveScreenshot(named: "04-premium-aura-record-sheet", in: screenshotDirectory)
        app.buttons["vitora.context.close"].tap()

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 5))
        waitForAnimationsToSettle()
        try saveScreenshot(named: "05-premium-aura-vitora", in: screenshotDirectory)

        if app.buttons["vitora.review.open"].waitForExistence(timeout: 2) {
            app.buttons["vitora.review.open"].tap()
            XCTAssertTrue(app.otherElements["vitora.review.sheet"].waitForExistence(timeout: 5))
            waitForAnimationsToSettle()
            try saveScreenshot(named: "06-premium-aura-evening-review", in: screenshotDirectory)
            app.buttons["vitora.review.close"].tap()
        }

        app.buttons["tab.cycle"].tap()
        XCTAssertTrue(app.staticTexts["周期回顾"].waitForExistence(timeout: 5))
        waitForAnimationsToSettle()
        try saveScreenshot(named: "07-premium-aura-cycle", in: screenshotDirectory)
    }

    @MainActor
    private func launchPivotApp(extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-vitoraUITestCompletedOnboarding",
            "-vitoraUITestRichToday",
        ]
        app.launchArguments += extraArguments
        app.launch()
        return app
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
