import XCTest
@testable import Vitora

final class LunaChatServiceTests: XCTestCase {
    func testOpeningMessagesUseHomeContextAndConfirmedRecord() {
        let service = LunaChatService(now: { Date(timeIntervalSince1970: 1_770_000_000) })
        let home = LunaHomeState(
            prompt: "今天发生了什么呢？",
            contextSummary: "今日黄体期 Day 18，身体在努力恢复中",
            contextDetail: "Luna 会结合记录轻轻整理。",
            dateContext: "Day 18 · 黄体期",
            isLowData: false
        )
        let record = ParsedUnderstanding(recordID: UUID(), summary: "能量记录：下午有点累", isUserConfirmed: true)

        let messages = service.openingMessages(homeState: home, recentRecord: record)

        XCTAssertEqual(messages.count, 2)
        XCTAssertEqual(messages.first?.role, .luna)
        XCTAssertEqual(messages.first?.contentSummary, "今日黄体期 Day 18，身体在努力恢复中")
        XCTAssertEqual(messages.last?.role, .system)
        XCTAssertTrue(messages.last?.contentSummary.contains("已保存记录") == true)
    }

    func testBlankUserMessageDoesNotEnterConversation() {
        let service = LunaChatService()

        XCTAssertNil(service.userMessage(text: "   \n"))
    }

    func testImmersiveChatContextIsMinimizedAndSanitized() {
        let builder = AIContextBuilder()
        let messages = [
            LunaConversationMessage(role: .user, contentSummary: "account:abc phone:123 user@example.com 下午有点累"),
            LunaConversationMessage(role: .luna, contentSummary: "我们先把节奏放轻一点"),
        ]

        let context = builder.buildImmersiveChatContext(messages: messages)

        XCTAssertEqual(context.job, .immersiveChatResponse)
        XCTAssertFalse(context.containsDirectIdentity)
        XCTAssertNotNil(context.conversationContext)
        XCTAssertFalse(context.conversationContext?.contains("account:") == true)
        XCTAssertFalse(context.conversationContext?.contains("phone:") == true)
        XCTAssertFalse(context.conversationContext?.contains("@") == true)
    }

    func testUnavailableAIProducesRecoverableLunaDraft() {
        let service = LunaChatService()
        let draft = service.responseDraft(
            messages: [],
            context: AIContextPackage(job: .immersiveChatResponse),
            capability: AppCapabilityState(aiAvailability: .unavailable)
        )
        let guarded = LunaOutputGuard().validate(draft, capability: AppCapabilityState(aiAvailability: .unavailable))
        let message = service.lunaMessage(from: guarded)

        XCTAssertEqual(guarded.guardStatus, .needsLowDataRecovery)
        XCTAssertTrue(message?.contentSummary.contains("先陪你把这件事记下来") == true)
    }

    func testBlockedDraftDoesNotBecomeVisibleMessage() {
        let service = LunaChatService()
        let blocked = LunaResponseDraft(job: .immersiveChatResponse, text: "blocked", guardStatus: .blocked)

        XCTAssertNil(service.lunaMessage(from: blocked))
    }
}
