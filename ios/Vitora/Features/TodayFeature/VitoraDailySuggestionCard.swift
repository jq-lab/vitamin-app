import SwiftUI

struct TodayInsightPanel: View {
    let topic: TodayInsightTopic
    var cycleDay: Int = 18
    var cyclePhase: String = "黄体期"
    let onOpenAnalysis: () -> Void
    let onRecord: (TodayInsightTopic) -> Void
    let onAskVitora: () -> Void
    @State private var showsReasons = ProcessInfo.processInfo.arguments.contains("-vitoraUITestEnergyReasons")
    @State private var showReminder = false

    private var reminderPlan: TodaySuggestionPlan {
        TodaySuggestionPlan.all[0]
    }

    private var subtitle: String {
        switch topic {
        case .energy: return "\(cyclePhase)D\(cycleDay) · 偏低"
        case .sleep: return "昨夜恢复 · 今日节奏参考"
        case .period: return "\(cyclePhase) Day \(cycleDay)"
        case .nutrition: return "补水与已在使用补给"
        }
    }

    private var trailingSummary: String {
        switch topic {
        case .energy: return "恢复 65 · 燃料 75"
        case .sleep: return "7.2h · 中断 2 次"
        case .period: return "预计 8 天后"
        case .nutrition: return "水 5/8 · 镁未记"
        }
    }

    var body: some View {
        AskableSurface(
            accessibilityID: "today.insight.panel",
            onOpenDetail: toggleEnergyReasonsOrOpenAnalysis,
            onAskVitora: onAskVitora,
            onCorrectVitora: onAskVitora
        ) {
            VStack(alignment: .leading, spacing: 15) {
                header

                switch topic {
                case .energy:
                    energyContent
                case .sleep:
                    sleepContent
                case .period:
                    periodContent
                case .nutrition:
                    nutritionContent
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(TodaySuggestionShell())
        }
        .sheet(isPresented: $showReminder) {
            ReminderSetupSheet(plan: reminderPlan, onClose: { showReminder = false })
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
        .onChange(of: topic) { _ in
            showsReasons = false
        }
        .accessibilityIdentifier("today.insight.panel.\(topic.rawValue)")
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Button(action: toggleEnergyReasonsOrOpenAnalysis) {
                    HStack(spacing: 6) {
                        Text(topic.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.black)
                        if topic == .energy {
                            Image(systemName: showsReasons ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(topic.accent)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("today.insight.title")

                Text(subtitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 7) {
                Text(trailingSummary)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                if topic == .energy {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showsReasons.toggle()
                        }
                    } label: {
                        Text(showsReasons ? "收起" : "为什么")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(topic.accent)
                            .padding(.horizontal, 10)
                            .frame(height: 28)
                            .background(topic.softAccent.opacity(0.42), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("today.insight.why")
                }
            }
        }
    }

    private var energyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 18) {
                TodayInsightRing(value: 65, title: "恢复", footnote: "睡眠 6h12m", tint: Color(red: 245 / 255, green: 160 / 255, blue: 35 / 255))
                TodayInsightRing(value: 75, title: "燃料", footnote: "水 5/8 杯", tint: Color(red: 49 / 255, green: 139 / 255, blue: 224 / 255))
                TodayInsightRing(value: 40, title: "活动", footnote: "步数 3.2k", tint: Color(red: 86 / 255, green: 155 / 255, blue: 43 / 255))
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: 9) {
                TodayInsightChip(text: "水", isSelected: true)
                TodayInsightChip(text: "镁", isSelected: false)
                TodayInsightChip(text: "铁", isSelected: false)
                TodayInsightChip(text: "B6", isSelected: false)
            }

            VitoraYellowHint(text: "VITORA: 下午容易掉电，HRV↓8%。先补镁还是先小睡？")

            if showsReasons {
                VStack(alignment: .leading, spacing: 10) {
                    TodayInsightReasonRow(symbol: "moon.zzz.fill", text: "昨夜恢复只到 65，午后更容易出现低谷。")
                    TodayInsightReasonRow(symbol: "waveform.path.ecg", text: "HRV 比平时低 8%，今天更适合降低刺激。")
                    TodayInsightReasonRow(symbol: "drop.fill", text: "补水 5/8 杯，燃料够用但还没满。")

                    Text("建议：先补水和已在使用的镁；如果 14:00 后仍明显掉电，安排 15 分钟安静恢复。")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineSpacing(3)
                }
                .padding(14)
                .background(Color(red: 255 / 255, green: 252 / 255, blue: 244 / 255), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.black.opacity(0.06), lineWidth: 0.6))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            footer(scoreText: "今日 68/100")
        }
    }

    private var sleepContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                TodayInsightMetricBox(title: "时长", value: "7.2h", detail: "比目标少 38m", tint: topic.accent)
                TodayInsightMetricBox(title: "深睡", value: "1.4h", detail: "恢复略浅", tint: Color(red: 79 / 255, green: 181 / 255, blue: 201 / 255))
                TodayInsightMetricBox(title: "中断", value: "2次", detail: "凌晨偏多", tint: Color(red: 135 / 255, green: 130 / 255, blue: 221 / 255))
            }

            VitoraYellowHint(text: "VITORA: 睡眠不算差，但恢复感没有满。今天先把午后安排做轻一点。")

            TodayInsightReasonRow(symbol: "heart.text.square.fill", text: "依据会结合睡眠、HRV 和黄体期 D18，不把单一指标当结论。")

            footer(scoreText: "睡眠 7.2h")
        }
    }

    private var periodContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                TodayInsightMetricBox(title: "阶段", value: "D18", detail: cyclePhase, tint: topic.accent)
                TodayInsightMetricBox(title: "窗口", value: "8天", detail: "距下次经期", tint: Color(red: 214 / 255, green: 142 / 255, blue: 80 / 255))
                TodayInsightMetricBox(title: "节律", value: "留余量", detail: "午后放慢", tint: Color(red: 100 / 255, green: 151 / 255, blue: 205 / 255))
            }

            VitoraYellowHint(text: "VITORA: 黄体期中段更容易对睡眠和补给敏感，今天不用硬把节奏拉满。")

            VStack(alignment: .leading, spacing: 8) {
                TodayInsightReasonRow(symbol: "calendar", text: "当前 D18 只解释周期位置，不做医学诊断。")
                TodayInsightReasonRow(symbol: "slider.horizontal.3", text: "如果今天体感和预测不一致，可以告诉 Vitora 校准。")
            }

            footer(scoreText: "\(cyclePhase) D\(cycleDay)")
        }
    }

    private var nutritionContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                TodayInsightMetricBox(title: "水", value: "5/8", detail: "还差 3 杯", tint: topic.accent)
                TodayInsightMetricBox(title: "镁", value: "未记", detail: "可补充记录", tint: Color(red: 129 / 255, green: 121 / 255, blue: 212 / 255))
                TodayInsightMetricBox(title: "B6", value: "未记", detail: "仅记录", tint: Color(red: 214 / 255, green: 142 / 255, blue: 80 / 255))
            }

            HStack(spacing: 9) {
                TodayInsightChip(text: "水 5/8", isSelected: true)
                TodayInsightChip(text: "镁", isSelected: false)
                TodayInsightChip(text: "B6", isSelected: false)
            }

            VitoraYellowHint(text: "VITORA: 这里只记录你已经在使用的补给和补水，不推荐购买，也不替代专业建议。")

            footer(scoreText: "水 5/8")
        }
    }

    private func footer(scoreText: String) -> some View {
        HStack {
            Button {
                onRecord(topic)
            } label: {
                HStack(spacing: 9) {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .medium))
                    Text("记一笔")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .frame(height: 56)
                .background(VitoraTheme.ColorToken.strongText, in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("today.insight.record")

            if topic == .energy && showsReasons {
                Button {
                    showReminder = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                        Text("提醒")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundStyle(topic.accent)
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(topic.softAccent.opacity(0.38), in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("today.insight.reminder")
            }

            Spacer()

            Text(scoreText)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .minimumScaleFactor(0.75)
                .lineLimit(1)
        }
    }

    private func toggleEnergyReasonsOrOpenAnalysis() {
        if topic == .energy {
            withAnimation(.easeInOut(duration: 0.2)) {
                showsReasons.toggle()
            }
        } else {
            onOpenAnalysis()
        }
    }
}

private struct TodayInsightRing: View {
    let value: Int
    let title: String
    let footnote: String
    let tint: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(tint.opacity(0.18), lineWidth: 9)
                Circle()
                    .trim(from: 0, to: CGFloat(value) / 100)
                    .stroke(tint, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(value)%")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(tint)
                    .monospacedDigit()
            }
            .frame(width: 82, height: 82)

            VStack(spacing: 1) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.black)
                Text(footnote)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(width: 92)
        }
    }
}

