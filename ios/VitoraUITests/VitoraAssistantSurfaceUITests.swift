import XCTest

final class VitoraAssistantSurfaceUITests: XCTestCase {
    @MainActor
    func testVitoraTabIsAssistantSurfaceNotEmptyChat() {
        let app = launchPivotApp()

        app.buttons["tab.vitora"].tap()

        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["可以直接问"].exists)
        XCTAssertFalse(app.staticTexts["Vitora 理解为"].exists)
        XCTAssertFalse(app.staticTexts["Vitora 今日建议"].exists)
        XCTAssertFalse(app.otherElements["vitora.modeAwareSuggestion.card"].exists)
        XCTAssertTrue(app.staticTexts["今日"].exists)
        XCTAssertTrue(app.staticTexts["5月5日 周二"].exists)
        XCTAssertTrue(app.staticTexts["黄体期 Day18"].exists)
        XCTAssertTrue(app.buttons["tab.today"].exists)
        XCTAssertTrue(app.buttons["tab.cycle"].exists)
        XCTAssertTrue(app.buttons["global.record.quick"].exists)
        XCTAssertTrue(app.otherElements["primary.tabbar"].exists)
        XCTAssertTrue(app.otherElements["global.vitora.dock"].exists)
        XCTAssertFalse(app.buttons["tab.vitora.embedded"].exists)
        XCTAssertFalse(app.buttons["vitora.input.cycle"].exists)
        XCTAssertFalse(app.buttons["vitora.input.plus"].exists)
        XCTAssertTrue(app.buttons["vitora.header.back"].exists)
        XCTAssertTrue(app.buttons["vitora.header.mute"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["pixel.vitora.message.avatar"].exists)
        XCTAssertTrue(app.buttons["vitora.date.context.openCalendar"].exists)
        app.buttons["vitora.date.context.openCalendar"].tap()
        XCTAssertTrue(app.otherElements["today.calendar.sheet"].waitForExistence(timeout: 3))
        app.buttons["关闭"].tap()
        XCTAssertFalse(app.otherElements["today.calendar.sheet"].waitForExistence(timeout: 1))
        XCTAssertEqual(app.buttons["vitora.header.mute"].value as? String, "未静音")
        app.buttons["vitora.header.mute"].tap()
        XCTAssertEqual(app.buttons["vitora.header.mute"].value as? String, "已静音")
        app.buttons["vitora.header.mute"].tap()
        XCTAssertEqual(app.buttons["vitora.header.mute"].value as? String, "未静音")
        app.buttons["vitora.support.open"].tap()
        XCTAssertTrue(app.otherElements["support.settings.panel"].waitForExistence(timeout: 3))
        app.buttons["support.close"].tap()
        XCTAssertFalse(app.otherElements["support.settings.panel"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.otherElements["vitora.chat.manager.topics"].exists)
        XCTAssertTrue(app.buttons["vitora.chat.topic.周期"].exists)
        XCTAssertTrue(app.buttons["vitora.chat.topic.睡眠"].exists)
        XCTAssertTrue(app.buttons["vitora.chat.topic.营养"].exists)
        XCTAssertFalse(app.buttons["vitora.sleepSeed.explain"].exists)
        XCTAssertFalse(app.staticTexts["为什么这颗种子半开"].exists)
        XCTAssertFalse(app.buttons["vitora.chat.topic.情绪"].exists)
        XCTAssertFalse(app.buttons["vitora.chat.topic.能量"].exists)
        XCTAssertFalse(app.otherElements["vitora.cycle.context.report"].exists)
        app.buttons["vitora.chat.topic.周期"].tap()
        XCTAssertTrue(app.otherElements["vitora.context.card.周期"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["黄体期 Day18"].exists)
        XCTAssertTrue(app.staticTexts["经期窗口 5月8日-5月12日"].exists)
        XCTAssertTrue(app.staticTexts["今晚适合轻量复盘"].exists)
        XCTAssertFalse(app.otherElements["vitora.cycle.context.report"].exists)
        XCTAssertTrue(app.buttons["取消周期卡片"].exists)
        app.buttons["取消周期卡片"].tap()
        XCTAssertFalse(app.otherElements["vitora.context.card.周期"].exists)
        XCTAssertTrue(app.buttons["vitora.chat.topic.周期"].exists)
        XCTAssertFalse(app.staticTexts["快捷上下文"].exists)
        XCTAssertTrue(app.textFields.element(boundBy: 0).exists)
        app.buttons["vitora.header.back"].tap()
        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testGlobalQuickRecordOpensContextualSheetWithoutSwitchingTabs() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.otherElements["vitora.input.dock"].exists)
        app.buttons["global.record.quick"].tap()

        XCTAssertTrue(app.staticTexts["告诉 Vitora"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["来源：快捷记录"].exists)
        XCTAssertFalse(app.otherElements["global.vitora.dock"].exists)
        XCTAssertTrue(app.staticTexts["告诉 Vitora 一件事..."].exists)
        XCTAssertTrue(app.staticTexts["快捷补充"].exists)

        app.buttons["vitora.context.close"].tap()
        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.otherElements["global.vitora.dock"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["Vitora 知道"].exists)
        XCTAssertFalse(app.otherElements["vitora.input.dock"].exists)
    }

    @MainActor
    func testVitoraTabAutoFocusesGlobalInput() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 5))

        let input = app.textFields["vitora.input.text"]
        XCTAssertTrue(input.waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["vitora.input.plus"].exists)
        input.tap()
        input.typeText("focus test")

