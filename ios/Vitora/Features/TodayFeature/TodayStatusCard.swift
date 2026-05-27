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

    var scoreValue: Int {
        switch self {
        case .energy: return 68
        case .sleep: return 72
        case .cycle: return 78
        case .heart: return 76
        case .hrv: return 48
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
        EnergyBowlWaterScale.fillLevel(forScore: scoreValue)
    }

    var showsDynamicCurve: Bool {
        self == .energy || self == .heart
    }

}

enum EnergyBowlWaterScale {
    static func fillLevel(forScore score: Int) -> CGFloat {
        let clampedScore = min(max(score, 0), 100)
        // Keep a visible shallow baseline while preserving a real 0...100 score mapping.
        return 0.04 + CGFloat(clampedScore) / 100 * 0.82
    }
}

enum TodayInsightTopic: String, CaseIterable, Identifiable, Hashable {
    case energy
    case sleep
    case period
    case nutrition

    var id: String { rawValue }

    static var launchOverride: TodayInsightTopic {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-vitoraUITestTopicSleep") { return .sleep }
        if arguments.contains("-vitoraUITestTopicPeriod") { return .period }
        if arguments.contains("-vitoraUITestTopicNutrition") { return .nutrition }
        return .energy
    }

    static var launchExpandedTopic: TodayInsightTopic? {
        ProcessInfo.processInfo.arguments.contains("-vitoraUITestExpandedTopic") ? launchOverride : nil
    }

    var title: String {
        switch self {
        case .energy: return "今日能量"
        case .sleep: return "睡眠"
        case .period: return "经期"
        case .nutrition: return "营养"
        }
    }

    var icon: String {
        switch self {
        case .energy: return "bolt.fill"
        case .sleep: return "moon.fill"
        case .period: return "drop.fill"
        case .nutrition: return "leaf.fill"
        }
    }

    var metric: String {
        switch self {
        case .energy: return "68/100"
        case .sleep: return "7.2h"
        case .period: return "D18"
        case .nutrition: return "水 5/8"
        }
    }

    var scoreNumber: String {
        switch self {
        case .energy: return "68"
        case .sleep: return "7.2"
        case .period: return "D18"
        case .nutrition: return "5/8"
        }
    }

    var scoreUnit: String {
        switch self {
        case .energy: return "/100"
        case .sleep: return "h"
        case .period: return ""
        case .nutrition: return "水"
        }
    }

    var ctaLabel: String {
        switch self {
        case .energy: return "查看分析"
        case .sleep: return "睡眠详情"
        case .period: return "阶段解释"
        case .nutrition: return "记录补给"
        }
    }

    var sourceTitle: String { title }

    var sourceSummary: String {
        switch self {
        case .energy: return "今日 68/100，恢复 65，燃料 75，黄体期 D18"
        case .sleep: return "昨夜睡眠 7.2h，深睡 1.4h，中断 2 次"
        case .period: return "黄体期 Day 18，今天适合留余量"
        case .nutrition: return "水 5/8，镁和 B6 仅记录已在使用内容"
        }
    }

    var recordSummary: String {
        switch self {
        case .energy: return "补充今天影响能量的事"
        case .sleep: return "补充昨晚睡眠或醒来感受"
        case .period: return "补充经期或黄体期身体变化"
        case .nutrition: return "记录已在使用的补给或补水"
        }
    }

    var analysisMode: TodayMetricMode {
        switch self {
        case .energy, .nutrition: return .energy
        case .sleep: return .sleep
        case .period: return .cycle
        }
    }

    var accent: Color {
        switch self {
        case .energy: return Color(red: 205 / 255, green: 127 / 255, blue: 22 / 255)
        case .sleep: return Color(red: 70 / 255, green: 134 / 255, blue: 220 / 255)
        case .period: return Color(red: 104 / 255, green: 157 / 255, blue: 74 / 255)
        case .nutrition: return Color(red: 61 / 255, green: 148 / 255, blue: 126 / 255)
        }
    }

