import SwiftUI

enum TodayMetricMode: String, CaseIterable, Equatable {
    case energy
    case sleep = "sleepHRV"
    case cycle
    case heart = "heartCycle"
    case hrv

    var topLabel: String {
        switch self {
        case .energy: return "综合能量"
        case .sleep: return "睡眠恢复"
        case .cycle: return "周期阶段"
        case .heart: return "心率"
        case .hrv: return "HRV"
        }
    }

    var bowlTitle: String {
        switch self {
        case .energy: return "今日综合能量"
        case .sleep: return "睡眠"
        case .cycle: return "周期"
        case .heart: return "心率"
        case .hrv: return "HRV"
        }
    }

    var railLabel: String {
        switch self {
        case .energy: return "综合"
        case .sleep: return "睡眠"
        case .cycle: return "周期"
        case .heart: return "心率"
        case .hrv: return "HRV"
        }
    }

    var number: String {
        switch self {
        case .energy: return "68"
        case .sleep: return "7.2"
        case .cycle: return "18"
        case .heart: return "72"
        case .hrv: return "48"
        }
    }

    var unit: String {
        switch self {
        case .energy: return "%"
        case .sleep: return "h"
        case .cycle: return "Day"
        case .heart: return "bpm"
        case .hrv: return "ms"
        }
    }

    var statusText: String {
        switch self {
        case .energy: return "能量低"
        case .sleep: return "昨夜恢复略低"
        case .cycle: return "黄体期中段"
        case .heart: return "心率稳定"
        case .hrv: return "HRV 偏低"
        }
    }

    var meaning: String {
        switch self {
        case .energy: return "综合能量用于判断今天适合轻安排还是高强度任务。"
        case .sleep: return "睡眠只看昨夜恢复，不和 HRV 混成一个分数。"
        case .cycle: return "周期只说明阶段位置和今天的节律意义。"
        case .heart: return "心率用于观察今日节奏负担，不和周期合并判断。"
        case .hrv: return "HRV 单独表达恢复弹性，不等同于睡眠时长。"
        }
    }

    var analysisRows: [String] {
        switch self {
        case .energy:
            return ["综合能量 68%", "低谷窗口 14:00", "今日负担偏轻"]
        case .sleep:
            return ["昨夜睡眠 7.2h", "深睡 1.4h", "浅睡 4.8h", "中断 2 次"]
        case .cycle:
            return ["当前阶段 黄体期", "Day 18", "预测窗口 5月8日-5月12日", "今日适合稳定节奏"]
        case .heart:
            return ["静息心率 72 bpm", "今日波动稳定", "未见高负担信号"]
        case .hrv:
            return ["HRV 48 ms", "恢复趋势略低", "建议降低强度"]
        }
    }

    var curveCaption: String {
        switch self {
        case .energy:
            return "综合能量用于判断今天适合轻安排还是高强度任务，不是医学预测。"
        case .sleep:
            return "睡眠是昨夜结论，不显示成实时监测。"
        case .cycle:
            return "周期展示阶段窗口，帮助理解今天的节律背景。"
        case .heart:
            return "心率曲线用于观察节奏负担，不单点诊断。"
        case .hrv:
            return "HRV 单独看恢复弹性，和睡眠分开解释。"
        }
    }

    var currentTimeLabel: String {
        switch self {
        case .energy: return "14:00"
        case .sleep: return "07:00"
        case .cycle: return "今天"
        case .heart: return "15:00"
        case .hrv: return "11:00"
        }
    }

    var currentStatusBubble: String {
        switch self {
        case .energy: return "14:00 · 能量低谷"
        case .sleep: return "07:00 · 恢复偏低"
        case .cycle: return "今天 · 黄体期"
        case .heart: return "15:00 · 节律偏稳"
        case .hrv: return "11:00 · 恢复偏低"
        }
    }

    var forecastAxisLabels: [String] {
        ["高", "中", "低"]
    }

    var forecastPoints: [(hour: String, level: CGFloat)] {
        switch self {
        case .energy:
            return [("10", 0.40), ("11", 0.46), ("12", 0.38), ("13", 0.48), ("14", 0.72), ("15", 0.44), ("16", 0.42)]
        case .sleep:
            return [("01", 0.70), ("03", 0.56), ("05", 0.48), ("07", 0.62), ("09", 0.52), ("11", 0.44), ("13", 0.42)]
        case .cycle:
            return [("D16", 0.42), ("D17", 0.45), ("D18", 0.50), ("D19", 0.54), ("D20", 0.58), ("D21", 0.62), ("D22", 0.60)]
        case .heart:
            return [("10", 0.43), ("11", 0.40), ("12", 0.42), ("13", 0.46), ("14", 0.48), ("15", 0.45), ("16", 0.43)]
        case .hrv:
            return [("08", 0.50), ("09", 0.54), ("10", 0.60), ("11", 0.64), ("12", 0.56), ("13", 0.50), ("14", 0.46)]
        }
    }

    var currentForecastIndex: Int {
        switch self {
        case .energy: return 4
        case .sleep: return 3
        case .cycle: return 2
        case .heart: return 5
        case .hrv: return 3
        }
    }

    var suggestionTitle: String {
        switch self {
        case .energy: return "今天先做轻安排"
        case .sleep: return "优先补回恢复感"
        case .cycle: return "按黄体期放慢节奏"
        case .heart: return "让心率负担更平稳"
        case .hrv: return "给恢复弹性留空间"
        }
    }

