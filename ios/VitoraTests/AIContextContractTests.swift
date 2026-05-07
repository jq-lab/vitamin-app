import XCTest
@testable import Vitora

final class AIContextContractTests: XCTestCase {
    func testContextBuilderRemovesDirectIdentityFields() {
        let builder = AIContextBuilder()
        let profile = UserProfile(displayLabel: "Real Name")
        let context = builder.build(job: .todayExplanation, userProfile: profile)

        XCTAssertFalse(context.containsDirectIdentity)
        XCTAssertEqual(context.userContext, "preferred-label-only")
    }

    func testUnconfirmedRecordDoesNotEnterContext() {
        let builder = AIContextBuilder()
        let record = ParsedUnderstanding(recordID: UUID(), summary: "尚未确认内容", isUserConfirmed: false)
        let context = builder.build(job: .lunaRecordUnderstanding, confirmedRecord: record)

        XCTAssertNil(context.recordContext)
    }

    func testOutputGuardBlocksRestrictedCategoryMarkers() {
        let draft = LunaResponseDraft(job: .todayExplanation, text: "这段输出包含 CX-001")
        let guarded = LunaOutputGuard().validate(draft)

        XCTAssertEqual(guarded.guardStatus, .blocked)
    }

    func testAIUnavailablePathKeepsRecoverableDraft() async {
        let client = UnavailableLunaAIClient()
        let context = AIContextPackage(job: .lunaRecordUnderstanding, recordContext: "summary")
        let result = await client.run(job: .lunaRecordUnderstanding, context: context)

        XCTAssertEqual(result, .failure(.unavailable))
    }
}
