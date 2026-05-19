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
        FrostedSheetShell(
            title: "今日分析",
            subtitle: "解释满分、扣分和今天怎么补充",
            closeAccessibilityID: "today.analysis.close",
            onClose: onClose
        ) {
            TodayScoreCard()

            VStack(alignment: .leading, spacing: 12) {
                Text(analysis.isLowData ? "基于目前信息" : "证据来源")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                Text(analysis.summary)
                    .font(.subheadline.weight(.medium))
                    .lineSpacing(3)
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(analysis.factors) { factor in
                    HStack(alignment: .top, spacing: 11) {
                        Image(systemName: symbol(for: factor.title))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                            .frame(width: 28, height: 28)
                            .background(VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.76), in: Circle())

                        VStack(alignment: .leading, spacing: 3) {
                            Text(factor.title)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            Text("\(factor.value) · \(factor.note)")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(VitoraTheme.ColorToken.paper.opacity(0.44), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.62), lineWidth: 0.7))
                }
            }
            .padding(16)
            .background(GlassSurface(cornerRadius: 24, opacity: 0.66, shadowStrength: 0.34, variant: .cleanResting))

            VStack(alignment: .leading, spacing: 8) {
                Text("Vitora 推荐今天这样补充")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text(analysis.nextStep)
                    .font(.subheadline.weight(.semibold))
                    .lineSpacing(3)
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GlassSurface(cornerRadius: 22, opacity: 0.68, shadowStrength: 0.32, variant: .cleanResting))

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
    }

    private func symbol(for title: String) -> String {
        if title.contains("睡") {
            return "moon.fill"
        }
        if title.contains("HRV") {
            return "heart.circle.fill"
        }
        if title.contains("心") {
            return "heart.fill"
        }
        if title.contains("周期") {
            return "sparkles"
        }
        return "circle.grid.2x2.fill"
    }
}
