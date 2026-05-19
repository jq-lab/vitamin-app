import Foundation
import SwiftUI

// MARK: - Auth

enum AuthMethod: Codable, Equatable {
    case apple(userIdentifier: String)
    case local
}

// MARK: - User Profile

struct UserProfile: Identifiable, Codable, Equatable {
    var id: UUID
    var displayLabel: String
    var authMethod: AuthMethod
    var localeIdentifier: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        displayLabel: String,
        authMethod: AuthMethod = .local,
        localeIdentifier: String = Locale.autoupdatingCurrent.identifier,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.displayLabel = displayLabel
        self.authMethod = authMethod
        self.localeIdentifier = localeIdentifier
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var aiSafeLabel: String {
        displayLabel.isEmpty ? "user" : "preferred-label"
    }
}

// MARK: - Onboarding Context

struct OnboardingContext: Identifiable, Codable, Equatable {
    var id: UUID
    var focusAreas: [FocusArea]
    var sportPreferences: [SportPreference]
    var cycleContext: CycleContext?
    var cycleSummary: String?
    var periodRegularity: PeriodRegularity
    var lastPeriodDate: Date?
    var flowAmount: FlowAmount?
    var hasDysmenorrhea: Bool
    var dysmenorrheaReminderEnabled: Bool
    var energyWindowPreference: EnergyWindowPreference
    var guidanceStyle: VitoraGuidanceStyle
    var reminderPreference: OnboardingReminderPreference
    var dataSourceAuthorization: DataSourceAuthorization
    var notificationPermissionState: NotificationPermissionState
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        focusAreas: [FocusArea] = [],
        sportPreferences: [SportPreference] = [],
        cycleContext: CycleContext? = nil,
        cycleSummary: String? = nil,
        periodRegularity: PeriodRegularity = .unsure,
        lastPeriodDate: Date? = nil,
        flowAmount: FlowAmount? = nil,
        hasDysmenorrhea: Bool = false,
        dysmenorrheaReminderEnabled: Bool = false,
        energyWindowPreference: EnergyWindowPreference = .unsure,
        guidanceStyle: VitoraGuidanceStyle = .explainFirst,
        reminderPreference: OnboardingReminderPreference = .eveningReview,
        dataSourceAuthorization: DataSourceAuthorization = .notAsked(),
        notificationPermissionState: NotificationPermissionState = .notDetermined,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.focusAreas = focusAreas
        self.sportPreferences = sportPreferences
        self.cycleContext = cycleContext
        self.cycleSummary = cycleSummary
        self.periodRegularity = periodRegularity
        self.lastPeriodDate = lastPeriodDate
        self.flowAmount = flowAmount
        self.hasDysmenorrhea = hasDysmenorrhea
        self.dysmenorrheaReminderEnabled = dysmenorrheaReminderEnabled
        self.energyWindowPreference = energyWindowPreference
        self.guidanceStyle = guidanceStyle
        self.reminderPreference = reminderPreference
        self.dataSourceAuthorization = dataSourceAuthorization
        self.notificationPermissionState = notificationPermissionState
        self.completedAt = completedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id, focusAreas, sportPreferences, cycleContext, cycleSummary
        case periodRegularity, lastPeriodDate, flowAmount
        case hasDysmenorrhea, dysmenorrheaReminderEnabled
        case energyWindowPreference, guidanceStyle, reminderPreference
        case dataSourceAuthorization, notificationPermissionState, completedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        focusAreas = try container.decodeIfPresent([FocusArea].self, forKey: .focusAreas) ?? [.energy]
        sportPreferences = try container.decodeIfPresent([SportPreference].self, forKey: .sportPreferences) ?? []
        cycleContext = try container.decodeIfPresent(CycleContext.self, forKey: .cycleContext)
        cycleSummary = try container.decodeIfPresent(String.self, forKey: .cycleSummary)
        periodRegularity = try container.decodeIfPresent(PeriodRegularity.self, forKey: .periodRegularity) ?? .unsure
        lastPeriodDate = try container.decodeIfPresent(Date.self, forKey: .lastPeriodDate)
        flowAmount = try container.decodeIfPresent(FlowAmount.self, forKey: .flowAmount)
        hasDysmenorrhea = try container.decodeIfPresent(Bool.self, forKey: .hasDysmenorrhea) ?? false
        dysmenorrheaReminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .dysmenorrheaReminderEnabled) ?? false
        energyWindowPreference = try container.decodeIfPresent(EnergyWindowPreference.self, forKey: .energyWindowPreference) ?? .unsure
        guidanceStyle = try container.decodeIfPresent(VitoraGuidanceStyle.self, forKey: .guidanceStyle) ?? .explainFirst
        reminderPreference = try container.decodeIfPresent(OnboardingReminderPreference.self, forKey: .reminderPreference) ?? .eveningReview
        dataSourceAuthorization = try container.decodeIfPresent(DataSourceAuthorization.self, forKey: .dataSourceAuthorization) ?? .notAsked()
        notificationPermissionState = try container.decodeIfPresent(NotificationPermissionState.self, forKey: .notificationPermissionState) ?? .notDetermined
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
    }

    var isComplete: Bool {
        completedAt != nil
    }

    var supportsLowDataMode: Bool {
        dataSourceAuthorization.state != .authorized
    }
}

