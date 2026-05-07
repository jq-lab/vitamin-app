import XCTest
@testable import Vitora

final class PersistenceContractTests: XCTestCase {
    func testSensitiveDataClassIsStoredWithProtectedPayloadFlag() throws {
        let persistence = InMemoryPersistenceClient()
        let record = LunaRecord(text: "一条用户记录", quickType: .freeText)

        try persistence.save(record, id: record.id, modelID: .dm008, dataClass: .dc02)

        let stored = try XCTUnwrap(persistence.storedRecord(id: record.id, modelID: .dm008))
        XCTAssertTrue(stored.encrypted)
        XCTAssertNotEqual(stored.payload, try JSONEncoder().encode(record))
    }

    func testTransientContextIsNotPersistedByDefault() {
        let persistence = InMemoryPersistenceClient()
        let context = AIContextPackage(job: .todayExplanation, todayContext: "status=ready")

        XCTAssertThrowsError(try persistence.save(context, id: context.id, modelID: .dm022, dataClass: .dc05))
    }

    func testExportSnapshotCoversSavedP0UserData() throws {
        let persistence = InMemoryPersistenceClient()
        let profile = UserProfile(displayLabel: "Vitora")
        let intention = DailyIntention(day: Date(timeIntervalSince1970: 0), choice: .a, state: .active)

        try persistence.save(profile, id: profile.id, modelID: .dm001, dataClass: .dc01)
        try persistence.save(intention, id: intention.id, modelID: .dm016, dataClass: .dc03)

        let exported = persistence.exportSnapshot().map(\.modelID)
        XCTAssertTrue(exported.contains(.dm001))
        XCTAssertTrue(exported.contains(.dm016))
    }

    func testAccountRemovalClearsLocalStateAndReturnsGate() throws {
        let keyStore = InMemorySecureKeyStore()
        let persistence = InMemoryPersistenceClient(keyStore: keyStore)
        let profile = UserProfile(displayLabel: "Vitora")

        try persistence.save(profile, id: profile.id, modelID: .dm001, dataClass: .dc01)
        let gate = try persistence.removeAccountData()

        XCTAssertEqual(gate, .needsOnboarding)
        XCTAssertTrue(persistence.exportSnapshot().isEmpty)
        XCTAssertTrue(keyStore.isEmpty)
    }
}
