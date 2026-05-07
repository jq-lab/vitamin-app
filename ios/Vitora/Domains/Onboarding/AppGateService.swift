import Foundation

struct AppGateService: AppGateServicing {
    func resolveGate(profile: UserProfile?, dataSource: DataSourceAuthorization?) -> AppGateState {
        guard profile != nil else {
            return .needsOnboarding
        }
        return dataSource?.isLowData == false ? .readyForToday : .lowDataReady
    }

    func resolveGate(profile: UserProfile?, context: OnboardingContext?) -> AppGateState {
        resolveGate(profile: profile, dataSource: context?.dataSourceAuthorization)
    }
}
