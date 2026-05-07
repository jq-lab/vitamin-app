import SwiftUI

struct AskableSurface<Content: View>: View {
    let accessibilityID: String
    let onOpenDetail: () -> Void
    let onAskVitora: () -> Void
    let onCorrectVitora: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        Button(action: onOpenDetail) {
            content
                .contentShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.card, style: .continuous))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("问 Vitora 为什么", action: onAskVitora)
            Button("告诉 Vitora 这里不准", action: onCorrectVitora)
            Button("查看详情", action: onOpenDetail)
        }
        .accessibilityHint("点按查看详情，长按可以问 Vitora 或校准这个判断")
        .accessibilityIdentifier(accessibilityID)
    }
}

struct AskableTipHint: View {
    var text = "按住这里，可以让 Vitora 解释或校准"

    var body: some View {
        Text(text)
            .font(.caption2.weight(.medium))
            .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(VitoraTheme.ColorToken.paper.opacity(0.72), lineWidth: 0.6))
            .accessibilityIdentifier("askable.tip.hint")
    }
}

struct ChartCallout: View {
    let title: String
    let subtitle: String
    let onAskVitora: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            Button("问 Vitora ›", action: onAskVitora)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.white.opacity(0.75), lineWidth: 0.7))
        .accessibilityIdentifier("chart.callout")
    }
}