    var suggestionEvidence: String {
        switch self {
        case .energy:
            return "依据：周期阶段、睡眠、心率与 HRV 的综合趋势。"
        case .sleep:
            return "依据：昨夜睡眠 7.2h、深睡偏少、中断 2 次。"
        case .cycle:
            return "依据：黄体期 Day18 与近期记录窗口。"
        case .heart:
            return "依据：静息心率 72 bpm 与今日波动趋势。"
        case .hrv:
            return "依据：HRV 48 ms 与恢复趋势略低。"
        }
    }

    var bodyExplanation: String {
        switch self {
        case .energy:
            return "Vitora 看到今天处在黄体期中段，综合能量偏低；更适合稳定输出，同时给身体留一点恢复余量。"
        case .sleep:
            return "Vitora 看到昨夜恢复不算满，今天先把节奏放稳。"
        case .cycle:
            return "Vitora 看到你在黄体期中段，今天更适合保留余量。"
        case .heart:
            return "Vitora 看到心率整体稳定，但午后仍适合减少刺激。"
        case .hrv:
            return "Vitora 看到 HRV 偏低，身体可能需要更多恢复空间。"
        }
    }

    var symbol: String {
        switch self {
        case .energy: return "sparkles"
        case .sleep: return "moon.fill"
        case .cycle: return "camera.macro"
        case .heart: return "heart.fill"
        case .hrv: return "waveform.path.ecg"
        }
    }

    var accent: Color {
        switch self {
        case .energy: return Color(red: 245 / 255, green: 154 / 255, blue: 91 / 255)
        case .sleep: return Color(red: 87 / 255, green: 178 / 255, blue: 232 / 255)
        case .cycle: return Color(red: 132 / 255, green: 121 / 255, blue: 238 / 255)
        case .heart: return Color(red: 236 / 255, green: 121 / 255, blue: 168 / 255)
        case .hrv: return Color(red: 78 / 255, green: 196 / 255, blue: 205 / 255)
        }
    }

    var secondaryAccent: Color {
        switch self {
        case .energy: return Color(red: 102 / 255, green: 157 / 255, blue: 239 / 255)
        case .sleep: return Color(red: 95 / 255, green: 217 / 255, blue: 204 / 255)
        case .cycle: return Color(red: 255 / 255, green: 177 / 255, blue: 111 / 255)
        case .heart: return Color(red: 252 / 255, green: 172 / 255, blue: 95 / 255)
        case .hrv: return Color(red: 112 / 255, green: 143 / 255, blue: 235 / 255)
        }
    }

    var fillLevel: CGFloat {
        switch self {
        case .energy: return 0.54
        case .sleep: return 0.46
        case .cycle: return 0.62
        case .heart: return 0.58
        case .hrv: return 0.42
        }
    }

    var showsDynamicCurve: Bool {
        self == .energy || self == .heart
    }

}

struct TodayStatusCard: View {
    @Binding var selectedMode: TodayMetricMode
    let cycleDay: Int
    let cyclePhase: String
    let eventTrigger: Int
    let onOpenDetail: () -> Void
    let onOpenEvidence: () -> Void
    let onAskVitora: () -> Void
    let onCalibrate: (String) -> Void

    private let stageHeight: CGFloat = 330

    var body: some View {
        VStack(spacing: 4) {
            Text("现在状态")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .accessibilityHidden(false)

            ZStack(alignment: .bottomTrailing) {
                Color.clear
                    .frame(maxWidth: .infinity)
                    .frame(height: stageHeight)
                    .accessibilityIdentifier("today.energy.stage")
                    .allowsHitTesting(false)

                EnergyBowlView(
                    mode: selectedMode,
                    trigger: eventTrigger,
                    cycleDay: cycleDay,
                    cyclePhase: cyclePhase,
                    onOpenData: onOpenEvidence
                )
                .frame(height: stageHeight)

                VStack {
                    Spacer(minLength: 122)
                    Button(action: onOpenDetail) {
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .contentShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.card, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("问 Vitora 为什么", action: onAskVitora)
                        Button("告诉 Vitora 这里不准") {
                            onCalibrate("这里不准")
                        }
                        Button("查看详情", action: onOpenDetail)
                    }
                    .accessibilityLabel("\(selectedMode.statusText)，\(selectedMode.number)\(selectedMode.unit)")
                    .accessibilityHint("点按查看今日状态详情，长按可以问 Vitora 或校准这个判断")
                    .accessibilityIdentifier("today.status.card")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 0)
        .padding(.top, 0)
        .padding(.bottom, 2)
        .animation(.easeOut(duration: 0.22), value: selectedMode)
    }
}

private struct CyclePhaseStrip: View {
    let cycleDay: Int
    let phaseLabel: String

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let nodes = visiblePhaseNodes
            let positions = [0.16, 0.50, 0.84].map { arcPoint(t: $0, width: width) }

            ZStack(alignment: .topLeading) {
                Canvas { context, size in
                    let path = cycleArcPath(width: size.width)

                    context.stroke(
                        path,
                        with: .linearGradient(
                            Gradient(colors: nodes.map { $0.color.opacity(0.35) }),
                            startPoint: CGPoint(x: 20, y: 24),
                            endPoint: CGPoint(x: size.width - 20, y: 24)
                        ),
                        style: StrokeStyle(lineWidth: 3.2, lineCap: .round, lineJoin: .round)
                    )

                    context.stroke(
                        path,
                        with: .linearGradient(
                            Gradient(colors: nodes.map(\.color)),
                            startPoint: CGPoint(x: 20, y: 24),
                            endPoint: CGPoint(x: size.width - 20, y: 24)
                        ),
                        style: StrokeStyle(lineWidth: 5.0, lineCap: .round, lineJoin: .round)
                    )
                }

                ForEach(Array(nodes.enumerated()), id: \.element.phase) { index, node in
                    let point = positions[index]
                    phaseMarker(systemName: node.symbol, color: node.color, selected: node.isCurrent)
                        .position(x: point.x, y: point.y)
                        .accessibilityHidden(true)

                    phaseLabel(node.label, selected: node.isCurrent)
                        .position(x: point.x, y: 61)
                }
            }
        }
        .frame(height: 72)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("周期圆弧，\(phaseLabel) Day \(cycleDay)，展示上一阶段、当前阶段和下一阶段")
        .accessibilityIdentifier("today.cycle.phase.strip")
    }

