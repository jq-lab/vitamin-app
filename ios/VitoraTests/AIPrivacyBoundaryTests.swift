import XCTest
@testable import Vitora

final class AIPrivacyBoundaryTests: XCTestCase {
    func testRecordUnderstandingContextMinimizesIdentityAndHealthValues() {
        let builder = AIContextBuilder()
        let profile = UserProfile(displayLabel: "Jocelyn")
        let record = LunaRecord(
            text: "phone:13800000000 user@example.com 昨晚睡眠 7.2h，HRV 48ms，心率 72bpm，能量 68%，下午有点累",
            quickType: .sleep
        )

        let context = builder.buildRecordUnderstandingContext(record: record, userProfile: profile)
        let payload = flattened(context)

        XCTAssertEqual(context.job, .lunaRecordUnderstanding)
        XCTAssertEqual(context.userContext, "preferred-label-only")
        XCTAssertFalse(context.containsDirectIdentity)
        XCTAssertFalse(payload.contains("Jocelyn"))
        XCTAssertFalse(payload.contains("13800000000"))
        XCTAssertFalse(payload.contains("user@example.com"))
        XCTAssertFalse(payload.contains("7.2h"))
        XCTAssertFalse(payload.contains("48ms"))
        XCTAssertFalse(payload.contains("72bpm"))
        XCTAssertFalse(payload.contains("68%"))
        XCTAssertTrue(payload.contains("[health-value]"))
    }

    func testImmersiveChatContextUsesRecentSummariesOnlyAndRedactsSensitiveDetails() {
        let builder = AIContextBuilder()
        let messages = [
            LunaConversationMessage(role: .user, contentSummary: "很早之前的一条原始长记录不应进入上下文"),
            LunaConversationMessage(role: .luna, contentSummary: "早期回复也不应进入上下文"),
            LunaConversationMessage(role: .user, contentSummary: "account:abc phone:123 user@example.com HRV 48ms 下午有点累"),
            LunaConversationMessage(role: .luna, contentSummary: "可能和睡眠有关，先放轻一点"),
            LunaConversationMessage(role: .user, contentSummary: "睡眠 7.2h，能量 68%，今天压力大"),
            LunaConversationMessage(role: .luna, contentSummary: "我会先理解为今天状态校准"),
        ]

        let context = builder.buildImmersiveChatContext(messages: messages)
        let conversation = context.conversationContext ?? ""

        XCTAssertEqual(context.job, .immersiveChatResponse)
        XCTAssertFalse(context.containsDirectIdentity)
        XCTAssertFalse(conversation.contains("很早之前的一条原始长记录"))
        XCTAssertFalse(conversation.contains("早期回复也不应进入上下文"))
        XCTAssertFalse(conversation.contains("account:"))
        XCTAssertFalse(conversation.contains("phone:"))
        XCTAssertFalse(conversation.contains("@"))
        XCTAssertFalse(conversation.contains("48ms"))
        XCTAssertFalse(conversation.contains("7.2h"))
        XCTAssertFalse(conversation.contains("68%"))
        XCTAssertLessThanOrEqual(conversation.count, 360)
    }

    func testVitoraOutputGuardBlocksRestrictedExpressionsAndKeepsLegacyWrapperCompatible() {
        let restricted = LunaResponseDraft(job: .todayExplanation, text: "这个建议可以保证效果，包含 CX-003。")

        XCTAssertEqual(VitoraOutputGuard().validate(restricted).guardStatus, .blocked)
        XCTAssertEqual(LunaOutputGuard().validate(restricted).guardStatus, .blocked)

        let unavailable = VitoraOutputGuard().validate(
            LunaResponseDraft(job: .immersiveChatResponse, text: "先记录下来。"),
            capability: AppCapabilityState(aiAvailability: .unavailable)
        )
        XCTAssertEqual(unavailable.guardStatus, .needsLowDataRecovery)
    }

    func testCapabilityStateMapsUserFeedbackForLowDataAIUnavailableAndDeniedPermissions() {
        let lowData = AppCapabilityState(dataSourceState: .skipped)
        XCTAssertTrue(lowData.userFeedbacks.contains { $0.kind == .lowData && $0.complianceLabelID == "CL-LOW-DATA" })

        let richData = AppCapabilityState(dataSourceState: .authorized)
        XCTAssertFalse(richData.userFeedbacks.contains { $0.kind == .lowData })

        let unavailable = AppCapabilityState(aiAvailability: .unavailable)
        XCTAssertTrue(unavailable.userFeedbacks.contains { $0.kind == .aiUnavailable && $0.complianceLabelID == "CL-AI-UNAVAILABLE" })

        let denied = AppCapabilityState(dataSourceState: .denied)
        XCTAssertTrue(denied.userFeedbacks.contains { $0.kind == .permissionDenied })
        XCTAssertTrue(denied.userFeedbacks.contains { $0.kind == .lowData })
    }

    private func flattened(_ context: AIContextPackage) -> String {
        [
            context.userContext,
            context.todayContext,
            context.cycleContext,
            context.recordContext,
            context.conversationContext,
            context.intentionContext,
            context.reviewContext,
        ]
        .compactMap { $0 }
        .joined(separator: " | ")
    }
}
