import Foundation
@MainActor
final class OnboardingViewModel: ObservableObject {
    enum Step: Equatable {
        case aboutYou
        case yourBody
    }

    enum ContextQuestionStep: Int, CaseIterable, Equatable {
        case periodBasics
        case periodImpact
        case exercise
        case sleepAndGoals
        case specialConditions
        case ready
    }

    enum PeriodBasicsSubStep: Int, CaseIterable, Equatable {
        case lastPeriodDate
        case duration
        case cycleLength
        case flow
        case cramps
        case complete
    }

    enum ExerciseSubStep: Int, CaseIterable, Equatable {
        case sport
        case intensity
        case complete
    }

    enum SleepGoalsSubStep: Int, CaseIterable, Equatable {
        case goals
        case device
        case complete
    }

    enum RegistrationProvider: String, CaseIterable {
        case apple
        case wechat
        case qq
        case local
    }

    // Navigation
    @Published var step: Step = .aboutYou

    // Page 1 — About You
    @Published var displayLabel = "你"
    @Published var authMethod: AuthMethod = .local
    @Published var acceptedAgreements = false
    @Published var agreementRequiresAttention = false

    // Page 2 — Context Questions
    @Published var contextQuestionStep: ContextQuestionStep = .periodBasics
    @Published var isContextAdvancing = false

    // Step 1 — Period Basics
    @Published var periodBasicsSubStep: PeriodBasicsSubStep = .lastPeriodDate
    @Published var lastPeriodDate: Date = Date()
    @Published var lastPeriodDateUnsure = true
    @Published var averagePeriodDuration: Double = 5
    @Published var averagePeriodDurationUnsure = true
    @Published var averageCycleLength: Double = 28
    @Published var averageCycleLengthUnsure = true
    @Published var flowAmount: FlowAmount? = nil
    @Published var dysmenorrheaSeverity: DysmenorrheaSeverity = .none

    // Step 2 — Period Impact
    @Published var selectedPeriodImpacts: Set<PeriodImpactArea> = []
    @Published var dysmenorrheaReminderEnabled = false

    // Step 3 — Exercise
    @Published var exerciseSubStep: ExerciseSubStep = .sport
    @Published var selectedSports: Set<SportPreference> = []
    @Published var customExercise: String = ""
    @Published var exerciseIntensity: ExerciseIntensity? = nil

    // Step 4 — Sleep & Goals
    @Published var sleepGoalsSubStep: SleepGoalsSubStep = .goals
    @Published var selectedGoals: Set<ImprovementGoal> = []

