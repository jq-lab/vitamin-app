import SwiftUI

struct ReminderPreferencePanel: View {
    let preference: ReminderPreference
    let onSave: (ReminderPreference) -> Void

    @State private var isEnabled: Bool
    @State private var intentionHour: Int
    @State private var reviewHour: Int

    init(preference: ReminderPreference, onSave: @escaping (ReminderPreference) -> Void) {
        self.preference = preference
        self.onSave = onSave
        _isEnabled = State(initialValue: preference.isEnabled)
        _intentionHour = State(initialValue: preference.intentionReminderHour ?? 14)
        _reviewHour = State(initialValue: preference.reviewReminderHour ?? 21)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
            Text("today.reminder.title")
                .font(.headline)
                .foregroundStyle(VitoraTheme.ColorToken.primaryText)

            Toggle(isOn: $isEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("today.reminder.toggle")
                        .font(.subheadline.weight(.semibold))
                    Text("today.reminder.body")
                        .font(.caption)
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }
            }
            .tint(VitoraTheme.ColorToken.actionPrimary)
            .accessibilityIdentifier("today.reminder.toggle")
            .onChange(of: isEnabled) { _, _ in
                save()
            }

            if isEnabled {
                HStack(spacing: VitoraTheme.Spacing.sm) {
                    reminderStepper(title: "today.reminder.intention", hour: $intentionHour)
                    reminderStepper(title: "today.reminder.review", hour: $reviewHour)
                }

                Text("today.reminder.ready")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
            } else {
                Text("today.reminder.off")
                    .font(.caption)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }
        }
        .padding(VitoraTheme.Spacing.md)
        .background(SupportGlassSurface())
        .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.card, style: .continuous))
        .onChange(of: intentionHour) { _, _ in
            save()
        }
        .onChange(of: reviewHour) { _, _ in
            save()
        }
    }

    private func reminderStepper(title: LocalizedStringKey, hour: Binding<Int>) -> some View {
        Stepper(value: hour, in: 8...22, step: 1) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                Text(String(format: "%02d:00", hour.wrappedValue))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.primaryText)
            }
        }
        .padding(VitoraTheme.Spacing.sm)
        .background(VitoraTheme.ColorToken.paper.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.md, style: .continuous))
    }

    private func save() {
        onSave(
            ReminderPreference(
                id: preference.id,
                isEnabled: isEnabled,
                intentionReminderHour: intentionHour,
                reviewReminderHour: reviewHour,
                updatedAt: .now
            )
        )
    }
}
