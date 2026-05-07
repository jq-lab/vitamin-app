import SwiftUI

struct EnergyRevealHeader: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let isExpanded: Bool
    let onOpenDetail: () -> Void
    let onAskVitora: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Capsule()
                .fill(VitoraTheme.ColorToken.auraBlue.opacity(0.28))
                .frame(width: 48, height: 4)

            if isExpanded {
                VStack(spacing: 8) {
                    PixelVitoraView(state: .idle, size: 74)

                    Text("68%")
                        .font(.system(size: 46, weight: .semibold, design: .rounded))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)

                    Text("能量平稳")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)

                    Text("睡眠略低 · HRV↓ · 黄体期 D18")
                        .font(.footnote)
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

                    HStack(spacing: 10) {
                        Button("查看依据", action: onOpenDetail)
                        Button("告诉 Vitora", action: onAskVitora)
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(GlassSurface(cornerRadius: 26, opacity: 0.38))
                .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                Text("轻轻下拉，可以随时查看今日能量球")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }
        }
        .animation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.84), value: isExpanded)
        .accessibilityIdentifier(isExpanded ? "today.energy.reveal.header" : "today.energy.reveal.handle")
    }
}
