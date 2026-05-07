import SwiftUI

struct EnergyDynamicsCard: View {
    let onOpenDetail: () -> Void
    let onAskVitora: () -> Void
    @State private var selectedGranularity = "周"
    @State private var showsCallout = false

    private let granularities = ["日", "周", "月"]

    var body: some View {
        AskableSurface(
            accessibilityID: "cycle.energy.card",
            onOpenDetail: onOpenDetail,
            onAskVitora: onAskVitora,
            onCorrectVitora: onAskVitora
        ) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("能量动态")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Spacer()
                    granularityPicker
                }

                Text("本周平均 62% · 较上周 ↑5%")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)

                EnergySparklineView(showsCallout: $showsCallout, onAskVitora: onAskVitora)
                    .frame(height: 150)

                Text("Vitora 看到：周三后恢复变慢")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }
            .padding(18)
            .background(GlassSurface(cornerRadius: 24, opacity: 0.42))
        }
    }

    private var granularityPicker: some View {
        HStack(spacing: 4) {
            ForEach(granularities, id: \.self) { value in
                Button {
                    selectedGranularity = value
                } label: {
                    Text(value)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(selectedGranularity == value ? VitoraTheme.ColorToken.paper : VitoraTheme.ColorToken.actionPrimaryDeep)
                        .frame(width: 32, height: 28)
                        .background(selectedGranularity == value ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.paper.opacity(0.34))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .accessibilityIdentifier("cycle.energy.granularity")
    }
}

struct EnergySparklineView: View {
    @Binding var showsCallout: Bool
    let onAskVitora: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let points = [
                CGPoint(x: proxy.size.width * 0.02, y: proxy.size.height * 0.70),
                CGPoint(x: proxy.size.width * 0.20, y: proxy.size.height * 0.42),
                CGPoint(x: proxy.size.width * 0.34, y: proxy.size.height * 0.30),
                CGPoint(x: proxy.size.width * 0.50, y: proxy.size.height * 0.58),
                CGPoint(x: proxy.size.width * 0.66, y: proxy.size.height * 0.72),
                CGPoint(x: proxy.size.width * 0.82, y: proxy.size.height * 0.50),
                CGPoint(x: proxy.size.width * 0.96, y: proxy.size.height * 0.34),
            ]

            ZStack(alignment: .topLeading) {
                VStack(spacing: proxy.size.height / 4) {
                    ForEach(0..<4, id: \.self) { _ in
                        Rectangle()
                            .fill(VitoraTheme.ColorToken.secondaryText.opacity(0.12))
                            .frame(height: 1)
                    }
                }

                Path { path in
                    path.move(to: points[0])
                    for index in 1..<points.count {
                        path.addLine(to: points[index])
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [VitoraTheme.ColorToken.auraBlue, VitoraTheme.ColorToken.auraCyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )

                Button {
                    showsCallout.toggle()
                } label: {
                    Circle()
                        .fill(VitoraTheme.ColorToken.actionPrimaryDeep)
                        .frame(width: 13, height: 13)
                        .overlay(Circle().stroke(VitoraTheme.ColorToken.paper, lineWidth: 2))
                }
                .buttonStyle(.plain)
                .position(points[6])
                .accessibilityIdentifier("cycle.energy.point.today")

                if showsCallout {
                    ChartCallout(title: "今天 68%", subtitle: "睡眠略低 · HRV↓", onAskVitora: onAskVitora)
                        .position(x: points[6].x - 48, y: max(36, points[6].y - 42))
                }

                HStack {
                    ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { day in
                        Text(day)
                            .font(.caption2)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            .frame(maxWidth: .infinity)
                    }
                }
                .position(x: proxy.size.width / 2, y: proxy.size.height - 10)
            }
        }
        .accessibilityIdentifier("cycle.energy.chart")
    }
}

