import SwiftUI

struct OnboardingContextView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    private let focusColumns = [
        GridItem(.adaptive(minimum: 96), spacing: VitoraTheme.Spacing.sm),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.xl) {
            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
                Text("onboarding.context.title")
                    .font(.title.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.primaryText)

                Text("onboarding.context.body")
                    .font(.body)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            focusPicker
            dataSourceChoice

            VitoraTextField(title: "onboarding.context.cycle.placeholder", text: $viewModel.cycleSummary)
                .accessibilityIdentifier("onboarding.context.cycle")

            Button {
                viewModel.goToReady()
            } label: {
                Text("onboarding.context.continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
            }
            .buttonStyle(.borderedProminent)
            .tint(VitoraTheme.ColorToken.actionPrimary)
            .accessibilityIdentifier("onboarding.context.continue")
        }
    }

    private var focusPicker: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
            Text("onboarding.context.focus.title")
                .font(.headline)

            LazyVGrid(columns: focusColumns, alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
                ForEach(FocusArea.allCases, id: \.self) { focusArea in
                    Button {
                        viewModel.toggleFocusArea(focusArea)
                    } label: {
                        VitoraChip(
                            title: focusArea.titleKey,
                            isSelected: viewModel.selectedFocusAreas.contains(focusArea)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("onboarding.focus.\(focusArea.rawValue)")
                }
            }
        }
    }

    private var dataSourceChoice: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
            Text("onboarding.healthkit.title")
                .font(.headline)

            Text("onboarding.healthkit.body")
                .font(.callout)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            VStack(spacing: VitoraTheme.Spacing.sm) {
                Button {
                    viewModel.chooseDataSource(.allow)
                } label: {
                    Label("onboarding.healthkit.allow", systemImage: "heart.text.square")
                        .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
                }
                .buttonStyle(.borderedProminent)
                .tint(VitoraTheme.ColorToken.actionPrimary)
                .accessibilityIdentifier("onboarding.healthkit.allow")

                HStack(spacing: VitoraTheme.Spacing.sm) {
                    Button {
                        viewModel.chooseDataSource(.skip)
                    } label: {
                        Label("onboarding.healthkit.skip", systemImage: "forward")
                            .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("onboarding.healthkit.skip")

                    Button {
                        viewModel.chooseDataSource(.deny)
                    } label: {
                        Label("onboarding.healthkit.deny", systemImage: "xmark.circle")
                            .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("onboarding.healthkit.deny")
                }
            }

            Text(LocalizedStringKey(viewModel.isLowData ? "onboarding.healthkit.lowdata.selected" : "onboarding.healthkit.connected.selected"))
                .font(.footnote)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .accessibilityIdentifier("onboarding.healthkit.state")
        }
    }
}

private extension FocusArea {
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
}
