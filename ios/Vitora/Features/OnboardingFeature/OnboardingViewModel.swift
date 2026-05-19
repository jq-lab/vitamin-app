import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    enum Step: Equatable {
        case identity
        case context
        case ready
    }

    @Published var step: Step = .identity
    @Published var displayLabel = ""
    @Published var selectedFocusAreas: Set<FocusArea> = [.energy]
    @Published var cycleSummary = ""
    @Published var cycleLengthSummary = "不确定"
    @Published var cycleRegularitySummary = "不确定"
    @Published var shouldEstimateCycle = true
    @Published var energyWindowPreference: EnergyWindowPreference = .unsure
    @Published var guidanceStyle: VitoraGuidanceStyle = .explainFirst
    @Published var reminderPreference: OnboardingReminderPreference = .eveningReview
    @Published private(set) var dataSourceAuthorization = DataSourceAuthorization.notAsked()
    @Published private(set) var completion: OnboardingCompletion?

    private let onboardingService: OnboardingServicing
    private let healthKitClient: HealthKitClient

    init(
        onboardingService: OnboardingServicing = OnboardingService(),
        healthKitClient: HealthKitClient = DefaultHealthKitClient()
    ) {
        self.onboardingService = onboardingService
        self.healthKitClient = healthKitClient
    }

    var canContinueIdentity: Bool {
        !displayLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var selectedFocusAreasList: [FocusArea] {
        let selected = FocusArea.allCases.filter { selectedFocusAreas.contains($0) }
        return selected.isEmpty ? [.energy] : selected
    }

    var canContinueContext: Bool {
        dataSourceAuthorization.state != .notAsked
    }

    var isLowData: Bool {
        dataSourceAuthorization.isLowData
    }

    func goToContext() {
        guard canContinueIdentity else {
            return
        }
        step = .context
    }

    func toggleFocusArea(_ focusArea: FocusArea) {
        if selectedFocusAreas.contains(focusArea) {
            selectedFocusAreas.remove(focusArea)
        } else if selectedFocusAreas.count < 3 {
            selectedFocusAreas.insert(focusArea)
        }
    }

    func chooseCycleLength(_ summary: String) {
        cycleLengthSummary = summary
    }

    func chooseCycleRegularity(_ summary: String) {
        cycleRegularitySummary = summary
    }

    func chooseEnergyWindow(_ preference: EnergyWindowPreference) {
        energyWindowPreference = preference
    }

    func chooseGuidanceStyle(_ style: VitoraGuidanceStyle) {
        guidanceStyle = style
    }

    func chooseReminderPreference(_ preference: OnboardingReminderPreference) {
        reminderPreference = preference
    }

    func chooseDataSource(_ choice: HealthKitAuthorizationChoice) {
        dataSourceAuthorization = healthKitClient.apply(choice: choice)
    }

    func goToReady() {
        guard canContinueContext else {
            return
        }
        completion = makeCompletion()
        step = .ready
    }

    func editCustomization() {
        step = .context
    }

    func finish() -> OnboardingCompletion {
        if dataSourceAuthorization.state == .notAsked {
            chooseDataSource(.skip)
        }
        let nextCompletion = makeCompletion()
        completion = nextCompletion
        return nextCompletion
    }

    private func makeCompletion() -> OnboardingCompletion {
        onboardingService.complete(
            draft: OnboardingDraft(
                displayLabel: displayLabel,
                focusAreas: selectedFocusAreasList,
                cycleSummary: cycleSummary,
                cycleLengthSummary: cycleLengthSummary,
                cycleRegularitySummary: cycleRegularitySummary,
                shouldEstimateCycle: shouldEstimateCycle,
                energyWindowPreference: energyWindowPreference,
                guidanceStyle: guidanceStyle,
                reminderPreference: reminderPreference,
                dataSourceAuthorization: dataSourceAuthorization
            ),
            completedAt: .now
        )
    }
}
