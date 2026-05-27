import SwiftUI

struct TodayScoreCard: View {
    private let deductions: [(title: String, points: String, reason: String, tint: Color)] = [
        ("睡眠略低", "-8", "昨夜 7.2h，恢复没有到满分状态。", VitoraTheme.ColorToken.auraBlue),
        ("HRV 下降", "-10", "48ms，较平时低 8%，恢复弹性偏弱。", VitoraTheme.ColorToken.auraCyan),
        ("14:00 低谷", "-7", "实时预测显示午后可能进入能量低谷。", VitoraTheme.ColorToken.lutealGold),
        ("黄体期负担", "-7", "Day 18 更适合保留余量。", VitoraTheme.ColorToken.auraLavender),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("今日状态")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("68")
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                        Text("/ 100")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("今日状态 68 分，满分 100 分")

                    Text("满分 100 表示睡眠、HRV、心率和周期负担都支持较高强度安排。")
                        .font(.footnote.weight(.medium))
                        .lineSpacing(3)
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }

                Spacer(minLength: 8)

                VStack(spacing: 5) {
                    Image(systemName: "gauge.with.dots.needle.50percent")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    Text("适合轻安排")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 78, height: 78)
                .background(GlassSurface(cornerRadius: 24, opacity: 0.62, shadowStrength: 0.20, variant: .cleanResting))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("为什么扣分")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                ForEach(deductions, id: \.title) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Text(item.points)
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(item.tint)
                            .frame(width: 34, height: 24)
                            .background(item.tint.opacity(0.12), in: Capsule())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.footnote.weight(.bold))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            Text(item.reason)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("今天怎么补充")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text("13:30 前加一小份蛋白；14:00 后把强任务拆小；下午轻走 10 分钟。")
                    .font(.subheadline.weight(.semibold))
                    .lineSpacing(3)
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }
            .padding(13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(VitoraTheme.ColorToken.paper.opacity(0.46), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.7))
        }
        .padding(16)
        .background(GlassSurface(cornerRadius: 26, opacity: 0.72, shadowStrength: 0.46, variant: .cleanElevated))
        .accessibilityIdentifier("today.score.card")
    }
}

struct TodayStateDetailSheet: View {
    let onClose: () -> Void
    let onAskVitora: () -> Void

    var body: some View {
        detailContainer(title: "今日状态详情", subtitle: "回看今天前后的变化", onClose: onClose) {
            Text("68% 能量平稳")
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
            Text("基于目前信息，下午 14:00 附近可能低谷。")
                .font(.subheadline)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            RhythmCurveView()
                .frame(height: 140)
                .padding(.vertical, 8)

            detailRow(time: "现在", body: "适合处理中等强度事务")
            detailRow(time: "13:30", body: "建议提前补充一点能量")
            detailRow(time: "14:00", body: "可能进入低谷窗口")

            Button("告诉 Vitora 今天的变化", action: onAskVitora)
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("today.state.askVitora")
        }
        .accessibilityIdentifier("today.state.detail.sheet")
    }
}

struct BodyFactorsDetailSheet: View {
    let onClose: () -> Void
    let onAskVitora: (String) -> Void

    private let factors: [BodyFactorSummary] = [
        BodyFactorSummary(title: "睡眠", value: "7.2h", note: "略低", symbol: "moon.fill", tint: VitoraTheme.ColorToken.auraBlue),
        BodyFactorSummary(title: "HRV", value: "48ms", note: "↓ 8%", symbol: "heart.circle.fill", tint: VitoraTheme.ColorToken.auraBlue),
        BodyFactorSummary(title: "心率", value: "72bpm", note: "稳定", symbol: "heart.fill", tint: VitoraTheme.ColorToken.auraCyan),
        BodyFactorSummary(title: "周期", value: "D18", note: "黄体期", symbol: "sparkles", tint: VitoraTheme.ColorToken.auraLavender),
    ]

    var body: some View {
        detailContainer(title: "今日分析", subtitle: "这些是 Vitora 判断今天状态的主要依据。", onClose: onClose) {
            TodayScoreCard()

            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    Text("综合实时预测")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Spacer()
                    Text(TodayMetricMode.energy.currentStatusBubble)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }

                RealtimePredictionChart(mode: .energy)
                    .frame(height: 132)

                TodayAnalysisSignalChips(mode: .energy)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(TodayMetricMode.energy.curveCaption)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }
            .padding(16)
            .background(GlassSurface(cornerRadius: 22, opacity: 0.50, shadowStrength: 0.30, variant: .cleanResting))
            .accessibilityIdentifier("today.analysis.realtime.section")

