import Foundation

struct OnboardingDraft: Equatable {
    var displayLabel: String
    var authMethod: AuthMethod
    var focusAreas: [FocusArea]
    var sportPreferences: [SportPreference]
    var periodRegularity: PeriodRegularity
    var lastPeriodDate: Date?
    var averageCycleLength: Int?
    var flowAmount: FlowAmount?
    var hasDysmenorrhea: Bool
    var dysmenorrheaReminderEnabled: Bool
    var dataSourceAuthorization: DataSourceAuthorization
    var notificationPermissionState: NotificationPermissionState

    init(
        displayLabel: String = "",
        authMethod: AuthMethod = .local,
        focusAreas: [FocusArea] = [.energy],
        sportPreferences: [SportPreference] = [],
        periodRegularity: PeriodRegularity = .unsure,
        lastPeriodDate: Date? = nil,
        averageCycleLength: Int? = nil,
        flowAmount: FlowAmount? = nil,
        hasDysmenorrhea: Bool = false,
        dysmenorrheaReminderEnabled: Bool = false,
        dataSourceAuthorization: DataSourceAuthorization = .notAsked(),
        notificationPermissionState: NotificationPermissionState = .notDetermined
    ) {
        self.displayLabel = displayLabel
        self.authMethod = authMethod
        self.focusAreas = focusAreas
        self.sportPreferences = sportPreferences
        self.periodRegularity = periodRegularity
        self.lastPeriodDate = lastPeriodDate
        self.averageCycleLength = averageCycleLength
        self.flowAmount = flowAmount
        self.hasDysmenorrhea = hasDysmenorrhea
        self.dysmenorrheaReminderEnabled = dysmenorrheaReminderEnabled
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
        let lengthText = averageCycleLength.map { "约 \($0) 天" } ?? "不确定"
        let flowText = flowAmount?.rawValue ?? "未填"
        let painText = hasDysmenorrhea ? "有痛经" : "无痛经"
        return "\(startText)；平均周期：\(lengthText)；规律性：\(periodRegularity.rawValue)；经量：\(flowText)；\(painText)"
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
            focusAreas: draft.focusAreas.isEmpty ? [.energy] : draft.focusAreas,
            sportPreferences: draft.sportPreferences,
            cycleContext: draft.lastPeriodDate.map { CycleContext(anchorDate: $0) },
            cycleSummary: draft.normalizedCycleSummary,
            periodRegularity: draft.periodRegularity,
            lastPeriodDate: draft.lastPeriodDate,
            flowAmount: draft.flowAmount,
            hasDysmenorrhea: draft.hasDysmenorrhea,
            dysmenorrheaReminderEnabled: draft.dysmenorrheaReminderEnabled,
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
