import SwiftUI

struct TodayAnalysisSheet: View {
    let analysis: TodayAnalysis
    let dailyIntention: DailyIntention?
    let selectedABOption: ABOptionSet.Option?
    let reminderPreference: ReminderPreference
    let reminderInstance: ReminderInstance?
    let onSelectABOption: (ABOptionSet.Option) -> Void
    let onRejectABOptions: () -> Void
    let onSaveReminderPreference: (ReminderPreference) -> Void
    let onClose: () -> Void

    var body: some View {
        VitoraSheetSurface {
            ScrollView {
                VStack(alignment: .leading, spacing: VitoraTheme.Spacing.lg) {
                    HStack {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .accessibilityIdentifier("today.analysis.close")

                        Spacer()

                        Text("today.analysis.title")
                            .font(.title3.weight(.semibold))

                        Spacer()

                        Color.clear
                            .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                    }

                    VStack(alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
                        Text(analysis.isLowData ? "today.analysis.lowdata.title" : "today.analysis.summary.title")
                            .font(.headline)
                            .foregroundStyle(VitoraTheme.ColorToken.primaryText)

                        Text(analysis.summary)
                            .font(.body)
                            .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
                        Text("today.analysis.factors.title")
                            .font(.headline)
                            .foregroundStyle(VitoraTheme.ColorToken.primaryText)

                        ForEach(analysis.factors) { factor in
                            HStack(alignment: .top, spacing: VitoraTheme.Spacing.sm) {
                                Text(factor.title)
                                    .font(.subheadline.weight(.medium))
                                    .frame(width: 56, alignment: .leading)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(factor.value)
                                        .font(.subheadline.weight(.semibold))
                                    Text(factor.note)
                                        .font(.caption)
                                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                                }
                            }
                            .padding(VitoraTheme.Spacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(VitoraTheme.ColorToken.softSurface)
                            .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.md, style: .continuous))
                        }
                    }

                    VStack(alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
                        Text("today.analysis.next.title")
                            .font(.headline)
                            .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)

                        Text(analysis.nextStep)
                            .font(.body)
                            .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                    }

                    if let optionSet = analysis.optionSet {
                        if let dailyIntention {
                            ABIntentSummary(
                                intention: dailyIntention,
                                selectedOptionTitle: selectedABOption?.title,
                                reminderPreference: reminderPreference,
                                reminderInstance: reminderInstance
                            )

                            if dailyIntention.choice == .a || dailyIntention.choice == .b {
                                ReminderPreferencePanel(
                                    preference: reminderPreference,
                                    onSave: onSaveReminderPreference
                                )
                            }
                        } else {
                            ABChoiceGroup(
                                optionSet: optionSet,
                                selectedChoice: nil,
                                onSelect: onSelectABOption,
                                onNotSuitable: onRejectABOptions
                            )
                        }
                    }

                    ComplianceLabel(text: "today.compliance.default")
                }
                .padding(.bottom, VitoraTheme.Spacing.lg)
            }
        }
    }
}
