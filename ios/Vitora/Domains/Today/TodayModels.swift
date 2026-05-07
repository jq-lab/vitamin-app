import Foundation

struct HealthSignal: Identifiable, Codable, Equatable {
    enum Kind: String, CaseIterable, Codable, Equatable {
        case sleepSummary
        case stepCount
        case activeEnergy
        case heartRateAverage
        case restingHeartRate
        case heartRateVariability
        case manualSummary
    }

    var id: UUID
    var kind: Kind
    var day: Date
    var valueCategory: String
    var source: DataSourceAuthorization.Source
    var createdAt: Date

    init(
        id: UUID = UUID(),
        kind: Kind,
        day: Date,
        valueCategory: String,
        source: DataSourceAuthorization.Source,
        createdAt: Date = .now
    ) {
        self.id = id
        self.kind = kind
        self.day = day
        self.valueCategory = valueCategory
        self.source = source
        self.createdAt = createdAt
    }
}

enum TodayStateStatus: String, Codable, Equatable {
    case forming
    case ready
    case lowData
    case needsRecord
    case updated
}

enum TodayNextAction: String, Codable, Equatable {
    case startEnergyRitual
    case openAnalysis
    case recordWithLuna
    case reviewIntention
    case stayQuiet
}

struct TodayState: Identifiable, Codable, Equatable {
    var id: UUID
    var day: Date
    var status: TodayStateStatus
    var cycleContextSummary: String?
    var signals: [HealthSignal]
    var nextAction: TodayNextAction
    var dailyIntentionID: UUID?
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        day: Date,
        status: TodayStateStatus,
        cycleContextSummary: String? = nil,
        signals: [HealthSignal] = [],
        nextAction: TodayNextAction,
        dailyIntentionID: UUID? = nil,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.day = day
        self.status = status
        self.cycleContextSummary = cycleContextSummary
        self.signals = signals
        self.nextAction = nextAction
        self.dailyIntentionID = dailyIntentionID
        self.updatedAt = updatedAt
    }

    static func lowData(day: Date = .now) -> TodayState {
        TodayState(day: day, status: .lowData, nextAction: .recordWithLuna)
    }

    var isUsable: Bool {
        status != .forming
    }
}

enum EnergyScoreBand: String, Codable, Equatable {
    case low
    case steady
    case high
    case unknown
}

struct EnergySummary: Identifiable, Codable, Equatable {
    var id: UUID
    var day: Date
    var scorePercent: Int?
    var scoreBand: EnergyScoreBand
    var explanationSummary: String
    var supportingSignalKinds: [HealthSignal.Kind]

    init(
        id: UUID = UUID(),
        day: Date,
        scorePercent: Int? = nil,
        scoreBand: EnergyScoreBand,
        explanationSummary: String,
        supportingSignalKinds: [HealthSignal.Kind] = []
    ) {
        self.id = id
        self.day = day
        self.scorePercent = scorePercent
        self.scoreBand = scoreBand
        self.explanationSummary = explanationSummary
        self.supportingSignalKinds = supportingSignalKinds
    }

    var displayScore: String {
        scorePercent.map { "\($0)%" } ?? "--"
    }

    var displayBand: String {
        switch scoreBand {
        case .low:
            "需要放轻"
        case .steady:
            "能量平稳"
        case .high:
            "能量充足"
        case .unknown:
            "信息较少"
        }
    }
}

enum EnergyRitualState: String, Codable, Equatable {
    case notDue
    case due
    case running
    case completed
    case skipped
    case error
}

struct DailyOpeningState: Identifiable, Codable, Equatable {
    var id: UUID
    var day: Date
    var state: EnergyRitualState

    init(id: UUID = UUID(), day: Date, state: EnergyRitualState) {
        self.id = id
        self.day = day
        self.state = state
    }
}

struct EnergyRitualResult: Identifiable, Codable, Equatable {
    var id: UUID
    var day: Date
    var state: EnergyRitualState
    var energySummary: EnergySummary?
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        day: Date,
        state: EnergyRitualState,
        energySummary: EnergySummary? = nil,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.day = day
        self.state = state
        self.energySummary = energySummary
        self.completedAt = completedAt
    }

    var isTerminal: Bool {
        state == .completed || state == .skipped || state == .error
    }
}

struct TodayAnalysis: Identifiable, Codable, Equatable {
    struct SupportFactor: Identifiable, Codable, Equatable {
        var id: UUID
        var title: String
        var value: String
        var note: String

        init(id: UUID = UUID(), title: String, value: String, note: String) {
            self.id = id
            self.title = title
            self.value = value
            self.note = note
        }
    }

    var id: UUID
    var day: Date
    var summary: String
    var factors: [SupportFactor]
    var nextStep: String
    var optionSet: ABOptionSet?
    var isLowData: Bool

    init(
        id: UUID = UUID(),
        day: Date,
        summary: String,
        factors: [SupportFactor],
        nextStep: String,
        optionSet: ABOptionSet? = nil,
        isLowData: Bool
    ) {
        self.id = id
        self.day = day
        self.summary = summary
        self.factors = Array(factors.prefix(3))
        self.nextStep = nextStep
        self.optionSet = optionSet
        self.isLowData = isLowData
    }
}

struct ABOptionSet: Identifiable, Codable, Equatable {
    struct Option: Identifiable, Codable, Equatable {
        enum Label: String, Codable, Equatable {
            case a
            case b
        }

        var id: Label { label }
        var label: Label
        var title: String
        var contextSummary: String
        var reminderHint: String?
    }

    var id: UUID
    var day: Date
    var options: [Option]

    init(id: UUID = UUID(), day: Date, options: [Option]) {
        self.id = id
        self.day = day
        self.options = options
    }

    var isCompletePair: Bool {
        Set(options.map(\.label)) == Set([.a, .b])
    }
}

struct DailyIntention: Identifiable, Codable, Equatable {
    enum Choice: String, Codable, Equatable {
        case a
        case b
        case notSuitable
        case dismissed
    }

    enum State: String, Codable, Equatable {
        case candidate
        case selected
        case active
        case rejected
        case reviewAvailable
        case reviewed
        case dismissed
        case canceled
        case skipped
        case closed
    }

    var id: UUID
    var day: Date
    var choice: Choice
    var state: State
    var optionSetID: UUID?
    var selectedAt: Date?

    init(
        id: UUID = UUID(),
        day: Date,
        choice: Choice,
        state: State,
        optionSetID: UUID? = nil,
        selectedAt: Date? = nil
    ) {
        self.id = id
        self.day = day
        self.choice = choice
        self.state = state
        self.optionSetID = optionSetID
        self.selectedAt = selectedAt
    }

    var canOpenEveningReview: Bool {
        state == .reviewAvailable || state == .active
    }
}
