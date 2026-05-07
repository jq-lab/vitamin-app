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
        } else {
            selectedFocusAreas.insert(focusArea)
        }
    }

    func chooseDataSource(_ choice: HealthKitAuthorizationChoice) {
        dataSourceAuthorization = healthKitClient.apply(choice: choice)
    }

    func goToReady() {
        if dataSourceAuthorization.state == .notAsked {
            chooseDataSource(.skip)
        }
        completion = makeCompletion()
        step = .ready
    }

    func finish() -> OnboardingCompletion {
        let nextCompletion = completion ?? makeCompletion()
        completion = nextCompletion
        return nextCompletion
    }

    private func makeCompletion() -> OnboardingCompletion {
        onboardingService.complete(
            draft: OnboardingDraft(
                displayLabel: displayLabel,
                focusAreas: selectedFocusAreasList,
                cycleSummary: cycleSummary,
                dataSourceAuthorization: dataSourceAuthorization
            ),
            completedAt: .now
        )
    }
}
