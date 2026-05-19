import Foundation
import AuthenticationServices

@MainActor
final class OnboardingViewModel: ObservableObject {
    enum Step: Equatable {
        case aboutYou
        case yourBody
    }

    // Navigation
    @Published var step: Step = .aboutYou

    // Page 1 — About You
    @Published var displayLabel = ""
    @Published var authMethod: AuthMethod = .local
    @Published var selectedSports: Set<SportPreference> = []
    @Published var selectedFocusAreas: Set<FocusArea> = [.energy]

    // Page 2 — Your Body
    @Published var periodRegularity: PeriodRegularity = .unsure
    @Published var lastPeriodDate: Date = Date()
    @Published var lastPeriodDateUnsure = true
    @Published var averageCycleLength: Double = 28
    @Published var averageCycleLengthUnsure = true
    @Published var flowAmount: FlowAmount? = nil
    @Published var hasDysmenorrhea = false
    @Published var dysmenorrheaReminderEnabled = false

    // Permissions
    @Published private(set) var dataSourceAuthorization = DataSourceAuthorization.notAsked()
    @Published private(set) var notificationPermissionState: NotificationPermissionState = .notDetermined
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

    // MARK: - Computed

    var canContinueAboutYou: Bool {
        !displayLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var selectedFocusAreasList: [FocusArea] {
        let selected = FocusArea.allCases.filter { selectedFocusAreas.contains($0) }
        return selected.isEmpty ? [.energy] : selected
    }

    var isLowData: Bool {
        dataSourceAuthorization.isLowData
    }

    // MARK: - Navigation

    func goToYourBody() {
        guard canContinueAboutYou else { return }
        step = .yourBody
    }

    // MARK: - Page 1 Actions

    func appleSignInCompleted(userIdentifier: String, fullName: PersonNameComponents?) {
        authMethod = .apple(userIdentifier: userIdentifier)
        if let name = fullName, let given = name.givenName {
            let combined = [given, name.familyName].compactMap { $0 }.joined(separator: " ")
            if !combined.isEmpty {
                displayLabel = combined
            }
        }
    }

    func skipSignIn() {
        authMethod = .local
    }

    func toggleFocusArea(_ focusArea: FocusArea) {
        if selectedFocusAreas.contains(focusArea) {
            selectedFocusAreas.remove(focusArea)
        } else if selectedFocusAreas.count < 3 {
            selectedFocusAreas.insert(focusArea)
        }
    }

    func toggleSport(_ sport: SportPreference) {
        if sport == .none {
            selectedSports = [.none]
            return
        }
        selectedSports.remove(.none)
        if selectedSports.contains(sport) {
            selectedSports.remove(sport)
        } else {
            selectedSports.insert(sport)
        }
    }

    // MARK: - Page 2 Actions

    func choosePeriodRegularity(_ regularity: PeriodRegularity) {
        periodRegularity = regularity
    }

    func chooseFlowAmount(_ amount: FlowAmount) {
        flowAmount = amount
    }

    func toggleDysmenorrhea() {
        hasDysmenorrhea.toggle()
        if !hasDysmenorrhea { dysmenorrheaReminderEnabled = false }
    }

    func chooseDataSource(_ choice: HealthKitAuthorizationChoice) {
        dataSourceAuthorization = healthKitClient.apply(choice: choice)
    }

    func requestNotificationPermission() {
        notificationPermissionState = .authorized
    }

    func skipNotificationPermission() {
        notificationPermissionState = .denied
    }

    // MARK: - Finish

    func finish() -> OnboardingCompletion {
        if dataSourceAuthorization.state == .notAsked {
            chooseDataSource(.skip)
        }
        let result = makeCompletion()
        completion = result
        return result
    }

    private func makeCompletion() -> OnboardingCompletion {
        onboardingService.complete(
            draft: OnboardingDraft(
                displayLabel: displayLabel,
                authMethod: authMethod,
                focusAreas: selectedFocusAreasList,
                sportPreferences: Array(selectedSports),
                periodRegularity: periodRegularity,
                lastPeriodDate: lastPeriodDateUnsure ? nil : lastPeriodDate,
                averageCycleLength: averageCycleLengthUnsure ? nil : Int(averageCycleLength),
                flowAmount: flowAmount,
                hasDysmenorrhea: hasDysmenorrhea,
                dysmenorrheaReminderEnabled: dysmenorrheaReminderEnabled,
                dataSourceAuthorization: dataSourceAuthorization,
                notificationPermissionState: notificationPermissionState
            ),
            completedAt: .now
        )
    }
}
