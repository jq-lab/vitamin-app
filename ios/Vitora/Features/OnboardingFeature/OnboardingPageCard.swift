import SwiftUI

struct OnboardingPageCard<Content: View>: View {
    let pageNumber: Int
    let eyebrow: LocalizedStringKey
    let title: LocalizedStringKey
    let bodyText: LocalizedStringKey
    var ipState: PixelVitoraState = .idle
    var ipSize: CGFloat = 116
    let content: Content

    init(
        pageNumber: Int,
        eyebrow: LocalizedStringKey,
        title: LocalizedStringKey,
        bodyText: LocalizedStringKey,
        ipState: PixelVitoraState = .idle,
        ipSize: CGFloat = 116,
        @ViewBuilder content: () -> Content
    ) {
        self.pageNumber = pageNumber
        self.eyebrow = eyebrow
        self.title = title
        self.bodyText = bodyText
        self.ipState = ipState
        self.ipSize = ipSize
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.lg) {
            heroStrip

            VStack(alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
                Text(eyebrow)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Text(title)
                    .font(pageNumber == 2 ? .title2.weight(.bold) : .title.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .fixedSize(horizontal: false, vertical: true)

                Text(bodyText)
                    .font(.subheadline)
                    .lineSpacing(4)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            content
        }
        .accessibilityIdentifier("onboarding.page.\(pageNumber)")
    }

    private var heroStrip: some View {
        HStack {
            Spacer()
            PixelVitoraScene(
                state: ipState,
                size: compactIPSize,
                accessory: .none,
                showsSparkles: true,
                showsBaseShadow: false,
                materialStyle: .heroCompanion
            )
            .accessibilityIdentifier("onboarding.pixelVitora")
            Spacer()
        }
        .frame(height: compactIPSize + 24)
    }

    private var compactIPSize: CGFloat {
        pageNumber == 2 ? min(ipSize, 80) : min(ipSize, 96)
    }
}

struct OnboardingChoiceButton: View {
    let title: LocalizedStringKey
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(isSelected ? VitoraTheme.ColorToken.strongText : VitoraTheme.ColorToken.secondaryText)
                .frame(maxWidth: .infinity, minHeight: 42)
                .padding(.horizontal, VitoraTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: VitoraTheme.Radius.pill, style: .continuous)
                        .fill(isSelected ? VitoraTheme.ColorToken.surfacePearlMain.opacity(0.92) : VitoraTheme.ColorToken.surfacePearlInset.opacity(0.68))
                        .shadow(color: isSelected ? VitoraTheme.ColorToken.paperLiftShadow.opacity(0.12) : .clear, radius: 12, x: 0, y: 6)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: VitoraTheme.Radius.pill, style: .continuous)
                        .stroke(Color.white.opacity(isSelected ? 0.88 : 0.48), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

struct OnboardingContinueButton: View {
    let title: LocalizedStringKey
    var disabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: disabled
                                    ? [Color.gray.opacity(0.3), Color.gray.opacity(0.2)]
                                    : [VitoraTheme.ColorToken.strongText, VitoraTheme.ColorToken.strongText.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: disabled ? .clear : VitoraTheme.ColorToken.strongText.opacity(0.22), radius: 16, x: 0, y: 8)
                )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1)
    }
}
