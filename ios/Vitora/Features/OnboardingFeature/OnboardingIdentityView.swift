import SwiftUI
import AuthenticationServices

struct OnboardingAboutYouView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    private let sportColumns = [
        GridItem(.adaptive(minimum: 88), spacing: VitoraTheme.Spacing.xs)
    ]
    private let focusColumns = [
        GridItem(.adaptive(minimum: 100), spacing: VitoraTheme.Spacing.xs)
    ]

    var body: some View {
        OnboardingPageCard(
            pageNumber: 1,
            eyebrow: "onboarding.aboutYou.eyebrow",
            title: "onboarding.aboutYou.title",
            bodyText: "onboarding.aboutYou.body",
            ipState: .questioning,
            ipSize: 124
        ) {
            VStack(alignment: .leading, spacing: 20) {
                signInSection
                nameSection
                sportSection
                focusSection

                OnboardingContinueButton(
                    title: "onboarding.aboutYou.continue",
                    disabled: !viewModel.canContinueAboutYou
                ) {
                    viewModel.goToYourBody()
                }
                .accessibilityIdentifier("onboarding.aboutYou.continue")

                if !viewModel.canContinueAboutYou {
                    Text("onboarding.identity.required")
                        .font(.footnote)
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .accessibilityIdentifier("onboarding.identity.required")
                }
            }
        }
    }

    // MARK: - Sign In

    private var signInSection: some View {
        onboardingSection {
            VStack(spacing: 12) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName]
                } onCompletion: { result in
                    handleAppleSignIn(result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(12)
                .accessibilityIdentifier("onboarding.appleSignIn")

                Button {
                    viewModel.skipSignIn()
                } label: {
                    Text("onboarding.signIn.skip")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }
                .accessibilityIdentifier("onboarding.signIn.skip")

                if case .apple = viewModel.authMethod {
                    Label("onboarding.signIn.connected", systemImage: "checkmark.circle.fill")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.success)
                }
            }
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        guard case .success(let auth) = result,
              let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
        viewModel.appleSignInCompleted(
            userIdentifier: credential.user,
            fullName: credential.fullName
        )
    }

    // MARK: - Name

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
            VitoraTextField(title: "onboarding.identity.placeholder", text: $viewModel.displayLabel)
                .textInputAutocapitalization(.never)
                .accessibilityIdentifier("onboarding.identity.name")

            HStack(alignment: .top, spacing: VitoraTheme.Spacing.sm) {
                Image(systemName: "leaf")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                ComplianceLabel(text: "onboarding.identity.privacy")
            }
        }
    }

    // MARK: - Sport

    private var sportSection: some View {
        onboardingSection {
            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.md) {
                sectionHeader(icon: "figure.run", title: "onboarding.sport.title", body: "onboarding.sport.body")

                LazyVGrid(columns: sportColumns, alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
                    ForEach(SportPreference.allCases, id: \.self) { sport in
                        OnboardingChoiceButton(
                            title: LocalizedStringKey(sport.titleKey),
                            isSelected: viewModel.selectedSports.contains(sport)
                        ) {
                            viewModel.toggleSport(sport)
                        }
                        .accessibilityIdentifier(sport.accessibilityID)
                    }
                }
            }
        }
    }

    // MARK: - Focus

    private var focusSection: some View {
        onboardingSection {
            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.md) {
                sectionHeader(icon: "scope", title: "onboarding.context.focus.title", body: "onboarding.context.focus.body")

                LazyVGrid(columns: focusColumns, alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
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
