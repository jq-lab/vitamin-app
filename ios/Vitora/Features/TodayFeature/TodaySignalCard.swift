import SwiftUI

struct TodayMonitorCard: View {
    let summary: EnergySummary
    let signals: [TodayViewModel.SignalDisplay]
    let isLowData: Bool
    let onOpenAnalysis: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Vitora 监测今日")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                if isLowData {
                    Text("today.lowdata.badge")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                        .padding(.horizontal, VitoraTheme.Spacing.xs)
                        .padding(.vertical, 4)
                        .background(VitoraTheme.ColorToken.actionPrimary.opacity(0.10))
                        .clipShape(Capsule())
                        .accessibilityIdentifier("today.lowdata.badge")
                }

                Spacer()

                Text("现在")
                    .font(.caption)
                    .foregroundStyle(VitoraTheme.ColorToken.mutedText)

                Text(summary.displayScore)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
            }

            TodayEventRow(isLowData: isLowData, onOpenAnalysis: onOpenAnalysis)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4),
                spacing: 8
            ) {
                ForEach(signals.prefix(4)) { signal in
                    TodayMetricTile(signal: signal)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 21, style: .continuous)
                .fill(VitoraTheme.ColorToken.cardGlass)
                .overlay(
                    RoundedRectangle(cornerRadius: 21, style: .continuous)
                        .stroke(VitoraTheme.ColorToken.paper.opacity(0.90), lineWidth: 0.6)
                )
                .shadow(color: VitoraTheme.ColorToken.actionPrimary.opacity(0.08), radius: 16, x: -2, y: 6)
        )
        .accessibilityIdentifier("today.monitor.card")
    }
}

private struct TodayEventRow: View {
    let isLowData: Bool
    let onOpenAnalysis: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: VitoraTheme.Radius.lg, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 248 / 255, green: 248 / 255, blue: 249 / 255),
                            VitoraTheme.ColorToken.actionPrimary.opacity(0.07),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            EnergyCurve()
                .stroke(VitoraTheme.ColorToken.actionPrimaryDeep, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [6, 5]))
                .frame(width: 112, height: 48)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 20)
                .padding(.top, 12)
                .opacity(0.82)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: VitoraTheme.Spacing.sm) {
                    ZStack(alignment: .topTrailing) {
                        Circle()
                            .fill(VitoraTheme.ColorToken.actionPrimaryDeep)
                            .frame(width: 38, height: 38)

                        Circle()
                            .fill(VitoraTheme.ColorToken.attention)
                            .frame(width: 9, height: 9)
                            .overlay(Circle().stroke(VitoraTheme.ColorToken.paper, lineWidth: 2))
                            .offset(x: 2, y: -2)

                        Image(systemName: "clock")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(VitoraTheme.ColorToken.paper)
                    }

                    Text(isLowData ? "--:--" : "14:00")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(isLowData ? "先补充信息" : "低谷提醒")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
                .frame(width: 240, alignment: .leading)
                .zIndex(1)

                Button(action: onOpenAnalysis) {
                    HStack(spacing: VitoraTheme.Spacing.xs) {
                        Text(isLowData ? "先记录一件事" : "低谷预计 · 建议轻任务")
                            .font(.system(size: 13))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }
                    .frame(minHeight: VitoraTheme.Size.touchTargetMin, alignment: .leading)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("today.openAnalysis.event")
            }
            .padding(.horizontal, VitoraTheme.Spacing.md)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)

            if !isLowData {
                VStack(alignment: .center, spacing: 4) {
                    Text("15")
                        .font(.caption2)
                        .foregroundStyle(VitoraTheme.ColorToken.mutedText)

                    Circle()
                        .fill(VitoraTheme.ColorToken.actionPrimaryDeep)
                        .frame(width: 9, height: 9)

                    Text("18")
                        .font(.caption2)
                        .foregroundStyle(VitoraTheme.ColorToken.mutedText)

                    Circle()
                        .fill(VitoraTheme.ColorToken.attention)
                        .frame(width: 16, height: 16)
                        .overlay(Circle().stroke(VitoraTheme.ColorToken.paper, lineWidth: 2))

                    Text("预计低谷")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.attention)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 0)
                .padding(.top, 2)
            }
        }
        .frame(height: 94)
    }
}

private struct EnergyCurve: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 4, y: rect.minY + 12))
        path.addCurve(
            to: CGPoint(x: rect.maxX - 10, y: rect.maxY - 6),
            control1: CGPoint(x: rect.minX + 42, y: rect.minY + 4),
            control2: CGPoint(x: rect.minX + 56, y: rect.maxY - 2)
        )
        return path
    }
}

private struct TodayMetricTile: View {
    let signal: TodayViewModel.SignalDisplay

    var body: some View {
        VStack(spacing: 5) {
            Text(signal.title)
                .font(.caption)
                .foregroundStyle(VitoraTheme.ColorToken.mutedText)
                .lineLimit(1)
                .minimumScaleFactor(0.80)

            Text(signal.value)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.70)

            Text(signal.note)
                .font(.system(size: 9))
                .foregroundStyle(noteColor)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .frame(maxWidth: .infinity, minHeight: 68)
        .background(VitoraTheme.ColorToken.paper.opacity(0.56))
        .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: VitoraTheme.Radius.md, style: .continuous)
                .stroke(Color(red: 229 / 255, green: 229 / 255, blue: 235 / 255), lineWidth: 0.8)
        )
    }

    private var noteColor: Color {
        if signal.note.contains("↓") {
            return VitoraTheme.ColorToken.attention
        }
        if signal.note.contains("+") {
            return VitoraTheme.ColorToken.success
        }
        return VitoraTheme.ColorToken.mutedText
    }
}

struct TodaySignalCard: View {
    let signal: TodayViewModel.SignalDisplay

    var body: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.xs) {
            Text(signal.title)
                .font(.caption)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            Text(signal.value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.primaryText)

            Text(signal.note)
                .font(.caption2)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .padding(VitoraTheme.Spacing.sm)
        .background(VitoraTheme.ColorToken.softSurface)
        .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.md, style: .continuous))
    }
}
