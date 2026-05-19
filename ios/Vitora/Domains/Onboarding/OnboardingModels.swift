import Foundation

struct UserProfile: Identifiable, Codable, Equatable {
    var id: UUID
    var displayLabel: String
    var localeIdentifier: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        displayLabel: String,
        localeIdentifier: String = Locale.autoupdatingCurrent.identifier,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.displayLabel = displayLabel
        self.localeIdentifier = localeIdentifier
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var aiSafeLabel: String {
        displayLabel.isEmpty ? "user" : "preferred-label"
    }
}

struct OnboardingContext: Identifiable, Codable, Equatable {
    var id: UUID
    var focusAreas: [FocusArea]
    var cycleContext: CycleContext?
    var cycleSummary: String?
    var energyWindowPreference: EnergyWindowPreference
    var guidanceStyle: VitoraGuidanceStyle
    var reminderPreference: OnboardingReminderPreference
    var dataSourceAuthorization: DataSourceAuthorization
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        focusAreas: [FocusArea] = [],
        cycleContext: CycleContext? = nil,
        cycleSummary: String? = nil,
        energyWindowPreference: EnergyWindowPreference = .unsure,
        guidanceStyle: VitoraGuidanceStyle = .explainFirst,
        reminderPreference: OnboardingReminderPreference = .eveningReview,
        dataSourceAuthorization: DataSourceAuthorization = .notAsked(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.focusAreas = focusAreas
        self.cycleContext = cycleContext
        self.cycleSummary = cycleSummary
        self.energyWindowPreference = energyWindowPreference
        self.guidanceStyle = guidanceStyle
        self.reminderPreference = reminderPreference
        self.dataSourceAuthorization = dataSourceAuthorization
        self.completedAt = completedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case focusAreas
        case cycleContext
        case cycleSummary
        case energyWindowPreference
        case guidanceStyle
        case reminderPreference
        case dataSourceAuthorization
        case completedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        focusAreas = try container.decodeIfPresent([FocusArea].self, forKey: .focusAreas) ?? [.energy]
        cycleContext = try container.decodeIfPresent(CycleContext.self, forKey: .cycleContext)
        cycleSummary = try container.decodeIfPresent(String.self, forKey: .cycleSummary)
        energyWindowPreference = try container.decodeIfPresent(EnergyWindowPreference.self, forKey: .energyWindowPreference) ?? .unsure
        guidanceStyle = try container.decodeIfPresent(VitoraGuidanceStyle.self, forKey: .guidanceStyle) ?? .explainFirst
        reminderPreference = try container.decodeIfPresent(OnboardingReminderPreference.self, forKey: .reminderPreference) ?? .eveningReview
        dataSourceAuthorization = try container.decodeIfPresent(DataSourceAuthorization.self, forKey: .dataSourceAuthorization) ?? .notAsked()
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
    }

    var isComplete: Bool {
        completedAt != nil
    }

    var supportsLowDataMode: Bool {
        dataSourceAuthorization.state != .authorized
    }
}

enum FocusArea: String, CaseIterable, Codable, Equatable, Hashable {
    case energy
    case cycle
    case sleep
    case mood
    case nutrition
}

enum EnergyWindowPreference: String, CaseIterable, Codable, Equatable, Hashable {
    case morning
    case afternoon
    case evening
    case unsure

    var titleKey: String {
        switch self {
        case .morning:
            "onboarding.energyWindow.morning"
        case .afternoon:
            "onboarding.energyWindow.afternoon"
        case .evening:
            "onboarding.energyWindow.evening"
        case .unsure:
            "onboarding.energyWindow.unsure"
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
        case .explainFirst:
            "onboarding.guidance.explainFirst"
        case .gentleSuggestion:
            "onboarding.guidance.gentleSuggestion"
        case .keyChangesOnly:
            "onboarding.guidance.keyChangesOnly"
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
        case .eveningReview:
            "onboarding.reminder.eveningReview"
        case .keyChanges:
            "onboarding.reminder.keyChanges"
        case .paused:
            "onboarding.reminder.paused"
        }
    }

    var accessibilityID: String {
        "onboarding.reminder.\(rawValue)"
    }
}

enum AppGateState: String, Codable, Equatable {
    case unknown
    case needsOnboarding
    case readyForToday
    case lowDataReady

    var allowsMainTabs: Bool {
        switch self {
        case .readyForToday, .lowDataReady:
            true
        case .unknown, .needsOnboarding:
            false
        }
    }
}

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

    var keepsAppUsable: Bool {
        true
    }

    var isLowData: Bool {
        state != .authorized
    }
}
