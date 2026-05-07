import Foundation

struct LunaChatService: LunaChatServicing {
    private let now: () -> Date

    init(now: @escaping () -> Date = Date.init) {
        self.now = now
    }

    func openingMessages(homeState: LunaHomeState, recentRecord: ParsedUnderstanding? = nil) -> [LunaConversationMessage] {
        var messages = [
            LunaConversationMessage(
                role: .luna,
                contentSummary: homeState.contextSummary,
                createdAt: now()
            ),
        ]

        if let summary = recentRecord?.summary, recentRecord?.isUserConfirmed == true {
            messages.append(
                LunaConversationMessage(
                    role: .system,
                    contentSummary: "已保存记录：\(summary)",
                    createdAt: now()
                )
            )
        }

        return messages
    }

    func userMessage(text: String) -> LunaConversationMessage? {
        let cleaned = normalized(text)
        guard !cleaned.isEmpty else {
            return nil
        }

        return LunaConversationMessage(
            role: .user,
            contentSummary: String(cleaned.prefix(180)),
            createdAt: now()
        )
    }

    func append(message: LunaConversationMessage, to messages: [LunaConversationMessage]) -> [LunaConversationMessage] {
        guard !normalized(message.contentSummary).isEmpty else {
            return messages
        }

        var next = messages
        next.append(message)
        return next
    }

    func responseDraft(
        messages: [LunaConversationMessage],
        context: AIContextPackage,
        capability: AppCapabilityState = .init()
    ) -> LunaResponseDraft {
        guard capability.canUseAI else {
            return LunaResponseDraft(
                job: .immersiveChatResponse,
                text: "我现在不能调用智能分析，但可以先陪你把这件事记下来。需要的话，点左下角 + 保存为记录。"
            )
        }

        let recentUserText = messages.last(where: { $0.role == .user })?.contentSummary
        let body = recentUserText.map { "我听到的是：\($0)。" } ?? "我会先从今天的状态开始。"
        let contextHint = context.todayContext == nil ? "如果信息还不多，我们就从你刚刚说的这件事开始。" : "结合今天的状态，可以先做一个很轻的调整。"

        return LunaResponseDraft(
            job: .immersiveChatResponse,
            text: "\(body)\(contextHint)"
        )
    }

    func lunaMessage(from draft: LunaResponseDraft) -> LunaConversationMessage? {
        let cleaned = normalized(draft.text)
        guard draft.guardStatus == .approved || draft.guardStatus == .needsLowDataRecovery else {
            return nil
        }
        guard !cleaned.isEmpty else {
            return nil
        }

        return LunaConversationMessage(
            role: .luna,
            contentSummary: cleaned,
            createdAt: now()
        )
    }

    private func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
