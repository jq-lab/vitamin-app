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
    var dataSourceAuthorization: DataSourceAuthorization
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        focusAreas: [FocusArea] = [],
        cycleContext: CycleContext? = nil,
        dataSourceAuthorization: DataSourceAuthorization = .notAsked(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.focusAreas = focusAreas
        self.cycleContext = cycleContext
        self.dataSourceAuthorization = dataSourceAuthorization
        self.completedAt = completedAt
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
