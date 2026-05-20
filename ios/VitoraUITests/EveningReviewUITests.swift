import XCTest

final class EveningReviewUITests: XCTestCase {
    @MainActor
    func testEveningReviewShowsBeforeAfterFeedbackAndLearningSignal() {
        let app = launchReviewApp()

        app.swipeUp()
        app.buttons["today.evening.review.card"].tap()

        XCTAssertTrue(app.staticTexts["今晚复盘"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["vitora.review.analysis.card"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["今日理解开放度"].exists)
        XCTAssertTrue(app.staticTexts["早上预测 vs 晚上感受"].exists)
        XCTAssertTrue(app.staticTexts["早上"].exists)
        XCTAssertTrue(app.staticTexts["晚上你的反馈"].exists)
        XCTAssertFalse(app.staticTexts["完成了吗"].exists)

        app.buttons["vitora.review.feedback.inline.helpful"].tap()
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