        XCTAssertEqual(input.value as? String, "focus test")
    }

    @MainActor
    func testVitoraChatFocusKeepsAssistantTabAndShowsConversationContent() {
        let app = launchLowDataPivotApp()

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["vitora.hero"].exists)

        app.swipeUp()

        XCTAssertTrue(app.staticTexts["今日"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["5月5日 周二"].exists)
        XCTAssertTrue(app.staticTexts["黄体期 Day18"].exists)
        XCTAssertTrue(app.otherElements["vitora.chat.manager.topics"].exists)
        XCTAssertFalse(app.staticTexts["Vitora 的理解来自你提供的数据和记录，可作为生活方式参考。"].exists)
        XCTAssertTrue(app.staticTexts["HRV 偏低但深睡充足，身体在努力恢复中。今天先把高强度任务往后放一点。"].exists)
        XCTAssertTrue(app.staticTexts["当前信息较少"].exists)
        XCTAssertTrue(app.otherElements["global.vitora.dock"].exists)
        XCTAssertTrue(app.textFields["vitora.input.text"].exists)
        XCTAssertTrue(app.buttons["tab.vitora"].exists)
        XCTAssertFalse(app.staticTexts["现在状态"].exists)
    }

    @MainActor
    func testVitoraTopicCardsUseUnifiedTemplateForCycleSleepAndNutrition() {
        let app = launchPivotApp()

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 5))

        app.buttons["vitora.chat.topic.周期"].tap()
        XCTAssertTrue(app.otherElements["vitora.context.card.周期"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["黄体期 Day18"].exists)
        XCTAssertTrue(app.staticTexts["经期窗口 5月8日-5月12日"].exists)
        XCTAssertTrue(app.staticTexts["今晚适合轻量复盘"].exists)
        XCTAssertFalse(app.otherElements["vitora.cycle.context.report"].exists)

        app.buttons["vitora.chat.topic.睡眠"].tap()
        XCTAssertTrue(app.otherElements["vitora.context.card.睡眠"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["睡眠 7.2h · 略低"].exists)
        XCTAssertTrue(app.staticTexts["深睡相对够"].exists)
        XCTAssertTrue(app.staticTexts["HRV ↓8%"].exists)
        XCTAssertFalse(app.otherElements["vitora.context.card.周期"].exists)

        app.buttons["vitora.chat.topic.营养"].tap()
        XCTAssertTrue(app.otherElements["vitora.context.card.营养"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["今日补给未记录"].exists)
        XCTAssertTrue(app.staticTexts["午后低谷前可加蛋白"].exists)
        XCTAssertTrue(app.staticTexts["补水和蛋白作为生活方式参考"].exists)
        XCTAssertFalse(app.otherElements["vitora.context.card.睡眠"].exists)

        XCTAssertTrue(app.buttons["取消营养卡片"].exists)
        app.buttons["取消营养卡片"].tap()
        XCTAssertFalse(app.otherElements["vitora.context.card.营养"].exists)
    }

    @MainActor
    func testVoiceEntryShowsReactiveListeningState() {
        let app = launchPivotApp()

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 5))

        app.buttons["vitora.input.voice"].tap()

        XCTAssertTrue(app.otherElements["vitora.input.voice.status"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["正在听 · 00:12"].exists)
        XCTAssertEqual(app.buttons["vitora.input.voice"].label, "键盘输入")
        XCTAssertTrue(app.buttons["vitora.input.send"].isEnabled)

        app.buttons["vitora.input.voice"].tap()
        XCTAssertTrue(app.textFields["vitora.input.text"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.buttons["vitora.input.voice"].label, "语音记录")
    }

    @MainActor
    func testGlobalInputPersistsAcrossTabsAndRoutesSendToVitora() {
        let app = launchPivotApp()

        XCTAssertTrue(app.staticTexts["现在状态"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["global.vitora.dock"].exists)
        XCTAssertTrue(app.buttons["tab.today"].exists)
        XCTAssertTrue(app.buttons["tab.vitora"].exists)
        XCTAssertTrue(app.buttons["tab.cycle"].exists)
        XCTAssertTrue(app.buttons["global.record.quick"].exists)
        XCTAssertFalse(app.otherElements["vitora.input.dock"].exists)
        XCTAssertFalse(app.textFields["vitora.input.text"].exists)

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.textFields["vitora.input.text"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["vitora.input.plus"].exists)

        app.textFields["vitora.input.text"].tap()
        app.textFields["vitora.input.text"].typeText("今天想补充睡眠")
        app.buttons["vitora.input.send"].tap()

        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["今天想补充睡眠"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["更新后的判断"].waitForExistence(timeout: 3))

        app.buttons["tab.cycle"].tap()
        XCTAssertTrue(app.staticTexts["周期回顾"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.otherElements["vitora.input.dock"].exists)
        XCTAssertFalse(app.textFields["vitora.input.text"].exists)

        app.buttons["tab.vitora"].tap()
        XCTAssertTrue(app.textFields["vitora.input.text"].waitForExistence(timeout: 3))
        app.textFields["vitora.input.text"].tap()
        app.textFields["vitora.input.text"].typeText("周期感觉偏累")
        app.buttons["vitora.input.send"].tap()

        XCTAssertTrue(app.staticTexts["Vitora 知道"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["周期感觉偏累"].waitForExistence(timeout: 3))
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

    @MainActor
    private func launchLowDataPivotApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(zh-Hans)",
            "-AppleLocale", "zh_CN",
            "-vitoraUITestCompletedOnboarding",
        ]
        app.launch()
        return app
    }
}
