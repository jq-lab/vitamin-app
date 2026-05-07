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
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("当前周期阶段与今天")
                            .font(.headline.weight(.bold))
                        Text("Day 18 · 黄体期中段")
                            .font(.title2.weight(.semibold))
                    }
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                    Spacer()

                    PixelVitoraView(state: .thinking, size: 50)
                }

                PhaseAxisView()
                    .frame(height: 76)

                Text("Vitora 今日建议已考虑这个阶段")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)

                Text("今天更适合稳定能量补给。")
                    .font(.footnote)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }
            .padding(18)
            .background(GlassSurface(cornerRadius: 24, opacity: 0.42))
        }
    }
}

struct PhaseAxisView: View {
    private let phases = ["月经", "卵泡", "排卵", "黄体"]

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let lineY = proxy.size.height * 0.42

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
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 5])
                )

                ForEach(Array(phases.enumerated()), id: \.offset) { index, phase in
                    VStack(spacing: 5) {
                        Circle()
                            .fill(index == 3 ? VitoraTheme.ColorToken.lutealGold : VitoraTheme.ColorToken.paper)
                            .frame(width: index == 3 ? 18 : 12, height: index == 3 ? 18 : 12)
                            .overlay(Circle().stroke(phaseColor(index), lineWidth: 2))
                        Text(phase)
                            .font(.caption2.weight(index == 3 ? .semibold : .regular))
                            .foregroundStyle(index == 3 ? VitoraTheme.ColorToken.lutealGold : VitoraTheme.ColorToken.secondaryText)
                    }
                    .position(x: xPosition(index: index, width: width), y: lineY + 26)
                }

                Text("● 今天")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.lutealGold)
                    .position(x: width * 0.85, y: 12)
            }
        }
        .accessibilityIdentifier("cycle.phase.axis")
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

