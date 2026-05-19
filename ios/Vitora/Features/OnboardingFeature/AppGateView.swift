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
            ZStack {
                onboardingBackground

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.lg) {
                            Color.clear
                                .frame(height: 0)
                                .id("onboarding.scroll.top")

                            stepProgress

                            pageContent
                                .id(viewModel.step)
                                .transition(
                                    .asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)
                                    )
                                )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, VitoraTheme.Spacing.sm)
                        .padding(.bottom, 40)
                    }
                    .onChange(of: viewModel.step) { _, _ in
                        proxy.scrollTo("onboarding.scroll.top", anchor: .top)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.42), value: viewModel.step)
            .navigationTitle(Text("vitora.app.title"))
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier("onboarding.appgate")
        }
    }

    @ViewBuilder
    private var pageContent: some View {
        switch viewModel.step {
        case .aboutYou:
            OnboardingAboutYouView(viewModel: viewModel)
        case .yourBody:
            OnboardingYourBodyView(viewModel: viewModel) { completion in
                environment.finishOnboarding(completion)
            }
        }
    }

    private var onboardingBackground: some View {
        OnboardingAuraBackground()
    }

    private var stepProgress: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(stepLabel)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)

                Spacer()

                Text(progressText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(VitoraTheme.ColorToken.surfacePearlInset.opacity(0.72))

                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [
                                    VitoraTheme.ColorToken.actionPrimaryDeep,
                                    VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.72),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * progressValue)
                        .animation(.easeInOut(duration: 0.4), value: progressValue)
                }
            }
            .frame(height: 5)
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .accessibilityIdentifier("onboarding.progress")
        }
    }

    private var stepLabel: String {
        switch viewModel.step {
        case .aboutYou: return "STEP 1"
        case .yourBody: return "STEP 2"
        }
    }

    private var progressText: String {
        switch viewModel.step {
        case .aboutYou: "1 / 2"
        case .yourBody: "2 / 2"
        }
    }

    private var progressValue: Double {
        switch viewModel.step {
        case .aboutYou: 0.5
        case .yourBody: 1.0
        }
    }
}

// MARK: - Onboarding Background

private struct OnboardingAuraBackground: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    // Palette
    private let milkyWhite = Color(red: 252 / 255, green: 250 / 255, blue: 247 / 255)
    private let pinkOrangeCore = Color(red: 255 / 255, green: 186 / 255, blue: 165 / 255)
    private let pinkOrangeSoft = Color(red: 255 / 255, green: 218 / 255, blue: 200 / 255)
    private let tealCore = Color(red: 130 / 255, green: 210 / 255, blue: 215 / 255)
    private let tealSoft = Color(red: 185 / 255, green: 232 / 255, blue: 234 / 255)

    var body: some View {
        ZStack {
            // 1 ── Milky white base
            milkyWhite

            // 2 ── Top-left pink-orange radial
            RadialGradient(
                colors: [
                    pinkOrangeCore.opacity(0.52),
                    pinkOrangeSoft.opacity(0.36),
                    Color(red: 255 / 255, green: 235 / 255, blue: 222 / 255).opacity(0.18),
                    .clear,
                ],
                center: UnitPoint(x: 0.08, y: 0.0),
                startRadius: 10,
                endRadius: 420
            )

            // 3 ── Bottom-right teal radial
            RadialGradient(
                colors: [
                    tealCore.opacity(0.44),
                    tealSoft.opacity(0.30),
                    Color(red: 210 / 255, green: 240 / 255, blue: 238 / 255).opacity(0.16),
                    .clear,
                ],
                center: UnitPoint(x: 0.92, y: 1.0),
                startRadius: 10,
                endRadius: 440
            )

            // 4 ── Soft cross-blend to keep center milky
            RadialGradient(
                colors: [
                    milkyWhite.opacity(0.72),
                    milkyWhite.opacity(0.38),
                    .clear,
                ],
                center: UnitPoint(x: 0.48, y: 0.42),
                startRadius: 20,
                endRadius: 320
            )

            // 5 ── Subtle warm bloom at top-left edge
            RadialGradient(
                colors: [
                    Color(red: 255 / 255, green: 200 / 255, blue: 178 / 255).opacity(0.20),
                    .clear,
                ],
                center: UnitPoint(x: 0.0, y: 0.08),
                startRadius: 1,
                endRadius: 220
            )

            // 6 ── Subtle teal bloom at bottom-right edge
            RadialGradient(
                colors: [
                    Color(red: 152 / 255, green: 224 / 255, blue: 226 / 255).opacity(0.18),
                    .clear,
                ],
                center: UnitPoint(x: 1.0, y: 0.92),
                startRadius: 1,
                endRadius: 240
            )

            // 7 ── Frosted glass layer: transparent at top → opaque at bottom
            Rectangle()
                .fill(.ultraThinMaterial)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .clear, location: 0.30),
                            .init(color: .black.opacity(0.12), location: 0.50),
                            .init(color: .black.opacity(0.46), location: 0.72),
                            .init(color: .black.opacity(0.82), location: 0.88),
                            .init(color: .black, location: 1.0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // 8 ── Accessibility: extra opacity when reduce-transparency is on
            if reduceTransparency {
                milkyWhite.opacity(0.42)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityIdentifier("onboarding.aura.background")
    }
}
