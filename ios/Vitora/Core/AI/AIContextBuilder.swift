import Foundation

struct AIContextBuilder {
    func build(
        job: AIJob,
        userProfile: UserProfile? = nil,
        todayState: TodayState? = nil,
        cycleContext: CycleContext? = nil,
        confirmedRecord: ParsedUnderstanding? = nil,
        intention: DailyIntention? = nil,
        review: EveningReview? = nil
    ) -> AIContextPackage {
        AIContextPackage(
            job: job,
            userContext: userProfile.map { _ in "preferred-label-only" },
            todayContext: todayState.map { "status=\($0.status.rawValue);next=\($0.nextAction.rawValue)" },
            cycleContext: cycleContext.map { $0.summary },
            recordContext: confirmedRecord?.isUserConfirmed == true ? confirmedRecord?.summary : nil,
            intentionContext: intention.map { "choice=\($0.choice.rawValue);state=\($0.state.rawValue)" },
            reviewContext: review?.comparesSameDayEffect == true ? "same-day-feedback" : nil
        )
    }

    func buildRecordUnderstandingContext(record: LunaRecord, userProfile: UserProfile? = nil) -> AIContextPackage {
        AIContextPackage(
            job: .lunaRecordUnderstanding,
            userContext: userProfile.map { _ in "preferred-label-only" },
            recordContext: sanitized(record.aiInputSummary)
        )
    }

    func buildImmersiveChatContext(
        messages: [LunaConversationMessage],
        userProfile: UserProfile? = nil,
        todayState: TodayState? = nil,
        confirmedRecord: ParsedUnderstanding? = nil,
        intention: DailyIntention? = nil
    ) -> AIContextPackage {
        AIContextPackage(
            job: .immersiveChatResponse,
            userContext: userProfile.map { _ in "preferred-label-only" },
            todayContext: todayState.map { "status=\($0.status.rawValue);next=\($0.nextAction.rawValue)" },
            recordContext: confirmedRecord?.isUserConfirmed == true ? sanitized(confirmedRecord?.summary ?? "") : nil,
            conversationContext: minimizedConversation(messages),
            intentionContext: intention.map { "choice=\($0.choice.rawValue);state=\($0.state.rawValue)" }
        )
    }

    private func sanitized(_ value: String) -> String {
        let identityRedacted = value
            .split(whereSeparator: { $0.isWhitespace || $0.isNewline })
            .filter { token in
                let lowercased = token.lowercased()
                return !lowercased.contains("@")
                    && !lowercased.contains("account:")
                    && !lowercased.contains("phone:")
            }
            .joined(separator: " ")
        return redactedHealthValues(identityRedacted)
    }

    private func minimizedConversation(_ messages: [LunaConversationMessage]) -> String? {
        let summaries = messages
            .suffix(4)
            .map { message in
                let role = message.role == .user ? "user" : "luna"
                let content = sanitized(message.contentSummary)
                return "\(role):\(String(content.prefix(80)))"
            }
            .filter { !$0.hasSuffix(":") }

        guard !summaries.isEmpty else {
            return nil
        }

        return summaries.joined(separator: " | ")
    }

    private func redactedHealthValues(_ value: String) -> String {
        var result = value
        let patterns = [
            #"(?i)\d+(\.\d+)?\s*(h|hr|hrs|hour|hours|ms|bpm|%)"#,
            #"\d+(\.\d+)?\s*(小时|分钟|毫秒|次/分)"#,
        ]

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern) else {
                continue
            }
            let range = NSRange(result.startIndex..<result.endIndex, in: result)
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: range,
                withTemplate: "[health-value]"
            )
        }

        return result
    }
}
