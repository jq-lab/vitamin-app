import XCTest

final class EveningReviewUITests: XCTestCase {
    @MainActor
    func testEveningReviewShowsBeforeAfterFeedbackAndLearningSignal() {
        let app = launchReviewApp()

        app.buttons["tab.vitora"].tap()

        XCTAssertTrue(app.staticTexts["今晚复盘"].waitForExistence(timeout: 5))
        app.buttons["vitora.review.open"].tap()

        XCTAssertTrue(app.otherElements["vitora.review.sheet"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["今天 Vitora 给过这个建议："].exists)
        XCTAssertTrue(app.staticTexts["早上"].exists)
        XCTAssertTrue(app.staticTexts["后来感觉如何？"].exists)
        XCTAssertFalse(app.staticTexts["完成了吗"].exists)

        app.buttons["vitora.review.feedback.helpful"].tap()

        XCTAssertTrue(app.staticTexts["Vitora 已记住这条反馈"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["更新后的学习信号"].exists)
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
