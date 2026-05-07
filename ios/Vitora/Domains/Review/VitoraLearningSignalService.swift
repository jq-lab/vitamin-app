import Foundation

struct VitoraLearningSignalService {
    var now: () -> Date = Date.init

    func makeSignal(review: EveningReview, intention: DailyIntention?) -> VitoraLearningSignal? {
        guard review.status == .submitted, review.comparesSameDayEffect else {
            return nil
        }

        var sourceIDs = [review.id]
        if let intentionID = review.intentionID ?? intention?.id {
            sourceIDs.append(intentionID)
        }

        let feedbackSummary = review.afterSummary.replacingOccurrences(of: "晚间反馈：", with: "")
        let choiceSummary = intention.map { "；当日意图：\($0.choice.rawValue)" } ?? ""

        return VitoraLearningSignal(
            sourceIDs: sourceIDs,
            summary: "从今天的建议和晚间反馈学习：\(feedbackSummary)\(choiceSummary)。后续建议要保持低负担，并优先解释原因。",
            createdAt: now()
        )
    }
}
