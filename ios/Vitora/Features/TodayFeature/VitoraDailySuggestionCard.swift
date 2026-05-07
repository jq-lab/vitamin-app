import SwiftUI

struct VitoraDailySuggestionCard: View {
    let onCommit: () -> Void
    let onSwap: () -> Void
    let onOpenDetail: () -> Void
    let onAskVitora: () -> Void

    var body: some View {
        AskableSurface(
            accessibilityID: "today.suggestion.card",
            onOpenDetail: onOpenDetail,
            onAskVitora: onAskVitora,
            onCorrectVitora: onAskVitora
        ) {
            VStack(alignment: .leading, spacing: 13) {
                Text("Vitora 今日建议")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(VitoraTheme.ColorToken.actionPrimarySoft)
                            .frame(width: 48, height: 48)

                        Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                            .font(.title3)
                            .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("13:30 前加一小份蛋白")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)

                        Text("下午轻走 10 分钟")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

                        Text("基于：14:00 低谷窗口 + 睡眠略低")
                            .font(.caption)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }

                    Spacer()
                }

                HStack(spacing: 8) {
                    suggestionButton("我试试", filled: true, action: onCommit)
                        .accessibilityIdentifier("today.suggestion.try")
                    suggestionButton("换一个", filled: false, action: onSwap)
                        .accessibilityIdentifier("today.suggestion.swap")
                    suggestionButton("详情", filled: false, action: onOpenDetail)
                        .accessibilityIdentifier("today.suggestion.detail")
                }
            }
            .padding(18)
            .background(GlassSurface(cornerRadius: 24, opacity: 0.44))
        }
    }

    private func suggestionButton(_ title: String, filled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(filled ? VitoraTheme.ColorToken.paper : VitoraTheme.ColorToken.actionPrimaryDeep)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(filled ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.paper.opacity(0.42))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(VitoraTheme.ColorToken.paper.opacity(0.75), lineWidth: filled ? 0 : 0.7))
        }
        .buttonStyle(.plain)
    }
}