    private enum StripPhase: CaseIterable {
        case menstrual
        case follicular
        case ovulation
        case luteal

        var previous: StripPhase {
            switch self {
            case .menstrual: return .luteal
            case .follicular: return .menstrual
            case .ovulation: return .follicular
            case .luteal: return .ovulation
            }
        }

        var next: StripPhase {
            switch self {
            case .menstrual: return .follicular
            case .follicular: return .ovulation
            case .ovulation: return .luteal
            case .luteal: return .menstrual
            }
        }
    }

    private struct PhaseNode {
        let phase: StripPhase
        let label: String
        let symbol: String
        let color: Color
        let isCurrent: Bool
    }

    private var visiblePhaseNodes: [PhaseNode] {
        let current = phase(for: cycleDay)
        return [current.previous, current, current.next].map { phase in
            PhaseNode(
                phase: phase,
                label: label(for: phase, isCurrent: phase == current),
                symbol: symbol(for: phase),
                color: phaseColor(phase),
                isCurrent: phase == current
            )
        }
    }

    private func phase(for day: Int) -> StripPhase {
        switch day {
        case 1...5:
            return .menstrual
        case 6...13:
            return .follicular
        case 14...16:
            return .ovulation
        default:
            return .luteal
        }
    }

    private func label(for phase: StripPhase, isCurrent: Bool) -> String {
        switch phase {
        case .menstrual:
            return isCurrent ? "月经期 D\(cycleDay)" : "月经期"
        case .follicular:
            return isCurrent ? "卵泡期 D\(cycleDay)" : "卵泡期"
        case .ovulation:
            return isCurrent ? "排卵期 D\(cycleDay)" : "排卵期"
        case .luteal:
            return isCurrent ? "黄体期 D\(cycleDay)" : "黄体期"
        }
    }

    private func symbol(for phase: StripPhase) -> String {
        switch phase {
        case .menstrual:
            return "drop.fill"
        case .follicular:
            return "leaf.fill"
        case .ovulation:
            return "sparkle"
        case .luteal:
            return "heart.fill"
        }
    }

    private func phaseColor(_ phase: StripPhase) -> Color {
        switch phase {
        case .menstrual:
            return DynamicAuraVariant.menstrual.softTint.opacity(0.94)
        case .follicular:
            return DynamicAuraVariant.follicular.softTint.opacity(0.94)
        case .ovulation:
            return DynamicAuraVariant.ovulation.softTint.opacity(0.98)
        case .luteal:
            return VitoraTheme.ColorToken.lutealGold.opacity(0.98)
        }
    }

    private func cycleArcPath(width: CGFloat) -> Path {
        var path = Path()
        let start = arcPoint(t: 0, width: width)
        let first = arcPoint(t: 0.5, width: width)
        let end = arcPoint(t: 1, width: width)
        path.move(to: start)
        path.addQuadCurve(
            to: first,
            control: CGPoint(x: width * 0.30, y: 40)
        )
        path.addQuadCurve(
            to: end,
            control: CGPoint(x: width * 0.70, y: 40)
        )
        return path
    }

    private func arcPoint(t: CGFloat, width: CGFloat) -> CGPoint {
        let clamped = min(max(t, 0), 1)
        let x = 24 + clamped * max(width - 48, 1)
        let y = 18 + sin(clamped * .pi) * 19
        return CGPoint(x: x, y: y)
    }

    private func phaseMarker(systemName: String, color: Color, selected: Bool) -> some View {
        Image(systemName: systemName)
            .font(.system(size: selected ? 14 : 10, weight: .bold))
            .foregroundStyle(color)
            .frame(width: selected ? 27 : 20, height: selected ? 27 : 20)
            .background(selected ? Color.white.opacity(0.66) : Color.white.opacity(0.16), in: Circle())
            .overlay(Circle().stroke(Color.white.opacity(selected ? 0.76 : 0.30), lineWidth: selected ? 1.0 : 0.7))
            .shadow(color: color.opacity(selected ? 0.28 : 0.12), radius: selected ? 7 : 3, x: 0, y: 3)
    }

    private func phaseLabel(_ text: String, selected: Bool) -> some View {
        Text(text)
            .font(.system(size: selected ? 14 : 12, weight: selected ? .bold : .semibold))
            .foregroundStyle(selected ? VitoraTheme.ColorToken.strongText : VitoraTheme.ColorToken.secondaryText.opacity(0.78))
            .lineLimit(1)
            .minimumScaleFactor(0.72)
    }
}

struct EnergyBowlView: View {
    let mode: TodayMetricMode
    let trigger: Int
    let cycleDay: Int
    let cyclePhase: String
    let onOpenData: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var fillLevel: CGFloat = 0.16

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let bowlWidth = min(width * 0.92, 334)
            let bowlHeight: CGFloat = 146
            let centerX = width / 2
            let bowlCenterY = height * 0.55
            let bowlTopY = bowlCenterY - bowlHeight * 0.45
            let bowlBottomY = bowlCenterY + bowlHeight * 0.48
            let waterSurfaceY = bowlBottomY - (bowlBottomY - bowlTopY) * min(max(fillLevel, 0.12), 0.86)