private struct TodayInsightChip: View {
    let text: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isSelected ? "checkmark" : "circle")
                .font(.system(size: 12, weight: .bold))
            Text(text)
                .font(.system(size: 14, weight: .bold))
        }
        .foregroundStyle(isSelected ? Color(red: 26 / 255, green: 106 / 255, blue: 92 / 255) : VitoraTheme.ColorToken.secondaryText)
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(isSelected ? Color(red: 216 / 255, green: 247 / 255, blue: 237 / 255) : Color(red: 241 / 255, green: 239 / 255, blue: 234 / 255), in: Capsule())
    }
}

private struct VitoraYellowHint: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(Color(red: 154 / 255, green: 91 / 255, blue: 15 / 255))
            .lineSpacing(4)
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 255 / 255, green: 241 / 255, blue: 210 / 255), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct TodayInsightReasonRow: View {
    let symbol: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .frame(width: 18, height: 18)
            Text(text)
                .font(.system(size: 13.5, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct TodayInsightMetricBox: View {
    let title: String
    let value: String
    let detail: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            Text(value)
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(detail)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 250 / 255, green: 249 / 255, blue: 246 / 255), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.black.opacity(0.06), lineWidth: 0.6))
    }
}

struct VitoraDailySuggestionCard: View {
    var mode: TodayMetricMode = .energy
    var cycleDay: Int = 18
    var cyclePhase: String = "黄体期"
    let onCommit: () -> Void
    let onOpenDetail: () -> Void
    let onAskVitora: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var suggestionIndex = 0
    @State private var showReminder = false

    private var currentPlan: TodaySuggestionPlan {
        TodaySuggestionPlan.all[suggestionIndex % TodaySuggestionPlan.all.count]
    }

    var body: some View {
        AskableSurface(
            accessibilityID: "today.suggestion.card",
            onOpenDetail: onOpenDetail,
            onAskVitora: onAskVitora,
            onCorrectVitora: onAskVitora
        ) {
            VStack(alignment: .leading, spacing: 13) {
                HStack(spacing: 10) {
                    PixelMorningSunMark(size: 38, tint: mode.accent)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("智能监测")
                            .font(.system(size: 21, weight: .medium))
                            .foregroundStyle(Color(red: 44/255, green: 44/255, blue: 42/255))
                        Text("身体翻译器正在整理管家方案")
                            .font(.system(size: 11.5, weight: .regular))
                            .foregroundStyle(Color(red: 95/255, green: 94/255, blue: 90/255))
                    }

                    Spacer(minLength: 0)
                }

                SmartMonitorPokerPanel(
                    plan: currentPlan,
                    cycleDay: cycleDay,
                    cyclePhase: cyclePhase,
                    onSwap: rotateSuggestion,
                    onReminder: { showReminder = true }
                )
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 14)
            .background(TodaySuggestionShell())
        }
        .sheet(isPresented: $showReminder) {
            ReminderSetupSheet(plan: currentPlan, onClose: { showReminder = false })
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
    }

    private func rotateSuggestion() {
        let nextIndex = (suggestionIndex + 1) % TodaySuggestionPlan.all.count
        if reduceMotion {
            suggestionIndex = nextIndex
        } else {
            withAnimation(.easeInOut(duration: 0.22)) {
                suggestionIndex = nextIndex
            }
        }
    }
}

// Spec §6: bg #FFFFFF, border 0.5px tertiary, shadow subtle
private struct TodaySuggestionShell: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

private struct SuggestionInsetPanel: View {
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        VitoraTheme.ColorToken.surfacePearlMain.opacity(0.68),
                        VitoraTheme.ColorToken.surfacePearlInset.opacity(0.42),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(.ultraThinMaterial.opacity(0.24), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.72), lineWidth: 0.8)
            )
            .shadow(color: Color.white.opacity(0.70), radius: 6, x: -3, y: -3)
            .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.10), radius: 10, x: 0, y: 7)
    }
}

private struct PixelMorningSunMark: View {
    var size: CGFloat
    var tint: Color
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isLit = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 255 / 255, green: 251 / 255, blue: 236 / 255).opacity(0.92),
                            Color(red: 255 / 255, green: 215 / 255, blue: 108 / 255).opacity(0.44),
                            tint.opacity(0.18),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                        .stroke(Color.white.opacity(0.82), lineWidth: 0.8)
                )
                .shadow(color: Color(red: 255 / 255, green: 193 / 255, blue: 83 / 255).opacity(isLit ? 0.28 : 0.14), radius: isLit ? 12 : 7, x: 0, y: 4)

            Canvas { context, canvasSize in
                let side = min(canvasSize.width, canvasSize.height)
                let unit = side / 14
                let xOffset = (canvasSize.width - side) / 2
                let yOffset = (canvasSize.height - side) / 2

                func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: Color) {
                    let pixelRect = CGRect(x: xOffset + x * unit, y: yOffset + y * unit, width: w * unit, height: h * unit)
                    context.fill(Path(pixelRect), with: .color(color))
                }

                let sun = Color(red: 255 / 255, green: 196 / 255, blue: 67 / 255)
                let sunLight = Color(red: 255 / 255, green: 230 / 255, blue: 112 / 255)
                let ray = Color(red: 255 / 255, green: 183 / 255, blue: 84 / 255).opacity(0.86)
                let horizon = Color(red: 103 / 255, green: 177 / 255, blue: 226 / 255).opacity(0.72)

                rect(6, 1, 2, 2, ray)
                rect(3, 3, 1, 2, ray)
                rect(10, 3, 1, 2, ray)
                rect(2, 6, 2, 1, ray)
                rect(10, 6, 2, 1, ray)
                rect(5, 4, 4, 4, sun)
                rect(6, 5, 2, 2, sunLight)
                rect(3, 9, 8, 1, horizon)
                rect(2, 10, 10, 1, horizon.opacity(0.52))
                rect(4, 11, 6, 1, Color.white.opacity(0.70))
            }
            .padding(size * 0.13)
            .scaleEffect(isLit && !reduceMotion ? 1.035 : 1)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                isLit = true
            }
        }
    }
}

