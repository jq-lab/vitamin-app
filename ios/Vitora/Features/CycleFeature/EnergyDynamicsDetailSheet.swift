import SwiftUI

struct EnergyDynamicsDetailSheet: View {
    let onClose: () -> Void
    let onAskVitora: () -> Void
    @State private var showsCallout = false

    var body: some View {
        cycleDetailContainer(title: "能量动态", subtitle: "回看趋势和 Vitora 叙事", onClose: onClose) {
            Text("本周平均 62% · 较上周 ↑5%")
                .font(.title2.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            EnergySparklineView(showsCallout: $showsCallout, onAskVitora: onAskVitora)
                .frame(height: 190)
                .padding(.vertical, 8)
                .background(GlassSurface(cornerRadius: 24, opacity: 0.58, shadowStrength: 0.38, variant: .cleanResting))

            VStack(alignment: .leading, spacing: 8) {
                Text("图层")
                    .font(.headline.weight(.bold))
                HStack {
                    ForEach(["周期阶段", "睡眠", "HRV", "记录事件"], id: \.self) { layer in
                        Text(layer)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                            .padding(.horizontal, 10)
                            .frame(height: 30)
                            .background(VitoraTheme.ColorToken.paper.opacity(0.62))
                            .clipShape(Capsule())
                    }
                }
            }

            cycleInfoBlock(title: "这 30 天，Vitora 看见的三件事", lines: [
                "低谷集中窗口：14:00-16:00。",
                "恢复较好时段：上午。",
                "影响因素：睡眠 + HRV + 周期；仍需校准 3 天待确认。"
            ])
            cycleInfoBlock(title: "Vitora 本周看到", lines: ["周三后恢复变慢，可能和睡眠下降、HRV 回落以及黄体期中段有关。"])
            cycleInfoBlock(title: "关键点", lines: ["周二：睡眠较好，能量上升", "周四：HRV 下降，能量回落", "今天：建议稳定补给"])
        }
    }
}