            ZStack(alignment: .topLeading) {
                EnergyBowlRainIntakeLayer(
                    mode: mode,
                    trigger: trigger,
                    reduceMotion: reduceMotion,
                    impactPoint: CGPoint(x: centerX, y: max(104, bowlTopY + 14)),
                    waterSurfaceY: waterSurfaceY
                )
                    .frame(width: width, height: height)
                    .allowsHitTesting(false)

                FrostedEnergyBowlView(mode: mode, fillLevel: fillLevel)
                    .frame(width: bowlWidth, height: bowlHeight)
                    .position(x: centerX, y: bowlCenterY)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("能量碗")
                    .accessibilityIdentifier("today.energy.bowl")

                EnergyBowlMetricCluster(mode: mode, onOpenData: onOpenData)
                    .frame(width: min(width - 8, 348))
                    .position(x: centerX, y: 67)

                CyclePhaseStrip(cycleDay: cycleDay, phaseLabel: cyclePhase)
                    .frame(width: min(width - 34, 310), height: 72)
                    .position(x: centerX, y: min(height - 20, bowlBottomY + 30))
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            fillLevel = 0.18
            animateFill(to: mode.fillLevel, delay: reduceMotion ? 0.02 : 0.16)
        }
        .onChange(of: mode) { _, newMode in
            if reduceMotion {
                fillLevel = newMode.fillLevel
            } else {
                withAnimation(.easeOut(duration: 0.18)) {
                    fillLevel = 0.25
                }
                animateFill(to: newMode.fillLevel, delay: 0.22)
            }
        }
        .onChange(of: trigger) { _, _ in
            guard !reduceMotion else {
                fillLevel = mode.fillLevel
                return
            }
            let lifted = min(mode.fillLevel + 0.045, 0.86)
            withAnimation(.easeOut(duration: 0.28)) {
                fillLevel = lifted
            }
            animateFill(to: mode.fillLevel, delay: 0.62)
        }
    }

    private func animateFill(to target: CGFloat, delay: Double) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            withAnimation(.spring(response: 0.72, dampingFraction: 0.86)) {
                fillLevel = target
            }
        }
    }
}

private struct FrostedEnergyBowlView: View {
    let mode: TodayMetricMode
    let fillLevel: CGFloat

    var body: some View {
        ZStack {
            supportShadow
            bowlBase
            bowlFill
            innerWallHighlight
            waterRefraction
            waterSurface
            rimUnderShadow
            rimHighlight
            topLightWash
            outerWallStroke
            innerGlassStroke
            bottomInnerGlow
            contactShadow
            accessibilityProbe
        }
    }

    private var supportShadow: some View {
        Color.clear.frame(width: 1, height: 1)
    }

    private var bowlBase: some View {
        BowlShape()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.22),
                        Color(red: 255 / 255, green: 251 / 255, blue: 246 / 255).opacity(0.30),
                        Color(red: 239 / 255, green: 247 / 255, blue: 255 / 255).opacity(0.38),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    private var bowlFill: some View {
        BowlFillLayer(level: fillLevel)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.20),
                        mode.secondaryAccent.opacity(0.42),
                        mode.accent.opacity(0.32),
                        Color(red: 232 / 255, green: 246 / 255, blue: 255 / 255).opacity(0.24),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .blur(radius: 2.6)
            .clipShape(BowlShape())
    }

    private var innerWallHighlight: some View {
        BowlShape()
            .inset(by: 4)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.60),
                        Color(red: 198 / 255, green: 213 / 255, blue: 226 / 255).opacity(0.32),
                        Color.white.opacity(0.46),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 2.2
            )
            .blur(radius: 0.25)
            .blendMode(.screen)
    }

    private var waterRefraction: some View {
        BowlWaterSurface(level: fillLevel)
            .stroke(Color(red: 121 / 255, green: 155 / 255, blue: 191 / 255).opacity(0.20), lineWidth: 5.0)
            .blur(radius: 3.0)
            .clipShape(BowlShape())
    }

    private var waterSurface: some View {
        BowlWaterSurface(level: fillLevel)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.82),
                        mode.secondaryAccent.opacity(0.62),
                        Color.white.opacity(0.46),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 1.7, lineCap: .round, lineJoin: .round)
            )
            .blur(radius: 0.35)
            .clipShape(BowlShape())
    }

    private var rimUnderShadow: some View {
        BowlRimShape()
            .stroke(Color(red: 155 / 255, green: 172 / 255, blue: 190 / 255).opacity(0.24), lineWidth: 2.2)
            .offset(y: 4)
            .blur(radius: 1.1)
    }

    private var rimHighlight: some View {
        BowlRimShape()
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.96),
                        mode.secondaryAccent.opacity(0.58),
                        Color(red: 190 / 255, green: 204 / 255, blue: 218 / 255).opacity(0.58),
                        Color.white.opacity(0.82),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 3.0, lineCap: .round, lineJoin: .round)
            )
            .blur(radius: 0.15)
    }

    private var topLightWash: some View {
        VStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.88),
                            Color.white.opacity(0.52),
                            Color.white.opacity(0.14),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 10)
                .blur(radius: 5)
                .offset(y: -2)
                .blendMode(.screen)
            Spacer(minLength: 0)
        }
    }

    private var outerWallStroke: some View {
        BowlShape()
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.98),
                        Color(red: 197 / 255, green: 212 / 255, blue: 226 / 255).opacity(0.70),
                        Color(red: 235 / 255, green: 226 / 255, blue: 216 / 255).opacity(0.44),
                        Color.white.opacity(0.84),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2.1
            )
    }

    private var innerGlassStroke: some View {
        BowlShape()
            .inset(by: 7)
            .stroke(Color.white.opacity(0.36), lineWidth: 1.2)
            .blur(radius: 1.3)
            .blendMode(.screen)
    }

    private var bottomInnerGlow: some View {
        VStack {
            Spacer(minLength: 0)
            ZStack {
                Ellipse()
                    .fill(mode.accent.opacity(0.07 + fillLevel * 0.14))
                    .frame(width: 226, height: 42)
                    .blur(radius: 18)
                    .blendMode(.screen)

                Ellipse()
                    .stroke(Color.white.opacity(0.18 + fillLevel * 0.20), lineWidth: 1)
                    .frame(width: 184, height: 24)
                    .blur(radius: 1.5)
                    .offset(y: -7)
            }
            .offset(y: 7)
        }
    }

    private var contactShadow: some View {
        Color.clear.frame(width: 1, height: 1)
    }

    private var accessibilityProbe: some View {
        Color.clear
            .frame(width: 1, height: 1)
            .accessibilityElement()
            .accessibilityLabel("能量碗水位")
            .accessibilityValue(waterLevelDescription)
            .accessibilityIdentifier("today.energy.water.level")
    }

    private var waterLevelDescription: String {
        let percent = Int((fillLevel * 100).rounded())
        let band: String
        switch fillLevel {
        case ..<0.34:
            band = "偏浅"
        case ..<0.68:
            band = "半碗"
        default:
            band = "接近满碗"
        }
        return "\(percent)%，\(band)"
    }
}

