import SwiftUI

struct ABIntentSummary: View {
    let intention: DailyIntention
    let selectedOptionTitle: String?
    let reminderPreference: ReminderPreference
    let reminderInstance: ReminderInstance?

    var body: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
            HStack(alignment: .center, spacing: VitoraTheme.Spacing.sm) {
                Image(systemName: iconName)
                    .font(.headline)
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .frame(width: 32, height: 32)
                    .background(VitoraTheme.ColorToken.actionPrimary.opacity(0.14))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.primaryText)

                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }
            }

            if intention.choice == .a || intention.choice == .b {
                if let selectedOptionTitle {
                    Text(selectedOptionTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                } else {
                    Text("today.intent.selected.fallback")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                }

                Text("today.intent.reviewHint")
                    .font(.footnote)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            if let reminderInstance {
                Text(reminderText(for: reminderInstance))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
            }
        }
        .padding(VitoraTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    VitoraTheme.ColorToken.actionPrimary.opacity(0.12),
                    VitoraTheme.ColorToken.paper.opacity(0.90),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: VitoraTheme.Radius.card, style: .continuous)
                .stroke(VitoraTheme.ColorToken.paper.opacity(0.92), lineWidth: 0.8)
        )
        .accessibilityIdentifier("today.intent.summary")
    }

    private var title: LocalizedStringKey {
        switch intention.choice {
        case .a, .b:
            "today.intent.title"
        case .notSuitable:
            "today.intent.notSuitable.title"
        case .dismissed:
            "today.intent.dismissed.title"
        }
    }

    private var subtitle: LocalizedStringKey {
        switch intention.choice {
        case .a, .b:
            reminderPreference.isEnabled ? "today.intent.reminder.enabled" : "today.intent.reminder.off"
        case .notSuitable:
            "today.intent.notSuitable.body"
        case .dismissed:
            "today.intent.dismissed.body"
        }
    }

    private var iconName: String {
        switch intention.choice {
        case .a, .b:
            "sparkle.magnifyingglass"
        case .notSuitable:
            "hand.raised"
        case .dismissed:
            "moon"
        }
    }

    private func reminderText(for reminder: ReminderInstance) -> LocalizedStringKey {
        switch reminder.state {
        case .scheduled:
            "today.intent.reminder.scheduled"
        case .notScheduledPermissionMissing:
            "today.intent.reminder.permissionMissing"
        case .canceled:
            "today.intent.reminder.canceled"
        case .fired:
            "today.intent.reminder.fired"
        }
    }
}