// MARK: - Enums

enum FocusArea: String, CaseIterable, Codable, Equatable, Hashable {
    case energy
    case cycle
    case sleep
    case mood
    case nutrition

    var titleKey: LocalizedStringKey {
        switch self {
        case .energy: "focus.energy"
        case .cycle: "focus.cycle"
        case .sleep: "focus.sleep"
        case .mood: "focus.mood"
        case .nutrition: "focus.nutrition"
        }
    }

    var accessibilityID: String {
        "onboarding.focus.\(rawValue)"
    }
}

enum SportPreference: String, CaseIterable, Codable, Equatable, Hashable {
    case yoga
    case running
    case swimming
    case strength
    case walking
    case cycling
    case dance
    case none

    var titleKey: String {
        "onboarding.sport.\(rawValue)"
    }

    var accessibilityID: String {
        "onboarding.sport.\(rawValue)"
    }
}

enum PeriodRegularity: String, CaseIterable, Codable, Equatable, Hashable {
    case regular
    case sometimesChanges
    case veryIrregular
    case unsure

    var titleKey: String {
        "onboarding.periodRegularity.\(rawValue)"
    }

    var accessibilityID: String {
        "onboarding.periodRegularity.\(rawValue)"
    }
}

enum FlowAmount: String, CaseIterable, Codable, Equatable, Hashable {
    case light
    case moderate
    case heavy
    case varies

    var titleKey: String {
        "onboarding.flowAmount.\(rawValue)"
    }

    var accessibilityID: String {
        "onboarding.flowAmount.\(rawValue)"
    }
}

enum EnergyWindowPreference: String, CaseIterable, Codable, Equatable, Hashable {
    case morning
    case afternoon
    case evening
    case unsure

    var titleKey: String {
        switch self {
        case .morning: "onboarding.energyWindow.morning"
        case .afternoon: "onboarding.energyWindow.afternoon"
        case .evening: "onboarding.energyWindow.evening"
        case .unsure: "onboarding.energyWindow.unsure"
        }
    }

    var accessibilityID: String {
        "onboarding.energyWindow.\(rawValue)"
    }
}

enum VitoraGuidanceStyle: String, CaseIterable, Codable, Equatable, Hashable {
    case explainFirst
    case gentleSuggestion
    case keyChangesOnly

    var titleKey: String {
        switch self {
        case .explainFirst: "onboarding.guidance.explainFirst"
        case .gentleSuggestion: "onboarding.guidance.gentleSuggestion"
        case .keyChangesOnly: "onboarding.guidance.keyChangesOnly"
        }
    }

    var accessibilityID: String {
        "onboarding.guidance.\(rawValue)"
    }
}

enum OnboardingReminderPreference: String, CaseIterable, Codable, Equatable, Hashable {
    case eveningReview
    case keyChanges
    case paused

    var titleKey: String {
        switch self {
        case .eveningReview: "onboarding.reminder.eveningReview"
        case .keyChanges: "onboarding.reminder.keyChanges"
        case .paused: "onboarding.reminder.paused"
        }
    }

    var accessibilityID: String {
        "onboarding.reminder.\(rawValue)"
    }
}

// MARK: - App Gate

enum AppGateState: String, Codable, Equatable {
    case unknown
    case needsOnboarding
    case readyForToday
    case lowDataReady

    var allowsMainTabs: Bool {
        switch self {
        case .readyForToday, .lowDataReady: true
        case .unknown, .needsOnboarding: false
        }
    }
}

// MARK: - Data Source

struct DataSourceAuthorization: Identifiable, Codable, Equatable {
    enum Source: String, Codable, Equatable {
        case healthKit
        case manual
    }

    enum State: String, Codable, Equatable {
        case notAsked
        case authorized
        case skipped
        case denied
        case revoked
    }

    var id: UUID
    var source: Source
    var state: State
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        source: Source = .healthKit,
        state: State,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.source = source
        self.state = state
        self.updatedAt = updatedAt
    }

    static func notAsked() -> DataSourceAuthorization {
        DataSourceAuthorization(state: .notAsked)
    }

    var keepsAppUsable: Bool { true }

    var isLowData: Bool {
        state != .authorized
    }
}
