import Foundation

enum PrimaryTab: String, CaseIterable, Codable, Equatable {
    case today
    case vitora
    case cycle
}

enum OnboardingStep: String, CaseIterable, Codable, Equatable {
    case identity
    case context
    case ready
}

enum ContextualPresentation: String, CaseIterable, Codable, Equatable {
    case energyRitual
    case todayAnalysis
    case todayCalendar
    case todayStateDetail
    case bodyFactorsDetail
    case suggestionDetail
    case vitoraContextualSheet
    case vitoraFullContextMode
    case cyclePhaseDetail
    case cycleEnergyDetail
    case settingsPanel
    case lunaRecord
    case lunaChat
    case eveningReview
    case cycleCalendar

    var hasExitPath: Bool {
        true
    }
}

enum SupportRoute: String, CaseIterable, Codable, Equatable {
    case profile
    case dataSources
    case nutrition
    case reminders
    case dataExport
    case privacyAndAccountRemoval

    static let p0Routes: [SupportRoute] = [
        .profile,
        .dataSources,
        .nutrition,
        .reminders,
        .dataExport,
        .privacyAndAccountRemoval,
    ]
}

enum VitoraRoute: Equatable {
    case appGate(AppGateState)
    case onboarding(OnboardingStep)
    case primary(PrimaryTab)
    case contextual(ContextualPresentation, source: PrimaryTab)
    case lightDrawer(source: PrimaryTab)
    case support(SupportRoute, source: PrimaryTab)
}

struct NavigationState: Equatable {
    var gate: AppGateState
    var selectedTab: PrimaryTab
    var presentation: ContextualPresentation?
    var supportRoute: SupportRoute?
    var isLightDrawerOpen: Bool

    init(
        gate: AppGateState = .needsOnboarding,
        selectedTab: PrimaryTab = .today,
        presentation: ContextualPresentation? = nil,
        supportRoute: SupportRoute? = nil,
        isLightDrawerOpen: Bool = false
    ) {
        self.gate = gate
        self.selectedTab = selectedTab
        self.presentation = presentation
        self.supportRoute = supportRoute
        self.isLightDrawerOpen = isLightDrawerOpen
    }

    var visibleTabs: [PrimaryTab] {
        gate.allowsMainTabs ? PrimaryTab.allCases : []
    }

    var visibleSupportRoutes: [SupportRoute] {
        SupportRoute.p0Routes
    }

    mutating func completeOnboarding(lowData: Bool) {
        gate = lowData ? .lowDataReady : .readyForToday
        selectedTab = .today
    }

    mutating func present(_ presentation: ContextualPresentation) {
        self.presentation = presentation
    }

    mutating func dismissPresentation() {
        presentation = nil
    }

    mutating func openDrawer(from tab: PrimaryTab) {
        selectedTab = tab
        isLightDrawerOpen = true
    }

    mutating func openSupport(_ route: SupportRoute) {
        guard SupportRoute.p0Routes.contains(route) else {
            return
        }
        supportRoute = route
        isLightDrawerOpen = true
    }

    mutating func closeSupport() {
        supportRoute = nil
        isLightDrawerOpen = false
    }
}
