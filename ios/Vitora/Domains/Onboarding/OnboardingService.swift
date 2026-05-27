import Foundation

struct OnboardingDraft: Equatable {
    var displayLabel: String
    var authMethod: AuthMethod
    var sportPreferences: [SportPreference]
    var periodRegularity: PeriodRegularity
    var lastPeriodDate: Date?
    var averageCycleLength: Int?
    var averagePeriodDuration: Int?
    var flowAmount: FlowAmount?
    var dysmenorrheaSeverity: DysmenorrheaSeverity
    var dysmenorrheaReminderEnabled: Bool
    var periodImpactAreas: [PeriodImpactArea]
    var exerciseIntensity: ExerciseIntensity?
    var customExercise: String?
    var improvementGoals: [ImprovementGoal]
    var specialConditions: [SpecialCondition]
    var specialConditionNote: String?
    var dataSourceAuthorization: DataSourceAuthorization
    var notificationPermissionState: NotificationPermissionState

    init(
        displayLabel: String = "",
        authMethod: AuthMethod = .local,
        sportPreferences: [SportPreference] = [],
        periodRegularity: PeriodRegularity = .unsure,
        lastPeriodDate: Date? = nil,
        averageCycleLength: Int? = nil,
        averagePeriodDuration: Int? = nil,
        flowAmount: FlowAmount? = nil,
        dysmenorrheaSeverity: DysmenorrheaSeverity = .none,
        dysmenorrheaReminderEnabled: Bool = false,
        periodImpactAreas: [PeriodImpactArea] = [],
        exerciseIntensity: ExerciseIntensity? = nil,
        customExercise: String? = nil,
        improvementGoals: [ImprovementGoal] = [],
        specialConditions: [SpecialCondition] = [],
        specialConditionNote: String? = nil,
        dataSourceAuthorization: DataSourceAuthorization = .notAsked(),
        notificationPermissionState: NotificationPermissionState = .notDetermined
    ) {
        self.displayLabel = displayLabel
        self.authMethod = authMethod
        self.sportPreferences = sportPreferences
        self.periodRegularity = periodRegularity
        self.lastPeriodDate = lastPeriodDate
        self.averageCycleLength = averageCycleLength
        self.averagePeriodDuration = averagePeriodDuration
        self.flowAmount = flowAmount
        self.dysmenorrheaSeverity = dysmenorrheaSeverity
        self.dysmenorrheaReminderEnabled = dysmenorrheaReminderEnabled
        self.periodImpactAreas = periodImpactAreas
        self.exerciseIntensity = exerciseIntensity
        self.customExercise = customExercise
        self.improvementGoals = improvementGoals
        self.specialConditions = specialConditions
        self.specialConditionNote = specialConditionNote
        self.dataSourceAuthorization = dataSourceAuthorization
        self.notificationPermissionState = notificationPermissionState
    }

    var trimmedDisplayLabel: String {
        displayLabel.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isReadyForCompletion: Bool {
        !trimmedDisplayLabel.isEmpty
    }

    var normalizedCycleSummary: String? {
        let startText: String
        if let date = lastPeriodDate {
            let fmt = DateFormatter()
            fmt.dateStyle = .medium
            startText = "上次月经开始日：\(fmt.string(from: date))"
        } else {
            startText = "上次月经开始日不确定"
        }
        let durationText = averagePeriodDuration.map { "经期约 \($0) 天" } ?? "经期天数不确定"
        let lengthText = averageCycleLength.map { "约 \($0) 天" } ?? "不确定"
        let flowText = flowAmount?.rawValue ?? "未填"
        let painText: String
        switch dysmenorrheaSeverity {
        case .none: painText = "无痛经"
        case .occasional: painText = "偶尔轻微痛经"
        case .frequent: painText = "经常痛经"
        case .severe: painText = "严重痛经"
        }
        return "\(startText)；\(durationText)；平均周期：\(lengthText)；经量：\(flowText)；\(painText)"
    }

    var derivedFocusAreas: [FocusArea] {
        var areas: [FocusArea] = []
        for goal in improvementGoals {
            switch goal {
            case .sleepQuality: areas.append(.sleep)
            case .moodManagement: areas.append(.mood)
            case .nutritionBalance: areas.append(.nutrition)
            case .energyManagement: areas.append(.energy)
            case .cycleRegularity: areas.append(.cycle)
            }
        }
        return areas.isEmpty ? [.energy] : Array(areas.prefix(3))
    }
}

struct OnboardingCompletion: Equatable {
    var profile: UserProfile
    var context: OnboardingContext
    var gateState: AppGateState
}

struct OnboardingService: OnboardingServicing {
    private let gateService: AppGateServicing

    init(gateService: AppGateServicing = AppGateService()) {
        self.gateService = gateService
    }

    func complete(profile: UserProfile, context: OnboardingContext, completedAt: Date = .now) -> OnboardingContext {
        var next = context
        next.completedAt = completedAt
        return next
    }

    func complete(draft: OnboardingDraft, completedAt: Date = .now) -> OnboardingCompletion {
        let profile = UserProfile(
            displayLabel: draft.trimmedDisplayLabel,
            authMethod: draft.authMethod,
            createdAt: completedAt,
            updatedAt: completedAt
        )
        let context = OnboardingContext(
            focusAreas: draft.derivedFocusAreas,
            sportPreferences: draft.sportPreferences,
            cycleContext: draft.lastPeriodDate.map { CycleContext(anchorDate: $0) },
            cycleSummary: draft.normalizedCycleSummary,
            periodRegularity: draft.periodRegularity,
            lastPeriodDate: draft.lastPeriodDate,
            flowAmount: draft.flowAmount,
            hasDysmenorrhea: draft.dysmenorrheaSeverity != .none,
            dysmenorrheaSeverity: draft.dysmenorrheaSeverity,
            dysmenorrheaReminderEnabled: draft.dysmenorrheaReminderEnabled,
            averagePeriodDuration: draft.averagePeriodDuration,
            periodImpactAreas: draft.periodImpactAreas,
            exerciseIntensity: draft.exerciseIntensity,
            customExercise: draft.customExercise,
            improvementGoals: draft.improvementGoals,
            specialConditions: draft.specialConditions,
            specialConditionNote: draft.specialConditionNote,
            energyWindowPreference: .unsure,
            guidanceStyle: .explainFirst,
            reminderPreference: .eveningReview,
            dataSourceAuthorization: draft.dataSourceAuthorization,
            notificationPermissionState: draft.notificationPermissionState,
            completedAt: completedAt
        )
        let gateState = gateService.resolveGate(profile: profile, context: context)
        return OnboardingCompletion(profile: profile, context: context, gateState: gateState)
    }
}
