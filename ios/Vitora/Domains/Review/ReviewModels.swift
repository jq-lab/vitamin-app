import Foundation

enum EveningReviewStatus: String, Codable, Equatable {
    case unavailable
    case available
    case submitted
    case skipped
}

enum EveningReviewFeedback: String, Codable, Equatable {
    case helpful
    case neutral
    case notSuitable
    case skipped

    var displayText: String {
        switch self {
        case .helpful:
            "有帮助"
        case .neutral:
            "一般"
        case .notSuitable:
            "不适合"
        case .skipped:
            "今天先不复盘"
        }
    }

    var learningTone: String {
        switch self {
        case .helpful:
            "这类低负担建议对今天有帮助"
        case .neutral:
            "这类建议影响一般，需要更贴近当时状态"
        case .notSuitable:
            "这类建议今天不适合，后续需要先询问限制"
        case .skipped:
            "用户暂时不想复盘，不生成效果判断"
        }
    }
}

struct EveningReview: Identifiable, Codable, Equatable {
    var id: UUID
    var day: Date
    var intentionID: UUID?
    var beforeSummary: String
    var afterSummary: String
    var status: EveningReviewStatus
    var submittedAt: Date?

    init(
        id: UUID = UUID(),
        day: Date,
        intentionID: UUID? = nil,
        beforeSummary: String = "",
        afterSummary: String = "",
        status: EveningReviewStatus = .unavailable,
        submittedAt: Date? = nil
    ) {
        self.id = id
        self.day = day
        self.intentionID = intentionID
        self.beforeSummary = beforeSummary
        self.afterSummary = afterSummary
        self.status = status
        self.submittedAt = submittedAt
    }

    var comparesSameDayEffect: Bool {
        !beforeSummary.isEmpty && !afterSummary.isEmpty
    }
}

struct VitoraLearningSignal: Identifiable, Codable, Equatable {
    var id: UUID
    var sourceIDs: [UUID]
    var summary: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        sourceIDs: [UUID],
        summary: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.sourceIDs = sourceIDs
        self.summary = summary
        self.createdAt = createdAt
    }
}

typealias LunaLearningSignal = VitoraLearningSignal
