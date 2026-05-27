import XCTest

final class EveningReviewUITests: XCTestCase {
    @MainActor
    func testEveningReviewShowsBeforeAfterFeedbackAndLearningSignal() {
        let app = launchReviewApp()

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.otherElements["vitora.assistant.surface"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.otherElements["vitora.review.sheet"].exists)
        XCTAssertTrue(app.buttons["vitora.review.capsule"].waitForExistence(timeout: 3))
        app.buttons["vitora.review.capsule"].tap()

        XCTAssertTrue(app.staticTexts["今晚复盘"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["vitora.review.sheet"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["今天 Vitora 给过这个建议："].exists)
        XCTAssertTrue(app.staticTexts["早上"].exists)
        XCTAssertTrue(app.staticTexts["晚间感受"].exists)
        XCTAssertFalse(app.staticTexts["完成了吗"].exists)

        app.buttons["vitora.review.feedback.helpful"].tap()
    }

    @MainActor
    private func launchReviewApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-vitoraUITestCompletedOnboarding",
            "-vitoraUITestRichToday",
            "-vitoraUITestReviewAvailable",
        ]
        app.launch()
        return app
    }
}
