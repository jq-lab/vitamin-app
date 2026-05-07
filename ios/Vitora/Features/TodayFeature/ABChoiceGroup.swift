import SwiftUI

struct ABChoiceGroup: View {
    let optionSet: ABOptionSet
    let selectedChoice: DailyIntention.Choice?
    let onSelect: (ABOptionSet.Option) -> Void
    let onNotSuitable: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
            Text("today.analysis.ab.title")
                .font(.headline)
                .foregroundStyle(VitoraTheme.ColorToken.primaryText)

            ForEach(optionSet.options) { option in
                Button {
                    onSelect(option)
                } label: {
                    HStack(alignment: .top, spacing: VitoraTheme.Spacing.sm) {
                        Text(option.label.rawValue.uppercased())
                            .font(.headline)
                            .foregroundStyle(isSelected(option) ? VitoraTheme.ColorToken.paper : VitoraTheme.ColorToken.actionPrimaryDeep)
                            .frame(width: 34, height: 34)
                            .background(isSelected(option) ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.actionPrimary.opacity(0.14))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(option.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                                .lineLimit(2)
                                .minimumScaleFactor(0.82)

                            Text(option.contextSummary)
                                .font(.caption)
                                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                                .lineLimit(2)

                            if let reminderHint = option.reminderHint {
                                Label(reminderHint, systemImage: "bell")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                            }
                        }

                        Spacer(minLength: VitoraTheme.Spacing.xs)

                        Image(systemName: isSelected(option) ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(isSelected(option) ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.secondaryText.opacity(0.45))
                    }
                    .padding(VitoraTheme.Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(isSelected(option) ? VitoraTheme.ColorToken.actionPrimary.opacity(0.10) : VitoraTheme.ColorToken.paper)
                    .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: VitoraTheme.Radius.md, style: .continuous)
                            .stroke(isSelected(option) ? VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.34) : VitoraTheme.ColorToken.actionPrimary.opacity(0.18), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("today.ab.choice.\(option.label.rawValue)")
            }

            Button(action: onNotSuitable) {
                Text("today.ab.notSuitable")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
                    .background(VitoraTheme.ColorToken.softSurface)
                    .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.md, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("today.ab.notSuitable")
        }
    }

    private func isSelected(_ option: ABOptionSet.Option) -> Bool {
        switch (selectedChoice, option.label) {
        case (.a?, .a), (.b?, .b):
            true
        default:
            false
        }
    }
}
