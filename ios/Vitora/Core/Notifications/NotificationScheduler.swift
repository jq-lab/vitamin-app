import Foundation
import UserNotifications

enum NotificationPermissionState: String, Codable, Equatable {
    case notDetermined
    case authorized
    case denied
}

enum VitoraNotificationType: String, Codable, Equatable {
    case intentionReminder
    case eveningReview
}

struct NotificationPayload: Codable, Equatable {
    var type: VitoraNotificationType
    var titleKey: String
    var bodyKey: String

    var containsSensitiveValues: Bool {
        false
    }

    static func generic(type: VitoraNotificationType) -> NotificationPayload {
        switch type {
        case .intentionReminder:
            NotificationPayload(type: type, titleKey: "notification.intention.title", bodyKey: "notification.intention.body")
        case .eveningReview:
            NotificationPayload(type: type, titleKey: "notification.review.title", bodyKey: "notification.review.body")
        }
    }
}

protocol NotificationScheduling {
    var permissionState: NotificationPermissionState { get }
    func schedule(type: VitoraNotificationType, intentionID: UUID?, at date: Date) -> ReminderInstance
    func scheduleIntentionReminder(for intention: DailyIntention, preference: ReminderPreference, day: Date) -> ReminderInstance?
    func cancel(instanceID: UUID) -> ReminderInstance?
    func cancelAll()
}

final class InMemoryNotificationScheduler: NotificationScheduling {
    private(set) var permissionState: NotificationPermissionState
    private var instances: [UUID: ReminderInstance] = [:]

    init(permissionState: NotificationPermissionState = .notDetermined) {
        self.permissionState = permissionState
    }

    func schedule(type: VitoraNotificationType, intentionID: UUID?, at date: Date) -> ReminderInstance {
        let state: ReminderInstanceState = permissionState == .authorized ? .scheduled : .notScheduledPermissionMissing
        let instance = ReminderInstance(intentionID: intentionID, type: type, state: state, scheduledAt: date)
        instances[instance.id] = instance
        return instance
    }

    func scheduleIntentionReminder(for intention: DailyIntention, preference: ReminderPreference, day: Date) -> ReminderInstance? {
        guard preference.isEnabled else {
            return nil
        }

        let scheduledHour = preference.intentionReminderHour ?? 14
        let scheduledDate = Calendar.current.date(
            bySettingHour: scheduledHour,
            minute: 0,
            second: 0,
            of: day
        ) ?? day

        return schedule(type: .intentionReminder, intentionID: intention.id, at: scheduledDate)
    }

    func cancel(instanceID: UUID) -> ReminderInstance? {
        guard var instance = instances[instanceID] else {
            return nil
        }
        instance.state = .canceled
        instances[instanceID] = instance
        return instance
    }

    func cancelAll() {
        instances = instances.mapValues { instance in
            var next = instance
            next.state = .canceled
            return next
        }
    }

    func allInstances() -> [ReminderInstance] {
        Array(instances.values)
    }
}