private enum SmartMonitorPane: Equatable {
    case push
    case cycleLog
}

private struct SmartMonitorPokerPanel: View {
    let plan: TodaySuggestionPlan
    let cycleDay: Int
    let cyclePhase: String
    let onSwap: () -> Void
    let onReminder: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var activePane: SmartMonitorPane = CommandLine.arguments.contains("-vitoraUITestSmartMonitorLog") ? .cycleLog : .push

    private var cycleAdvice: CycleSuggestionAdvice {
        CycleSuggestionAdvice.make(phase: cyclePhase, day: cycleDay, plan: plan)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 14) {
                SmartMonitorRecommendationIntro(
                    cycleDay: cycleDay,
                    cyclePhase: cyclePhase,
                    plan: plan
                )

                SmartMonitorEmbeddedSwitchPanel(
                    activePane: $activePane,
                    plan: plan,
                    cycleAdvice: cycleAdvice,
                    onSelectPane: selectPane
                )

                // Spec §6: dual CTA — 换一换 transparent+border, 一键提醒 amber
                HStack(spacing: 10) {
                    Button(action: leftAction) {
                        HStack(spacing: 5) {
                            Image(systemName: activePane == .push ? "arrow.triangle.2.circlepath" : "arrow.left")
                                .font(.system(size: 12, weight: .medium))
                            Text(activePane == .push ? "换一换" : "回到推送")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(Color(red: 44/255, green: 44/255, blue: 42/255))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.clear)
                        .overlay(Capsule().stroke(Color.black.opacity(0.10), lineWidth: 0.5))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("today.suggestion.swap")

                    Button(action: onReminder) {
                        HStack(spacing: 6) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 12, weight: .medium))
                            Text("一键提醒")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(Color(red: 44/255, green: 44/255, blue: 42/255))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color(red: 250/255, green: 199/255, blue: 117/255), in: Capsule()) // #FAC775
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("today.suggestion.remind")
                }
            }

            SmartMonitorCornerSignal(phase: cyclePhase, day: cycleDay)
                .padding(.top, 10)
                .padding(.trailing, 18)
                .accessibilityHidden(true)
        }
        .padding(14)
        .background(SmartMonitorInnerPanelBackground())
        .contentShape(BrokenCornerCardShape())
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("today.suggestion.combination.card")
    }

    private func selectPane(_ pane: SmartMonitorPane) {
        if reduceMotion {
            activePane = pane
        } else {
            withAnimation(.easeInOut(duration: 0.22)) {
                activePane = pane
            }
        }
    }

    private func leftAction() {
        if activePane == .push {
            onSwap()
        } else {
            selectPane(.push)
        }
    }
}

private struct SmartMonitorRecommendationIntro: View {
    let cycleDay: Int
    let cyclePhase: String
    let plan: TodaySuggestionPlan

    private var primaryCopy: String {
        "今天是\(cyclePhase)第\(cycleDay)天，你可能午后更容易掉电。"
    }

    private var secondaryCopy: String {
        "监测到昨晚睡眠略晚，先补给再安排安静恢复。"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("个性化推荐")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .lineLimit(1)

            Text(primaryCopy)
                .font(.system(size: 16.2, weight: .heavy, design: .rounded))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineLimit(2)
                .minimumScaleFactor(0.84)
                .lineSpacing(1)

            Text(secondaryCopy)
                .font(.system(size: 12.2, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .accessibilityHint(plan.rationale)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.trailing, 112)
        .padding(.top, 2)
    }
}

private struct SmartMonitorCornerSignal: View {
    let phase: String
    let day: Int

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)

            Text("D\(day)")
                .font(.system(size: 10.5, weight: .black, design: .rounded).monospacedDigit())
                .foregroundStyle(VitoraTheme.ColorToken.strongText.opacity(0.82))
                .lineLimit(1)
        }
        .frame(width: 48, height: 42)
        .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(Color.white.opacity(0.72), lineWidth: 0.65))
    }
}

private struct SmartMonitorEmbeddedSwitchPanel: View {
    @Binding var activePane: SmartMonitorPane
    let plan: TodaySuggestionPlan
    let cycleAdvice: CycleSuggestionAdvice
    let onSelectPane: (SmartMonitorPane) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                SmartMonitorPaneTab(
                    title: "今日推送",
                    systemImage: "sparkles",
                    isSelected: activePane == .push
                ) {
                    onSelectPane(.push)
                }

                SmartMonitorPaneTab(
                    title: "LOG",
                    systemImage: "doc.text.magnifyingglass",
                    isSelected: activePane == .cycleLog
                ) {
                    onSelectPane(.cycleLog)
                }
                .frame(width: 84)
            }
            .padding(.horizontal, 0)
            .padding(.bottom, 10)
            .zIndex(2)

            ZStack {
                SmartMonitorPushPane(plan: plan)
                    .opacity(activePane == .push ? 1 : 0)
                    .offset(x: activePane == .push ? 0 : -12)
                    .accessibilityHidden(activePane != .push)

                SmartMonitorCycleLogPane(plan: plan, advice: cycleAdvice)
                    .opacity(activePane == .cycleLog ? 1 : 0)
                    .offset(x: activePane == .cycleLog ? 0 : 12)
                    .accessibilityHidden(activePane != .cycleLog)
            }
            .frame(height: 142)
            .padding(.horizontal, 10)
            .clipped()
            .zIndex(1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("today.suggestion.switch.panel")
    }
}

private struct SmartMonitorPaneTab: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 11, weight: .heavy))
                Text(title)
                    .font(.system(size: 12.5, weight: .heavy))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
            .foregroundStyle(isSelected ? VitoraTheme.ColorToken.strongText : VitoraTheme.ColorToken.secondaryText)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) {
                Capsule()
                    .fill(isSelected ? VitoraTheme.ColorToken.actionPrimaryDeep : Color.clear)
                    .frame(width: 24, height: 3)
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .accessibilityIdentifier(title == "LOG" ? "today.suggestion.log" : "today.suggestion.push")
    }
}

private struct SmartMonitorPushPane: View {
    let plan: TodaySuggestionPlan

    private var primaryItem: TodaySuggestionPlan.Item? {
        plan.items.first
    }

    private var supportItem: TodaySuggestionPlan.Item? {
        plan.items.dropFirst().first
    }

    private var actionLine: String {
        guard let primaryItem else { return plan.rationale }
        if let supportItem {
            return "\(primaryItem.shortTimeText) \(primaryItem.reminderAction)，\(supportItem.shortTimeText) \(supportItem.reminderAction)"
        }
        return "\(primaryItem.shortTimeText) \(primaryItem.reminderAction)"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            if let primaryItem {
                SuggestionMetricIcon(kind: primaryItem.kind, tint: primaryItem.tint, size: 34)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("今日 \(plan.themeTitle)")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(actionLine)
                    .font(.system(size: 12.5, weight: .heavy).monospacedDigit())
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)

                HStack(spacing: 7) {
                    ForEach(plan.sources.prefix(3), id: \.title) { source in
                        CycleLogChip(icon: source.kind.symbol, text: source.title)
                    }
                }

                Text(plan.rationale)
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("today.suggestion.push.pane")
    }
}

