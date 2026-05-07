import SwiftUI

struct TodayStatusCard: View {
    let onOpenDetail: () -> Void
    let onAskVitora: () -> Void
    let onCalibrate: (String) -> Void

    var body: some View {
        AskableSurface(
            accessibilityID: "today.status.card",
            onOpenDetail: onOpenDetail,
            onAskVitora: onAskVitora,
            onCorrectVitora: { onCalibrate("这里不准") }
        ) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("现在状态")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)

                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("68%")
                                .font(.system(size: 40, weight: .semibold, design: .rounded))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)

                            Text("能量平稳")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        }

                        Text("下午 14:00 附近可能低谷")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }

                    Spacer()

                    PixelVitoraView(state: .thinking, size: 46)
                        .accessibilityIdentifier("today.pixel.vitora.decoration")
                }

                RhythmCurveView()
                    .frame(height: 118)
                    .accessibilityIdentifier("today.rhythm.curve")

                VStack(alignment: .leading, spacing: 9) {
                    Text("Vitora 还不知道今天的变化？")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

                    CalibrationChips(onSelect: onCalibrate)
                }
            }
            .padding(18)
            .background(GlassSurface(cornerRadius: 24, opacity: 0.42))
        }
    }
}

struct RhythmCurveView: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                VitoraTheme.ColorToken.paper.opacity(0.08),
                                VitoraTheme.ColorToken.auraBlue.opacity(0.06),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Path { path in
                    path.move(to: CGPoint(x: 0, y: height * 0.46))
                    path.addCurve(
                        to: CGPoint(x: width * 0.36, y: height * 0.36),
                        control1: CGPoint(x: width * 0.14, y: height * 0.47),
                        control2: CGPoint(x: width * 0.18, y: height * 0.25)
                    )
                    path.addCurve(
                        to: CGPoint(x: width * 0.64, y: height * 0.64),
                        control1: CGPoint(x: width * 0.47, y: height * 0.42),
                        control2: CGPoint(x: width * 0.50, y: height * 0.66)
                    )
                    path.addCurve(
                        to: CGPoint(x: width, y: height * 0.44),
                        control1: CGPoint(x: width * 0.76, y: height * 0.60),
                        control2: CGPoint(x: width * 0.82, y: height * 0.42)
                    )
                }
                .stroke(
                    LinearGradient(
                        colors: [VitoraTheme.ColorToken.auraBlue, VitoraTheme.ColorToken.auraCyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round)
                )

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(VitoraTheme.ColorToken.auraBlue.opacity(0.09))
                    .frame(width: width * 0.26, height: height * 0.62)
                    .offset(x: width * 0.58, y: height * 0.25)

                point(x: width * 0.36, y: height * 0.36, label: "现在")
                point(x: width * 0.64, y: height * 0.64, label: "14:00 低谷窗口", isLow: true)
                point(x: width * 0.94, y: height * 0.44, label: "晚间", isDark: true)

                VStack(alignment: .leading, spacing: 14) {
                    Text("高")
                    Text("中")
                    Text("低")
                }
                .font(.caption2)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .offset(x: 1, y: 14)
            }
        }
    }

    private func point(x: CGFloat, y: CGFloat, label: String, isLow: Bool = false, isDark: Bool = false) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isDark ? VitoraTheme.ColorToken.strongText : VitoraTheme.ColorToken.auraBlue)
                .frame(width: isLow ? 9 : 12, height: isLow ? 9 : 12)
                .overlay(Circle().stroke(VitoraTheme.ColorToken.paper, lineWidth: 2))

            Text(label)
                .font(.caption2.weight(isLow ? .semibold : .regular))
                .foregroundStyle(isLow ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.secondaryText)
        }
        .position(x: x, y: y + 22)
    }
}