    var softAccent: Color {
        switch self {
        case .energy: return Color(red: 255 / 255, green: 201 / 255, blue: 107 / 255)
        case .sleep: return Color(red: 221 / 255, green: 238 / 255, blue: 255 / 255)
        case .period: return Color(red: 224 / 255, green: 241 / 255, blue: 208 / 255)
        case .nutrition: return Color(red: 212 / 255, green: 244 / 255, blue: 232 / 255)
        }
    }

    var pillRotationDegrees: Double {
        switch self {
        case .energy: return 12
        case .sleep: return -4
        case .period: return -8
        case .nutrition: return -14
        }
    }

    var pillOffset: CGSize {
        switch self {
        case .energy: return CGSize(width: -62, height: -2)
        case .sleep: return CGSize(width: -72, height: -2)
        case .period: return CGSize(width: -72, height: 2)
        case .nutrition: return CGSize(width: -68, height: 6)
        }
    }
}

enum TodayChatMode: Equatable {
    case expanded
    case collapsed
}

enum TodayHeroVariant: String, CaseIterable {
    case v1, v2, v3

    var label: String {
        switch self {
        case .v1: return "V1 居中满展"
        case .v2: return "V2 信息并排"
        case .v3: return "V3 紧凑一体"
        }
    }
}

struct TodayStatusCard: View {
    @Binding var selectedTopic: TodayInsightTopic
    @Binding var expandedTopic: TodayInsightTopic?
    let cycleDay: Int
    let cyclePhase: String
    let eventTrigger: Int
    let onOpenDetail: () -> Void
    let onOpenEvidence: () -> Void
    let onAskVitora: () -> Void
    let onCalibrate: (String) -> Void
    let onQuickRecord: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private func eggExpression() -> PixelEggExpression {
        .from(phase: cyclePhase, energyScore: 68)
    }

    // MARK: - Compact Chat-First Layout

