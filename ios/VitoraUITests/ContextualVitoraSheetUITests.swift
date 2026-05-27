import XCTest

final class ContextualVitoraSheetUITests: XCTestCase {
    @MainActor
    func testGlobalQuickRecordOpensManualHealthOutlinesByDefault() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["today.calibration.tell"].exists)
        app.buttons["global.record.quick"].tap()

        XCTAssertTrue(app.buttons["vitora.context.close"].waitForExistence(timeout: 4))
        XCTAssertFalse(app.otherElements["global.vitora.dock"].exists)
        XCTAssertEqual(app.buttons["vitora.record.mode.manual"].value as? String, "已选择")
        XCTAssertTrue(app.buttons["vitora.record.periodState.period"].exists)
        XCTAssertTrue(app.buttons["vitora.record.periodState.nonPeriod"].exists)
        XCTAssertTrue(app.buttons["vitora.record.outline.periodFlow"].exists)
        XCTAssertTrue(app.buttons["vitora.record.outline.body"].exists)
        XCTAssertTrue(app.buttons["vitora.record.option.periodFlow.medium"].exists)
        XCTAssertTrue(app.buttons["vitora.record.done"].isEnabled)
        XCTAssertFalse(app.buttons["vitora.accounting.type.expense"].exists)
        XCTAssertFalse(app.buttons["vitora.accounting.key.1"].exists)
        XCTAssertTrue(app.otherElements["vitora.accounting.mediaCard"].exists)
        XCTAssertTrue(app.buttons["vitora.accounting.media.photo"].exists)
        XCTAssertTrue(app.buttons["vitora.accounting.media.camera"].exists)
        XCTAssertTrue(app.buttons["vitora.accounting.media.voice"].exists)
    }

    @MainActor
    func testManualOutlinesPeriodSwitchMoreAndResetState() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        app.buttons["global.record.quick"].tap()

        XCTAssertTrue(app.buttons["vitora.record.periodState.nonPeriod"].waitForExistence(timeout: 4))
        app.buttons["vitora.record.periodState.nonPeriod"].tap()
        XCTAssertEqual(app.buttons["vitora.record.periodState.nonPeriod"].value as? String, "已选择")
        XCTAssertTrue(app.buttons["vitora.record.outline.discharge"].exists)
        XCTAssertTrue(app.buttons["vitora.record.option.discharge.dry"].exists)

        app.buttons["vitora.record.outline.discharge.more"].tap()
        XCTAssertTrue(app.buttons["vitora.record.option.discharge.smell"].waitForExistence(timeout: 2))

        app.buttons["vitora.record.option.discharge.dry"].tap()
        XCTAssertEqual(app.buttons["vitora.record.option.discharge.dry"].value as? String, "已选择")
        app.buttons["vitora.accounting.media.photo"].tap()
        app.buttons["vitora.record.reset"].tap()
        XCTAssertTrue(app.buttons["vitora.record.done"].isEnabled)
    }

    @MainActor
    func testAITextRecordParsesPreview() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        app.buttons["global.record.quick"].tap()
        XCTAssertTrue(app.buttons["vitora.record.mode.ai"].waitForExistence(timeout: 4))
        app.buttons["vitora.record.mode.ai"].tap()
        app.buttons["vitora.record.ai.mode.text"].tap()

        let input = app.textViews["vitora.record.ai.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 3))
        input.tap()
        input.typeText("今天有点头痛吃了 B6")
        app.buttons["vitora.record.ai.send"].tap()

        XCTAssertTrue(app.otherElements["vitora.record.ai.preview"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["AI 已拆出字段"].exists)
        XCTAssertTrue(app.staticTexts["营养"].exists)
        XCTAssertTrue(app.staticTexts["B6"].exists)
        XCTAssertTrue(app.buttons["vitora.record.done"].isEnabled)
    }

    @MainActor
    func testLongPressQuickRecordOpensVoiceMode() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        app.buttons["global.record.quick"].press(forDuration: 0.5)

        XCTAssertTrue(app.buttons["vitora.context.close"].waitForExistence(timeout: 4))
        XCTAssertEqual(app.buttons["vitora.record.mode.ai"].value as? String, "已选择")
        XCTAssertEqual(app.buttons["vitora.record.ai.mode.voice"].value as? String, "已选择")
        XCTAssertTrue(app.buttons["vitora.record.ai.voice.toggle"].exists)
        XCTAssertTrue(app.buttons["vitora.record.ai.voice.toText"].exists)
    }

    @MainActor
    private func launchPivotApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-vitoraUITestCompletedOnboarding",
            "-vitoraUITestRichToday",
        ]
        app.launch()
        return app
    }
}
