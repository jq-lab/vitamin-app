import Foundation
import HealthKit

enum HealthKitDataKind: String, CaseIterable, Codable, Equatable {
    case sleepSummary
    case stepCount
    case activeEnergy
    case heartRateAverage
    case restingHeartRate
    case heartRateVariability
}

struct HealthKitSummary: Identifiable, Codable, Equatable {
    var id: UUID
    var kind: HealthKitDataKind
    var day: Date
    var valueCategory: String

    init(id: UUID = UUID(), kind: HealthKitDataKind, day: Date, valueCategory: String) {
        self.id = id
        self.kind = kind
        self.day = day
        self.valueCategory = valueCategory
    }
}

protocol HealthKitClient {
    var authorizationState: DataSourceAuthorization.State { get }
    func allowedDataKinds() -> [HealthKitDataKind]
    func apply(choice: HealthKitAuthorizationChoice) -> DataSourceAuthorization
    func skipAuthorization() -> DataSourceAuthorization
    func markDenied() -> DataSourceAuthorization
    func markRevoked() -> DataSourceAuthorization
}

enum HealthKitAuthorizationChoice: String, Codable, Equatable {
    case allow
    case skip
    case deny
}

struct DefaultHealthKitClient: HealthKitClient {
    private(set) var authorizationState: DataSourceAuthorization.State

    init(authorizationState: DataSourceAuthorization.State = .notAsked) {
        self.authorizationState = authorizationState
    }

    func allowedDataKinds() -> [HealthKitDataKind] {
        HealthKitDataKind.allCases
    }

    func apply(choice: HealthKitAuthorizationChoice) -> DataSourceAuthorization {
        switch choice {
        case .allow:
            DataSourceAuthorization(state: .authorized)
        case .skip:
            skipAuthorization()
        case .deny:
            markDenied()
        }
    }

    func skipAuthorization() -> DataSourceAuthorization {
        DataSourceAuthorization(state: .skipped)
    }

    func markDenied() -> DataSourceAuthorization {
        DataSourceAuthorization(state: .denied)
    }

    func markRevoked() -> DataSourceAuthorization {
        DataSourceAuthorization(state: .revoked)
    }

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
}
