import SwiftUI

struct CurrentPhaseRelationCard: View {
    let onOpenDetail: () -> Void
    let onAskVitora: () -> Void

    var body: some View {
        AskableSurface(
            accessibilityID: "cycle.phase.card",
            onOpenDetail: onOpenDetail,
            onAskVitora: onAskVitora,
            onCorrectVitora: onAskVitora
        ) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("当前周期阶段与今天")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("Day 18")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)

                        Text("· 黄体期中段")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.lutealGold)
                    }
                }

                PhaseAxisView()
                    .frame(height: 62)

                HStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading, spacing: 7) {
                        phaseInfoRow(icon: "sparkles", text: "Vitora 今日建议已考虑这个阶段")
                        phaseInfoRow(icon: "heart.text.square", text: "今天更适合稳定能量补给")
                    }

                    Spacer(minLength: 8)

                    HStack(spacing: 1) {
                        PixelVitoraScene(
                            state: .idle,
                            size: 27,
                            accessory: .none,
                            showsSparkles: false,
                            showsBaseShadow: true
                        )
                        .frame(width: 40, height: 34)
                        .allowsHitTesting(false)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.70))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(GlassSurface(cornerRadius: 24, opacity: 0.58, shadowStrength: 0.70, variant: .cleanElevated))
        }
    }

    private func phaseInfoRow(icon: String, text: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .frame(width: 17, height: 17)
                .background(VitoraTheme.ColorToken.actionPrimary.opacity(0.16), in: Circle())

            Text(text)
                .font(.caption.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.86)
        }
    }
}

struct PhaseAxisView: View {
    private let phases = ["月经", "卵泡", "排卵", "黄体"]

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let lineY = proxy.size.height * 0.38

            ZStack(alignment: .topLeading) {
                Path { path in
                    path.move(to: CGPoint(x: 18, y: lineY))
                    path.addCurve(
                        to: CGPoint(x: width - 18, y: lineY + 6),
                        control1: CGPoint(x: width * 0.30, y: lineY - 18),
                        control2: CGPoint(x: width * 0.68, y: lineY + 18)
                    )
                }
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 245 / 255, green: 143 / 255, blue: 176 / 255),
                            VitoraTheme.ColorToken.auraBlue,
                            VitoraTheme.ColorToken.success,
                            VitoraTheme.ColorToken.lutealGold,
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 1.45, lineCap: .round, dash: [4, 5])
                )

                ForEach(Array(phases.enumerated()), id: \.offset) { index, phase in
                    VStack(spacing: 5) {
                        Circle()
                            .fill(index == 3 ? VitoraTheme.ColorToken.lutealGold : VitoraTheme.ColorToken.paper)
                            .frame(width: index == 3 ? 15 : 10, height: index == 3 ? 15 : 10)
                            .overlay(Circle().stroke(phaseColor(index), lineWidth: index == 3 ? 2 : 1.6))
                            .shadow(color: phaseColor(index).opacity(index == 3 ? 0.30 : 0.10), radius: index == 3 ? 6 : 3, x: 0, y: 2)
                        Text(phase)
                            .font(.system(size: 10, weight: index == 3 ? .semibold : .regular))
                            .foregroundStyle(index == 3 ? VitoraTheme.ColorToken.lutealGold : VitoraTheme.ColorToken.secondaryText)
                    }
                    .position(x: xPosition(index: index, width: width), y: lineY + 22)
                }

                HStack(spacing: 3) {
                    Circle()
                        .fill(VitoraTheme.ColorToken.lutealGold)
                        .frame(width: 5, height: 5)
                    Text("今天")
                        .font(.system(size: 9, weight: .semibold))
                }
                .foregroundStyle(VitoraTheme.ColorToken.lutealGold)
                .position(x: width * 0.86, y: 10)
            }
        }
        .accessibilityIdentifier("cycle.phase.axis")
        .allowsHitTesting(false)
    }

    private func phaseColor(_ index: Int) -> Color {
        switch index {
        case 0:
            return Color(red: 245 / 255, green: 143 / 255, blue: 176 / 255)
        case 1:
            return VitoraTheme.ColorToken.auraBlue
        case 2:
            return VitoraTheme.ColorToken.success
        default:
            return VitoraTheme.ColorToken.lutealGold
        }
    }

    private func xPosition(index: Int, width: CGFloat) -> CGFloat {
        let positions: [CGFloat] = [0.10, 0.38, 0.63, 0.86]
        return width * positions[index]
    }
}
