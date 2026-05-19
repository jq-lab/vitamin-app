import SwiftUI

struct OnboardingReadyView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    var onFinish: (OnboardingCompletion) -> Void

    var body: some View {
        OnboardingPageCard(
            pageNumber: 3,
            eyebrow: "onboarding.ready.eyebrow",
            title: "onboarding.ready.title",
            bodyText: LocalizedStringKey(viewModel.isLowData ? "onboarding.ready.lowdata" : "onboarding.ready.connected"),
            ipState: .confirming,
            ipSize: 120
        ) {
            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.lg) {
                summaryCard

                ComplianceLabel(text: "onboarding.ready.body")

                Button {
                    viewModel.editCustomization()
                } label: {
                    Label("onboarding.ready.editCustomization", systemImage: "slider.horizontal.3")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.62))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.white.opacity(0.68), lineWidth: 0.8)
                                }
                        )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("onboarding.ready.editCustomization")

                OnboardingContinueButton(title: "onboarding.ready.enterToday") {
                    onFinish(viewModel.finish())
                }
                .accessibilityIdentifier("onboarding.ready.enterToday")
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
                Text("onboarding.ready.summary.title")
                    .font(.headline)
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                Text("onboarding.ready.summary.body")
                    .font(.subheadline)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
                focusSummary
                summaryRow(title: "onboarding.energyWindow.title", value: LocalizedStringKey(viewModel.energyWindowPreference.titleKey), systemImage: "clock")
                summaryRow(title: "onboarding.guidance.title", value: LocalizedStringKey(viewModel.guidanceStyle.titleKey), systemImage: "sparkles")
                summaryRow(title: "onboarding.reminder.title", value: LocalizedStringKey(viewModel.reminderPreference.titleKey), systemImage: "bell")
                summaryRow(title: "onboarding.ready.datasource", value: dataSourceSummary, systemImage: "heart.text.square")
            }
        }
        .padding(VitoraTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.58))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.72), lineWidth: 0.8)
                }
        )
        .accessibilityIdentifier("onboarding.ready.summary")
    }

    private var focusSummary: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
            Label("onboarding.context.focus.title", systemImage: "scope")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            HStack(spacing: VitoraTheme.Spacing.xs) {
                ForEach(viewModel.selectedFocusAreasList, id: \.self) { focus in
                    Text(focus.titleKey)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                        .padding(.horizontal, VitoraTheme.Spacing.md)
                        .frame(minHeight: 34)
                        .background(
                            Capsule(style: .continuous)
                                .fill(VitoraTheme.ColorToken.paper.opacity(0.72))
                        )
                }
            }
        }
    }

    private var dataSourceSummary: LocalizedStringKey {
        switch viewModel.dataSourceAuthorization.state {
        case .authorized:
            "onboarding.ready.datasource.connected"
        case .notAsked:
            "onboarding.healthkit.notAsked"
        case .skipped, .denied, .revoked:
            "onboarding.ready.datasource.lowdata"
        }
    }

    private func summaryRow(title: LocalizedStringKey, value: LocalizedStringKey, systemImage: String) -> some View {
        HStack(alignment: .top, spacing: VitoraTheme.Spacing.sm) {
            Image(systemName: systemImage)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

                Text(value)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}