private struct SmartMonitorCycleLogPane: View {
    let plan: TodaySuggestionPlan
    let advice: CycleSuggestionAdvice

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                SuggestionMetricIcon(kind: .cycle, tint: SuggestionSignalKind.cycle.tint, size: 34)

                VStack(alignment: .leading, spacing: 4) {
                    Text(advice.phaseText)
                        .font(.system(size: 12.5, weight: .heavy).monospacedDigit())
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)

                    Text(advice.title)
                        .font(.system(size: 23, weight: .black, design: .rounded))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(advice.action)
                        .font(.system(size: 12.5, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 7) {
                CycleLogChip(icon: "moon.fill", text: "睡眠略低")
                CycleLogChip(icon: "waveform.path.ecg", text: "HRV 下降")
                CycleLogChip(icon: "clock", text: "14:00 低谷")
            }

            Text("Vitora 把周期位置、睡眠和恢复信号合在一起，只建议先留余量。")
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(advice.phaseText)，\(advice.title)，\(advice.action)。睡眠略低，HRV 下降，14点低谷。")
        .accessibilityIdentifier("today.suggestion.cycleLog.pane")
    }
}

private struct CycleLogChip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9.5, weight: .bold))
            Text(text)
                .font(.system(size: 10.5, weight: .heavy))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
        .padding(.horizontal, 7)
        .frame(height: 25)
        .background(Color.white.opacity(0.58), in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.64), lineWidth: 0.6))
    }
}

private struct SmartMonitorInnerPanelBackground: View {
    var body: some View {
        BrokenCornerCardShape()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.90),
                        VitoraTheme.ColorToken.surfacePearlMain.opacity(0.78),
                        Color(red: 242 / 255, green: 248 / 255, blue: 247 / 255).opacity(0.52),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                BrokenCornerCardShape()
                    .stroke(Color.white.opacity(0.88), lineWidth: 0.9)
            )
            .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.08), radius: 12, x: 0, y: 7)
    }
}

private struct BrokenCornerCardShape: Shape {
    var cornerRadius: CGFloat = 30
    var notchWidth: CGFloat = 134
    var notchDrop: CGFloat = 42

    func path(in rect: CGRect) -> Path {
        let radius = min(cornerRadius, min(rect.width, rect.height) * 0.20)
        let drop = min(notchDrop, rect.height * 0.22)
        let width = min(notchWidth, rect.width * 0.38)
        let notchStartX = rect.maxX - width
        let notchKneeX = rect.maxX - width * 0.56
        let notchShelfX = rect.maxX - radius

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
        path.addLine(to: CGPoint(x: notchStartX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: notchStartX + 16, y: rect.minY + 7),
            control: CGPoint(x: notchStartX + 10, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: notchKneeX, y: rect.minY + drop))
        path.addQuadCurve(
            to: CGPoint(x: notchKneeX + 24, y: rect.minY + drop),
            control: CGPoint(x: notchKneeX + 10, y: rect.minY + drop + 7)
        )
        path.addLine(to: CGPoint(x: notchShelfX, y: rect.minY + drop))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + drop + radius),
            control: CGPoint(x: rect.maxX, y: rect.minY + drop)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - radius),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.closeSubpath()
        return path
    }
}

private struct SuggestionPokerCard: View {
    let item: TodaySuggestionPlan.Item

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SuggestionMetricIcon(kind: item.kind, tint: item.tint, size: 27)

            Spacer(minLength: 0)

            Text(item.category)
                .font(.system(size: 11.5, weight: .heavy))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .padding(.horizontal, 7)
                .frame(height: 22)
                .background(item.tint.opacity(0.16), in: Capsule())

            Text(item.shortActionTitle)
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.66)

            Text(item.shortTimeText)
                .font(.system(size: 11, weight: .heavy).monospacedDigit())
                .foregroundStyle(item.tint)
                .lineLimit(1)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 118, maxHeight: 132, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.90),
                            item.tint.opacity(0.18),
                            VitoraTheme.ColorToken.surfacePearlInset.opacity(0.64),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white.opacity(0.82), lineWidth: 0.8))
                .shadow(color: item.tint.opacity(0.10), radius: 8, x: 0, y: 6)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.category)，\(item.shortTimeText) \(item.reminderAction)")
    }
}

private struct CycleAdvicePokerCard: View {
    let advice: CycleSuggestionAdvice

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            SuggestionMetricIcon(kind: .cycle, tint: SuggestionSignalKind.cycle.tint, size: 28)

            Spacer(minLength: 0)

            Text(advice.phaseText)
                .font(.system(size: 12, weight: .heavy).monospacedDigit())
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .lineLimit(1)
                .minimumScaleFactor(0.70)

            Text(advice.title)
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.64)

            Text(advice.action)
                .font(.system(size: 11.2, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 118, maxHeight: 132, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.90),
                            SuggestionSignalKind.cycle.tint.opacity(0.15),
                            Color(red: 255 / 255, green: 243 / 255, blue: 222 / 255).opacity(0.56),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white.opacity(0.82), lineWidth: 0.8))
                .shadow(color: SuggestionSignalKind.cycle.tint.opacity(0.10), radius: 8, x: 0, y: 6)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(advice.phaseText)，\(advice.title)，\(advice.action)")
    }
}

private struct CycleSuggestionAdvice {
    let phaseText: String
    let title: String
    let action: String

    static func make(phase: String, day: Int, plan: TodaySuggestionPlan) -> CycleSuggestionAdvice {
        let phaseText = "\(phase) D\(day)"

        switch plan.themeTitle {
        case "午后启动":
            return CycleSuggestionAdvice(phaseText: phaseText, title: "轻动窗口", action: "先短走，再补给")
        case "傍晚舒展":
            return CycleSuggestionAdvice(phaseText: phaseText, title: "恢复优先", action: "降下来再舒展")
        default:
            return CycleSuggestionAdvice(phaseText: phaseText, title: "午后留余量", action: "先补给，再安静恢复")
        }
    }
}