private struct EnergyBowlMetricCluster: View {
    let mode: TodayMetricMode
    let onOpenData: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var searchIconOffset: CGFloat = 0
    @State private var bounceTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            metricNumber
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 12) {
                Text("/")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.48))
                    .frame(width: 22, height: 58)
                    .offset(y: 1)

                statusDataButton
            }
            .offset(x: 122, y: 7)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 96)
        .accessibilityElement(children: .contain)
        .onAppear(perform: startSearchBounce)
        .onDisappear {
            bounceTask?.cancel()
            bounceTask = nil
            searchIconOffset = 0
        }
    }

    private var metricNumber: some View {
        HStack(alignment: .lastTextBaseline, spacing: 1) {
            if mode == .cycle {
                Text(mode.unit)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(mode.secondaryAccent.opacity(0.90))
                    .padding(.trailing, 2)
            }

            PixelMetricNumber(text: mode.number, mode: mode)
                .frame(width: mode.number.count > 2 ? 112 : 108, height: 76)
                .accessibilityIdentifier("today.energy.score")

            if mode != .cycle && mode != .energy {
                Text(mode.unit)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(EnergyNumberStyle.unitGradient)
                    .offset(y: -4)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(mode.number)\(mode.unit)")
    }

    private var statusDataButton: some View {
        Button(action: onOpenData) {
            VStack(spacing: 2) {
                HStack(spacing: 5) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                        .offset(y: searchIconOffset)
                        .accessibilityHidden(true)

                    Text(mode.statusText)
                        .font(.system(size: 13.5, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                        .accessibilityIdentifier("today.energy.status")
                }
                .padding(.horizontal, 9)
                .frame(height: 27)
                .background(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.72),
                            VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.50),
                            Color(red: 229 / 255, green: 245 / 255, blue: 248 / 255).opacity(0.42),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: Capsule()
                )
                .overlay(Capsule().stroke(Color.white.opacity(0.74), lineWidth: 0.75))
                .shadow(color: VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.10), radius: 7, x: 0, y: 4)

                Text("查看数据")
                    .font(.system(size: 9.5, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.76))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .frame(minWidth: 74)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(mode.statusText)，查看数据")
        .accessibilityIdentifier("today.evidence.open")
    }

    private func startSearchBounce() {
        guard !reduceMotion, bounceTask == nil else { return }

        bounceTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 700_000_000)
                await quickSearchHop()
                try? await Task.sleep(nanoseconds: 100_000_000)
                await quickSearchHop()
                try? await Task.sleep(nanoseconds: 1_550_000_000)
            }
        }
    }

    @MainActor
    private func quickSearchHop() async {
        guard !Task.isCancelled else { return }

        withAnimation(.easeOut(duration: 0.10)) {
            searchIconOffset = -3.5
        }
        try? await Task.sleep(nanoseconds: 95_000_000)

        guard !Task.isCancelled else { return }

        withAnimation(.spring(response: 0.22, dampingFraction: 0.46)) {
            searchIconOffset = 0
        }
        try? await Task.sleep(nanoseconds: 150_000_000)
    }
}

struct TodayAnalysisSignalChips: View {
    let mode: TodayMetricMode

    private var compactRows: [String] {
        switch mode {
        case .energy:
            return ["综合能量68%", "低谷14:00", "负担偏轻"]
        case .sleep:
            return ["睡眠7.2h", "深睡1.4h", "中断2次"]
        case .cycle:
            return ["黄体期", "Day18", "节奏稳定"]
        case .heart:
            return ["心率72", "波动稳定", "低负担"]
        case .hrv:
            return ["HRV48", "恢复偏低", "降强度"]
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(compactRows, id: \.self) { item in
                Text(item)
                    .font(.system(size: 11.2, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText.opacity(0.84))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, 8)
                    .frame(height: 28)
                    .background(VitoraTheme.ColorToken.paper.opacity(0.38), in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.48), lineWidth: 0.7))
            }
        }
        .accessibilityIdentifier("today.analysis.signal.chips")
    }
}

