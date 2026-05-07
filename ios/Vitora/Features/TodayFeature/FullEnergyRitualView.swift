import SwiftUI

struct FullEnergyRitualView: View {
    let summary: EnergySummary
    let result: EnergyRitualResult?
    let onSkip: () -> Void
    let onReveal: () -> Void
    let onOpenAnalysis: () -> Void
    let onReturn: () -> Void

    private var hasResult: Bool {
        result?.state == .completed
    }

    var body: some View {
        ZStack {
            VitoraTheme.ColorToken.canvas
                .ignoresSafeArea()

            VStack(spacing: VitoraTheme.Spacing.xxl) {
                Spacer()

                TodayStateOrb(
                    summary: hasResult ? summary : EnergySummary(day: summary.day, scoreBand: .unknown, explanationSummary: ""),
                    isLowData: !hasResult
                )
                    .scaleEffect(hasResult ? 1 : 0.82)
                    .animation(.easeInOut(duration: 0.35), value: hasResult)

                VStack(spacing: VitoraTheme.Spacing.sm) {
                    Text(hasResult ? "today.ritual.done.title" : "today.ritual.running.title")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.primaryText)

                    Text(hasResult ? summary.explanationSummary : String(localized: "today.ritual.running.body"))
                        .font(.body)
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, VitoraTheme.Spacing.xl)
                }

                ComplianceLabel(text: "today.compliance.short")

                Spacer()

                if hasResult {
                    HStack(spacing: VitoraTheme.Spacing.sm) {
                        Button(action: onReturn) {
                            Text("today.ritual.return")
                                .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("today.ritual.return")

                        Button(action: onOpenAnalysis) {
                            Text("today.ritual.analysis")
                                .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(VitoraTheme.ColorToken.actionPrimary)
                        .accessibilityIdentifier("today.ritual.analysis")
                    }
                } else {
                    HStack(spacing: VitoraTheme.Spacing.sm) {
                        Button(action: onSkip) {
                            Text("today.ritual.skip")
                                .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("today.ritual.skip")

                        Button(action: onReveal) {
                            Text("today.ritual.reveal")
                                .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(VitoraTheme.ColorToken.actionPrimary)
                        .accessibilityIdentifier("today.ritual.reveal")
                    }
                }
            }
            .padding(VitoraTheme.Spacing.xl)
        }
    }
}
