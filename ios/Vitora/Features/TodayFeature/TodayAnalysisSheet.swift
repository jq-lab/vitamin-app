import SwiftUI

struct TodayAnalysisSheet: View {
    let analysis: TodayAnalysis
    let dailyIntention: DailyIntention?
    let selectedABOption: ABOptionSet.Option?
    let reminderPreference: ReminderPreference
    let reminderInstance: ReminderInstance?
    let onSelectABOption: (ABOptionSet.Option) -> Void
    let onRejectABOptions: () -> Void
    let onSaveReminderPreference: (ReminderPreference) -> Void
    let onClose: () -> Void

    var body: some View {
        FrostedSheetShell(
            title: "今日分析",
            subtitle: "黄体期 Day 18 · 解释今天为什么是 68",
            closeAccessibilityID: "today.analysis.close",
            onClose: onClose
        ) {
            TodayAnalysisPhaseHeader()
            TodayAnalysisOrbReport()
            TodayAnalysisExplanationCard(summary: analysis.summary, isLowData: analysis.isLowData)
            TodayAnalysisMonitoringCard()
            TodayAnalysisPredictionRecommendationCard(nextStep: analysis.nextStep)
            TodayAnalysisShareSaveActions()

            ComplianceLabel(text: "today.compliance.default")
        }
        .accessibilityIdentifier("today.analysis.sheet")
    }
}

private struct TodayAnalysisPhaseHeader: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(VitoraTheme.ColorToken.lutealGold.opacity(0.20))
                Image(systemName: "heart.fill")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(VitoraTheme.ColorToken.lutealGold)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text("黄体期 Day 18")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text("今天的能量判断会优先参考周期中段、睡眠恢复和 HRV 弹性。")
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(15)
        .background(GlassSurface(cornerRadius: 24, opacity: 0.70, shadowStrength: 0.30, variant: .cleanElevated))
        .accessibilityIdentifier("today.analysis.phase.header")
    }
}

private struct TodayAnalysisOrbReport: View {
    var body: some View {
        VStack(spacing: 14) {
            AnalysisScoreOrb(score: 68)
                .frame(height: 224)

            HStack(spacing: 8) {
                analysisPill(title: "睡眠", value: "7.2h", tint: Color(red: 151 / 255, green: 134 / 255, blue: 239 / 255))
                analysisPill(title: "HRV", value: "↓8%", tint: VitoraTheme.ColorToken.auraCyan)
                analysisPill(title: "周期", value: "D18", tint: VitoraTheme.ColorToken.lutealGold)
            }
        }
        .padding(16)
        .background(GlassSurface(cornerRadius: 28, opacity: 0.74, shadowStrength: 0.42, variant: .cleanElevated))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("今日能量 68 分，睡眠 7.2 小时，HRV 下降 8%，黄体期第 18 天")
        .accessibilityIdentifier("today.score.card")
    }

    private func analysisPill(title: String, value: String, tint: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            Text(value)
                .font(.system(size: 15, weight: .heavy).monospacedDigit())
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(tint.opacity(0.13), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.7))
    }
}

private struct AnalysisScoreOrb: View {
    let score: Int

    var body: some View {
        ZStack {
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) * 0.36
                let baseRect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)

                context.fill(Path(ellipseIn: baseRect.insetBy(dx: -18, dy: -18)), with: .color(VitoraTheme.ColorToken.lutealGold.opacity(0.10)))
                context.fill(Path(ellipseIn: baseRect), with: .color(Color.white.opacity(0.94)))
                context.stroke(Path(ellipseIn: baseRect), with: .color(Color.white.opacity(0.86)), lineWidth: 2)

                for index in 0..<5 {
                    let inset = CGFloat(index) * 14
                    let rect = baseRect.insetBy(dx: -28 + inset, dy: -28 + inset)
                    var path = Path()
                    path.addArc(
                        center: center,
                        radius: rect.width / 2,
                        startAngle: .degrees(Double(-160 + index * 16)),
                        endAngle: .degrees(Double(126 + index * 10)),
                        clockwise: false
                    )
                    let color: Color = index.isMultiple(of: 3)
                        ? Color(red: 124 / 255, green: 89 / 255, blue: 213 / 255)
                        : (index.isMultiple(of: 2) ? Color(red: 255 / 255, green: 137 / 255, blue: 104 / 255) : VitoraTheme.ColorToken.lutealGold)
                    context.stroke(path, with: .color(color.opacity(0.92)), style: StrokeStyle(lineWidth: index == 0 ? 13 : 8, lineCap: .round))
                }

