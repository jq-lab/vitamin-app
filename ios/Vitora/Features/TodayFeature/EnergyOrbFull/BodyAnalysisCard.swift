import SwiftUI

struct BodyAnalysisCard: View {
    let onClose: () -> Void
    @State private var planAReminder = true
    @State private var planBReminder = true

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    miniRingSection
                    summaryRow
                    metricCards
                    aiTranslation
                    aiSuggestions
                    complianceFooter
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .frame(width: 36, height: 36)
                    .background(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.72), in: Circle())
            }
            .accessibilityLabel("关闭")
            .accessibilityIdentifier("analysis.close")

            Spacer()

            Text("今日分析")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            Spacer()

            Color.clear.frame(width: 36, height: 36)
        }
    }

    // MARK: - Mini Ring + Score

    private var miniRingSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("AI 分析 →")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                Spacer()
            }

            ZStack {
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [VitoraTheme.ColorToken.auraCyan, VitoraTheme.ColorToken.auraBlue, VitoraTheme.ColorToken.auraCyan],
                            center: .center
                        ),
                        lineWidth: 8
                    )
                    .frame(width: 120, height: 120)

                VStack(spacing: 2) {
                    Text("68%")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                }
            }

            Text("↓ 身体年龄 -1.2%")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.success)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Summary Row

    private var summaryRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("综合能量 68%")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
            Text("2026年5月22日 · 黄体期 Day 18 · 充足、能动，别逞强")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
        }
    }

    // MARK: - 4 Metric Cards

    private var metricCards: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            metricCard(title: "深睡", value: "7.2h", delta: "↑12%", note: "凌晨 1:14 醒了一次",
                       bg: Color(red: 220 / 255, green: 240 / 255, blue: 255 / 255))
            metricCard(title: "HRV", value: "48ms", delta: "↓8%", note: "神经还紧绷",
                       bg: Color(red: 255 / 255, green: 228 / 255, blue: 235 / 255))
            metricCard(title: "心率", value: "72bpm", delta: "↑5%", note: "今日举铁达人",
                       bg: Color(red: 220 / 255, green: 250 / 255, blue: 230 / 255))
            metricCard(title: "周期", value: "D18", delta: "黄体期", note: "孕酮升，情绪会波动",
                       bg: Color(red: 240 / 255, green: 230 / 255, blue: 255 / 255))
        }
    }

    private func metricCard(title: String, value: String, delta: String, note: String, bg: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                Spacer()
                Text(delta)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
            Text(note)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .lineLimit(2)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(bg))
    }

    // MARK: - AI Translation

    private var aiTranslation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI 定制翻译")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)

            Text("HRV 48ms 偏低 + 深睡 7.2h 充足 = 神经还紧绷，但恢复到位。综合能量 68%——能动，别逞强。")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineSpacing(4)

            Text("合规标识 #5：以上内容由 AI 生成，不构成医学建议。")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.72)))
    }

    // MARK: - AI Suggestions (Plan A / B)

    private var aiSuggestions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("AI 今日建议")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)

            suggestionCard(
                title: "方案A：食补",
                subtitle: "提前加餐 + 散步",
                reminderOn: $planAReminder
            )

            suggestionCard(
                title: "方案B：运动建议",
                subtitle: "专注峰值 82%",
                reminderOn: $planBReminder
            )

            Button {} label: {
                Text("都不合适")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Capsule().fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.62)))
            }
            .buttonStyle(.plain)
        }
    }

    private func suggestionCard(title: String, subtitle: String, reminderOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }
            Spacer()
            Toggle("", isOn: reminderOn)
                .labelsHidden()
                .tint(VitoraTheme.ColorToken.actionPrimaryDeep)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(red: 245 / 255, green: 245 / 255, blue: 248 / 255)))
    }

    // MARK: - Compliance

    private var complianceFooter: some View {
        Text("合规标识 #4：健康数据仅存储在本地设备，不上传至任何服务器。")
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }
}
