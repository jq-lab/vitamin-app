import Foundation

struct EveningReviewService: EveningReviewServicing {
    var now: () -> Date = Date.init
    var calendar: Calendar = .current

    func availability(
        day: Date,
        intention: DailyIntention?,
        morningSummary: String,
        suggestionSummary: String
    ) -> EveningReview {
        guard let intention,
              intention.canOpenEveningReview,
              calendar.isDate(intention.day, inSameDayAs: day)
        else {
            return EveningReview(day: day, intentionID: intention?.id, status: .unavailable)
        }

        return EveningReview(
            day: day,
            intentionID: intention.id,
            beforeSummary: "\(morningSummary)；Vitora 早些时候建议：\(suggestionSummary)",
            afterSummary: "",
            status: .available
        )
    }

    func submit(
        day: Date,
        intentionID: UUID?,
        before: String,
        feedback: EveningReviewFeedback,
        note: String?
    ) -> EveningReview {
        let detail = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        let noteText = detail?.isEmpty == false ? "；补充：\(detail!)" : ""

        return EveningReview(
            day: day,
            intentionID: intentionID,
            beforeSummary: before,
            afterSummary: "晚间反馈：\(feedback.displayText)\(noteText)",
            status: feedback == .skipped ? .skipped : .submitted,
            submittedAt: now()
        )
    }

    func skip(day: Date, intentionID: UUID?, before: String) -> EveningReview {
        submit(day: day, intentionID: intentionID, before: before, feedback: .skipped, note: nil)
    }
}
