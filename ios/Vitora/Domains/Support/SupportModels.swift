import Foundation

struct ReminderPreference: Identifiable, Codable, Equatable {
    var id: UUID
    var isEnabled: Bool
    var intentionReminderHour: Int?
    var reviewReminderHour: Int?
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        isEnabled: Bool = false,
        intentionReminderHour: Int? = nil,
        reviewReminderHour: Int? = nil,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.isEnabled = isEnabled
        self.intentionReminderHour = intentionReminderHour
        self.reviewReminderHour = reviewReminderHour
        self.updatedAt = updatedAt
    }
}

enum ReminderInstanceState: String, Codable, Equatable {
    case scheduled
    case canceled
    case fired
    case notScheduledPermissionMissing
}

struct ReminderInstance: Identifiable, Codable, Equatable {
    var id: UUID
    var intentionID: UUID?
    var type: VitoraNotificationType
    var state: ReminderInstanceState
    var scheduledAt: Date?

    init(
        id: UUID = UUID(),
        intentionID: UUID? = nil,
        type: VitoraNotificationType,
        state: ReminderInstanceState,
        scheduledAt: Date? = nil
    ) {
        self.id = id
        self.intentionID = intentionID
        self.type = type
        self.state = state
        self.scheduledAt = scheduledAt
    }
}

enum DataExportState: String, Codable, Equatable {
    case viewing
    case confirming
    case preparing
    case ready
    case completed
    case error
    case canceled
}

struct DataExportRequest: Identifiable, Codable, Equatable {
    var id: UUID
    var state: DataExportState
    var requestedAt: Date
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        state: DataExportState = .viewing,
        requestedAt: Date = .now,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.state = state
        self.requestedAt = requestedAt
        self.completedAt = completedAt
    }
}

enum AccountRemovalState: String, Codable, Equatable {
    case viewing
    case confirming
    case processing
    case completed
    case error
    case canceled
}

struct AccountRemovalRequest: Identifiable, Codable, Equatable {
    var id: UUID
    var state: AccountRemovalState
    var requestedAt: Date
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        state: AccountRemovalState = .viewing,
        requestedAt: Date = .now,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.state = state
        self.requestedAt = requestedAt
        self.completedAt = completedAt
    }
}

enum SupportItem: String, CaseIterable, Codable, Equatable {
    case profile
    case dataSources
    case nutrition
    case reminders
    case dataExport
    case privacyAndAccountRemoval

    static let p0Items: [SupportItem] = [
        .profile,
        .dataSources,
        .nutrition,
        .reminders,
        .dataExport,
        .privacyAndAccountRemoval,
    ]

    var title: String {
        switch self {
        case .profile:
            "个人资料"
        case .dataSources:
            "HealthKit 与数据来源"
        case .nutrition:
            "营养补给"
        case .reminders:
            "提醒偏好"
        case .dataExport:
            "数据导出"
        case .privacyAndAccountRemoval:
            "隐私法律与账号移除"
        }
    }

    var subtitle: String {
        switch self {
        case .profile:
            "本地称呼与账号状态"
        case .dataSources:
            "HealthKit 可选增强，低数据仍可使用"
        case .nutrition:
            "管理补给上下文，供 Vitora 建议参考"
        case .reminders:
            "只服务今日建议和晚间复盘"
        case .dataExport:
            "准备一份本地数据导出摘要"
        case .privacyAndAccountRemoval:
            "查看隐私说明并移除本地账号数据"
        }
    }

    var systemImage: String {
        switch self {
        case .profile:
            "person.crop.circle"
        case .dataSources:
            "heart.text.square"
        case .nutrition:
            "leaf"
        case .reminders:
            "bell.badge"
        case .dataExport:
            "square.and.arrow.up"
        case .privacyAndAccountRemoval:
            "lock.shield"
        }
    }

    var route: SupportRoute {
        switch self {
        case .profile:
            .profile
        case .dataSources:
            .dataSources
        case .nutrition:
            .nutrition
        case .reminders:
            .reminders
        case .dataExport:
            .dataExport
        case .privacyAndAccountRemoval:
            .privacyAndAccountRemoval
        }
    }
}

struct SupportPanelState: Equatable {
    var visibleItems: [SupportItem]
    var selectedRoute: SupportRoute?

    init(visibleItems: [SupportItem] = SupportItem.p0Items, selectedRoute: SupportRoute? = nil) {
        self.visibleItems = visibleItems
        self.selectedRoute = selectedRoute
    }
}

struct DataSourceSummary: Equatable {
    var authorization: DataSourceAuthorization
    var title: String
    var detail: String
    var keepsAppUsable: Bool
    var isLowDataMode: Bool
}

struct DataExportPackage: Equatable {
    var request: DataExportRequest
    var itemCount: Int
    var containsSensitiveClasses: Bool
}

struct AccountRemovalResult: Equatable {
    var request: AccountRemovalRequest
    var gateState: AppGateState
}

extension SupportRoute {
    var item: SupportItem {
        switch self {
        case .profile:
            .profile
        case .dataSources:
            .dataSources
        case .nutrition:
            .nutrition
        case .reminders:
            .reminders
        case .dataExport:
            .dataExport
        case .privacyAndAccountRemoval:
            .privacyAndAccountRemoval
        }
    }

    var title: String {
        item.title
    }
}