                for offset in stride(from: -44.0, through: 44.0, by: 14.0) {
                    var stripe = Path()
                    stripe.move(to: CGPoint(x: center.x - radius * 0.55, y: center.y + offset))
                    stripe.addQuadCurve(
                        to: CGPoint(x: center.x + radius * 0.55, y: center.y + offset * 0.72),
                        control: CGPoint(x: center.x, y: center.y + offset - 10)
                    )
                    context.stroke(stripe, with: .color(VitoraTheme.ColorToken.auraLavender.opacity(0.12)), lineWidth: 1.2)
                }
            }

            VStack(spacing: 0) {
                Text("今日能量")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                Text("\(score)")
                    .font(.system(size: 76, weight: .black, design: .rounded))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .monospacedDigit()
                Text("适合留余量")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(VitoraTheme.ColorToken.lutealGold)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct TodayAnalysisExplanationCard: View {
    let summary: String
    let isLowData: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("为什么是这个分数")
                .font(.headline.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
            Text(isLowData ? summary : "今天的 68 分主要来自三个关键点：昨晚睡眠偏短，HRV 比平时低 8%，同时处在黄体期 Day 18。Vitora 会建议你把强任务拆小，把补给和安静恢复放在低谷前后。")
                .font(.system(size: 14.5, weight: .semibold))
                .lineSpacing(4)
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(GlassSurface(cornerRadius: 22, opacity: 0.68, shadowStrength: 0.30, variant: .cleanResting))
    }
}

private struct TodayAnalysisMonitoringCard: View {
    private let rows: [(title: String, value: String, body: String, tint: Color)] = [
        ("晚上睡眠", "7.2h", "恢复没有到满分，午后更容易掉电。", Color(red: 151 / 255, green: 134 / 255, blue: 239 / 255)),
        ("今天周期", "黄体期 D18", "更适合稳定节奏，少做硬扛式高强度安排。", VitoraTheme.ColorToken.lutealGold),
        ("HRV", "48ms · ↓8%", "恢复弹性偏低，建议把强任务拆小。", VitoraTheme.ColorToken.auraCyan),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("关键监测项")
                .font(.headline.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            ForEach(rows, id: \.title) { row in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(row.tint)
                        .frame(width: 10, height: 10)
                        .padding(.top, 5)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(row.title)
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            Text(row.value)
                                .font(.system(size: 13, weight: .heavy).monospacedDigit())
                                .foregroundStyle(row.tint)
                        }
                        Text(row.body)
                            .font(.system(size: 12.6, weight: .semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(12)
                .background(VitoraTheme.ColorToken.paper.opacity(0.46), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.62), lineWidth: 0.7))
            }
        }
        .padding(16)
        .background(GlassSurface(cornerRadius: 24, opacity: 0.66, shadowStrength: 0.30, variant: .cleanResting))
    }
}

private struct TodayAnalysisPredictionRecommendationCard: View {
    let nextStep: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("综合实时预测")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Spacer()
                Text(TodayMetricMode.energy.currentStatusBubble)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(VitoraTheme.ColorToken.lutealGold)
            }

            RealtimePredictionChart(mode: .energy)
                .frame(height: 132)

            Text("14:00 附近可能出现能量低谷。今天更适合先补给、再安排一段安静恢复，保留晚间余量。")
                .font(.system(size: 13.4, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                Text("今日推荐")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text("午间补能：13:20 加一份蛋白；14:40 安静恢复 20 分钟。")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(VitoraTheme.ColorToken.lutealGold.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.70), lineWidth: 0.7))
        }
        .padding(16)
        .background(GlassSurface(cornerRadius: 24, opacity: 0.68, shadowStrength: 0.34, variant: .cleanResting))
        .accessibilityIdentifier("today.analysis.realtime.section")
    }
}

private struct TodayAnalysisShareSaveActions: View {
    var body: some View {
        HStack(spacing: 10) {
            Button(action: {}) {
                Label("保存卡片", systemImage: "square.and.arrow.down")
                    .font(.system(size: 14, weight: .heavy))
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
            }
            .buttonStyle(.plain)
            .foregroundStyle(VitoraTheme.ColorToken.strongText)
            .background(VitoraTheme.ColorToken.paper.opacity(0.62), in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.70), lineWidth: 0.7))
            .accessibilityIdentifier("today.analysis.save")

            Button(action: {}) {
                Label("分享", systemImage: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .heavy))
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(VitoraTheme.ColorToken.strongText, in: Capsule())
            .accessibilityIdentifier("today.analysis.share")
        }
    }
}
