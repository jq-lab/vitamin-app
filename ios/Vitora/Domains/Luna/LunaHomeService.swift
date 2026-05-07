import Foundation

struct LunaHomeService: LunaHomeServicing {
    func context(today: TodayState?, intention: DailyIntention?, review: EveningReview?) -> String {
        makeState(today: today, intention: intention, review: review).contextSummary
    }

    func makeState(
        today: TodayState?,
        intention: DailyIntention?,
        review: EveningReview?,
        recentRecord: ParsedUnderstanding? = nil,
        isLowData: Bool? = nil
    ) -> LunaHomeState {
        let lowData = isLowData ?? today.map { $0.status == .lowData || $0.signals.isEmpty } ?? true
        let dateContext = today?.cycleContextSummary ?? "Day 18 · 黄体期"

        let contextSummary: String
        let contextDetail: String
        if lowData {
            contextSummary = "今天可参考的信息还不多"
            contextDetail = "你可以先告诉 Vitora 一件事，记录会成为今天的上下文。"
        } else if let intention, intention.canOpenEveningReview {
            contextSummary = "今天的小尝试已经记录"
            contextDetail = "晚一点可以回看它对你有没有帮助。"
        } else {
            contextSummary = "今日黄体期 Day 18，身体在努力恢复中"
            contextDetail = "Vitora 会结合记录、周期和 Today 状态，帮你轻轻整理今天。"
        }

        let reviewPrompt = review?.status == .available ? "可以做一次轻复盘，看看今天前后有什么变化。" : nil

        return LunaHomeState(
            prompt: "今天发生了什么呢？",
            contextSummary: contextSummary,
            contextDetail: contextDetail,
            dateContext: dateContext,
            recentRecordSummary: recentRecord?.isUserConfirmed == true ? recentRecord?.summary : nil,
            reviewPrompt: reviewPrompt,
            isLowData: lowData
        )
    }
}
