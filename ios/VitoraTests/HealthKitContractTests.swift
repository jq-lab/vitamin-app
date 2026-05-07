import XCTest
@testable import Vitora

final class HealthKitContractTests: XCTestCase {
    func testHealthKitAllowlistContainsOnlyP0Kinds() {
        let client = DefaultHealthKitClient()

        XCTAssertEqual(client.allowedDataKinds(), [
            .sleepSummary,
            .stepCount,
            .activeEnergy,
            .heartRateAverage,
            .restingHeartRate,
            .heartRateVariability,
        ])
    }

    func testSkippingHealthKitKeepsAppUsable() {
        let client = DefaultHealthKitClient()
        let authorization = client.skipAuthorization()

        XCTAssertEqual(authorization.state, .skipped)
        XCTAssertTrue(authorization.keepsAppUsable)
        XCTAssertTrue(authorization.isLowData)
    }

    func testRevokedHealthKitReturnsLowDataCapability() {
        let client = DefaultHealthKitClient()
        let authorization = client.markRevoked()
        let capability = AppCapabilityState(dataSourceState: authorization.state)

        XCTAssertEqual(authorization.state, .revoked)
        XCTAssertTrue(capability.isLowDataMode)
    }
}
