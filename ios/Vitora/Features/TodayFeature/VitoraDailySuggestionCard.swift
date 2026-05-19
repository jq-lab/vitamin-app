import SwiftUI

struct VitoraDailySuggestionCard: View {
    var mode: TodayMetricMode = .energy
    var sleepSeed: SleepSeedCard?
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
            VStack(alignment: .leading, spacing: 11) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(mode.accent)

                    Text("Vitora 今日建议")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)

                    Spacer()
                }

                VStack(alignment: .leading, spacing: 13) {
                    HStack(alignment: .top, spacing: 8) {
                        Text("睡眠偏短，HRV 还在恢复，下午更容易掉电。")
                            .font(.system(size: 18.5, weight: .heavy))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            .lineSpacing(3)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .layoutPriority(1)
                    }

                    Divider()
                        .overlay(VitoraTheme.ColorToken.secondaryText.opacity(0.10))

                    HStack(spacing: 8) {
                        Text("监测到")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            .lineLimit(1)

                        evidenceChip(symbol: "moon.fill", text: "睡眠 7.2h", tint: Color(red: 103 / 255, green: 106 / 255, blue: 236 / 255))
                        evidenceChip(symbol: "heart.fill", text: "HRV ↓8%", tint: Color(red: 111 / 255, green: 97 / 255, blue: 220 / 255))
                        evidenceChip(symbol: "calendar", text: "黄体期 D18", tint: VitoraTheme.ColorToken.actionPrimaryDeep)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SuggestionInsetPanel(cornerRadius: 22))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("睡眠偏短，HRV 还在恢复，下午更容易掉电。监测到睡眠、HRV 和黄体期。")

                if let sleepSeed {
                    sleepSeedStateBlock(sleepSeed)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 7) {
                        Text(currentPlan.title)
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)

                        Spacer()

                        Text("组合推荐")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(mode.accent)
                            .padding(.horizontal, 7)
                            .frame(height: 22)
                            .background(mode.accent.opacity(0.10), in: Capsule())
                    }

                    ForEach(Array(currentPlan.items.enumerated()), id: \.offset) { index, item in
                        suggestionRow(index: index, icon: item.symbol, tint: item.tint, text: item.text)
                    }
                }

                HStack(spacing: 8) {
                    suggestionButton("我试试", systemImage: "sparkle", filled: true, action: onCommit)
                        .accessibilityIdentifier("today.suggestion.try")

                    suggestionButton("一键提醒", systemImage: "bell.fill", filled: false) {
                        showReminder = true
                    }
                    .accessibilityIdentifier("today.suggestion.remind")

                    Button(action: rotateSuggestion) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                            .frame(width: 40, height: 32)
                            .background(VitoraTheme.ColorToken.paper.opacity(0.46), in: Capsule())
                            .overlay(Capsule().stroke(VitoraTheme.ColorToken.paper.opacity(0.75), lineWidth: 0.7))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("换一换")
                    .accessibilityIdentifier("today.suggestion.swap")
                }
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

    private func evidenceChip(symbol: String, text: String, tint: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: symbol)
                .font(.system(size: 10.5, weight: .bold))
                .foregroundStyle(tint)

            Text(text)
                .font(.system(size: 11.5, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
        }
        .padding(.horizontal, 9)
        .frame(height: 30)
        .background(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.54), in: Capsule())
        .background(.ultraThinMaterial.opacity(0.20), in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.66), lineWidth: 0.7))
    }

    private func suggestionRow(index: Int, icon: String, tint: Color, text: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 25, height: 25)
                .background(
                    RadialGradient(
                        colors: [tint.opacity(0.95), tint.opacity(0.70)],
                        center: .topLeading,
                        startRadius: 4,
                        endRadius: 24
                    )
                )
                .clipShape(Circle())
                .shadow(color: tint.opacity(0.24), radius: 8, x: 0, y: 3)

            Text(text)
                .font(.system(size: 13.2, weight: .medium))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.76)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.success)
                .accessibilityIdentifier("today.suggestion.checkmark.\(index)")
        }
        .padding(.horizontal, 11)
        .frame(height: 42)
        .background(
            LinearGradient(
                colors: [
                    VitoraTheme.ColorToken.surfacePearlInset.opacity(0.72),
                    VitoraTheme.ColorToken.surfacePearlMain.opacity(0.48),
                ],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .background(.ultraThinMaterial.opacity(0.26), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.74), lineWidth: 0.7)
        )
        .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.08), radius: 7, x: 0, y: 4)
    }

    private func sleepSeedStateBlock(_ seed: SleepSeedCard) -> some View {
        HStack(alignment: .top, spacing: 9) {
            SleepSeedPixelView(kind: seed.kind, state: seed.growthState, size: 40)
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("昨晚种子状态：\(seed.growthState.displayText)")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text(seed.kind.shortTitle)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                        .padding(.horizontal, 6)
                        .frame(height: 20)
                        .background(VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.72), in: Capsule())
                }

                seedLine(prefix: "原因", text: seed.reason)
                seedLine(prefix: "今天让它继续打开", text: seed.todayAction)
            }
        }
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(VitoraTheme.ColorToken.paper.opacity(0.52))
                .background(.ultraThinMaterial.opacity(0.18), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.72), lineWidth: 0.7)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("昨晚种子状态 \(seed.growthState.displayText)，原因 \(seed.reason)，今天让它继续打开 \(seed.todayAction)")
        .accessibilityIdentifier("today.sleepSeed.card")
    }

    private func seedLine(prefix: String, text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text("\(prefix)：")
                .font(.system(size: 11.2, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            Text(text)
                .font(.system(size: 11.2, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func suggestionButton(_ title: String, systemImage: String?, filled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 3) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 9, weight: .bold))
                }
                Text(title)
            }
            .font(.system(size: 12.5, weight: .medium))
            .foregroundStyle(filled ? VitoraTheme.ColorToken.paper : VitoraTheme.ColorToken.actionPrimaryDeep)
            .frame(maxWidth: .infinity)
            .frame(height: 31)
            .background(filled ? VitoraTheme.ColorToken.strongText.opacity(0.88) : VitoraTheme.ColorToken.paper.opacity(0.46))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(VitoraTheme.ColorToken.paper.opacity(0.75), lineWidth: filled ? 0 : 0.7))
        }
        .buttonStyle(.plain)
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

