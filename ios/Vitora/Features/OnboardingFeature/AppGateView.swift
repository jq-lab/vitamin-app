import SwiftUI

struct AppGateView: View {
    @ObservedObject var environment: AppEnvironment
    @StateObject private var viewModel: OnboardingViewModel

    init(environment: AppEnvironment, viewModel: OnboardingViewModel = OnboardingViewModel()) {
        self.environment = environment
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: VitoraTheme.Spacing.xl) {
                    stepProgress

                    switch viewModel.step {
                    case .identity:
                        OnboardingIdentityView(viewModel: viewModel)
                    case .context:
                        OnboardingContextView(viewModel: viewModel)
                    case .ready:
                        OnboardingReadyView(viewModel: viewModel) { completion in
                            environment.finishOnboarding(completion)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(VitoraTheme.Spacing.xl)
            }
            .background(VitoraTheme.ColorToken.canvas)
            .navigationTitle(Text("vitora.app.title"))
            .accessibilityIdentifier("onboarding.appgate")
        }
    }

    private var stepProgress: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
            Text("onboarding.progress.title")
                .font(.footnote.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            VitoraProgressBar(progress: progressValue)
                .accessibilityIdentifier("onboarding.progress")
        }
    }

    private var progressValue: Double {
        switch viewModel.step {
        case .identity:
            0.33
        case .context:
            0.66
        case .ready:
            1.0
        }
    }
}
