import XCTest

final class EveningReviewUITests: XCTestCase {
    @MainActor
    func testEveningReviewShowsBeforeAfterFeedbackAndLearningSignal() {
        let app = launchReviewApp()

        app.buttons["tab.vitora"].tap()

        XCTAssertTrue(app.staticTexts["今晚复盘"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["薄荷芽"].exists)
        XCTAssertFalse(app.staticTexts["小雏菊"].exists)
        app.buttons["vitora.review.open"].tap()

        XCTAssertTrue(app.otherElements["vitora.review.sheet"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["今天 Vitora 给过这个建议："].exists)
        XCTAssertTrue(app.staticTexts["早上"].exists)
        XCTAssertTrue(app.staticTexts["后来感觉如何？"].exists)
        XCTAssertFalse(app.staticTexts["完成了吗"].exists)

        app.buttons["vitora.review.feedback.helpful"].tap()

        XCTAssertTrue(app.staticTexts["Vitora 已记住这条反馈"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["更新后的学习信号"].exists)
        XCTAssertTrue(app.staticTexts["选择今晚种子"].exists)
        XCTAssertTrue(app.buttons["vitora.review.seed.recovery"].exists)
        XCTAssertTrue(app.buttons["vitora.review.seed.reserve"].exists)
        XCTAssertTrue(app.buttons["vitora.review.seed.lightMovement"].exists)

        app.buttons["vitora.review.seed.reserve"].tap()
        XCTAssertTrue(app.staticTexts["留余量种子已保存，明早会结合休息情况观察。"].waitForExistence(timeout: 2))
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
