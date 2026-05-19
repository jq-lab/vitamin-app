import SwiftUI

struct EnergyDynamicsCard: View {
    let onOpenDetail: () -> Void
    let onAskVitora: () -> Void
    @State private var selectedGranularity = "周"
    @State private var showsCallout = true

    private let granularities = ["日", "周", "月"]

    var body: some View {
        AskableSurface(
            accessibilityID: "cycle.energy.card",
            onOpenDetail: onOpenDetail,
            onAskVitora: onAskVitora,
            onCorrectVitora: onAskVitora
        ) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("能量动态")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Spacer()
                    granularityPicker
                }

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("本周平均")
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    Text("62%")
                        .font(.callout.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    Text("· 较上周")
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    Text("↑5%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.success)
                }
                .font(.caption.weight(.medium))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("本周平均 62% · 较上周 ↑5%")

                EnergySparklineView(showsCallout: $showsCallout, onAskVitora: onAskVitora)
                    .frame(height: 126)

                HStack(spacing: 8) {
                    PixelVitoraScene(
                        state: .idle,
                        size: 20,
                        accessory: .none,
                        showsSparkles: false,
                        showsBaseShadow: true
                    )
                    .frame(width: 28, height: 24)
                    .allowsHitTesting(false)

                    Text("Vitora 看到：周三后恢复变慢")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.88)

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.70))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(GlassSurface(cornerRadius: 24, opacity: 0.58, shadowStrength: 0.70, variant: .cleanElevated))
        }
    }

    private var granularityPicker: some View {
        HStack(spacing: 3) {
            ForEach(granularities, id: \.self) { value in
                Button {
                    selectedGranularity = value
                } label: {
                    Text(value)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(selectedGranularity == value ? VitoraTheme.ColorToken.paper : VitoraTheme.ColorToken.actionPrimaryDeep)
                        .frame(width: 30, height: 24)
                        .background(selectedGranularity == value ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.paper.opacity(0.28))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(GlassSurface(cornerRadius: 15, opacity: 0.48, shadowStrength: 0.16, variant: .cleanResting))
        .accessibilityIdentifier("cycle.energy.granularity")
    }
}

struct EnergySparklineView: View {
    @Binding var showsCallout: Bool
    let onAskVitora: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let leftInset: CGFloat = 24
            let rightInset: CGFloat = 12
            let topInset: CGFloat = 10
            let bottomInset: CGFloat = 24
            let plotWidth = max(1, proxy.size.width - leftInset - rightInset)
            let plotHeight = max(1, proxy.size.height - topInset - bottomInset)
            let points = [
                CGPoint(x: leftInset + plotWidth * 0.02, y: topInset + plotHeight * 0.68),
                CGPoint(x: leftInset + plotWidth * 0.20, y: topInset + plotHeight * 0.42),
                CGPoint(x: leftInset + plotWidth * 0.34, y: topInset + plotHeight * 0.30),
                CGPoint(x: leftInset + plotWidth * 0.50, y: topInset + plotHeight * 0.48),
                CGPoint(x: leftInset + plotWidth * 0.66, y: topInset + plotHeight * 0.58),
                CGPoint(x: leftInset + plotWidth * 0.82, y: topInset + plotHeight * 0.56),
                CGPoint(x: leftInset + plotWidth * 0.96, y: topInset + plotHeight * 0.34),
            ]
            let selectedPoint = points[6]

            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(["高", "中", "低"], id: \.self) { label in
                        Text(label)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.74))
                            .frame(width: 16, alignment: .leading)
                            .frame(height: plotHeight / 2)
                    }
                }
                .offset(x: 0, y: topInset - 4)

                VStack(spacing: plotHeight / 3) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(VitoraTheme.ColorToken.secondaryText.opacity(0.08))
                            .frame(height: 1)
                    }
                }
                .frame(width: plotWidth, height: plotHeight)
                .offset(x: leftInset, y: topInset)

                smoothAreaPath(points: points, baseline: proxy.size.height - bottomInset)
                    .fill(
                        LinearGradient(
                            colors: [
                                VitoraTheme.ColorToken.auraBlue.opacity(0.14),
                                VitoraTheme.ColorToken.auraCyan.opacity(0.03),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                smoothLinePath(points: points)
                .stroke(
                    LinearGradient(
                        colors: [VitoraTheme.ColorToken.auraBlue, VitoraTheme.ColorToken.auraCyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                )
                .shadow(color: VitoraTheme.ColorToken.auraBlue.opacity(0.22), radius: 5, x: 0, y: 4)

                if showsCallout {
                    Path { path in
                        path.move(to: CGPoint(x: selectedPoint.x, y: selectedPoint.y + 9))
                        path.addLine(to: CGPoint(x: selectedPoint.x, y: proxy.size.height - bottomInset + 2))
                    }
                    .stroke(
                        VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.24),
                        style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [3, 4])
                    )

                    EnergyTodayCallout()
                        .position(
                            x: min(proxy.size.width - 30, max(30, selectedPoint.x - 8)),
                            y: max(24, selectedPoint.y - 34)
                        )
                        .accessibilityIdentifier("chart.callout")
                }

                Button {
                    withAnimation(.easeOut(duration: 0.18)) {
                        showsCallout.toggle()
                    }
                } label: {
                    Circle()
                        .fill(VitoraTheme.ColorToken.actionPrimaryDeep)
                        .frame(width: 15, height: 15)
                        .overlay(Circle().stroke(VitoraTheme.ColorToken.paper, lineWidth: 2.2))
                        .shadow(color: VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.42), radius: 8, x: 0, y: 3)
                        .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .position(selectedPoint)
                .accessibilityIdentifier("cycle.energy.point.today")

                HStack {
                    ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { day in
                        Text(day)
                            .font(.caption2)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: plotWidth)
                .position(x: leftInset + plotWidth / 2, y: proxy.size.height - 8)
            }
        }
        .accessibilityIdentifier("cycle.energy.chart")
    }

    private func smoothLinePath(points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else {
            return path
        }

        path.move(to: first)
        for index in 1..<points.count {
            let previous = points[index - 1]
            let current = points[index]
            let midpoint = CGPoint(x: (previous.x + current.x) / 2, y: (previous.y + current.y) / 2)
            path.addQuadCurve(to: midpoint, control: previous)
            if index == points.count - 1 {
                path.addQuadCurve(to: current, control: current)
            }
        }
        return path
    }

    private func smoothAreaPath(points: [CGPoint], baseline: CGFloat) -> Path {
        var path = smoothLinePath(points: points)
        guard let first = points.first, let last = points.last else {
            return path
        }

        path.addLine(to: CGPoint(x: last.x, y: baseline))
        path.addLine(to: CGPoint(x: first.x, y: baseline))
        path.closeSubpath()
        return path
    }
}

private struct EnergyTodayCallout: View {
    var body: some View {
        VStack(spacing: 1) {
            Text("今天")
                .font(.system(size: 8, weight: .semibold))
            Text("68%")
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(GlassSurface(cornerRadius: 10, opacity: 0.66, shadowStrength: 0.24, variant: .cleanResting))
    }
}
