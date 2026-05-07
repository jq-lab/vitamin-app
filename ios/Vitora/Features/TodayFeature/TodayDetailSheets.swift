import SwiftUI

struct TodayStateDetailSheet: View {
    let onClose: () -> Void
    let onAskVitora: () -> Void

    var body: some View {
        detailContainer(title: "今日状态详情", onClose: onClose) {
            Text("68% 能量平稳")
                .font(.largeTitle.weight(.semibold))
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

    var body: some View {
        detailContainer(title: "身体要素", onClose: onClose) {
            Text("这些是 Vitora 判断今天状态的主要依据。")
                .font(.subheadline)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            factorDetail(title: "睡眠 7.2h · 略低", body: "可能让下午恢复速度变慢。", actionTitle: "告诉 Vitora 睡眠情况")
            factorDetail(title: "HRV 48ms · 较昨日下降 8%", body: "今天恢复信号偏弱。", actionTitle: nil)
            factorDetail(title: "心率 72bpm · 稳定", body: "当前没有明显异常趋势。", actionTitle: nil)
            factorDetail(title: "周期 D18 · 黄体期", body: "今天更适合稳定能量补给。", actionTitle: "补充周期感受")
        }
        .accessibilityIdentifier("today.bodyFactors.detail.sheet")
    }

    private func factorDetail(title: String, body: String, actionTitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline.weight(.semibold))
            Text(body)
                .font(.footnote)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            if let actionTitle {
                Button(actionTitle) {
                    onAskVitora(title)
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GlassSurface(cornerRadius: 18, opacity: 0.38))
    }
}

struct SuggestionDetailSheet: View {
    let onClose: () -> Void
    let onCommit: () -> Void
    let onSwap: () -> Void
    let onAskVitora: () -> Void

    var body: some View {
        detailContainer(title: "Vitora 今日建议", onClose: onClose) {
            Text("推荐你今天试这个")
                .font(.headline.weight(.semibold))
            Text("13:30 前加一小份蛋白，下午轻走 10 分钟。")
                .font(.title3.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            Text("为什么是这个建议？因为 14:00 附近可能低谷，且睡眠略低。")
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

func detailContainer<Content: View>(
    title: String,
    onClose: @escaping () -> Void,
    @ViewBuilder content: () -> Content
) -> some View {
    ZStack {
        AuraBackground(intensity: 0.82)

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button("关闭", action: onClose)
                        .font(.callout.weight(.semibold))
                    Spacer()
                    Text(title)
                        .font(.headline.weight(.bold))
                    Spacer()
                    Color.clear.frame(width: 44, height: 1)
                }
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

                content()
            }
            .padding(20)
            .padding(.bottom, 32)
        }
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
    .background(GlassSurface(cornerRadius: 18, opacity: 0.38))
}
