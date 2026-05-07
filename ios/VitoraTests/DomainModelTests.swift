import XCTest
@testable import Vitora

final class DomainModelTests: XCTestCase {
    func testDomainModelIDsCoverDM001ThroughDM025() {
        XCTAssertEqual(DomainModelID.allCases.count, 25)
        XCTAssertEqual(DomainModelID.allCases.first?.rawValue, "DM-001")
        XCTAssertEqual(DomainModelID.allCases.last?.rawValue, "DM-025")
    }

    func testAppGateAllowsLowDataMainTabs() {
        let service = AppGateService()
        let profile = UserProfile(displayLabel: "Luna")
        let skipped = DataSourceAuthorization(state: .skipped)

        XCTAssertEqual(service.resolveGate(profile: profile, dataSource: skipped), .lowDataReady)
        XCTAssertTrue(service.resolveGate(profile: profile, dataSource: skipped).allowsMainTabs)
    }

    func testSupportKeepsExactlyP0Items() {
        XCTAssertEqual(SupportItem.p0Items.count, 6)
        XCTAssertEqual(SupportItem.p0Items, [.profile, .dataSources, .nutrition, .reminders, .dataExport, .privacyAndAccountRemoval])
    }

    func testLunaRecordRequiresConfirmationBeforeSavedUnderstanding() {
        let record = LunaRecord(text: "今天想记录一点感受", quickType: .freeText)
        let service = LunaRecordService()
        let understanding = service.confirm(record: record, summary: "用户确认后的简短摘要")

        XCTAssertEqual(record.state, .draft)
        XCTAssertTrue(understanding.isUserConfirmed)
        XCTAssertEqual(understanding.recordID, record.id)
    }
}
