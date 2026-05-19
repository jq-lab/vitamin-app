import SwiftUI

struct OnboardingContextView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    private let cycleLengthOptions = ["约 28 天", "不确定", "不太规律"]
    private let regularityOptions = ["比较规律", "偶尔变化", "不确定"]
    private let contextColumns = [
        GridItem(.adaptive(minimum: 118), spacing: VitoraTheme.Spacing.xs)
    ]
    private let preferenceColumns = [
        GridItem(.adaptive(minimum: 92), spacing: VitoraTheme.Spacing.xs)
    ]

    var body: some View {
        OnboardingPageCard(
            pageNumber: 2,
            eyebrow: "onboarding.context.eyebrow",
            title: "onboarding.context.title",
            bodyText: "onboarding.context.body",
            ipState: .thinking,
            ipSize: 112
        ) {
            VStack(alignment: .leading, spacing: 20) {
                focusSection
                preferenceSection
                rhythmSection
                dataSourceSection

                OnboardingContinueButton(
                    title: "onboarding.context.continue",
                    disabled: !viewModel.canContinueContext
                ) {
                    viewModel.goToReady()
                }
                .accessibilityIdentifier("onboarding.context.continue")

                if !viewModel.canContinueContext {
                    Text("onboarding.context.datasource.required")
                        .font(.footnote)
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("onboarding.context.requireDataSource")
                }
            }
        }
    }

    private var focusSection: some View {
        onboardingSection {
            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.md) {
                sectionHeader(
                    icon: "scope",
                    title: "onboarding.context.focus.title",
                    body: "onboarding.context.focus.body"
                )

                LazyVGrid(columns: contextColumns, alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
                    ForEach(FocusArea.allCases, id: \.self) { focus in
                        OnboardingChoiceButton(
                            title: focus.titleKey,
                            isSelected: viewModel.selectedFocusAreas.contains(focus)
                        ) {
                            viewModel.toggleFocusArea(focus)
                        }
                        .accessibilityIdentifier(focus.accessibilityID)
                    }
                }

                Text("onboarding.context.focus.limit")
                    .font(.caption)
                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
            }
        }
    }

    private var dataSourceSection: some View {
        onboardingSection {
            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.md) {
                sectionHeader(
                    icon: "heart.text.square",
                    title: "onboarding.healthkit.title",
                    body: "onboarding.healthkit.body"
                )

                Button {
                    viewModel.chooseDataSource(.allow)
                } label: {
                    Label("onboarding.healthkit.allow", systemImage: "heart.text.square")
                        .font(.callout.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
                }
                .buttonStyle(.borderedProminent)
                .tint(VitoraTheme.ColorToken.strongText)
                .accessibilityIdentifier("onboarding.healthkit.allow")

                HStack(spacing: VitoraTheme.Spacing.sm) {
                    Button {
                        viewModel.chooseDataSource(.skip)
                    } label: {
                        Label("onboarding.healthkit.skip", systemImage: "forward")
                            .font(.callout.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("onboarding.healthkit.skip")

                    Button {
                        viewModel.chooseDataSource(.deny)
                    } label: {
                        Label("onboarding.healthkit.deny", systemImage: "xmark.circle")
                            .font(.callout.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("onboarding.healthkit.deny")
                }

                Text(dataSourceStateText)
                    .font(.footnote)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("onboarding.healthkit.state")
            }
        }
    }

    private var rhythmSection: some View {
        onboardingSection {
            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.md) {
                sectionHeader(
                    icon: "waveform.path",
                    title: "onboarding.context.rhythm.title",
                    body: "onboarding.context.rhythm.body"
                )

                VitoraTextField(title: "onboarding.context.cycle.placeholder", text: $viewModel.cycleSummary)
                    .accessibilityIdentifier("onboarding.context.cycle")

                optionGroup(
                    title: "onboarding.context.length.title",
                    options: cycleLengthOptions,
                    selected: viewModel.cycleLengthSummary,
                    onSelect: viewModel.chooseCycleLength
                )

                optionGroup(
                    title: "onboarding.context.regularity.title",
                    options: regularityOptions,
                    selected: viewModel.cycleRegularitySummary,
                    onSelect: viewModel.chooseCycleRegularity
                )

                Toggle(isOn: $viewModel.shouldEstimateCycle) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("onboarding.context.estimate.title")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                        Text("onboarding.context.estimate.body")
                            .font(.footnote)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }
                }
                .toggleStyle(.switch)
                .tint(VitoraTheme.ColorToken.actionPrimary)
            }
        }
    }

    private var preferenceSection: some View {
        onboardingSection {
            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.md) {
                sectionHeader(
                    icon: "slider.horizontal.3",
                    title: "onboarding.custom.title",
                    body: "onboarding.custom.body"
                )

                enumOptionGrid(
                    title: "onboarding.energyWindow.title",
                    options: EnergyWindowPreference.allCases,
                    selected: viewModel.energyWindowPreference,
                    titleKey: \.titleKey,
                    idKey: \.accessibilityID,
                    onSelect: viewModel.chooseEnergyWindow
                )

                enumOptionGrid(
                    title: "onboarding.guidance.title",
                    options: VitoraGuidanceStyle.allCases,
                    selected: viewModel.guidanceStyle,
                    titleKey: \.titleKey,
                    idKey: \.accessibilityID,
                    onSelect: viewModel.chooseGuidanceStyle
                )

                enumOptionGrid(
                    title: "onboarding.reminder.title",
                    options: OnboardingReminderPreference.allCases,
                    selected: viewModel.reminderPreference,
                    titleKey: \.titleKey,
                    idKey: \.accessibilityID,
                    onSelect: viewModel.chooseReminderPreference
                )
            }
        }
    }

    private var dataSourceStateText: LocalizedStringKey {
        switch viewModel.dataSourceAuthorization.state {
        case .notAsked:
            "onboarding.healthkit.notAsked"
        case .authorized:
            "onboarding.healthkit.connected.selected"
        case .skipped, .denied, .revoked:
            "onboarding.healthkit.lowdata.selected"
        }
    }

    private func onboardingSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.md) {
            content()
        }
        .padding(VitoraTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.58))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.72), lineWidth: 0.8)
                }
        )
    }

    private func sectionHeader(icon: String, title: LocalizedStringKey, body: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }

            Text(body)
                .font(.subheadline)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func enumOptionGrid<Option: Hashable>(
        title: LocalizedStringKey,
        options: [Option],
        selected: Option,
        titleKey: KeyPath<Option, String>,
        idKey: KeyPath<Option, String>,
        onSelect: @escaping (Option) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            LazyVGrid(columns: preferenceColumns, alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
                ForEach(options, id: \.self) { option in
                    OnboardingChoiceButton(
                        title: LocalizedStringKey(option[keyPath: titleKey]),
                        isSelected: selected == option
                    ) {
                        onSelect(option)
                    }
                    .accessibilityIdentifier(option[keyPath: idKey])
                }
            }
        }
    }

    private func optionGroup(
        title: LocalizedStringKey,
        options: [String],
        selected: String,
        onSelect: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            HStack(spacing: VitoraTheme.Spacing.xs) {
                ForEach(options, id: \.self) { option in
                    OnboardingChoiceButton(
                        title: LocalizedStringKey(option),
                        isSelected: selected == option
                    ) {
                        onSelect(option)
                    }
                }
            }
        }
    }
}

extension FocusArea {
    var titleKey: LocalizedStringKey {
        switch self {
        case .energy:
            "focus.energy"
        case .cycle:
            "focus.cycle"
        case .sleep:
            "focus.sleep"
        case .mood:
            "focus.mood"
        case .nutrition:
            "focus.nutrition"
        }
    }

    var accessibilityID: String {
        "onboarding.focus.\(rawValue)"
    }
}