    var body: some View {
        VStack(spacing: 12) {
            Text("现在状态")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .accessibilityHidden(false)

            // Compact hero: egg left + score right (方案A chat-first)
            HStack(spacing: 16) {
                Button(action: onOpenDetail) {
                    PixelEggView(
                        size: 60,
                        expression: eggExpression(),
                        materialStyle: .blueCrystal
                    )
                    .shadow(color: Color(red: 119 / 255, green: 197 / 255, blue: 255 / 255).opacity(0.22), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("蓝晶 Pixel Egg，今日能量 \(selectedTopic.metric)")
                .accessibilityIdentifier("today.pixel.egg")

                Button(action: onOpenDetail) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text(selectedTopic.scoreNumber)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(selectedTopic.accent)
                                .monospacedDigit()
                            if !selectedTopic.scoreUnit.isEmpty {
                                Text(selectedTopic.scoreUnit)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                            }
                        }

                        HStack(spacing: 5) {
                            Text(selectedTopic.ctaLabel)
                                .font(.system(size: 14, weight: .semibold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(selectedTopic.accent)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(selectedTopic.metric) \(selectedTopic.ctaLabel)")
                .accessibilityIdentifier("today.status.card")

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
            .contextMenu {
                Button("问 Vitora 为什么", action: onAskVitora)
                Button("告诉 Vitora 这里不准") { onCalibrate("这里不准") }
                Button("查看分析", action: onOpenDetail)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 2)
        .animation(.easeOut(duration: 0.22), value: selectedTopic)
    }
}

struct TodayTopicStrip: View {
    @Binding var selectedTopic: TodayInsightTopic
    @Binding var expandedTopic: TodayInsightTopic?
    let onQuickRecord: () -> Void

    private let pillTopics: [TodayInsightTopic] = [.period, .sleep, .nutrition]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(pillTopics) { topic in
                let isActive = selectedTopic == topic
                Button {
                    withAnimation(.easeOut(duration: 0.22)) {
                        if isActive {
                            selectedTopic = .energy
                            expandedTopic = nil
                        } else {
                            selectedTopic = topic
                            expandedTopic = topic
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: topic.icon)
                            .font(.system(size: 14, weight: .semibold))
                        Text(topic.title)
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(isActive ? .white : VitoraTheme.ColorToken.strongText)
                    .padding(.horizontal, 18)
                    .frame(height: 38)
                    .background(
                        isActive
                            ? VitoraTheme.ColorToken.strongText
                            : Color.white.opacity(0.82),
                        in: Capsule()
                    )
                    .overlay(
                        isActive
                            ? nil
                            : Capsule().stroke(Color.black.opacity(0.08), lineWidth: 0.7)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(topic.title) \(topic.metric)")
                .accessibilityIdentifier("today.topic.\(topic.rawValue)")
            }

            Spacer(minLength: 0)
        }
        .accessibilityIdentifier("today.topic.strip")
    }
}

private struct TodayUnifiedOrbitArc: View {
    @Binding var selectedTopic: TodayInsightTopic
    @Binding var expandedTopic: TodayInsightTopic?
    let stageWidth: CGFloat
    let stageHeight: CGFloat
    let center: CGPoint
    let cycleDay: Int
    let reduceMotion: Bool
    let onQuickRecord: () -> Void

    private struct OrbitTopic: Identifiable {
        let topic: TodayInsightTopic
        let point: CGPoint

        var id: TodayInsightTopic { topic }
    }

    private var topicPositions: [OrbitTopic] {
        TodayInsightTopic.allCases.map { topic in
            OrbitTopic(
                topic: topic,
                point: TodayOrbitArcGeometry.point(
                    stageWidth: stageWidth,
                    stageHeight: stageHeight,
                    center: center,
                    angle: TodayOrbitArcGeometry.angle(for: topic)
                )
            )
        }
    }

    private var quickRecordPoint: CGPoint {
        TodayOrbitArcGeometry.point(
            stageWidth: stageWidth,
            stageHeight: stageHeight,
            center: center,
            angle: TodayOrbitArcGeometry.quickRecordAngle
        )
    }

    var body: some View {
        ZStack {
            TodayUnifiedOrbitTrack(
                stageWidth: stageWidth,
                stageHeight: stageHeight,
                center: center,
                expandedTopic: expandedTopic,
                cycleDay: cycleDay
            )

            ForEach(topicPositions) { item in
                TodayUnifiedOrbitTopicButton(
                    topic: item.topic,
                    isExpanded: expandedTopic == item.topic,
                    action: {
                        withTopicAnimation {
                            if expandedTopic == item.topic {
                                expandedTopic = nil
                            } else {
                                selectedTopic = item.topic
                                expandedTopic = item.topic
                            }
                        }
                    }
                )
                .position(item.point)
                .transition(.scale(scale: 0.92).combined(with: .opacity))
            }

            if let expandedTopic {
                TodayUnifiedOrbitArcInfoOverlay(
                    topic: expandedTopic,
                    stageWidth: stageWidth,
                    stageHeight: stageHeight,
                    center: center
                )
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.96)))
            }

            Button(action: onQuickRecord) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.94))
                        .frame(width: 54, height: 54)
                        .overlay(Circle().stroke(Color.black.opacity(0.07), lineWidth: 0.8))
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)

                    Image(systemName: "plus")
                        .font(.system(size: 23, weight: .medium))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                }
                .frame(width: 74, height: 74)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .position(quickRecordPoint)
            .accessibilityLabel("快捷记录")
            .accessibilityIdentifier("today.unifiedOrbit.quickRecord")
        }
        .animation(reduceMotion ? nil : .spring(response: 0.34, dampingFraction: 0.82), value: expandedTopic)
    }

    private func withTopicAnimation(_ updates: @escaping () -> Void) {
        if reduceMotion {
            updates()
        } else {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.82), updates)
        }
    }
}

private enum TodayOrbitArcGeometry {
    static let quickRecordAngle: CGFloat = 58
    private static let trackStartAngle: CGFloat = -108
    private static let trackEndAngle: CGFloat = 64

    static func angle(for topic: TodayInsightTopic) -> CGFloat {
        switch topic {
        case .energy: return -58
        case .sleep: return -32
        case .period: return -6
        case .nutrition: return 20
        }
    }

    static func segment(for topic: TodayInsightTopic) -> (start: CGFloat, end: CGFloat) {
        switch topic {
        case .energy: return (-108, -46)
        case .sleep: return (-50, -14)
        case .period: return (-24, 18)
        case .nutrition: return (0, 36)
        }
    }

