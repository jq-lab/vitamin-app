import SwiftUI

struct BodyFactorTiles: View {
    let onOpenDetail: () -> Void
    let onAskVitora: (String) -> Void

    private let factors: [(title: String, value: String, note: String, icon: String, color: Color)] = [
        ("睡眠", "7.2h", "略低", "moon.fill", VitoraTheme.ColorToken.auraBlue),
        ("HRV", "48ms", "↓ 8%", "heart.circle.fill", VitoraTheme.ColorToken.auraBlue),
        ("心率", "72bpm", "稳定", "heart.fill", VitoraTheme.ColorToken.auraCyan),
        ("周期", "D18", "黄体期", "sparkles", VitoraTheme.ColorToken.auraLavender),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("身体要素")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .frame(width: 1, height: 1)
                .opacity(0.01)

            HStack(spacing: 7) {
                ForEach(factors, id: \.title) { factor in
                    factorTile(factor)
                }
            }
        }
        .accessibilityIdentifier("today.bodyFactors.card")
    }

    private func factorTile(_ factor: (title: String, value: String, note: String, icon: String, color: Color)) -> some View {
        AskableSurface(
            accessibilityID: "today.factor.\(factor.title)",
            onOpenDetail: onOpenDetail,
            onAskVitora: { onAskVitora(factor.title) },
            onCorrectVitora: { onAskVitora("\(factor.title) 不准") }
        ) {
            VStack(alignment: .leading, spacing: 5) {
                Text(factor.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                Image(systemName: factor.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.paper)
                    .frame(width: 26, height: 26)
                    .background(
                        RadialGradient(
                            colors: [factor.color.opacity(0.92), factor.color.opacity(0.62)],
                            center: .topLeading,
                            startRadius: 3,
                            endRadius: 22
                        )
                    )
                    .clipShape(Circle())

                Text(factor.value)
                    .font(.system(size: 21, weight: .regular))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)

                Text(factor.note)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(noteColor(for: factor.note))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .frame(height: 96)
            .background(GlassSurface(cornerRadius: 17, opacity: 0.58, shadowStrength: 0.34, variant: .cleanResting))
        }
    }

    private func noteColor(for note: String) -> Color {
        if note.contains("↓") {
            return Color(red: 232 / 255, green: 61 / 255, blue: 66 / 255)
        }
        if note == "稳定" {
            return VitoraTheme.ColorToken.success
        }
        return VitoraTheme.ColorToken.actionPrimaryDeep
    }
}
