import SwiftUI

struct OnboardingIdentityView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingPageCard(
            pageNumber: 1,
            eyebrow: "onboarding.identity.eyebrow",
            title: "onboarding.identity.title",
            bodyText: "onboarding.identity.body",
            ipState: .questioning,
            ipSize: 124
        ) {
            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.md) {
                VitoraTextField(title: "onboarding.identity.placeholder", text: $viewModel.displayLabel)
                    .textInputAutocapitalization(.never)
                    .accessibilityIdentifier("onboarding.identity.name")

                HStack(alignment: .top, spacing: VitoraTheme.Spacing.sm) {
                    Image(systemName: "leaf")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)

                    ComplianceLabel(text: "onboarding.identity.privacy")
                }

                if !viewModel.canContinueIdentity {
                    Text("onboarding.identity.required")
                        .font(.footnote)
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("onboarding.identity.required")
                }

                OnboardingContinueButton(
                    title: "onboarding.identity.continue",
                    disabled: !viewModel.canContinueIdentity
                ) {
                    viewModel.goToContext()
                }
                .accessibilityIdentifier("onboarding.identity.continue")
            }
        }
    }
}