private struct BowlShape: InsettableShape {
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        var path = Path()
        let topY = rect.minY + rect.height * 0.13
        let leftTop = CGPoint(x: rect.minX + rect.width * 0.04, y: topY)
        let rightTop = CGPoint(x: rect.maxX - rect.width * 0.04, y: topY)
        let bottom = CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.04)

        path.move(to: leftTop)
        path.addLine(to: rightTop)
        path.addCurve(
            to: bottom,
            control1: CGPoint(x: rect.maxX - rect.width * 0.03, y: rect.minY + rect.height * 0.62),
            control2: CGPoint(x: rect.maxX - rect.width * 0.27, y: rect.maxY - rect.height * 0.01)
        )
        path.addCurve(
            to: leftTop,
            control1: CGPoint(x: rect.minX + rect.width * 0.27, y: rect.maxY - rect.height * 0.01),
            control2: CGPoint(x: rect.minX + rect.width * 0.03, y: rect.minY + rect.height * 0.62)
        )
        path.closeSubpath()
        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}

private struct BowlRimShape: Shape {
    func path(in rect: CGRect) -> Path {
        let topY = rect.minY + rect.height * 0.13
        let insetX = rect.width * 0.045
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + insetX, y: topY))
        path.addCurve(
            to: CGPoint(x: rect.maxX - insetX, y: topY + rect.height * 0.002),
            control1: CGPoint(x: rect.minX + rect.width * 0.30, y: topY - rect.height * 0.020),
            control2: CGPoint(x: rect.minX + rect.width * 0.70, y: topY + rect.height * 0.026)
        )
        return path
    }
}

private struct BowlFillLayer: Shape {
    let level: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let clamped = min(max(level, 0.12), 0.86)
        let fillTop = rect.maxY - rect.height * clamped

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: fillTop + rect.height * 0.04))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: fillTop),
            control1: CGPoint(x: rect.minX + rect.width * 0.28, y: fillTop - rect.height * 0.03),
            control2: CGPoint(x: rect.minX + rect.width * 0.66, y: fillTop + rect.height * 0.05)
                        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct BowlWaterSurface: Shape {
    let level: CGFloat

    func path(in rect: CGRect) -> Path {
        let clamped = min(max(level, 0.12), 0.86)
        let surfaceY = rect.maxY - rect.height * clamped
        let insetX = rect.width * 0.08
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + insetX, y: surfaceY + rect.height * 0.012))
        path.addCurve(
            to: CGPoint(x: rect.maxX - insetX, y: surfaceY),
            control1: CGPoint(x: rect.minX + rect.width * 0.32, y: surfaceY - rect.height * 0.025),
            control2: CGPoint(x: rect.minX + rect.width * 0.66, y: surfaceY + rect.height * 0.032)
        )
        return path
    }
}

private struct PixelMetricNumber: View {
    let text: String
    let mode: TodayMetricMode

