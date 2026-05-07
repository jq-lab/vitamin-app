import SwiftUI

struct OnboardingReadyView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    var onFinish: (OnboardingCompletion) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
                Text("onboarding.ready.title")
                    .font(.title.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.primaryText)

                Text(LocalizedStringKey(viewModel.isLowData ? "onboarding.ready.lowdata" : "onboarding.ready.connected"))
                    .font(.body)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
                Label("onboarding.ready.item.today", systemImage: "sun.max")
                Label("onboarding.ready.item.luna", systemImage: "sparkles")
                Label("onboarding.ready.item.cycle", systemImage: "calendar")
            }
            .font(.callout)
            .foregroundStyle(VitoraTheme.ColorToken.primaryText)

            Button {
                onFinish(viewModel.finish())
            } label: {
                Text("onboarding.ready.enterToday")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
            }
            .buttonStyle(.borderedProminent)
            .tint(VitoraTheme.ColorToken.actionPrimary)
            .accessibilityIdentifier("onboarding.ready.enterToday")
        }
    }
}
