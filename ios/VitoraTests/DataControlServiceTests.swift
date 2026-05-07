import XCTest
@testable import Vitora

final class DataControlServiceTests: XCTestCase {
    func testDataExportMovesThroughConfirmationReadyAndCompletedStates() {
        let requestedAt = Date(timeIntervalSince1970: 1_770_000_000)
        let completedAt = Date(timeIntervalSince1970: 1_770_000_600)
        var currentDate = requestedAt
        let service = DataExportService(now: { currentDate })
        let exportItems = [
            ExportItem(id: UUID(), modelID: .dm001, dataClass: .dc01),
            ExportItem(id: UUID(), modelID: .dm010, dataClass: .dc03),
        ]

        let request = service.requestExport()
        XCTAssertEqual(request.state, .viewing)

        let confirming = service.beginConfirmation(request)
        XCTAssertEqual(confirming.state, .confirming)

        let package = service.prepare(confirming, exportItems: exportItems)
        XCTAssertEqual(package.request.state, .ready)
        XCTAssertEqual(package.itemCount, 2)
        XCTAssertTrue(package.containsSensitiveClasses)

        currentDate = completedAt
        let completed = service.complete(package.request)
        XCTAssertEqual(completed.state, .completed)
        XCTAssertEqual(completed.completedAt, completedAt)
    }

    func testAccountRemovalClearsPersistenceAndReturnsOnboardingGate() throws {
        let persistence = InMemoryPersistenceClient()
        let profile = UserProfile(displayLabel: "小雨")
        try persistence.save(profile, id: profile.id, modelID: .dm001, dataClass: .dc01)
        XCTAssertEqual(persistence.exportSnapshot().count, 1)

        let requestedAt = Date(timeIntervalSince1970: 1_770_000_000)
        let completedAt = Date(timeIntervalSince1970: 1_770_000_500)
        var currentDate = requestedAt
        let service = AccountRemovalService(now: { currentDate })

        let request = service.requestRemoval()
        let confirming = service.beginConfirmation(request)
        XCTAssertEqual(confirming.state, .confirming)

        currentDate = completedAt
        let result = try service.complete(confirming, persistence: persistence)

        XCTAssertEqual(result.request.state, .completed)
        XCTAssertEqual(result.request.completedAt, completedAt)
        XCTAssertEqual(result.gateState, .needsOnboarding)
        XCTAssertTrue(persistence.exportSnapshot().isEmpty)
    }
}