    var body: some View {
        GeometryReader { proxy in
            let size = text.count > 2 ? min(86, proxy.size.width * 0.60) : min(96, proxy.size.width * 0.68)
            Text(text)
                .font(.system(size: size, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.66)
                .foregroundStyle(EnergyNumberStyle.numberGradient)
                .shadow(color: EnergyNumberStyle.glow.opacity(0.28), radius: 12, x: 0, y: 4)
                .shadow(color: Color.white.opacity(0.42), radius: 5, x: -1, y: -1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

private enum EnergyNumberStyle {
    static let glow = Color(red: 75 / 255, green: 142 / 255, blue: 228 / 255)
    static let numberGradient = LinearGradient(
        colors: [
            Color(red: 39 / 255, green: 104 / 255, blue: 203 / 255),
            Color(red: 92 / 255, green: 157 / 255, blue: 241 / 255),
            Color(red: 120 / 255, green: 190 / 255, blue: 248 / 255),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let unitGradient = LinearGradient(
        colors: [
            Color(red: 75 / 255, green: 139 / 255, blue: 230 / 255),
            Color(red: 113 / 255, green: 181 / 255, blue: 249 / 255),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

private struct EnergyBowlRainIntakeLayer: View {
    let mode: TodayMetricMode
    let trigger: Int
    let reduceMotion: Bool
    let impactPoint: CGPoint
    let waterSurfaceY: CGFloat
    @State private var isRunning = false
    @State private var startDate = Date()

    var body: some View {
        ZStack {
            if reduceMotion {
                Canvas { context, size in
                    drawSettledWaterGlow(context: &context, size: size)
                }
            } else if isRunning {
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let elapsed = timeline.date.timeIntervalSince(startDate)
                        let progress = min(max(elapsed / 1.95, 0), 1)
                        drawTopSource(context: &context, size: size, progress: progress)
                        drawFallingDrops(context: &context, size: size, progress: progress, time: elapsed)
                        drawImpactRipples(context: &context, size: size, progress: progress)
                    }
                }
            }

            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityElement()
                .accessibilityLabel("水滴从屏幕顶端落入能量碗")
                .accessibilityIdentifier("today.energy.intake.animation")
        }
        .onAppear {
            runAnimation()
        }
        .onChange(of: trigger) { _, _ in
            runAnimation()
        }
    }

    private func runAnimation() {
        guard !reduceMotion else {
            return
        }
        startDate = Date()
        isRunning = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_180_000_000)
            withAnimation(.easeOut(duration: 0.22)) {
                isRunning = false
            }
        }
    }

    private func drawTopSource(context: inout GraphicsContext, size: CGSize, progress: Double) {
        let alpha = max(0, 1 - progress * 1.45)
        let sourceRect = CGRect(x: size.width * 0.30, y: -18, width: size.width * 0.40, height: 38)
        context.fill(
            Path(ellipseIn: sourceRect),
            with: .color(mode.secondaryAccent.opacity(0.14 * alpha))
        )
    }

    private func drawFallingDrops(context: inout GraphicsContext, size: CGSize, progress: Double, time: TimeInterval) {
        let mainLocal = min(max(progress / 0.62, 0), 1)
        if mainLocal < 1 {
            let eased = easeInOut(mainLocal)
            let x = impactPoint.x + CGFloat(sin(time * 4.2)) * 7
            let y = -32 + (impactPoint.y + 6 + 32) * CGFloat(eased)
            drawDrop(
                context: &context,
                center: CGPoint(x: x, y: y),
                radius: 7.2,
                color: Color(red: 114 / 255, green: 202 / 255, blue: 255 / 255).opacity(0.74)
            )
        }

        for index in 0..<11 {
            let seed = Double(index + 1)
            let stagger = 0.04 + seed * 0.035
            let local = min(max((progress - stagger) / 0.58, 0), 1)
            guard local > 0, local < 1 else { continue }
            let randomX = pseudoRandom(seed)
            let xOffset = CGFloat((randomX - 0.5) * 118)
            let drift = CGFloat(sin(time * 3.8 + seed)) * 5
            let x = impactPoint.x + xOffset + drift
            let endY = impactPoint.y - CGFloat(index % 3) * 5
            let y = -24 + (endY + 24) * CGFloat(easeIn(local))
            let radius = CGFloat(2.3 + (seed.truncatingRemainder(dividingBy: 3)) * 0.75)
            drawDrop(
                context: &context,
                center: CGPoint(x: x, y: y),
                radius: radius,
                color: particleColor(index: index).opacity(0.40 + 0.28 * (1 - local))
            )
        }
    }

    private func drawImpactRipples(context: inout GraphicsContext, size: CGSize, progress: Double) {
        guard progress > 0.45 else { return }
        let splashLocal = min(max((progress - 0.45) / 0.42, 0), 1)
        let splashAlpha = max(0, 1 - splashLocal)
        for index in 0..<5 {
            let angle = Double(index) / 5.0 * .pi * 2
            let distance = CGFloat(10 + splashLocal * 22)
            let center = CGPoint(
                x: impactPoint.x + CGFloat(cos(angle)) * distance * 0.72,
                y: impactPoint.y + CGFloat(sin(angle)) * distance * 0.25
            )
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - 1.6, y: center.y - 1.6, width: 3.2, height: 3.2)),
                with: .color(Color.white.opacity(0.42 * splashAlpha))
            )
        }

        for index in 0..<3 {
            let local = min(max((progress - 0.48 - Double(index) * 0.10) / 0.48, 0), 1)
            guard local > 0 else { continue }
            let width = size.width * (0.15 + CGFloat(local) * 0.34)
            let height = CGFloat(5 + local * 11)
            let rect = CGRect(
                x: impactPoint.x - width / 2,
                y: waterSurfaceY - height / 2 + CGFloat(index) * 2,
                width: width,
                height: height
            )
            context.stroke(
                Path(ellipseIn: rect),
                with: .color(Color.white.opacity(0.36 * (1 - local))),
                lineWidth: 1.15
            )
        }
    }

    private func drawSettledWaterGlow(context: inout GraphicsContext, size: CGSize) {
        let rect = CGRect(x: size.width * 0.28, y: waterSurfaceY - 9, width: size.width * 0.44, height: 18)
        context.fill(Path(ellipseIn: rect), with: .color(mode.secondaryAccent.opacity(0.14)))
    }

    private func drawDrop(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, color: Color) {
        var path = Path()
        path.move(to: CGPoint(x: center.x, y: center.y - radius * 1.42))
        path.addCurve(
            to: CGPoint(x: center.x + radius, y: center.y + radius * 0.10),
            control1: CGPoint(x: center.x + radius * 0.72, y: center.y - radius * 0.70),
            control2: CGPoint(x: center.x + radius, y: center.y - radius * 0.24)
        )
        path.addCurve(
            to: CGPoint(x: center.x, y: center.y + radius * 1.16),
            control1: CGPoint(x: center.x + radius, y: center.y + radius * 0.80),
            control2: CGPoint(x: center.x + radius * 0.46, y: center.y + radius * 1.16)
        )
        path.addCurve(
            to: CGPoint(x: center.x - radius, y: center.y + radius * 0.10),
            control1: CGPoint(x: center.x - radius * 0.46, y: center.y + radius * 1.16),
            control2: CGPoint(x: center.x - radius, y: center.y + radius * 0.80)
        )
        path.addCurve(
            to: CGPoint(x: center.x, y: center.y - radius * 1.42),
            control1: CGPoint(x: center.x - radius, y: center.y - radius * 0.24),
            control2: CGPoint(x: center.x - radius * 0.72, y: center.y - radius * 0.70)
        )
        path.closeSubpath()
        context.fill(path, with: .color(color))

        context.fill(
            Path(ellipseIn: CGRect(x: center.x - radius * 0.28, y: center.y - radius * 0.60, width: radius * 0.34, height: radius * 0.52)),
            with: .color(Color.white.opacity(0.38))
        )
    }

    private func particleColor(index: Int) -> Color {
        index.isMultiple(of: 2) ? mode.secondaryAccent : VitoraTheme.ColorToken.auraCyan
    }

    private func pseudoRandom(_ seed: Double) -> Double {
        abs((sin(seed * 12.9898) * 43758.5453).truncatingRemainder(dividingBy: 1))
    }

    private func easeIn(_ value: Double) -> Double {
        value * value
    }

    private func easeInOut(_ value: Double) -> Double {
        value < 0.5 ? 2 * value * value : 1 - pow(-2 * value + 2, 2) / 2
    }
}
struct RealtimePredictionChart: View {
    let mode: TodayMetricMode

    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height
                let axisWidth: CGFloat = 28
                let rightPadding: CGFloat = 8
                let topPadding: CGFloat = 24
                let bottomPadding: CGFloat = 24
                let chartWidth = max(width - axisWidth - rightPadding, 1)
                let chartHeight = max(height - topPadding - bottomPadding, 1)
                let points = mode.forecastPoints
                let currentIndex = min(max(mode.currentForecastIndex, 0), points.count - 1)
                let currentPoint = points[currentIndex]
                let currentX = x(index: currentIndex, count: points.count, axisWidth: axisWidth, chartWidth: chartWidth)
                let currentY = y(level: currentPoint.level, topPadding: topPadding, chartHeight: chartHeight)

                ZStack(alignment: .topLeading) {
                    Canvas { context, _ in
                        let chartRect = CGRect(x: axisWidth, y: topPadding, width: chartWidth, height: chartHeight)
                        let midY = chartRect.midY

                        var baseline = Path()
                        baseline.move(to: CGPoint(x: chartRect.minX, y: currentY))
                        baseline.addLine(to: CGPoint(x: chartRect.maxX, y: currentY))
                        context.stroke(
                            baseline,
                            with: .color(VitoraTheme.ColorToken.secondaryText.opacity(0.20)),
                            style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [4, 7])
                        )

                        var middleGuide = Path()
                        middleGuide.move(to: CGPoint(x: chartRect.minX, y: midY))
                        middleGuide.addLine(to: CGPoint(x: chartRect.maxX, y: midY))
                        context.stroke(
                            middleGuide,
                            with: .color(Color.white.opacity(0.40)),
                            style: StrokeStyle(lineWidth: 0.8, lineCap: .round, dash: [2, 8])
                        )

                        var curve = Path()
                        for index in points.indices {
                            let point = CGPoint(
                                x: x(index: index, count: points.count, axisWidth: axisWidth, chartWidth: chartWidth),
                                y: y(level: points[index].level, topPadding: topPadding, chartHeight: chartHeight)
                            )
                            if index == 0 {
                                curve.move(to: point)
                            } else {
                                curve.addLine(to: point)
                            }
                        }
                        context.stroke(
                            curve,
                            with: .linearGradient(
                                Gradient(colors: [mode.secondaryAccent, mode.accent, mode.secondaryAccent.opacity(0.78)]),
                                startPoint: CGPoint(x: chartRect.minX, y: chartRect.midY),
                                endPoint: CGPoint(x: chartRect.maxX, y: chartRect.midY)
                            ),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                        )

                        var marker = Path()
                        marker.move(to: CGPoint(x: currentX, y: chartRect.minY))
                        marker.addLine(to: CGPoint(x: currentX, y: chartRect.maxY))
                        context.stroke(marker, with: .color(Color.white.opacity(0.76)), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                    }

                    ForEach(Array(mode.forecastAxisLabels.enumerated()), id: \.offset) { index, label in
                        Text(label)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.78))
                            .position(x: 8, y: axisLabelY(index: index, topPadding: topPadding, chartHeight: chartHeight))
                    }

                    ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                        let pointX = x(index: index, count: points.count, axisWidth: axisWidth, chartWidth: chartWidth)
                        let pointY = y(level: point.level, topPadding: topPadding, chartHeight: chartHeight)

                        Circle()
                            .fill(index == currentIndex ? mode.accent : Color.white.opacity(0.92))
                            .frame(width: index == currentIndex ? 10 : 6, height: index == currentIndex ? 10 : 6)
                            .overlay(Circle().stroke(index == currentIndex ? Color.white : mode.secondaryAccent.opacity(0.42), lineWidth: index == currentIndex ? 2 : 1))
                            .position(x: pointX, y: pointY)

                        Text(point.hour)
                            .font(.system(size: 8.5, weight: index == currentIndex ? .bold : .medium))
                            .foregroundStyle(index == currentIndex ? mode.accent : VitoraTheme.ColorToken.secondaryText.opacity(0.76))
                            .position(x: pointX, y: height - 8)
                    }

                    Text(mode.currentStatusBubble)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .padding(.horizontal, 8)
                        .frame(height: 23)
                        .background(VitoraTheme.ColorToken.paper.opacity(0.70), in: Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.70), lineWidth: 0.7))
                        .position(x: min(max(currentX, 66), width - 66), y: max(12, currentY - 18))
                        .accessibilityIdentifier("today.realtime.currentBubble")
                }
            }

            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityElement()
                .accessibilityLabel("实时预测，\(mode.currentStatusBubble)")
                .accessibilityIdentifier("today.realtime.chart")
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("实时预测，\(mode.currentStatusBubble)")
    }

    private func x(index: Int, count: Int, axisWidth: CGFloat, chartWidth: CGFloat) -> CGFloat {
        guard count > 1 else {
            return axisWidth + chartWidth / 2
        }
        return axisWidth + chartWidth * CGFloat(index) / CGFloat(count - 1)
    }

    private func y(level: CGFloat, topPadding: CGFloat, chartHeight: CGFloat) -> CGFloat {
        topPadding + chartHeight * min(max(level, 0.08), 0.92)
    }

    private func axisLabelY(index: Int, topPadding: CGFloat, chartHeight: CGFloat) -> CGFloat {
        switch index {
        case 0: return topPadding
        case 1: return topPadding + chartHeight / 2
        default: return topPadding + chartHeight
        }
    }
}

struct RhythmCurveView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("实时预测")
                .font(.caption.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            RealtimePredictionChart(mode: .energy)
                .frame(height: 112)
        }
        .padding(12)
        .background(GlassSurface(cornerRadius: 20, opacity: 0.56, shadowStrength: 0.18, variant: .cleanResting))
    }
}
