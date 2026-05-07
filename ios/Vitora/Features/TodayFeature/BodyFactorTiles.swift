import SwiftUI

struct BodyFactorTiles: View {
    let onOpenDetail: () -> Void
    let onAskVitora: (String) -> Void

    private let factors: [(title: String, value: String, note: String, icon: String)] = [
        ("睡眠", "7.2h", "略低", "moon.zzz.fill"),
        ("HRV", "48ms", "↓ 8%", "waveform.path.ecg"),
        ("心率", "72bpm", "稳定", "heart.fill"),
        ("周期", "D18", "黄体期", "circle.hexagongrid.fill"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("身体要素")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                Spacer()

                Button("查看依据", action: onOpenDetail)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("today.bodyFactors.detail")
            }

            HStack(spacing: 8) {
                ForEach(factors, id: \.title) { factor in
                    AskableSurface(
                        accessibilityID: "today.factor.\(factor.title)",
                        onOpenDetail: onOpenDetail,
                        onAskVitora: { onAskVitora(factor.title) },
                        onCorrectVitora: { onAskVitora("\(factor.title) 不准") }
                    ) {
                        VStack(spacing: 5) {
                            Image(systemName: factor.icon)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)

                            Text(factor.title)
                                .font(.caption)
                                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

                            Text(factor.value)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)

                            Text(factor.note)
                                .font(.caption2)
                                .foregroundStyle(factor.note.contains("↓") ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.secondaryText)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 88)
                        .background(GlassSurface(cornerRadius: 18, opacity: 0.34))
                    }
                }
            }
        }
        .accessibilityIdentifier("today.bodyFactors.card")
    }
}