            HStack(spacing: 8) {
                ForEach(factors) { factor in
                    bodyFactorCard(factor)
                }
            }
            .accessibilityIdentifier("today.analysis.factor.row")

            VStack(alignment: .leading, spacing: 12) {
                Text("综合判断")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                analysisRow(title: "综合能量 68%", body: "用于判断今天适合轻安排还是高强度任务。")
                analysisRow(title: "低谷窗口 14:00", body: "实时预测显示 14:00 附近可能进入能量低谷。")
                analysisRow(title: "今日负担偏轻", body: "今天更适合保留余量，不是医学预测。")
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GlassSurface(cornerRadius: 20, opacity: 0.46, shadowStrength: 0.30, variant: .cleanResting))
        }
        .accessibilityIdentifier("today.bodyFactors.detail.sheet")
    }

    private func bodyFactorCard(_ factor: BodyFactorSummary) -> some View {
        Button {
            onAskVitora(factor.title)
        } label: {
            VStack(spacing: 6) {
                Text(factor.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Image(systemName: factor.symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.96))
                    .frame(width: 34, height: 34)
                    .background(
                        RadialGradient(
                            colors: [factor.tint.opacity(0.96), factor.tint.opacity(0.70)],
                            center: .topLeading,
                            startRadius: 3,
                            endRadius: 28
                        ),
                        in: Circle()
                    )

                Text(factor.value)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)

                Text(factor.note)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(noteColor(for: factor.note))
                    .lineLimit(1)
                    .minimumScaleFactor(0.64)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 126)
            .background(GlassSurface(cornerRadius: 18, opacity: 0.52, shadowStrength: 0.26, variant: .cleanResting))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("告诉 Vitora \(factor.title)情况") {
                onAskVitora(factor.title)
            }
        }
        .accessibilityIdentifier("today.analysis.factor.\(factor.id)")
    }

    private func analysisRow(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
            Text(body)
                .font(.footnote.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
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

private struct BodyFactorSummary: Identifiable {
    let title: String
    let value: String
    let note: String
    let symbol: String
    let tint: Color

    var id: String {
        title
    }
}

struct SuggestionDetailSheet: View {
    let onClose: () -> Void
    let onCommit: () -> Void
    let onSwap: () -> Void
    let onAskVitora: () -> Void

    var body: some View {
        detailContainer(title: "智能监测", subtitle: "管家方案会随早、中、晚时段调整", onClose: onClose) {
            Text("推荐你今天试这个")
                .font(.headline.weight(.semibold))
            Text("午后补一点蛋白和镁，把重点任务拆成两段。")
                .font(.title3.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            Text("黄体期中段更适合稳定输出。Vitora 会帮你留一点恢复余量，而不是只建议休息。")
                .font(.subheadline)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            VStack(alignment: .leading, spacing: 8) {
                Text("提醒")
                    .font(.headline.weight(.semibold))
                Text("○ 不提醒    ● 13:20 提醒    ○ 自定义")
                    .font(.subheadline)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }
            .padding(14)
            .background(GlassSurface(cornerRadius: 18, opacity: 0.36))

            HStack {
                Button("我试试", action: onCommit)
                    .buttonStyle(.borderedProminent)
                Button("换一个", action: onSwap)
                    .buttonStyle(.bordered)
                Button("不适合", action: onAskVitora)
                    .buttonStyle(.bordered)
            }
            .accessibilityIdentifier("today.suggestion.detail.actions")
        }
        .accessibilityIdentifier("today.suggestion.detail.sheet")
    }
}

@MainActor
func detailContainer<Content: View>(
    title: String,
    subtitle: String? = nil,
    onClose: @escaping () -> Void,
    @ViewBuilder content: () -> Content
) -> some View {
    FrostedSheetShell(
        title: title,
        subtitle: subtitle,
        closeAccessibilityID: "today.detail.close",
        onClose: onClose
    ) {
        content()
    }
}

func detailRow(time: String, body: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
        Text(time)
            .font(.headline.weight(.semibold))
            .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
            .frame(width: 62, alignment: .leading)
        Text(body)
            .font(.subheadline)
            .foregroundStyle(VitoraTheme.ColorToken.strongText)
        Spacer()
    }
    .padding(14)
    .background(GlassSurface(cornerRadius: 18, opacity: 0.62, shadowStrength: 0.22, variant: .cleanResting))
}
