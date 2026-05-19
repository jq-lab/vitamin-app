import SwiftUI

struct VitoraDailySuggestionCard: View {
    var mode: TodayMetricMode = .energy
    var sleepSeed: SleepSeedCard?
    let onCommit: () -> Void
    let onOpenDetail: () -> Void
    let onAskVitora: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var suggestionIndex = 0

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

private struct TodaySuggestionPlan {
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
