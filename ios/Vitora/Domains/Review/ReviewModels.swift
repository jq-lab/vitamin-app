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

enum SleepSeedKind: String, Codable, CaseIterable, Identifiable {
    case recovery
    case reserve
    case lightMovement

    var id: String { rawValue }

    var title: String {
        switch self {
        case .recovery:
            return "恢复种子"
        case .reserve:
            return "留余量种子"
        case .lightMovement:
            return "轻动种子"
        }
    }

    var shortTitle: String {
        switch self {
        case .recovery:
            return "恢复"
        case .reserve:
            return "留余量"
        case .lightMovement:
            return "轻动"
        }
    }

    var subtitle: String {
        switch self {
        case .recovery:
            return "明早重点看休息有没有把状态托回来。"
        case .reserve:
            return "明早重点看今天能不能少透支一点。"
        case .lightMovement:
            return "明早重点看轻活动是否让恢复更顺。"
        }
    }

    var todayAction: String {
        switch self {
        case .recovery:
            return "午后留 20 分钟安静恢复"
        case .reserve:
            return "下午只保留一件高负担事情"
        case .lightMovement:
            return "傍晚轻走 10 分钟"
        }
    }
}

enum SleepSeedGrowthState: String, Codable, Equatable {
    case seed
    case halfOpen
    case bloom
    case dormant

    var displayText: String {
        switch self {
        case .seed:
            return "已种下"
        case .halfOpen:
            return "半开"
        case .bloom:
            return "全开"
        case .dormant:
            return "休眠"
        }
    }

    var evidenceText: String {
        switch self {
        case .seed:
            return "等待明早观察"
        case .halfOpen:
            return "待确认"
        case .bloom:
            return "有帮助"
        case .dormant:
            return "可复活"
        }
    }
}

struct SleepSeedCard: Identifiable, Codable, Equatable {
    var id: UUID
    var day: Date
    var kind: SleepSeedKind
    var growthState: SleepSeedGrowthState
    var energyPercent: Int
    var reason: String
    var todayAction: String
    var feedbackSummary: String
    var learnedSignal: String

    init(
        id: UUID = UUID(),
        day: Date = .now,
        kind: SleepSeedKind,
        growthState: SleepSeedGrowthState,
        energyPercent: Int,
        reason: String,
        todayAction: String,
        feedbackSummary: String,
        learnedSignal: String
    ) {
        self.id = id
        self.day = day
        self.kind = kind
        self.growthState = growthState
        self.energyPercent = energyPercent
        self.reason = reason
        self.todayAction = todayAction
        self.feedbackSummary = feedbackSummary
        self.learnedSignal = learnedSignal
    }

    func updatingGrowthState(_ state: SleepSeedGrowthState) -> SleepSeedCard {
        var copy = self
        copy.growthState = state
        switch state {
        case .seed:
            copy.feedbackSummary = "等待明早观察"
            copy.learnedSignal = "Vitora 会先看休息和明早感受。"
        case .halfOpen:
            copy.feedbackSummary = "待确认"
            copy.learnedSignal = "还需要今天的反馈确认这条建议是否适合你。"
        case .bloom:
            copy.feedbackSummary = "有帮助"
            copy.learnedSignal = "这类低负担建议更适合当前状态。"
        case .dormant:
            copy.feedbackSummary = "可复活"
            copy.learnedSignal = "这次不代表失败，之后可以补充一句重新判断。"
        }
        return copy
    }

    static let morningHalfOpenSample = SleepSeedCard(
        day: Date(timeIntervalSince1970: 1_770_000_000),
        kind: .reserve,
        growthState: .halfOpen,
        energyPercent: 68,
        reason: "睡眠偏短，HRV 仍在恢复",
        todayAction: SleepSeedKind.reserve.todayAction,
        feedbackSummary: "待确认",
        learnedSignal: "今天如果留出缓冲，Vitora 能判断这类建议是否真的帮你稳住下午。"
    )

    static let cycleEvidenceSamples: [SleepSeedCard] = [
        SleepSeedCard(kind: .reserve, growthState: .bloom, energyPercent: 72, reason: "午后保留余量后晚间反馈更稳", todayAction: SleepSeedKind.reserve.todayAction, feedbackSummary: "有帮助", learnedSignal: "留余量类建议更适合黄体期中段。"),
        SleepSeedCard(kind: .recovery, growthState: .halfOpen, energyPercent: 61, reason: "睡眠短但上午恢复感尚可", todayAction: SleepSeedKind.recovery.todayAction, feedbackSummary: "待确认", learnedSignal: "恢复建议需要再结合睡眠时长确认。"),
        SleepSeedCard(kind: .lightMovement, growthState: .bloom, energyPercent: 70, reason: "轻走后晚间疲惫下降", todayAction: SleepSeedKind.lightMovement.todayAction, feedbackSummary: "有帮助", learnedSignal: "轻动建议可作为低谷后的回升动作。"),
        SleepSeedCard(kind: .reserve, growthState: .dormant, energyPercent: 54, reason: "当日安排临时变重，反馈不够完整", todayAction: SleepSeedKind.reserve.todayAction, feedbackSummary: "可复活", learnedSignal: "这张花卡保留为休眠证据，之后可补充一句。"),
        SleepSeedCard(kind: .recovery, growthState: .bloom, energyPercent: 76, reason: "午休后下午低谷变浅", todayAction: SleepSeedKind.recovery.todayAction, feedbackSummary: "有帮助", learnedSignal: "安静恢复对午后波动有帮助。"),
        SleepSeedCard(kind: .lightMovement, growthState: .halfOpen, energyPercent: 64, reason: "活动量合适，但晚间反馈待确认", todayAction: SleepSeedKind.lightMovement.todayAction, feedbackSummary: "待确认", learnedSignal: "轻动建议还需要区分时段。"),
        SleepSeedCard(kind: .reserve, growthState: .bloom, energyPercent: 69, reason: "减少下午强安排后恢复更平稳", todayAction: SleepSeedKind.reserve.todayAction, feedbackSummary: "有帮助", learnedSignal: "下午留白可能是本周期的有效助力。"),
    ]
}