private struct SuggestionCombinationCard: View {
    let plan: TodaySuggestionPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.themeTitle)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Text(plan.sourceSummary)
                        .font(.system(size: 11.4, weight: .semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }

                Spacer(minLength: 0)

                SuggestionPushSlotRail(slots: plan.pushSlots)
            }

            HStack(spacing: 10) {
                if let first = plan.items.first {
                    SuggestionStripItem(item: first)
                }

                Text("+")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText.opacity(0.72))
                    .frame(width: 24)
                    .accessibilityHidden(true)

                if plan.items.indices.contains(1) {
                    SuggestionStripItem(item: plan.items[1])
                }
            }

            Text(plan.rationale)
                .font(.system(size: 12.6, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .padding(13)
        .background(
            RoundedRectangle(cornerRadius: 23, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            VitoraTheme.ColorToken.surfacePearlMain.opacity(0.80),
                            VitoraTheme.ColorToken.surfacePearlInset.opacity(0.58),
                            Color(red: 226 / 255, green: 241 / 255, blue: 247 / 255).opacity(0.40),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(.ultraThinMaterial.opacity(0.30), in: RoundedRectangle(cornerRadius: 23, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 23, style: .continuous).stroke(Color.white.opacity(0.78), lineWidth: 0.8))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(plan.themeTitle)，\(plan.sourceSummary)，\(plan.items.map { $0.text }.joined(separator: "，"))")
        .accessibilityIdentifier("today.suggestion.combination.card")
    }
}

private struct SuggestionPushSlotRail: View {
    let slots: [TodaySuggestionPlan.PushSlot]

    var body: some View {
        Text(slots.map { "\($0.label)\($0.time)" }.joined(separator: " · "))
            .font(.system(size: 10.4, weight: .heavy).monospacedDigit())
            .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
            .lineLimit(1)
            .minimumScaleFactor(0.66)
            .padding(.horizontal, 8)
            .frame(height: 23)
            .background(VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.50), in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("推送时间 \(slots.map { "\($0.label) \($0.time)" }.joined(separator: "，"))")
    }
}

private struct SuggestionStripItem: View {
    let item: TodaySuggestionPlan.Item

    var body: some View {
        HStack(spacing: 7) {
            Text(item.category)
                .font(.system(size: 11.4, weight: .heavy))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .padding(.horizontal, 7)
                .frame(height: 22)
                .background(item.tint.opacity(0.15), in: Capsule())

            Text(compactActionText)
                .font(.system(size: 14.2, weight: .heavy))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.88),
                            item.tint.opacity(0.18),
                            VitoraTheme.ColorToken.surfacePearlInset.opacity(0.62),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(.ultraThinMaterial.opacity(0.20), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(Color.white.opacity(0.78), lineWidth: 0.75))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.category)，\(timeText) \(item.reminderAction)")
    }

    private var timeText: String {
        String(format: "%02d:%02d", item.defaultHour, item.defaultMinute)
    }

    private var compactActionText: String {
        switch item.reminderAction {
        case "加一份蛋白":
            return "蛋白"
        case "安静恢复 20 分钟":
            return "恢复20分钟"
        case "轻走 10 分钟":
            return "轻走10分钟"
        case "补水和蛋白":
            return "补水蛋白"
        case "闭眼恢复 8 分钟":
            return "闭眼8分钟"
        default:
            return item.reminderAction
        }
    }
}

private struct SuggestionMetricIcon: View {
    let kind: SuggestionSignalKind
    let tint: Color
    var size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.92),
                            tint.opacity(0.36),
                            kind.secondaryTint.opacity(0.22),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                        .stroke(Color.white.opacity(0.86), lineWidth: 0.75)
                )

            Image(systemName: kind.symbol)
                .font(.system(size: size * 0.40, weight: .bold))
                .foregroundStyle(tint)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

enum ReviewPixelFlowerStage: String {
    case sprout
    case bud
    case halfOpen
    case bloom
    case fullBloom
}

enum ReviewPixelFlowerPalette {
    case pink
    case white
    case lavender
    case green

    var petal: Color {
        switch self {
        case .pink:
            return Color(red: 247 / 255, green: 150 / 255, blue: 174 / 255)
        case .white:
            return Color(red: 244 / 255, green: 244 / 255, blue: 236 / 255)
        case .lavender:
            return Color(red: 147 / 255, green: 126 / 255, blue: 226 / 255)
        case .green:
            return Color(red: 116 / 255, green: 196 / 255, blue: 124 / 255)
        }
    }

    var petalShade: Color {
        switch self {
        case .pink:
            return Color(red: 255 / 255, green: 204 / 255, blue: 214 / 255)
        case .white:
            return Color(red: 196 / 255, green: 202 / 255, blue: 190 / 255)
        case .lavender:
            return Color(red: 190 / 255, green: 172 / 255, blue: 246 / 255)
        case .green:
            return Color(red: 155 / 255, green: 218 / 255, blue: 150 / 255)
        }
    }
}

struct ReviewPixelFlowerView: View {
    let stage: ReviewPixelFlowerStage
    var palette: ReviewPixelFlowerPalette = .pink
    var size: CGFloat = 56