    // Step 5 — Special Conditions
    @Published var selectedSpecialConditions: Set<SpecialCondition> = []
    @Published var specialConditionNote: String = ""

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
        acceptedAgreements
    }

    var isLowData: Bool {
        dataSourceAuthorization.isLowData
    }

    var showsDysmenorrheaRescue: Bool {
        dysmenorrheaSeverity == .frequent || dysmenorrheaSeverity == .severe
    }

    // MARK: - Navigation

    func prepareRegistrationEntry() {
        if ProcessInfo.processInfo.arguments.contains("-vitoraPreviewOnboardingContext") {
            acceptedAgreements = true
            step = .yourBody
            return
        }

        step = .aboutYou
    }

    func goToYourBody() {
        guard canContinueAboutYou else { return }
        step = .yourBody
    }

    // MARK: - Page 1 Actions

    func toggleAgreements() {
        acceptedAgreements.toggle()
        if acceptedAgreements {
            agreementRequiresAttention = false
        }
    }

    func startRegistration(provider: RegistrationProvider) {
        guard acceptedAgreements else {
            agreementRequiresAttention = true
            return
        }

        switch provider {
        case .apple:
            authMethod = .apple(userIdentifier: "apple-local-preview")
            displayLabel = "Apple 用户"
        case .wechat:
            authMethod = .local
            displayLabel = "微信用户"
        case .qq:
            authMethod = .local
            displayLabel = "QQ 用户"
        case .local:
            authMethod = .local
            displayLabel = "你"
        }

        resetContextQuestionFlow()
        step = .yourBody
    }

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

    // MARK: - Step 1: Period Basics

    func choosePeriodDate(unsure: Bool) {
        lastPeriodDateUnsure = unsure
        advancePeriodBasicsSubStep()
    }

    func choosePeriodDuration(unsure: Bool) {
        averagePeriodDurationUnsure = unsure
        advancePeriodBasicsSubStep()
    }

    func chooseCycleLength(unsure: Bool) {
        averageCycleLengthUnsure = unsure
        advancePeriodBasicsSubStep()
    }

    func chooseFlowAmount(_ amount: FlowAmount) {
        flowAmount = amount
        advancePeriodBasicsSubStep()
    }

    func chooseDysmenorrheaSeverity(_ severity: DysmenorrheaSeverity) {
        dysmenorrheaSeverity = severity
        advancePeriodBasicsSubStep()
    }

    func continueFromPeriodBasics() {
        advanceContextQuestion(to: .periodImpact)
    }

    // MARK: - Step 2: Period Impact

    func togglePeriodImpact(_ area: PeriodImpactArea) {
        if selectedPeriodImpacts.contains(area) {
            selectedPeriodImpacts.remove(area)
        } else {
            selectedPeriodImpacts.insert(area)
        }
    }

    func continueFromPeriodImpact() {
        advanceContextQuestion(to: .exercise)
    }

    // MARK: - Step 3: Exercise

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

    func chooseExerciseIntensity(_ intensity: ExerciseIntensity) {
        exerciseIntensity = intensity
    }

    func continueFromExercise() {
        advanceContextQuestion(to: .sleepAndGoals)
    }

    func continueFromExerciseSport() {
        if selectedSports.isEmpty && customExercise.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            selectedSports = [.none]
        }
        advanceExerciseSubStep()
    }

    func chooseExerciseIntensityAndContinue(_ intensity: ExerciseIntensity) {
        exerciseIntensity = intensity
        advanceExerciseSubStep()
    }

    // MARK: - Step 4: Sleep & Goals

    func toggleGoal(_ goal: ImprovementGoal) {
        if selectedGoals.contains(goal) {
            selectedGoals.remove(goal)
        } else {
            selectedGoals.insert(goal)
        }
    }

    func chooseDataSource(_ choice: HealthKitAuthorizationChoice) {
        dataSourceAuthorization = healthKitClient.apply(choice: choice)
    }

    func continueFromSleepAndGoals() {
        advanceContextQuestion(to: .specialConditions)
    }

    func continueFromGoals() {
        if selectedGoals.isEmpty {
            selectedGoals = [.energyManagement]
        }
        advanceSleepGoalsSubStep()
    }

    func chooseDataSourceAndContinue(_ choice: HealthKitAuthorizationChoice) {
        chooseDataSource(choice)
        advanceSleepGoalsSubStep()
    }

    // MARK: - Step 5: Special Conditions

    func toggleSpecialCondition(_ condition: SpecialCondition) {
        if condition == .noneSpecial {
            selectedSpecialConditions = [.noneSpecial]
            return
        }
        selectedSpecialConditions.remove(.noneSpecial)
        if selectedSpecialConditions.contains(condition) {
            selectedSpecialConditions.remove(condition)
        } else {
            selectedSpecialConditions.insert(condition)
        }
    }

    func continueFromSpecialConditions() {
        advanceContextQuestion(to: .ready)
    }

    func skipAllContextQuestions() {
        contextQuestionStep = .ready
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

    func requestNotificationPermission() {
        notificationPermissionState = .authorized
    }

    func skipNotificationPermission() {
        notificationPermissionState = .denied
    }

    // MARK: - Internal

    private func makeCompletion() -> OnboardingCompletion {
        onboardingService.complete(
            draft: OnboardingDraft(
                displayLabel: displayLabel,
                authMethod: authMethod,
                sportPreferences: Array(selectedSports),
                periodRegularity: inferPeriodRegularity(),
                lastPeriodDate: lastPeriodDateUnsure ? nil : lastPeriodDate,
                averageCycleLength: averageCycleLengthUnsure ? nil : Int(averageCycleLength),
                averagePeriodDuration: averagePeriodDurationUnsure ? nil : Int(averagePeriodDuration),
                flowAmount: flowAmount,
                dysmenorrheaSeverity: dysmenorrheaSeverity,
                dysmenorrheaReminderEnabled: dysmenorrheaReminderEnabled,
                periodImpactAreas: Array(selectedPeriodImpacts),
                exerciseIntensity: exerciseIntensity,
                customExercise: customExercise.isEmpty ? nil : customExercise,
                improvementGoals: Array(selectedGoals),
                specialConditions: Array(selectedSpecialConditions),
                specialConditionNote: specialConditionNote.isEmpty ? nil : specialConditionNote,
                dataSourceAuthorization: dataSourceAuthorization,
                notificationPermissionState: notificationPermissionState
            ),
            completedAt: .now
        )
    }

    private func inferPeriodRegularity() -> PeriodRegularity {
        if lastPeriodDateUnsure && averageCycleLengthUnsure {
            return .unsure
        }
        return .regular
    }

    private func resetContextQuestionFlow() {
        contextQuestionStep = .periodBasics
        periodBasicsSubStep = .lastPeriodDate
        exerciseSubStep = .sport
        sleepGoalsSubStep = .goals
        isContextAdvancing = false
    }

    private func advancePeriodBasicsSubStep() {
        guard let next = PeriodBasicsSubStep(rawValue: periodBasicsSubStep.rawValue + 1) else { return }
        advanceAfterShortPause {
            self.periodBasicsSubStep = next
        }
    }

    private func advanceExerciseSubStep() {
        guard let next = ExerciseSubStep(rawValue: exerciseSubStep.rawValue + 1) else { return }
        advanceAfterShortPause {
            self.exerciseSubStep = next
        }
    }

    private func advanceSleepGoalsSubStep() {
        guard let next = SleepGoalsSubStep(rawValue: sleepGoalsSubStep.rawValue + 1) else { return }
        advanceAfterShortPause {
            self.sleepGoalsSubStep = next
        }
    }

    private func advanceContextQuestion(to nextStep: ContextQuestionStep) {
        guard contextQuestionStep.rawValue < nextStep.rawValue else { return }
        if nextStep == .exercise {
            exerciseSubStep = .sport
        }
        if nextStep == .sleepAndGoals {
            sleepGoalsSubStep = .goals
        }
        advanceAfterShortPause {
            self.contextQuestionStep = nextStep
        }
    }

    private func advanceAfterShortPause(_ update: @escaping () -> Void) {
        isContextAdvancing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) { [weak self] in
            guard let self else { return }
            update()
            self.isContextAdvancing = false
        }
    }
}
