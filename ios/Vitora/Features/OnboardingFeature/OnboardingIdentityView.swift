import SwiftUI

struct OnboardingIdentityView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
                Text("onboarding.identity.title")
                    .font(.title.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.primaryText)

                Text("onboarding.identity.body")
                    .font(.body)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            VitoraTextField(title: "onboarding.identity.placeholder", text: $viewModel.displayLabel)
                .textInputAutocapitalization(.never)
                .accessibilityIdentifier("onboarding.identity.name")

            ComplianceLabel(text: "onboarding.identity.privacy")

            Button {
                viewModel.goToContext()
            } label: {
                Text("onboarding.identity.continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
            }
            .buttonStyle(.borderedProminent)
            .tint(VitoraTheme.ColorToken.actionPrimary)
            .disabled(!viewModel.canContinueIdentity)
            .accessibilityIdentifier("onboarding.identity.continue")
        }
    }
}