    static func fullTrackPath(stageWidth: CGFloat, stageHeight: CGFloat, center: CGPoint) -> Path {
        arcPath(
            stageWidth: stageWidth,
            stageHeight: stageHeight,
            center: center,
            startAngle: trackStartAngle,
            endAngle: trackEndAngle,
            steps: 72
        )
    }

    static func selectedPath(for topic: TodayInsightTopic, stageWidth: CGFloat, stageHeight: CGFloat, center: CGPoint) -> Path {
        let segment = segment(for: topic)
        return arcPath(
            stageWidth: stageWidth,
            stageHeight: stageHeight,
            center: center,
            startAngle: segment.start,
            endAngle: segment.end,
            steps: 36
        )
    }

    static func point(stageWidth: CGFloat, stageHeight: CGFloat, center: CGPoint, angle: CGFloat) -> CGPoint {
        let ellipse = ellipse(stageWidth: stageWidth, stageHeight: stageHeight, center: center)
        let radians = angle * .pi / 180
        return CGPoint(
            x: ellipse.center.x + ellipse.radiusX * cos(radians),
            y: ellipse.center.y + ellipse.radiusY * sin(radians)
        )
    }

    static func tangentDegrees(stageWidth: CGFloat, stageHeight: CGFloat, center: CGPoint, angle: CGFloat) -> Double {
        let ellipse = ellipse(stageWidth: stageWidth, stageHeight: stageHeight, center: center)
        let radians = angle * .pi / 180
        let dx = -ellipse.radiusX * sin(radians)
        let dy = ellipse.radiusY * cos(radians)
        return Double(atan2(dy, dx) * 180 / .pi)
    }

    private static func arcPath(
        stageWidth: CGFloat,
        stageHeight: CGFloat,
        center: CGPoint,
        startAngle: CGFloat,
        endAngle: CGFloat,
        steps: Int
    ) -> Path {
        var path = Path()
        for index in 0...steps {
            let progress = CGFloat(index) / CGFloat(max(steps, 1))
            let angle = startAngle + (endAngle - startAngle) * progress
            let point = point(stageWidth: stageWidth, stageHeight: stageHeight, center: center, angle: angle)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }

    private static func ellipse(stageWidth: CGFloat, stageHeight: CGFloat, center: CGPoint) -> (center: CGPoint, radiusX: CGFloat, radiusY: CGFloat) {
        let radiusX = min(124, max(104, stageWidth * 0.33))
        let radiusY = min(156, max(142, stageHeight * 0.37))
        let ellipseX = min(stageWidth - radiusX - 30, center.x + 22)
        return (
            center: CGPoint(x: max(center.x + 8, ellipseX), y: center.y + 32),
            radiusX: radiusX,
            radiusY: radiusY
        )
    }
}

private struct TodayUnifiedOrbitTrack: View {
    let stageWidth: CGFloat
    let stageHeight: CGFloat
    let center: CGPoint
    let expandedTopic: TodayInsightTopic?
    let cycleDay: Int

    var body: some View {
        ZStack(alignment: .topLeading) {
            Canvas { context, _ in
                drawBaseRail(in: &context)
                drawExpandedRail(in: &context)
            }
        }
        .frame(width: stageWidth, height: stageHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("右侧统一半圆弧轨道，黄体期第 \(cycleDay) 天")
        .accessibilityIdentifier("today.unifiedOrbit.cycleArc")
    }

    private func drawBaseRail(in context: inout GraphicsContext) {
        let path = TodayOrbitArcGeometry.fullTrackPath(stageWidth: stageWidth, stageHeight: stageHeight, center: center)
        context.stroke(
            path,
            with: .color(Color.black.opacity(0.065)),
            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
        )
    }

    private func drawExpandedRail(in context: inout GraphicsContext) {
        guard let expandedTopic else { return }

        let path = TodayOrbitArcGeometry.selectedPath(
            for: expandedTopic,
            stageWidth: stageWidth,
            stageHeight: stageHeight,
            center: center
        )
        let segment = TodayOrbitArcGeometry.segment(for: expandedTopic)
        let start = TodayOrbitArcGeometry.point(stageWidth: stageWidth, stageHeight: stageHeight, center: center, angle: segment.start)
        let end = TodayOrbitArcGeometry.point(stageWidth: stageWidth, stageHeight: stageHeight, center: center, angle: segment.end)

        var shadowContext = context
        shadowContext.addFilter(.shadow(color: expandedTopic.accent.opacity(0.18), radius: 14, x: 0, y: 8))
        shadowContext.stroke(
            path,
            with: .color(Color.white.opacity(0.92)),
            style: StrokeStyle(lineWidth: 54, lineCap: .round, lineJoin: .round)
        )

        context.stroke(
            path,
            with: .linearGradient(
                Gradient(colors: [
                    Color.white.opacity(0.98),
                    expandedTopic.softAccent.opacity(0.72),
                    Color.white.opacity(0.88),
                ]),
                startPoint: start,
                endPoint: end
            ),
            style: StrokeStyle(lineWidth: 48, lineCap: .round, lineJoin: .round)
        )
    }
}

private struct TodayUnifiedOrbitArcInfoOverlay: View {
    let topic: TodayInsightTopic
    let stageWidth: CGFloat
    let stageHeight: CGFloat
    let center: CGPoint