    var body: some View {
        Canvas { context, canvasSize in
            let side = min(canvasSize.width, canvasSize.height)
            let unit = side / 18
            let xOffset = (canvasSize.width - side) / 2
            let yOffset = (canvasSize.height - side) / 2

            func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: Color) {
                let pixelRect = CGRect(
                    x: xOffset + x * unit,
                    y: yOffset + y * unit,
                    width: w * unit,
                    height: h * unit
                )
                context.fill(Path(pixelRect), with: .color(color))
            }

            let stem = Color(red: 55 / 255, green: 141 / 255, blue: 74 / 255)
            let stemDark = Color(red: 35 / 255, green: 104 / 255, blue: 56 / 255)
            let leaf = Color(red: 93 / 255, green: 173 / 255, blue: 79 / 255)
            let leafLight = Color(red: 136 / 255, green: 205 / 255, blue: 95 / 255)
            let pot = Color(red: 42 / 255, green: 80 / 255, blue: 112 / 255)
            let potLight = Color(red: 83 / 255, green: 143 / 255, blue: 177 / 255)
            let soil = Color(red: 115 / 255, green: 88 / 255, blue: 62 / 255)
            let center = Color(red: 255 / 255, green: 203 / 255, blue: 72 / 255)
            let shadow = Color(red: 43 / 255, green: 55 / 255, blue: 72 / 255).opacity(0.14)

            rect(5, 16, 8, 1, shadow)
            rect(5, 13, 8, 1, potLight)
            rect(6, 14, 6, 2, pot)
            rect(7, 16, 4, 1, Color(red: 32 / 255, green: 55 / 255, blue: 78 / 255))
            rect(6, 12, 6, 1, soil.opacity(stage == .sprout ? 0.72 : 0.35))

            if stage == .sprout {
                rect(9, 8, 1, 5, stem)
                rect(7, 8, 3, 1, leaf)
                rect(10, 7, 3, 1, leafLight)
                rect(8, 7, 1, 1, leafLight)
                return
            }

            rect(8, 7, 1, 6, stemDark)
            rect(9, 6, 1, 7, stem)
            rect(6, 9, 3, 1, leaf)
            rect(5, 10, 2, 1, leafLight)
            rect(10, 9, 3, 1, leaf)
            rect(12, 8, 1, 1, leafLight)

            switch stage {
            case .bud:
                rect(8, 5, 2, 2, palette.petal)
                rect(8, 4, 1, 1, palette.petalShade)
                rect(9, 4, 1, 1, palette.petal)
                rect(7, 7, 1, 1, leaf)
                rect(10, 7, 1, 1, leaf)
            case .halfOpen:
                rect(8, 4, 2, 2, palette.petal)
                rect(7, 5, 1, 2, palette.petalShade)
                rect(10, 5, 1, 2, palette.petalShade)
                rect(8, 6, 3, 1, palette.petal)
                rect(9, 5, 1, 1, center)
                rect(7, 7, 1, 1, leaf)
                rect(10, 7, 1, 1, leaf)
            case .bloom, .fullBloom:
                drawBloom(x: 9, y: 5, scale: 1)
                if stage == .fullBloom {
                    drawBloom(x: 5, y: 8, scale: 0.72)
                    drawBloom(x: 13, y: 8, scale: 0.72)
                    rect(6, 10, 1, 3, stemDark.opacity(0.86))
                    rect(13, 10, 1, 3, stemDark.opacity(0.86))
                }
            case .sprout:
                break
            }

            func drawBloom(x: CGFloat, y: CGFloat, scale: CGFloat) {
                let p = palette.petal
                let ps = palette.petalShade
                let s = max(scale, 0.7)
                rect(x - 1 * s, y - 3 * s, 2 * s, 2 * s, ps)
                rect(x - 3 * s, y - 1 * s, 2 * s, 2 * s, p)
                rect(x + 1 * s, y - 1 * s, 2 * s, 2 * s, p)
                rect(x - 1 * s, y + 1 * s, 2 * s, 2 * s, ps)
                rect(x - 1 * s, y - 1 * s, 2 * s, 2 * s, center)
                rect(x, y, 1 * s, 1 * s, Color.white.opacity(0.64))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

enum ReviewPixelGlyphKind {
    case moon
    case check
    case clock
    case sun
    case idea
    case chart
    case bell
    case chat
    case fork
    case walk
    case water
    case sprout
}

struct ReviewPixelGlyphView: View {
    let kind: ReviewPixelGlyphKind
    var tint: Color = VitoraTheme.ColorToken.actionPrimaryDeep
    var size: CGFloat = 24

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.88),
                            tint.opacity(0.18),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                        .stroke(Color.white.opacity(0.72), lineWidth: 0.7)
                )

            Canvas { context, canvasSize in
                let side = min(canvasSize.width, canvasSize.height)
                let unit = side / 12
                let xOffset = (canvasSize.width - side) / 2
                let yOffset = (canvasSize.height - side) / 2

                func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: Color? = nil) {
                    let pixelRect = CGRect(
                        x: xOffset + x * unit,
                        y: yOffset + y * unit,
                        width: w * unit,
                        height: h * unit
                    )
                    context.fill(Path(pixelRect), with: .color(color ?? tint))
                }

                let dark = VitoraTheme.ColorToken.strongText.opacity(0.78)
                let light = Color.white.opacity(0.82)

                switch kind {
                case .moon:
                    rect(4, 2, 3, 1)
                    rect(3, 3, 3, 1)
                    rect(2, 4, 3, 3)
                    rect(3, 7, 3, 1)
                    rect(4, 8, 4, 1)
                    rect(6, 4, 2, 1, light)
                    rect(6, 5, 3, 2, light)
                    rect(7, 7, 2, 1, light)
                    rect(8, 2, 1, 1, Color(red: 246 / 255, green: 149 / 255, blue: 144 / 255))
                    rect(9, 3, 1, 1, Color(red: 246 / 255, green: 149 / 255, blue: 144 / 255))
                case .check:
                    rect(2, 6, 2, 2)
                    rect(4, 8, 2, 1)
                    rect(6, 5, 2, 2)
                    rect(8, 3, 2, 2)
                case .clock:
                    rect(4, 2, 4, 1)
                    rect(3, 3, 1, 1)
                    rect(8, 3, 1, 1)
                    rect(2, 4, 1, 4)
                    rect(9, 4, 1, 4)
                    rect(3, 8, 1, 1)
                    rect(8, 8, 1, 1)
                    rect(4, 9, 4, 1)
                    rect(6, 4, 1, 3, dark)
                    rect(6, 6, 2, 1, dark)
                case .sun:
                    rect(5, 1, 2, 2)
                    rect(5, 9, 2, 2)
                    rect(1, 5, 2, 2)
                    rect(9, 5, 2, 2)
                    rect(4, 4, 4, 4)
                    rect(5, 5, 2, 2, Color(red: 255 / 255, green: 221 / 255, blue: 91 / 255))
                case .idea:
                    rect(4, 2, 4, 1)
                    rect(3, 3, 1, 3)
                    rect(8, 3, 1, 3)
                    rect(4, 6, 4, 1)
                    rect(5, 7, 2, 1)
                    rect(5, 9, 2, 1, dark)
                    rect(4, 8, 4, 1, tint.opacity(0.72))
                case .chart:
                    rect(2, 8, 8, 1, dark.opacity(0.72))
                    rect(2, 3, 1, 6, dark.opacity(0.72))
                    rect(4, 6, 1, 2)
                    rect(6, 4, 1, 4)
                    rect(8, 5, 1, 3)
                    rect(3, 4, 2, 1, tint.opacity(0.74))
                    rect(5, 3, 2, 1, tint.opacity(0.74))
                case .bell:
                    rect(5, 2, 2, 1)
                    rect(4, 3, 4, 1)
                    rect(3, 4, 6, 4)
                    rect(2, 8, 8, 1)
                    rect(5, 9, 2, 1, dark)
                    rect(8, 3, 1, 1, light)
                case .chat:
                    rect(2, 3, 8, 5)
                    rect(3, 8, 2, 1)
                    rect(4, 9, 1, 1)
                    rect(4, 5, 1, 1, light)
                    rect(6, 5, 1, 1, light)
                    rect(8, 5, 1, 1, light)
                case .fork:
                    rect(3, 2, 1, 4)
                    rect(5, 2, 1, 4)
                    rect(3, 6, 3, 1)
                    rect(4, 7, 1, 3)
                    rect(8, 2, 1, 8)
                    rect(7, 2, 2, 1)
                case .walk:
                    rect(5, 2, 2, 2)
                    rect(5, 4, 2, 3)
                    rect(4, 6, 1, 2)
                    rect(7, 6, 1, 2)
                    rect(4, 8, 1, 2)
                    rect(7, 8, 2, 1)
                case .water:
                    rect(6, 2, 1, 1)
                    rect(5, 3, 3, 2)
                    rect(4, 5, 5, 3)
                    rect(5, 8, 3, 1)
                    rect(5, 5, 1, 1, light)
                case .sprout:
                    rect(6, 5, 1, 5)
                    rect(3, 5, 3, 1)
                    rect(2, 6, 2, 1)
                    rect(7, 4, 3, 1)
                    rect(9, 5, 1, 1)
                }
            }
            .padding(size * 0.13)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct PixelReviewProgressBar: View {
    var value: CGFloat
    var tint: Color = VitoraTheme.ColorToken.actionPrimaryDeep
    var blockCount: Int = 20

    var body: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 2
            let blockWidth = max(1, (proxy.size.width - spacing * CGFloat(blockCount - 1)) / CGFloat(blockCount))
            let activeCount = max(0, min(blockCount, Int((value * CGFloat(blockCount)).rounded(.up))))

            HStack(spacing: spacing) {
                ForEach(0..<blockCount, id: \.self) { index in
                    Rectangle()
                        .fill(index < activeCount ? tint.opacity(index % 2 == 0 ? 0.92 : 0.74) : Color.gray.opacity(0.13))
                        .frame(width: blockWidth)
                }
            }
        }
        .frame(height: 10)
        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
        .accessibilityHidden(true)
    }
}

enum SuggestionSignalKind {
    case sleep
    case hrv
    case cycle
    case nutrition
    case recovery
    case movement
    case hydration

    var symbol: String {
        switch self {
        case .sleep:
            return "moon.fill"
        case .hrv:
            return "waveform.path.ecg"
        case .cycle:
            return "drop.fill"
        case .nutrition:
            return "fork.knife"
        case .recovery:
            return "bed.double.fill"
        case .movement:
            return "figure.walk"
        case .hydration:
            return "drop.fill"
        }
    }

