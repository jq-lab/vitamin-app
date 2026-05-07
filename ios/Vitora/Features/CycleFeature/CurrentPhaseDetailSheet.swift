import SwiftUI

struct CurrentPhaseDetailSheet: View {
    let onClose: () -> Void
    let onAskVitora: () -> Void

    var body: some View {
        cycleDetailContainer(title: "当前周期阶段", onClose: onClose) {
            Text("Day 18 · 黄体期中段")
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            Text("置信度：中等")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)

            PhaseAxisView()
                .frame(height: 92)
                .padding(.vertical, 8)

            cycleInfoBlock(title: "Vitora 如何判断", lines: ["最近周期开始：4月17日", "平均周期长度：28 天", "最近记录：较少"])
            cycleInfoBlock(title: "预测窗口", lines: ["下次周期可能在 5月12日 - 5月15日"])
            cycleInfoBlock(title: "对今天的意义", lines: ["当前阶段可能让下午能量更容易波动。", "Today 建议偏向低负担、稳定补给。"])

            HStack {
                Button("日期不准", action: onAskVitora)
                Button("有腹胀", action: onAskVitora)
                Button("情绪波动", action: onAskVitora)
            }
            .buttonStyle(.bordered)
            .font(.footnote.weight(.semibold))
        }
    }
}
