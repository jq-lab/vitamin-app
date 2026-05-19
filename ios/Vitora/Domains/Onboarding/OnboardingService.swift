import Foundation

struct OnboardingDraft: Equatable {
    var displayLabel: String
    var focusAreas: [FocusArea]
    var cycleSummary: String
    var cycleLengthSummary: String
    var cycleRegularitySummary: String
    var shouldEstimateCycle: Bool
    var energyWindowPreference: EnergyWindowPreference
    var guidanceStyle: VitoraGuidanceStyle
    var reminderPreference: OnboardingReminderPreference
    var dataSourceAuthorization: DataSourceAuthorization

    init(
        displayLabel: String = "",
        focusAreas: [FocusArea] = [.energy],
        cycleSummary: String = "",
        cycleLengthSummary: String = "不确定",
        cycleRegularitySummary: String = "不确定",
        shouldEstimateCycle: Bool = true,
        energyWindowPreference: EnergyWindowPreference = .unsure,
        guidanceStyle: VitoraGuidanceStyle = .explainFirst,
        reminderPreference: OnboardingReminderPreference = .eveningReview,
        dataSourceAuthorization: DataSourceAuthorization = .notAsked()
    ) {
        self.displayLabel = displayLabel
        self.focusAreas = focusAreas
        self.cycleSummary = cycleSummary
        self.cycleLengthSummary = cycleLengthSummary
        self.cycleRegularitySummary = cycleRegularitySummary
        self.shouldEstimateCycle = shouldEstimateCycle
        self.energyWindowPreference = energyWindowPreference
        self.guidanceStyle = guidanceStyle
        self.reminderPreference = reminderPreference
        self.dataSourceAuthorization = dataSourceAuthorization
    }

    var trimmedDisplayLabel: String {
        displayLabel.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isReadyForCompletion: Bool {
        !trimmedDisplayLabel.isEmpty
    }

    var normalizedCycleSummary: String? {
        let start = cycleSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        let startText = start.isEmpty ? "上次月经开始日不确定" : "上次月经开始日：\(start)"
        let estimateText = shouldEstimateCycle ? "先用低数据估算" : "用户希望按提供信息判断"
        return "\(startText)；平均周期：\(cycleLengthSummary)；规律性：\(cycleRegularitySummary)；\(estimateText)"
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
            createdAt: completedAt,
            updatedAt: completedAt
        )
        let context = OnboardingContext(
            focusAreas: draft.focusAreas.isEmpty ? [.energy] : draft.focusAreas,
            cycleContext: nil,
            cycleSummary: draft.normalizedCycleSummary,
            energyWindowPreference: draft.energyWindowPreference,
            guidanceStyle: draft.guidanceStyle,
            reminderPreference: draft.reminderPreference,
            dataSourceAuthorization: draft.dataSourceAuthorization,
            completedAt: completedAt
        )
        let gateState = gateService.resolveGate(profile: profile, context: context)

        return OnboardingCompletion(profile: profile, context: context, gateState: gateState)
    }
}