    var tint: Color {
        switch self {
        case .sleep:
            return Color(red: 128 / 255, green: 120 / 255, blue: 236 / 255)
        case .hrv:
            return Color(red: 82 / 255, green: 193 / 255, blue: 213 / 255)
        case .cycle:
            return Color(red: 96 / 255, green: 177 / 255, blue: 238 / 255)
        case .nutrition:
            return Color(red: 246 / 255, green: 169 / 255, blue: 74 / 255)
        case .recovery:
            return Color(red: 128 / 255, green: 120 / 255, blue: 236 / 255)
        case .movement:
            return Color(red: 244 / 255, green: 167 / 255, blue: 94 / 255)
        case .hydration:
            return Color(red: 94 / 255, green: 199 / 255, blue: 203 / 255)
        }
    }

    var secondaryTint: Color {
        switch self {
        case .sleep:
            return Color(red: 180 / 255, green: 171 / 255, blue: 248 / 255)
        case .cycle:
            return Color(red: 144 / 255, green: 211 / 255, blue: 246 / 255)
        case .nutrition:
            return Color(red: 255 / 255, green: 211 / 255, blue: 116 / 255)
        default:
            return tint.opacity(0.72)
        }
    }
}

struct TodaySuggestionPlan {
    struct Source {
        let kind: SuggestionSignalKind
        let title: String
        let value: String

        var accessibilityText: String {
            "\(title) \(value)"
        }
    }

    struct Item {
        let kind: SuggestionSignalKind
        let category: String
        let symbol: String
        let tint: Color
        let text: String
        let reminderAction: String
        let reason: String
        let defaultHour: Int
        let defaultMinute: Int
    }

    struct PushSlot {
        let label: String
        let time: String
        let isActive: Bool
    }

    let themeTitle: String
    let sourceSummary: String
    let pushSlots: [PushSlot]
    let sources: [Source]
    let rationale: String
    let items: [Item]

    static let all: [TodaySuggestionPlan] = [
        TodaySuggestionPlan(
            themeTitle: "午间补能",
            sourceSummary: "睡眠7.2h / HRV↓8 / 黄体D18",
            pushSlots: [
                PushSlot(label: "早", time: "09:30", isActive: false),
                PushSlot(label: "中", time: "13:20", isActive: true),
                PushSlot(label: "晚", time: "20:30", isActive: false),
            ],
            sources: [
                Source(kind: .sleep, title: "睡眠偏短", value: "7.2h"),
                Source(kind: .hrv, title: "HRV", value: "↓8%"),
                Source(kind: .cycle, title: "黄体期", value: "D18"),
            ],
            rationale: "下午更容易掉电，先补给再安排一段安静恢复。",
            items: [
                Item(kind: .nutrition, category: "补剂", symbol: "fork.knife", tint: SuggestionSignalKind.nutrition.tint, text: "13:20 加一份蛋白", reminderAction: "加一份蛋白", reason: "低谷前先补上蛋白，给下午留余量。", defaultHour: 13, defaultMinute: 20),
                Item(kind: .recovery, category: "休息", symbol: "bed.double.fill", tint: SuggestionSignalKind.recovery.tint, text: "14:40 安静恢复 20 分钟", reminderAction: "安静恢复 20 分钟", reason: "午后用安静恢复替代硬撑。", defaultHour: 14, defaultMinute: 40),
            ]
        ),
        TodaySuggestionPlan(
            themeTitle: "午后启动",
            sourceSummary: "低谷后移 / 轻动窗 / 补水少",
            pushSlots: [
                PushSlot(label: "早", time: "10:00", isActive: false),
                PushSlot(label: "中", time: "15:30", isActive: true),
                PushSlot(label: "晚", time: "20:00", isActive: false),
            ],
            sources: [
                Source(kind: .cycle, title: "低谷后移", value: "15:30"),
                Source(kind: .movement, title: "轻动窗口", value: "可用"),
                Source(kind: .hydration, title: "补水", value: "偏少"),
            ],
            rationale: "先用轻走把身体叫醒，再补水和蛋白，节奏更稳。",
            items: [
                Item(kind: .movement, category: "轻动", symbol: "figure.walk", tint: SuggestionSignalKind.movement.tint, text: "15:30 轻走 10 分钟", reminderAction: "轻走 10 分钟", reason: "低谷后移时，轻走比硬撑更适合启动。", defaultHour: 15, defaultMinute: 30),
                Item(kind: .hydration, category: "补给", symbol: "drop.fill", tint: SuggestionSignalKind.hydration.tint, text: "16:00 补水和蛋白", reminderAction: "补水和蛋白", reason: "活动后把水和蛋白接上，减少后续掉电。", defaultHour: 16, defaultMinute: 0),
            ]
        ),
        TodaySuggestionPlan(
            themeTitle: "傍晚舒展",
            sourceSummary: "恢复窗短 / 肩颈紧 / 黄体D18",
            pushSlots: [
                PushSlot(label: "早", time: "09:10", isActive: false),
                PushSlot(label: "中", time: "13:10", isActive: false),
                PushSlot(label: "晚", time: "17:30", isActive: true),
            ],
            sources: [
                Source(kind: .recovery, title: "恢复窗口", value: "偏短"),
                Source(kind: .movement, title: "肩颈", value: "偏紧"),
                Source(kind: .cycle, title: "黄体期", value: "D18"),
            ],
            rationale: "先把身体降下来，再做轻舒展，避免把恢复窗口挤掉。",
            items: [
                Item(kind: .recovery, category: "休息", symbol: "eye.fill", tint: SuggestionSignalKind.recovery.tint, text: "13:10 闭眼恢复 8 分钟", reminderAction: "闭眼恢复 8 分钟", reason: "先给身体一个短暂停顿。", defaultHour: 13, defaultMinute: 10),
                Item(kind: .movement, category: "舒展", symbol: "figure.cooldown", tint: Color(red: 238 / 255, green: 120 / 255, blue: 176 / 255), text: "17:30 舒展肩颈", reminderAction: "舒展肩颈", reason: "晚些时候只做轻舒展，不加训练负担。", defaultHour: 17, defaultMinute: 30),
            ]
        ),
    ]
}

private extension TodaySuggestionPlan.Item {
    var shortTimeText: String {
        String(format: "%02d:%02d", defaultHour, defaultMinute)
    }

    var shortActionTitle: String {
        switch reminderAction {
        case "加一份蛋白":
            return "蛋白"
        case "安静恢复 20 分钟":
            return "恢复20分钟"
        case "轻走 10 分钟":
            return "轻走10分钟"
        case "补水和蛋白":
            return "补水"
        case "闭眼恢复 8 分钟":
            return "闭眼8分钟"
        case "舒展肩颈":
            return "舒展"
        default:
            return reminderAction
        }
    }
}

// MARK: - Reminder Setup Sheet

struct ReminderSetupSheet: View {
    let plan: TodaySuggestionPlan
    let onClose: () -> Void
    @State private var time1Hour = 13
    @State private var time1Min = 20
    @State private var time2Hour = 14
    @State private var time2Min = 40
    @State private var selectedIndexes: Set<Int> = [0, 1]

