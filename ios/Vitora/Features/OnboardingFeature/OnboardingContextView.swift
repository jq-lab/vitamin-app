import SwiftUI

struct OnboardingYourBodyView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    var onFinish: (OnboardingCompletion) -> Void

    private let regularityColumns = [
        GridItem(.adaptive(minimum: 92), spacing: VitoraTheme.Spacing.xs)
    ]
    private let flowColumns = [
        GridItem(.adaptive(minimum: 80), spacing: VitoraTheme.Spacing.xs)
    ]

    var body: some View {
        OnboardingPageCard(
            pageNumber: 2,
            eyebrow: "onboarding.yourBody.eyebrow",
            title: "onboarding.yourBody.title",
            bodyText: "onboarding.yourBody.body",
            ipState: .thinking,
            ipSize: 112
        ) {
            VStack(alignment: .leading, spacing: 20) {
                periodSection
                permissionsSection

                OnboardingContinueButton(title: "onboarding.yourBody.enter") {
                    onFinish(viewModel.finish())
                }
                .accessibilityIdentifier("onboarding.yourBody.enter")
            }
        }
    }

    // MARK: - Period

    private var periodSection: some View {
        onboardingSection {
            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.md) {
                sectionHeader(icon: "waveform.path", title: "onboarding.period.title", body: "onboarding.period.body")

                // Regularity
                VStack(alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
                    Text("onboarding.periodRegularity.title")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

                    LazyVGrid(columns: regularityColumns, alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
                        ForEach(PeriodRegularity.allCases, id: \.self) { option in
                            OnboardingChoiceButton(
                                title: LocalizedStringKey(option.titleKey),
                                isSelected: viewModel.periodRegularity == option
                            ) {
                                viewModel.choosePeriodRegularity(option)
                            }
                            .accessibilityIdentifier(option.accessibilityID)
                        }
                    }
                }

                // Last period date
                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: Binding(
                        get: { !viewModel.lastPeriodDateUnsure },
                        set: { viewModel.lastPeriodDateUnsure = !$0 }
                    )) {
                        Text("onboarding.period.lastDate.title")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                    }
                    .toggleStyle(.switch)
                    .tint(VitoraTheme.ColorToken.actionPrimary)

                    if !viewModel.lastPeriodDateUnsure {
                        DatePicker(
                            "",
                            selection: $viewModel.lastPeriodDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    } else {
                        Text("onboarding.period.lastDate.unsure")
                            .font(.footnote)
                            .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                    }
                }

                // Average cycle length
                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: Binding(
                        get: { !viewModel.averageCycleLengthUnsure },
                        set: { viewModel.averageCycleLengthUnsure = !$0 }
                    )) {
                        Text("onboarding.period.cycleLength.title")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                    }
                    .toggleStyle(.switch)
                    .tint(VitoraTheme.ColorToken.actionPrimary)

                    if !viewModel.averageCycleLengthUnsure {
                        HStack(spacing: 12) {
                            Text("\(Int(viewModel.averageCycleLength))")
                                .font(.title3.weight(.bold).monospacedDigit())
                                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                                .frame(width: 36)

                            Slider(value: $viewModel.averageCycleLength, in: 21...35, step: 1)
                                .tint(VitoraTheme.ColorToken.actionPrimary)

                            Text("onboarding.period.cycleLength.unit")
                                .font(.callout.weight(.medium))
                                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        }
                    } else {
                        Text("onboarding.period.cycleLength.unsure")
                            .font(.footnote)
                            .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                    }
                }

                // Flow amount
                VStack(alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
                    Text("onboarding.flowAmount.title")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

                    LazyVGrid(columns: flowColumns, alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
                        ForEach(FlowAmount.allCases, id: \.self) { option in
                            OnboardingChoiceButton(
                                title: LocalizedStringKey(option.titleKey),
                                isSelected: viewModel.flowAmount == option
                            ) {
                                viewModel.chooseFlowAmount(option)
                            }
                            .accessibilityIdentifier(option.accessibilityID)
                        }
                    }
                }

                // Dysmenorrhea
                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: Binding(
                        get: { viewModel.hasDysmenorrhea },
                        set: { _ in viewModel.toggleDysmenorrhea() }
                    )) {
                        Text("onboarding.period.dysmenorrhea")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                    }
                    .toggleStyle(.switch)
                    .tint(VitoraTheme.ColorToken.actionPrimary)

                    if viewModel.hasDysmenorrhea {
                        Toggle(isOn: $viewModel.dysmenorrheaReminderEnabled) {
                            Text("onboarding.period.dysmenorrhea.reminder")
                                .font(.callout.weight(.medium))
                                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        }
                        .toggleStyle(.switch)
                        .tint(VitoraTheme.ColorToken.actionPrimary)
                        .padding(.leading, 8)
                    }
                }
            }
        }
    }

    // MARK: - Permissions

    private var permissionsSection: some View {
        onboardingSection {
            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.md) {
                sectionHeader(icon: "link", title: "onboarding.permissions.title", body: "onboarding.permissions.body")

                // HealthKit
                VStack(alignment: .leading, spacing: 8) {
                    Text("onboarding.healthkit.title")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

                    HStack(spacing: VitoraTheme.Spacing.sm) {
                        Button {
                            viewModel.chooseDataSource(.allow)
                        } label: {
                            Label("onboarding.healthkit.allow", systemImage: "heart.text.square")
                                .font(.callout.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 42)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(VitoraTheme.ColorToken.strongText)
                        .accessibilityIdentifier("onboarding.healthkit.allow")

                        Button {
                            viewModel.chooseDataSource(.skip)
                        } label: {
                            Label("onboarding.healthkit.skip", systemImage: "forward")
                                .font(.callout.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 42)
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("onboarding.healthkit.skip")
                    }

                    Text(healthKitStateText)
                        .font(.footnote)
                        .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                        .accessibilityIdentifier("onboarding.healthkit.state")
                }

                // Notifications
                VStack(alignment: .leading, spacing: 8) {
                    Text("onboarding.notification.title")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

                    HStack(spacing: VitoraTheme.Spacing.sm) {
                        Button {
                            viewModel.requestNotificationPermission()
                        } label: {
                            Label("onboarding.notification.allow", systemImage: "bell.badge")
                                .font(.callout.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 42)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(VitoraTheme.ColorToken.strongText)
                        .accessibilityIdentifier("onboarding.notification.allow")

                        Button {
                            viewModel.skipNotificationPermission()
                        } label: {
                            Label("onboarding.notification.skip", systemImage: "forward")
                                .font(.callout.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 42)
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("onboarding.notification.skip")
                    }

                    Text(notificationStateText)
                        .font(.footnote)
                        .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                        .accessibilityIdentifier("onboarding.notification.state")
                }
            }
        }
    }

    // MARK: - State Text

    private var healthKitStateText: LocalizedStringKey {
        switch viewModel.dataSourceAuthorization.state {
        case .notAsked: "onboarding.healthkit.notAsked"
        case .authorized: "onboarding.healthkit.connected.selected"
        case .skipped, .denied, .revoked: "onboarding.healthkit.lowdata.selected"
        }
    }

    private var notificationStateText: LocalizedStringKey {
        switch viewModel.notificationPermissionState {
        case .notDetermined: "onboarding.notification.notAsked"
        case .authorized: "onboarding.notification.authorized"
        case .denied: "onboarding.notification.denied"
        }
    }

    // MARK: - Helpers

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
}
