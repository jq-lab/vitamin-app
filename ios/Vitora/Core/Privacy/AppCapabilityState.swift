import Foundation

enum AIAvailabilityState: String, Codable, Equatable {
    case available
    case unavailable
    case limited
}

struct AppCapabilityState: Codable, Equatable {
    var dataSourceState: DataSourceAuthorization.State
    var notificationPermission: NotificationPermissionState
    var aiAvailability: AIAvailabilityState

    init(
        dataSourceState: DataSourceAuthorization.State = .notAsked,
        notificationPermission: NotificationPermissionState = .notDetermined,
        aiAvailability: AIAvailabilityState = .available
    ) {
        self.dataSourceState = dataSourceState
        self.notificationPermission = notificationPermission
        self.aiAvailability = aiAvailability
    }

    var isLowDataMode: Bool {
        dataSourceState != .authorized
    }

    var canUseAI: Bool {
        aiAvailability == .available || aiAvailability == .limited
    }

    var userFeedbacks: [AppCapabilityFeedback] {
        var feedbacks: [AppCapabilityFeedback] = []

        if isLowDataMode {
            feedbacks.append(.lowData)
        }

        if dataSourceState == .denied || dataSourceState == .revoked {
            feedbacks.append(.permissionDenied)
        }

        if !canUseAI {
            feedbacks.append(.aiUnavailable)
        }

        return feedbacks
    }
}

struct AppCapabilityFeedback: Codable, Equatable, Identifiable {
    enum Kind: String, Codable, Equatable {
        case lowData
        case aiUnavailable
        case permissionDenied
    }

    var id: Kind { kind }
    var kind: Kind
    var title: String
    var message: String
    var complianceLabelID: String

    static let lowData = AppCapabilityFeedback(
        kind: .lowData,
        title: "当前信息较少",
        message: "你可以继续手动记录，或稍后连接 HealthKit。",
        complianceLabelID: "CL-LOW-DATA"
    )

    static let aiUnavailable = AppCapabilityFeedback(
        kind: .aiUnavailable,
        title: "Vitora 暂时不可用",
        message: "你仍可以保存记录，稍后再让 Vitora 理解。",
        complianceLabelID: "CL-AI-UNAVAILABLE"
    )

    static let permissionDenied = AppCapabilityFeedback(
        kind: .permissionDenied,
        title: "HealthKit 未授权",
        message: "你可以继续手动记录，也可以稍后在数据来源里重新管理权限。",
        complianceLabelID: "CL-LOW-DATA"
    )
}