    var body: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color.gray.opacity(0.35)).frame(width: 36, height: 5).padding(.top, 10).padding(.bottom, 14)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("设置提醒")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            Text("Vitora 会在合适的时间轻轻提醒你")
                                .font(.subheadline)
                                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        }
                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text(plan.themeTitle)
                                .font(.system(size: 19, weight: .heavy))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)

                            Text("智能提醒")
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                                .padding(.horizontal, 8)
                                .frame(height: 24)
                                .background(VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.62), in: Capsule())
                        }

                        ForEach(Array(plan.items.enumerated()), id: \.offset) { index, item in
                            timeReminderRow(index: index, item: item)
                        }
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.white.opacity(0.72)))
                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white.opacity(0.58), lineWidth: 0.7))
                    .onAppear(perform: syncDefaultTimes)

                    // Note
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                        Text("提醒可以随时调整，不影响今天的判断。")
                            .font(.caption)
                            .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                    }

                    // Save button
                    Button(action: onClose) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkle")
                                .font(.system(size: 16, weight: .bold))
                            Text("保存智能提醒")
                                .font(.headline.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(VitoraTheme.ColorToken.strongText, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("today.reminder.save")

                    Button("稍后再说", action: onClose)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 20)
            }
        }
        .background(Color(red: 250 / 255, green: 248 / 255, blue: 245 / 255))
    }

    private func timeReminderRow(index: Int, item: TodaySuggestionPlan.Item) -> some View {
        let isSelected = selectedIndexes.contains(index)
        let hour = hourBinding(for: index)
        let minute = minuteBinding(for: index)

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Button {
                    selectedIndexes = [index]
                } label: {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(isSelected ? VitoraTheme.ColorToken.success : VitoraTheme.ColorToken.secondaryText.opacity(0.52))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("只提醒\(item.reminderAction)")
                .accessibilityIdentifier("today.reminder.select.\(index)")

                SuggestionMetricIcon(kind: item.kind, tint: item.tint, size: 38)

                VStack(alignment: .leading, spacing: 3) {
                    Text("\(timeText(hour: hour.wrappedValue, minute: minute.wrappedValue)) \(item.reminderAction)")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text("（\(plan.sourceSummary)；\(item.reason)）")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .lineLimit(2)
                }

                Spacer(minLength: 4)

                timeStepper(hour: hour, minute: minute)
                    .accessibilityIdentifier("today.reminder.timeStepper.\(index)")
            }
            .opacity(isSelected ? 1 : 0.58)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(isSelected ? VitoraTheme.ColorToken.surfacePearlMain.opacity(0.62) : VitoraTheme.ColorToken.paper.opacity(0.42))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.58), lineWidth: 0.7))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(timeText(hour: hour.wrappedValue, minute: minute.wrappedValue)) \(item.reminderAction)，\(plan.sourceSummary)，\(item.reason)")
    }

    private func timeStepper(hour: Binding<Int>, minute: Binding<Int>) -> some View {
        HStack(spacing: 6) {
            Button { shiftTime(hour: hour, minute: minute, by: -10) } label: {
                Image(systemName: "minus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .frame(width: 28, height: 28)
                    .background(Color.gray.opacity(0.10), in: Circle())
            }
            .buttonStyle(.plain)

            Text(timeText(hour: hour.wrappedValue, minute: minute.wrappedValue))
                .font(.title3.weight(.bold).monospacedDigit())
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .frame(width: 64)

            Button { shiftTime(hour: hour, minute: minute, by: 10) } label: {
                Image(systemName: "plus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .frame(width: 28, height: 28)
                    .background(Color.gray.opacity(0.10), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(Color.white.opacity(0.66), in: Capsule())
        .gesture(
            DragGesture(minimumDistance: 10)
                .onEnded { value in
                    if value.translation.height < -10 {
                        shiftTime(hour: hour, minute: minute, by: 10)
                    } else if value.translation.height > 10 {
                        shiftTime(hour: hour, minute: minute, by: -10)
                    }
                }
        )
        .accessibilityHint("上下滑动调整提醒时间")
    }

    private func syncDefaultTimes() {
        if let first = plan.items.first {
            time1Hour = first.defaultHour
            time1Min = first.defaultMinute
        }
        if plan.items.indices.contains(1) {
            time2Hour = plan.items[1].defaultHour
            time2Min = plan.items[1].defaultMinute
        }
        selectedIndexes = Set(plan.items.indices)
    }

    private func hourBinding(for index: Int) -> Binding<Int> {
        index == 0 ? $time1Hour : $time2Hour
    }

    private func minuteBinding(for index: Int) -> Binding<Int> {
        index == 0 ? $time1Min : $time2Min
    }

    private func shiftTime(hour: Binding<Int>, minute: Binding<Int>, by deltaMinutes: Int) {
        let rawTotal = hour.wrappedValue * 60 + minute.wrappedValue + deltaMinutes
        let normalized = (rawTotal % 1_440 + 1_440) % 1_440
        hour.wrappedValue = normalized / 60
        minute.wrappedValue = normalized % 60
    }

    private func timeText(hour: Int, minute: Int) -> String {
        String(format: "%02d:%02d", hour, minute)
    }
}

// MARK: - Insight Detail Sheet (low valley / recovery / factors)

struct InsightDetailSheet: View {
    let title: String
    var accent: Color = VitoraTheme.ColorToken.actionPrimaryDeep
    let onAskVitora: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(accent)
                            Text(title)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        }
                        Text("基于你最近的数据，Vitora 为你整理了非诊断性解释。")
                            .font(.caption)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }

                    // 1. Evidence
                    insightSection(number: "1", icon: "chart.bar.fill", title: "Vitora 看到的证据") {
                        insightRow(icon: "waveform.path.ecg", text: "本周 4 天在下午变慢")
                        insightRow(icon: "moon.fill", text: "睡眠偏短日低谷更明显")
                        insightRow(icon: "calendar", text: "黄体期 D18 附近波动更常见")
                    }

                    // 2. What it means
                    insightSection(number: "2", icon: "heart.fill", title: "这对今天意味着") {
                        HStack(spacing: 16) {
                            VStack(spacing: 4) {
                                Text("🌸").font(.system(size: 32))
                                Text("68分 · 半开").font(.caption2.weight(.medium)).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            }
                            VStack(spacing: 4) {
                                Text("- - - →").font(.caption).foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                            }
                            VStack(spacing: 4) {
                                Text("🌺").font(.system(size: 32))
                                Text("100分 · 盛开+露水").font(.caption2.weight(.medium)).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.white.opacity(0.52), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                        Text("如果下午保留恢复时间，晚间反馈更可能稳定。")
                            .font(.caption)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }

                    // 3. Actions
                    insightSection(number: "3", icon: "leaf.fill", title: "可以怎么用") {
                        insightRow(icon: "sun.max.fill", text: "把高负担事放到上午")
                        insightRow(icon: "clock", text: "下午预留 20 分钟缓冲")
                    }

                    // 4. Calibrate
                    insightSection(number: "4", icon: "scope", title: "继续校准") {
                        insightRow(icon: "waveform.path", text: "还需要 3 天记录确认，不急着下结论。")
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }

            // Bottom buttons
            HStack(spacing: 12) {
                Button(action: onAskVitora) {
                    HStack(spacing: 8) {
                        Image(systemName: "ellipsis.message.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("问 Vitora 这一点")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)

                Button("关闭", action: onClose)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .frame(width: 60, height: 50)
                    .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.gray.opacity(0.18), lineWidth: 1))
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .background(Color(red: 250 / 255, green: 248 / 255, blue: 245 / 255))
        }
        .background(Color(red: 250 / 255, green: 248 / 255, blue: 245 / 255))
    }

    private func insightSection<Content: View>(number: String, icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(number)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(accent.opacity(0.72), in: Circle())
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }
            content()
        }
    }

    private func insightRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 30, height: 30)
                .background(accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
        }
        .padding(12)
        .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
