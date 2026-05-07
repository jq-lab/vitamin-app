import XCTest
@testable import Vitora

final class SupportServiceTests: XCTestCase {
    func testVisibleSupportItemsAreExactlyP0ItemsInSpecOrder() {
        let service = SupportService()

        let items = service.visibleItems()

        XCTAssertEqual(items, [
            .profile,
            .dataSources,
            .nutrition,
            .reminders,
            .dataExport,
            .privacyAndAccountRemoval,
        ])
        XCTAssertEqual(items.map(\.title), [
            "个人资料",
            "HealthKit 与数据来源",
            "营养补给",
            "提醒偏好",
            "数据导出",
            "隐私法律与账号移除",
        ])
    }

    func testPanelStateOnlyContainsP0SupportRoutes() {
        let service = SupportService()

        let state = service.panelState(selectedRoute: .dataExport)

        XCTAssertEqual(state.visibleItems, SupportItem.p0Items)
        XCTAssertEqual(state.selectedRoute, .dataExport)
        XCTAssertEqual(state.visibleItems.map(\.route), SupportRoute.p0Routes)
    }

    func testDataSourceSummaryKeepsAppUsableWhenHealthKitSkippedOrDenied() {
        let service = SupportService()

        let skipped = service.dataSourceSummary(for: DataSourceAuthorization(state: .skipped))
        let denied = service.dataSourceSummary(for: DataSourceAuthorization(state: .denied))
        let authorized = service.dataSourceSummary(for: DataSourceAuthorization(state: .authorized))

        XCTAssertTrue(skipped.keepsAppUsable)
        XCTAssertTrue(denied.keepsAppUsable)
        XCTAssertTrue(skipped.isLowDataMode)
        XCTAssertTrue(denied.isLowDataMode)
        XCTAssertFalse(authorized.isLowDataMode)
        XCTAssertTrue(skipped.detail.contains("低数据"))
    }
}