    var body: some View {
        let segment = TodayOrbitArcGeometry.segment(for: topic)
        let iconAngle = segment.start + 6
        let valueAngle: CGFloat = {
            switch topic {
            case .nutrition:
                return segment.start + 27
            default:
                return segment.end - 12
            }
        }()
        let iconPoint = TodayOrbitArcGeometry.point(stageWidth: stageWidth, stageHeight: stageHeight, center: center, angle: iconAngle)
        let valuePoint = TodayOrbitArcGeometry.point(stageWidth: stageWidth, stageHeight: stageHeight, center: center, angle: valueAngle)
        let valueRotation = TodayOrbitArcGeometry.tangentDegrees(stageWidth: stageWidth, stageHeight: stageHeight, center: center, angle: valueAngle)

        ZStack {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.96))
                    .frame(width: 42, height: 42)
                    .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 1))
                    .shadow(color: topic.accent.opacity(0.16), radius: 8, x: 0, y: 5)

                Image(systemName: topic.icon)
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(topic.accent)
            }
            .position(iconPoint)

            Text(topic.metric)
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundStyle(VitoraTheme.ColorToken.strongText.opacity(0.88))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .fixedSize(horizontal: true, vertical: false)
                .rotationEffect(.degrees(valueRotation))
                .shadow(color: Color.white.opacity(0.84), radius: 5, x: 0, y: 1)
                .position(valuePoint)
        }
        .frame(width: stageWidth, height: stageHeight)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct TodayUnifiedOrbitTopicButton: View {
    let topic: TodayInsightTopic
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isExpanded {
                    Color.clear
                        .frame(width: 60, height: 60)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.92))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.07), lineWidth: 0.7)
                        )
                        .shadow(color: topic.accent.opacity(0.08), radius: 6, x: 0, y: 5)

                    Image(systemName: topic.icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }
            }
            .frame(width: 70, height: 70)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(topic.title) \(topic.metric)")
        .accessibilityValue(isExpanded ? "已展开" : "未展开")
        .accessibilityIdentifier("today.unifiedOrbit.\(topic.rawValue)")
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

// MARK: - Bezier Orbit Arc (right side of bowl)

struct OrbitCascadeArc: View {
    @Binding var selectedMode: TodayMetricMode
    let onTapPlus: () -> Void

    // Amber palette (spec §2)
    private let amberActive = Color(red: 250/255, green: 199/255, blue: 117/255) // #FAC775
    private let amberBorder = Color(red: 186/255, green: 117/255, blue: 23/255)  // #BA7517
    private let darkBg = Color(red: 44/255, green: 44/255, blue: 42/255)         // #2C2C2A

    private struct OrbitItem: Identifiable {
        let id: TodayMetricMode?
        let icon: String
        let label: String
    }

    private let items: [OrbitItem] = [
        OrbitItem(id: .energy, icon: "bolt.fill", label: "能量"),
        OrbitItem(id: .sleep, icon: "moon.fill", label: "睡眠"),
        OrbitItem(id: .cycle, icon: "drop.fill", label: "经期"),
        OrbitItem(id: nil, icon: "plus", label: "+"),
    ]

