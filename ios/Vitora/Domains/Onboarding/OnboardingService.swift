import Foundation

struct OnboardingDraft: Equatable {
    var displayLabel: String
    var focusAreas: [FocusArea]
    var cycleSummary: String
    var dataSourceAuthorization: DataSourceAuthorization

    init(
        displayLabel: String = "",
        focusAreas: [FocusArea] = [.energy],
        cycleSummary: String = "",
        dataSourceAuthorization: DataSourceAuthorization = .notAsked()
    ) {
        self.displayLabel = displayLabel
        self.focusAreas = focusAreas
        self.cycleSummary = cycleSummary
        self.dataSourceAuthorization = dataSourceAuthorization
    }

    var trimmedDisplayLabel: String {
        displayLabel.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isReadyForCompletion: Bool {
        !trimmedDisplayLabel.isEmpty
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
            dataSourceAuthorization: draft.dataSourceAuthorization,
            completedAt: completedAt
        )
        let gateState = gateService.resolveGate(profile: profile, context: context)

        return OnboardingCompletion(profile: profile, context: context, gateState: gateState)
    }
}