private struct TodaySuggestionShell: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                VitoraTheme.ColorToken.surfacePearlMain.opacity(0.82),
                                Color(red: 255 / 255, green: 248 / 255, blue: 241 / 255).opacity(0.64),
                                Color(red: 238 / 255, green: 248 / 255, blue: 246 / 255).opacity(0.52),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.72),
                                Color.white.opacity(0.10),
                                .clear,
                            ],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .blendMode(.screen)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.92),
                                Color(red: 208 / 255, green: 222 / 255, blue: 218 / 255).opacity(0.42),
                                Color.white.opacity(0.68),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.18), radius: 18, x: 0, y: 12)
            .shadow(color: Color(red: 121 / 255, green: 202 / 255, blue: 200 / 255).opacity(0.08), radius: 20, x: -8, y: 12)
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

struct SleepSeedPixelView: View {
    let kind: SleepSeedKind
    let state: SleepSeedGrowthState
    var size: CGFloat = 48

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            VitoraTheme.ColorToken.paper.opacity(0.88),
                            baseColor.opacity(0.18),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                        .stroke(Color.white.opacity(0.82), lineWidth: 0.8)
                )
                .shadow(color: baseColor.opacity(0.14), radius: size * 0.18, x: 0, y: size * 0.08)

            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    stem
                    bloom
                }
                .frame(width: size * 0.58, height: size * 0.58)

                pot
                    .frame(width: size * 0.34, height: size * 0.18)
                    .offset(y: -size * 0.02)
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("\(kind.title)\(state.displayText)")
    }

    private var baseColor: Color {
        switch kind {
        case .recovery:
            return Color(red: 94 / 255, green: 186 / 255, blue: 220 / 255)
        case .reserve:
            return Color(red: 246 / 255, green: 181 / 255, blue: 82 / 255)
        case .lightMovement:
            return Color(red: 97 / 255, green: 184 / 255, blue: 112 / 255)
        }
    }

    private var petalColor: Color {
        switch kind {
        case .recovery:
            return Color(red: 142 / 255, green: 206 / 255, blue: 238 / 255)
        case .reserve:
            return Color(red: 248 / 255, green: 199 / 255, blue: 94 / 255)
        case .lightMovement:
            return Color(red: 130 / 255, green: 211 / 255, blue: 148 / 255)
        }
    }

    private var stem: some View {
        ZStack(alignment: .bottom) {
            Capsule()
                .fill(Color(red: 72 / 255, green: 142 / 255, blue: 94 / 255))
                .frame(width: max(size * 0.055, 2), height: stemHeight)

            HStack(spacing: size * 0.10) {
                leaf(rotation: -28)
                leaf(rotation: 30)
            }
            .offset(y: -size * 0.14)
            .opacity(state == .dormant ? 0.45 : 1)
        }
    }

    private var bloom: some View {
        ZStack {
            switch state {
            case .seed:
                Circle()
                    .fill(baseColor.opacity(0.55))
                    .frame(width: size * 0.12, height: size * 0.12)
                    .offset(y: size * 0.10)
            case .halfOpen:
                bud
            case .bloom:
                flower
            case .dormant:
                dormantHead
            }
        }
        .offset(y: bloomOffset)
    }

    private var flower: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                RoundedRectangle(cornerRadius: size * 0.045, style: .continuous)
                    .fill(petalColor)
                    .frame(width: size * 0.14, height: size * 0.20)
                    .offset(y: -size * 0.12)
                    .rotationEffect(.degrees(Double(index) * 60))
                    .shadow(color: petalColor.opacity(0.18), radius: 2, x: 0, y: 1)
            }

            Circle()
                .fill(Color(red: 255 / 255, green: 225 / 255, blue: 112 / 255))
                .frame(width: size * 0.13, height: size * 0.13)
                .overlay(Circle().stroke(Color.white.opacity(0.86), lineWidth: 0.7))
        }
    }

    private var bud: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.06, style: .continuous)
                .fill(petalColor.opacity(0.96))
                .frame(width: size * 0.18, height: size * 0.23)
                .rotationEffect(.degrees(-6))

            RoundedRectangle(cornerRadius: size * 0.04, style: .continuous)
                .fill(Color.white.opacity(0.72))
                .frame(width: size * 0.06, height: size * 0.18)
                .offset(x: -size * 0.035)
                .rotationEffect(.degrees(-10))
        }
    }

    private var dormantHead: some View {
        RoundedRectangle(cornerRadius: size * 0.05, style: .continuous)
            .fill(Color(red: 178 / 255, green: 147 / 255, blue: 104 / 255).opacity(0.86))
            .frame(width: size * 0.16, height: size * 0.20)
            .rotationEffect(.degrees(22))
            .offset(x: size * 0.08, y: size * 0.02)
    }

    private var pot: some View {
        UnevenRoundedRectangle(
            topLeadingRadius: size * 0.035,
            bottomLeadingRadius: size * 0.09,
            bottomTrailingRadius: size * 0.09,
            topTrailingRadius: size * 0.035,
            style: .continuous
        )
        .fill(
            LinearGradient(
                colors: [
                    Color(red: 68 / 255, green: 83 / 255, blue: 102 / 255),
                    Color(red: 40 / 255, green: 51 / 255, blue: 69 / 255),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func leaf(rotation: Double) -> some View {
        Capsule()
            .fill(Color(red: 92 / 255, green: 170 / 255, blue: 112 / 255))
            .frame(width: size * 0.11, height: size * 0.06)
            .rotationEffect(.degrees(rotation))
    }

    private var stemHeight: CGFloat {
        switch state {
        case .seed:
            return size * 0.22
        case .halfOpen:
            return size * 0.32
        case .bloom:
            return size * 0.38
        case .dormant:
            return size * 0.30
        }
    }

    private var bloomOffset: CGFloat {
        switch state {
        case .seed:
            return size * 0.04
        case .halfOpen:
            return -size * 0.10
        case .bloom:
            return -size * 0.17
        case .dormant:
            return -size * 0.09
        }
    }
}

struct TodaySuggestionPlan {
    struct Item {
        let symbol: String
        let tint: Color
        let text: String
    }

    let title: String
    let items: [Item]

    static let all: [TodaySuggestionPlan] = [
        TodaySuggestionPlan(
            title: "吃 + 休息",
            items: [
                Item(symbol: "fork.knife", tint: Color(red: 144 / 255, green: 112 / 255, blue: 238 / 255), text: "13:30 前加一份蛋白"),
                Item(symbol: "bed.double.fill", tint: Color(red: 91 / 255, green: 178 / 255, blue: 232 / 255), text: "午后留 20 分钟安静恢复"),
            ]
        ),
        TodaySuggestionPlan(
            title: "运动 + 吃",
            items: [
                Item(symbol: "figure.walk", tint: Color(red: 244 / 255, green: 167 / 255, blue: 94 / 255), text: "下午轻走 10 分钟"),
                Item(symbol: "drop.fill", tint: Color(red: 94 / 255, green: 199 / 255, blue: 203 / 255), text: "运动后补水和蛋白"),
            ]
        ),
        TodaySuggestionPlan(
            title: "休息 + 运动",
            items: [
                Item(symbol: "eye.fill", tint: Color(red: 132 / 255, green: 121 / 255, blue: 238 / 255), text: "先闭眼恢复 8 分钟"),
                Item(symbol: "figure.cooldown", tint: Color(red: 238 / 255, green: 120 / 255, blue: 176 / 255), text: "傍晚舒展肩颈"),
            ]
        ),
    ]
}

// MARK: - Reminder Setup Sheet

struct ReminderSetupSheet: View {
    let plan: TodaySuggestionPlan
    let onClose: () -> Void
    @State private var time1Hour = 13
    @State private var time1Min = 20
    @State private var time2Hour = 14
    @State private var time2Min = 40

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
                        Text("🌸").font(.system(size: 38))
                    }

                    // Plan summary card
                    VStack(alignment: .leading, spacing: 10) {
                        Text(plan.title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)

                        ForEach(Array(plan.items.enumerated()), id: \.offset) { _, item in
                            HStack(spacing: 10) {
                                Image(systemName: item.symbol)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(item.tint)
                                    .frame(width: 32, height: 32)
                                    .background(item.tint.opacity(0.14), in: Circle())
                                Text(item.text)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            }
                        }
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.white.opacity(0.72)))

                    // Time pickers
                    if plan.items.count >= 1 {
                        timeRow(icon: "fork.knife", color: Color(red: 0.62, green: 0.52, blue: 0.82), title: "补充能量", subtitle: "提醒加一份蛋白", hour: $time1Hour, min: $time1Min)
                    }
                    if plan.items.count >= 2 {
                        timeRow(icon: "bed.double.fill", color: Color(red: 0.52, green: 0.62, blue: 0.88), title: "安静恢复", subtitle: "提醒安静休息 20 分钟", hour: $time2Hour, min: $time2Min)
                    }

                    // Note
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                        Text("时间可以随时调整，不会变成打卡任务。")
                            .font(.caption)
                            .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                    }

                    // Save button
                    Button(action: onClose) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkle")
                                .font(.system(size: 16, weight: .bold))
                            Text("保存提醒")
                                .font(.headline.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(VitoraTheme.ColorToken.strongText, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)

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

    private func timeRow(icon: String, color: Color, title: String, subtitle: String, hour: Binding<Int>, min: Binding<Int>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.bold)).foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text(subtitle).font(.caption).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            Spacer()

            HStack(spacing: 6) {
                Button { if hour.wrappedValue > 0 { hour.wrappedValue -= 1 } } label: {
                    Image(systemName: "minus").font(.caption.weight(.bold)).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .frame(width: 28, height: 28).background(Color.gray.opacity(0.10), in: Circle())
                }.buttonStyle(.plain)

                Text(String(format: "%d:%02d", hour.wrappedValue, min.wrappedValue))
                    .font(.title3.weight(.bold).monospacedDigit())
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .frame(width: 62)

                Button { if hour.wrappedValue < 23 { hour.wrappedValue += 1 } } label: {
                    Image(systemName: "plus").font(.caption.weight(.bold)).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .frame(width: 28, height: 28).background(Color.gray.opacity(0.10), in: Circle())
                }.buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.white.opacity(0.72))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.52), lineWidth: 0.7)))
    }
}

// MARK: - Insight Detail Sheet (low valley / recovery / factors)

struct InsightDetailSheet: View {
    let title: String
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
                                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
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
                    .background(VitoraTheme.ColorToken.actionPrimaryDeep, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
                    .background(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.72), in: Circle())
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
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .frame(width: 30, height: 30)
                .background(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
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