    // Spec §4.4: Exact positions (right-aligned, from container trailing edge)
    // Position 1: top=76, right=38; Position 2: top=132, right=12 (apex)
    // Position 3: top=196, right=12; Position 4: top=250, right=38
    private func position(index: Int, in size: CGSize) -> CGPoint {
        let positions: [(top: CGFloat, right: CGFloat)] = [
            (76, 38), (132, 12), (196, 12), (250, 38)
        ]
        let p = positions[min(index, positions.count - 1)]
        return CGPoint(x: size.width - p.right - 19, y: p.top)
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            // Faint bezier arc path (spec: M268,88 Q312,178 264,270 mapped to frame)
            Path { path in
                let p0 = position(index: 0, in: size)
                let apex = CGPoint(x: size.width - 12 + 10, y: (position(index: 1, in: size).y + position(index: 2, in: size).y) / 2)
                let p3 = position(index: 3, in: size)
                path.move(to: p0)
                path.addQuadCurve(to: p3, control: apex)
            }
            .stroke(Color(red: 0, green: 0, blue: 0).opacity(0.06), style: StrokeStyle(lineWidth: 1, dash: [4, 6]))

            // Orbit dots
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                let pos = position(index: index, in: size)
                let isSelected = item.id == selectedMode
                let isPlus = item.id == nil
                let dotSize: CGFloat = isSelected ? 42 : 38

                Button {
                    if let mode = item.id {
                        withAnimation(.easeOut(duration: 0.2)) { selectedMode = mode }
                    } else {
                        onTapPlus()
                    }
                } label: {
                    ZStack {
                        if isPlus {
                            Circle()
                                .fill(darkBg)
                                .frame(width: dotSize, height: dotSize)
                        } else {
                            Circle()
                                .fill(isSelected ? amberActive : Color.white)
                                .frame(width: dotSize, height: dotSize)
                            Circle()
                                .stroke(
                                    isSelected ? amberBorder : Color.black.opacity(0.08),
                                    lineWidth: isSelected ? 1.5 : 0.5
                                )
                                .frame(width: dotSize, height: dotSize)
                        }

                        Image(systemName: isPlus ? "plus" : item.icon)
                            .font(.system(size: isPlus ? 15 : 14, weight: .medium))
                            .foregroundStyle(isPlus ? .white : (isSelected ? amberBorder : Color(red: 95/255, green: 94/255, blue: 90/255)))
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 44, height: 44)
                .position(pos)
                .accessibilityLabel(item.label)
            }
        }
        .allowsHitTesting(true)
    }
}

// MARK: - Top 3-Cell Mode Selector

// MARK: - Top Banana Pill — 3-cell selector (spec §4.1)

struct TopModeSelector: View {
    @Binding var selectedMode: TodayMetricMode

    // Spec colors
    private let pillBg = Color(red: 44/255, green: 44/255, blue: 42/255)       // #2C2C2A
    private let amberFill = Color(red: 250/255, green: 199/255, blue: 117/255)  // #FAC775
    private let inactiveStroke = Color.white.opacity(0.55)

    private struct SelectorCell: Identifiable {
        let id: TodayMetricMode
        let icon: String
        let label: String
    }

    private let cells: [SelectorCell] = [
        SelectorCell(id: .energy, icon: "bolt.fill", label: "能量"),
        SelectorCell(id: .sleep, icon: "moon.fill", label: "睡眠"),
        SelectorCell(id: .cycle, icon: "drop.fill", label: "经期"),
    ]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(cells) { cell in
                let isActive = selectedMode == cell.id
                let cellSize: CGFloat = isActive ? 28 : 24

                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        selectedMode = cell.id
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(isActive ? amberFill : Color.clear)
                            .frame(width: cellSize, height: cellSize)

                        if !isActive {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(inactiveStroke, lineWidth: 1.4)
                                .frame(width: cellSize, height: cellSize)
                        }

                        if isActive {
                            Text(cell.icon == "bolt.fill" ? "⚡" : cell.icon == "moon.fill" ? "🌙" : "🩸")
                                .font(.system(size: 14))
                        }
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 44, height: 44)
                .accessibilityLabel(cell.label)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(pillBg)
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        )
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
