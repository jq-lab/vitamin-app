import XCTest
@testable import Vitora

final class LunaRecordFallbackTests: XCTestCase {
    func testAIUnavailableStillAllowsManualFallbackSave() {
        let service = LunaRecordService()
        let capability = AppCapabilityState(aiAvailability: .unavailable)
        let draft = service.draft(text: "昨晚睡了 7 小时，深睡偏少", quickType: .freeText)

        let preview = service.parse(record: draft, capability: capability)
        let saved = service.save(record: draft, preview: preview)

        XCTAssertFalse(preview.aiWasAvailable)
        XCTAssertTrue(preview.canSaveAsFallback)
        XCTAssertEqual(preview.complianceLabelID, "CL-AI-UNAVAILABLE")
        XCTAssertTrue(saved.understanding.isUserConfirmed)
        XCTAssertEqual(saved.record.state, .saved)
    }

    func testRecordUnderstandingContextUsesDraftButRemovesDirectIdentity() {
        let record = LunaRecord(text: "phone:123 user@example.com 下午有点累", quickType: .energy)

        let context = AIContextBuilder().buildRecordUnderstandingContext(record: record)

        XCTAssertEqual(context.job, .lunaRecordUnderstanding)
        XCTAssertFalse(context.containsDirectIdentity)
        XCTAssertEqual(context.recordContext, "下午有点累")
    }

    func testRecordUnderstandingGuardRequiresRecoverableAIState() {
        let draft = LunaResponseDraft(job: .lunaRecordUnderstanding, text: "能量记录：下午有点累")

        let blocked = LunaOutputGuard().validateRecordUnderstanding(
            draft,
            capability: AppCapabilityState(aiAvailability: .unavailable)
        )
        let approved = LunaOutputGuard().validateRecordUnderstanding(draft)

        XCTAssertEqual(blocked.guardStatus, .needsLowDataRecovery)
        XCTAssertEqual(approved.guardStatus, .approved)
    }
}
