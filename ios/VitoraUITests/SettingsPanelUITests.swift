import XCTest

final class SettingsPanelUITests: XCTestCase {
    @MainActor
    func testSettingsPanelShowsOnlyP0SupportItemsAndChildPanels() {
        let app = launchSupportApp()

        app.buttons["tab.cycle"].tap()
        XCTAssertTrue(app.buttons["cycle.settings.open"].waitForExistence(timeout: 5))
        app.buttons["cycle.settings.open"].tap()

        XCTAssertTrue(app.otherElements["support.settings.panel"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["我的"].exists)

        for identifier in [
            "support.route.profile",
            "support.route.dataSources",
            "support.route.nutrition",
            "support.route.reminders",
            "support.route.dataExport",
            "support.route.privacyAndAccountRemoval",
        ] {
            XCTAssertTrue(app.buttons[identifier].exists, "Missing support route \(identifier)")
        }

        XCTAssertFalse(app.staticTexts["VIP"].exists)
        XCTAssertFalse(app.staticTexts["主题商城"].exists)
        XCTAssertFalse(app.staticTexts["小组件"].exists)
        XCTAssertFalse(app.staticTexts["帮助墙"].exists)
        XCTAssertFalse(app.staticTexts["Vitora 养成"].exists)

        app.buttons["support.route.dataSources"].tap()
        XCTAssertTrue(app.staticTexts["已跳过 HealthKit"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["当前为低数据模式"].exists)

        app.buttons["support.back"].tap()
        app.buttons["support.route.nutrition"].tap()
        XCTAssertTrue(app.staticTexts["营养补给管理"].waitForExistence(timeout: 3))
        app.buttons["support.nutrition.add"].tap()
        XCTAssertGreaterThanOrEqual(app.otherElements.matching(identifier: "support.nutrition.entry").count, 3)
    }

    @MainActor
    func testDataExportAndAccountRemovalRequireConfirmationAndShowResult() {
        let app = launchSupportApp()

        app.buttons["tab.cycle"].tap()
        app.buttons["cycle.settings.open"].tap()
        XCTAssertTrue(app.otherElements["support.settings.panel"].waitForExistence(timeout: 5))

        app.buttons["support.route.dataExport"].tap()
        XCTAssertTrue(app.staticTexts["数据导出"].waitForExistence(timeout: 3))
        app.buttons["support.export.start"].tap()
        XCTAssertTrue(app.staticTexts["确认导出"].waitForExistence(timeout: 2))
        app.buttons["support.export.confirm"].tap()
        XCTAssertTrue(app.staticTexts["导出准备好了"].waitForExistence(timeout: 2))

        app.buttons["support.back"].tap()
        app.buttons["support.route.privacyAndAccountRemoval"].tap()
        XCTAssertTrue(app.staticTexts["隐私与法律"].waitForExistence(timeout: 3))
        app.buttons["support.account.start"].tap()
        XCTAssertTrue(app.staticTexts["再次确认"].waitForExistence(timeout: 2))
        app.buttons["support.account.confirm"].tap()
        XCTAssertTrue(app.staticTexts["账号移除已完成"].waitForExistence(timeout: 2))
    }

    @MainActor
    private func launchSupportApp() -> XCUIApplication {
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
