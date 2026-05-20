import Foundation

@MainActor
final class AppEnvironment: ObservableObject {
    @Published private(set) var route: AppRoute = .onboarding
    @Published private(set) var navigationState = NavigationState()
    @Published private(set) var onboardingCompletion: OnboardingCompletion?
    @Published private(set) var lunaRecordRequestID: UUID?
    @Published private(set) var vitoraContext = VitoraContextPayload(sourceTitle: "Today", sourceSummary: "68% · 14:00 可能低谷")
    @Published private(set) var eveningReview = EveningReview(day: .now, status: .unavailable)
    @Published private(set) var reviewLearningSignal: VitoraLearningSignal?
    @Published private(set) var selectedCycleDay = 18
    @Published private(set) var selectedAuraVariant: DynamicAuraVariant = .luteal

    let appName = String(localized: "vitora.app.title")
    let isAIUnavailableForUITests: Bool
    let hasRichTodayDataForUITests: Bool
    private let eveningReviewService = EveningReviewService(now: { Date() })
    private let learningSignalService = VitoraLearningSignalService(now: { Date() })

    init(arguments: [String] = ProcessInfo.processInfo.arguments) {
        isAIUnavailableForUITests = arguments.contains("-vitoraUITestAIUnavailable")
        hasRichTodayDataForUITests = arguments.contains("-vitoraUITestRichToday")

        if arguments.contains("-vitoraUITestCompletedOnboarding") {
            let lowData = !hasRichTodayDataForUITests
            navigationState.completeOnboarding(lowData: lowData)
            applyUITestInitialTab(from: arguments)
            route = .today
        }

        if arguments.contains("-vitoraUITestReviewAvailable") {
            seedEveningReviewForUITests()
        }
    }

    func completeOnboarding(lowData: Bool = true) {
        navigationState.completeOnboarding(lowData: lowData)
        route = .today
    }

    func finishOnboarding(_ completion: OnboardingCompletion) {
        onboardingCompletion = completion
        navigationState.completeOnboarding(lowData: completion.gateState == .lowDataReady)
        route = .today
    }

    func selectTab(_ tab: PrimaryTab) {
        navigationState.selectedTab = tab
    }

    func selectCycleDay(_ day: Int) {
        selectedCycleDay = day
        selectedAuraVariant = DynamicAuraVariant.cycleVariant(for: day)
    }

    func present(_ presentation: ContextualPresentation) {
        navigationState.present(presentation)
    }

    func openLunaRecord() {
        openVitoraContext(
            sourceTitle: "今日状态",
            sourceSummary: "68% · 14:00 可能低谷",
            prompt: "Vitora 会用你的补充校准今天的判断。"
        )
        lunaRecordRequestID = UUID()
    }

    func openQuickRecord() {
        openVitoraContext(
            sourceTitle: "快捷记录",
            sourceSummary: "告诉 Vitora 一件事",
            prompt: "告诉 Vitora 一件事..."
        )
    }

    func openVitoraContext(sourceTitle: String, sourceSummary: String, prompt: String) {
        vitoraContext = VitoraContextPayload(
            sourceTitle: sourceTitle,
            sourceSummary: sourceSummary,
            prompt: prompt
        )
        navigationState.present(.vitoraContextualSheet)
    }

    var isEveningReviewAvailable: Bool {
        eveningReview.status == .available
    }

    var canShowEveningReviewAnalysis: Bool {
        eveningReview.status == .available || eveningReview.status == .submitted
    }

    func openEveningReviewInVitora() {
        guard canShowEveningReviewAnalysis else {
            return
        }
        navigationState.dismissPresentation()
        navigationState.selectedTab = .vitora
    }

    func openEveningReview() {
        guard eveningReview.status == .available || eveningReview.status == .submitted else {
            return
        }
        navigationState.present(.eveningReview)
    }

    func submitEveningReview(feedback: EveningReviewFeedback, note: String? = nil) {
        let submitted = eveningReviewService.submit(
            day: eveningReview.day,
            intentionID: eveningReview.intentionID,
            before: eveningReview.beforeSummary,
            feedback: feedback,
            note: note
        )
        eveningReview = submitted
        reviewLearningSignal = learningSignalService.makeSignal(review: submitted, intention: nil)
    }

    func dismissPresentation() {
        navigationState.dismissPresentation()
    }

    func openDrawer(from tab: PrimaryTab) {
        navigationState.openDrawer(from: tab)
    }

    func openSupport(_ route: SupportRoute) {
        navigationState.openSupport(route)
    }

    func closeSupport() {
        navigationState.closeSupport()
    }

    func resetForPreview() {
        onboardingCompletion = nil
        navigationState = NavigationState()
        route = .onboarding
        eveningReview = EveningReview(day: .now, status: .unavailable)
        reviewLearningSignal = nil
    }

    private func seedEveningReviewForUITests() {
        let day = Date(timeIntervalSince1970: 1_770_000_000)
        let intention = DailyIntention(day: day, choice: .a, state: .reviewAvailable)
        eveningReview = eveningReviewService.availability(
            day: day,
            intention: intention,
            morningSummary: "早上 68% · 能量平稳 · 14:00 附近可能低谷",
            suggestionSummary: "13:30 前加一小份蛋白，下午轻走 10 分钟"
        )
    }

    private func applyUITestInitialTab(from arguments: [String]) {
        if arguments.contains("-vitoraUITestInitialTabVitora") {
            navigationState.selectedTab = .vitora
        } else if arguments.contains("-vitoraUITestInitialTabCycle") {
            navigationState.selectedTab = .cycle
        }
    }
}

enum AppRoute: Equatable {
    case onboarding
    case today
}

struct VitoraContextPayload: Equatable {
    var sourceTitle: String
    var sourceSummary: String
    var prompt: String = "告诉 Vitora 一件重要变化。"
}
