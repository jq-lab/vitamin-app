import SwiftUI
import UIKit

struct CycleView: View {
    @ObservedObject var environment: AppEnvironment
    @State private var sheet: CycleSheet?
    @State private var shareImage: UIImage?
    @State private var isSharePresented = false
    @State private var shareFailurePresented = false

    var body: some View {
        ZStack {
            WaterAuraReferenceBackground(scene: .cycle, intensity: 1.02)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header

                    CycleReviewInsightCard()

                    EnergyDynamicsCard(
                        onOpenDetail: { sheet = .energy },
                        onAskVitora: { openVitora(source: "能量动态", summary: "本周平均 62% · 周三后恢复变慢") }
                    )

                    CycleInsightSwitcher(
                        onOpenDetail: { insight in sheet = .insight(insight) },
                        onAskVitora: { insight in openVitora(source: insight.title, summary: insight.summary) }
                    )
                }
                .padding(.horizontal, VitoraTheme.Spacing.screenMargin)
                .padding(.top, 4)
                .padding(.bottom, VitoraTheme.Size.tabBarHeight + 42)
            }
        }
        .sheet(isPresented: $isSharePresented) {
            if let shareImage {
                CycleShareActivityView(activityItems: [shareImage])
                    .accessibilityIdentifier("cycle.share.sheet")
            }
        }
        .alert("暂时无法生成周期卡片", isPresented: $shareFailurePresented) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text("稍后再试一次。")
        }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .phase:
                CurrentPhaseDetailSheet(
                    onClose: { self.sheet = nil },
                    onAskVitora: { openVitora(source: "当前周期阶段", summary: "用户想校准日期或感受") }
                )
            case .energy:
                EnergyDynamicsDetailSheet(
                    onClose: { self.sheet = nil },
                    onAskVitora: { openVitora(source: "能量动态", summary: "解释趋势或某个低点") }
                )
            case .settings:
                SettingsPanel(onClose: { self.sheet = nil })
            case let .insight(insight):
                CycleInsightDetailSheet(
                    insight: insight,
                    onClose: { self.sheet = nil },
                    onAskVitora: { openVitora(source: insight.title, summary: insight.summary) }
                )
            }
        }
        .preference(key: AppSheetPresentationPreferenceKey.self, value: sheet != nil || isSharePresented)
        .accessibilityIdentifier("cycle.pivot.surface")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Button {
                    sheet = .settings
                } label: {
                    ZStack {
                        GlassSurface(cornerRadius: 19, opacity: 0.62, shadowStrength: 0.28, variant: .cleanResting)
                            .frame(width: 38, height: 38)
                            .clipShape(Circle())

                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.92),
                                            VitoraTheme.ColorToken.paper.opacity(0.76),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("小")
                                .font(.system(size: 15, weight: .heavy))
                                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                        }
                        .frame(width: 30, height: 30)
                        .overlay(Circle().stroke(Color.white.opacity(0.82), lineWidth: 0.8))
                    }
                    .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                .accessibilityLabel("打开我的")
                .accessibilityIdentifier("cycle.settings.open")

                Spacer()

                Button {
                    presentCycleShareCard()
                } label: {
                    ZStack {
                        GlassSurface(cornerRadius: 18, opacity: 0.58, shadowStrength: 0.28, variant: .cleanResting)
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())

                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 19, weight: .medium))
                            .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    }
                    .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                .accessibilityLabel("分享周期卡片")
                .accessibilityIdentifier("cycle.share.open")
            }

            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("周期回顾")
                        .font(.system(size: 30, weight: .heavy, design: .default))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)

                    Text("复盘成长 · 洞察规律")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }

                Spacer(minLength: 0)

                CycleHeaderIllustration()
            }
        }
    }

    @MainActor
    private func presentCycleShareCard() {
        let renderer = ImageRenderer(
            content: CycleShareCardSnapshotView()
                .frame(width: 360)
                .padding(.vertical, 1)
        )
        renderer.scale = UIScreen.main.scale
        renderer.isOpaque = false

        guard let image = renderer.uiImage else {
            shareFailurePresented = true
            return
        }

        shareImage = image
        isSharePresented = true
    }

    private func openVitora(source: String, summary: String) {
        environment.openVitoraContext(
            sourceTitle: source,
            sourceSummary: summary,
            prompt: "Vitora 会带着这个长期节律上下文来解释或校准。"
        )
        sheet = nil
    }
}

private struct CycleHeaderIllustration: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            VitoraTheme.ColorToken.auraCyan.opacity(0.76),
                            VitoraTheme.ColorToken.auraBlue.opacity(0.82),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 74, height: 58)
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.62))
                        .frame(height: 14)
                        .padding(.horizontal, 7)
                        .offset(y: -2)
                }
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.system(size: 25, weight: .heavy))
                        .foregroundStyle(Color.white.opacity(0.92))
                }
                .shadow(color: VitoraTheme.ColorToken.auraBlue.opacity(0.20), radius: 16, x: 0, y: 8)

            Circle()
                .fill(VitoraTheme.ColorToken.lutealGold)
                .frame(width: 26, height: 26)
                .overlay(Circle().stroke(Color.white.opacity(0.88), lineWidth: 1.2))
                .overlay {
                    Image(systemName: "sparkle")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.88))
                }
                .offset(x: 7, y: 7)

            ForEach([0.18, 0.74], id: \.self) { x in
                Capsule()
                    .fill(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.70))
                    .frame(width: 7, height: 15)
                    .offset(x: -74 * (0.5 - x), y: -49)
            }
        }
        .frame(width: 96, height: 76)
        .accessibilityHidden(true)
    }
}

private struct CycleReviewInsightCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedTab: CycleReviewTab = .week

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 10) {
                    PixelVitoraScene(
                        state: .idle,
                        size: 34,
                        accessory: .none,
                        showsSparkles: true,
                        showsBaseShadow: true
                    )
                    .frame(width: 50, height: 50)
                    .allowsHitTesting(false)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("这 30 天，Vitora 看见的三件事")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            .accessibilityIdentifier("cycle.review.insights")
                        Text("Vitora 已更新 5月8日 的理解")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }

                    Spacer(minLength: 0)
                }

                CycleReviewSnapshotGrid()
            }
            .padding(14)
            .background(GlassSurface(cornerRadius: 26, opacity: 0.68, shadowStrength: 0.48, variant: .cleanElevated))

            segmentedTabs

            VStack(spacing: 0) {
                ForEach(rowsForSelectedTab, id: \.title) { row in
                    CycleReviewInsightRow(row: row)
                    if row.title != rowsForSelectedTab.last?.title {
                        Divider()
                            .overlay(VitoraTheme.ColorToken.secondaryText.opacity(0.12))
                            .padding(.leading, 34)
                    }
                }
            }
            .id(selectedTab)
            .transition(.opacity)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(GlassSurface(cornerRadius: 24, opacity: 0.70, shadowStrength: 0.34, variant: .cleanResting))
        }
    }

    private var segmentedTabs: some View {
        HStack(spacing: 0) {
            ForEach(CycleReviewTab.allCases) { tab in
                Button {
                    if reduceMotion {
                        selectedTab = tab
                    } else {
                        withAnimation(.easeOut(duration: 0.18)) {
                            selectedTab = tab
                        }
                    }
                } label: {
                    CycleReviewTabLabel(tab: tab, isSelected: selectedTab == tab)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(tab.accessibilityID)
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 4)
        .padding(.bottom, 6)
        .background(
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(VitoraTheme.ColorToken.paper.opacity(0.30))
                .overlay(
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .stroke(Color.white.opacity(0.52), lineWidth: 0.7)
                )
                .offset(y: 8)
        )
    }

    private var rowsForSelectedTab: [CycleReviewRowModel] {
        switch selectedTab {
        case .trend:
            return [
                CycleReviewRowModel(icon: "chart.line.uptrend.xyaxis", title: "月内低谷", caption: "仍集中在午后", value: "14:00-16:00", tint: VitoraTheme.ColorToken.lutealGold),
                CycleReviewRowModel(icon: "arrow.up.right", title: "回升节点", caption: "周五后曲线回稳", value: "周五-周日", tint: VitoraTheme.ColorToken.success),
                CycleReviewRowModel(icon: "heart.text.square", title: "影响因素", caption: "睡眠、HRV 和周期同向", value: "三项同看", tint: VitoraTheme.ColorToken.auraBlue),
                CycleReviewRowModel(icon: "scope", title: "仍需校准", caption: "再观察三天，不催促", value: "3 天待确认", tint: VitoraTheme.ColorToken.actionPrimaryDeep),
            ]
        case .cycle:
            return [
                CycleReviewRowModel(icon: "calendar", title: "当前阶段", caption: "今天处在黄体中段", value: "D18", tint: VitoraTheme.ColorToken.lutealGold),
                CycleReviewRowModel(icon: "clock", title: "经期窗口", caption: "只是估算，支持校准", value: "5月8日-5月12日", tint: Color(red: 245 / 255, green: 143 / 255, blue: 176 / 255)),
                CycleReviewRowModel(icon: "leaf", title: "有效助力", caption: "轻量运动反馈更稳", value: "轻量运动", tint: VitoraTheme.ColorToken.success),
                CycleReviewRowModel(icon: "slider.horizontal.3", title: "下周期调整", caption: "强安排先避开恢复慢日", value: "周一缓冲", tint: VitoraTheme.ColorToken.actionPrimaryDeep),
            ]
        case .week:
            return [
                CycleReviewRowModel(icon: "clock", title: "低谷集中窗口", caption: "本周最需要留余量", value: "14:00-16:00", tint: VitoraTheme.ColorToken.lutealGold),
                CycleReviewRowModel(icon: "sun.max", title: "恢复较好时段", caption: "适合安排需要专注的事", value: "上午", tint: VitoraTheme.ColorToken.success),
                CycleReviewRowModel(icon: "waveform.path.ecg", title: "影响因素", caption: "睡眠、HRV 和周期共同解释", value: "睡眠 + HRV + 周期", tint: VitoraTheme.ColorToken.auraBlue),
                CycleReviewRowModel(icon: "target", title: "仍需校准", caption: "中性确认，不是失败", value: "3 天待确认", tint: VitoraTheme.ColorToken.actionPrimaryDeep),
            ]
        }
    }
}

private enum CycleReviewTab: String, CaseIterable, Identifiable {
    case week
    case trend
    case cycle

    var id: String { rawValue }

    var title: String {
        switch self {
        case .week:
            return "本周"
        case .trend:
            return "趋势（月）"
        case .cycle:
            return "周期"
        }
    }

    var accessibilityID: String {
        switch self {
        case .week:
            return "cycle.review.tab.week"
        case .trend:
            return "cycle.review.tab.trend"
        case .cycle:
            return "cycle.review.tab.cycle"
        }
    }
}

private struct CycleReviewTabLabel: View {
    let tab: CycleReviewTab
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 5) {
            Text(tab.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(isSelected ? VitoraTheme.ColorToken.strongText : VitoraTheme.ColorToken.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.76)

            Capsule()
                .fill(isSelected ? VitoraTheme.ColorToken.auraCyan : Color.clear)
                .frame(width: 23, height: 3)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(
            Group {
                if isSelected {
                    GlassSurface(cornerRadius: 22, opacity: 0.76, shadowStrength: 0.26, variant: .cleanElevated)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .contentShape(Rectangle())
    }
}

private struct CycleReviewSnapshotGrid: View {
    private let primaryItems: [CycleReviewSnapshotItem] = [
        .init(title: "当前阶段", value: "黄体期 D18", caption: "以今天的位置理解波动"),
        .init(title: "本周平均", value: "62%", caption: "较上周 ↑5%"),
    ]
    private let secondaryItems: [CycleReviewSnapshotItem] = [
        .init(title: "低谷窗口", value: "14:00-16:00", caption: "午后保留余量"),
        .init(title: "待确认", value: "3 天", caption: "继续用记录校准"),
    ]

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                CycleReviewSnapshotMetric(item: primaryItems[0], prominence: .primary)

                Divider()
                    .overlay(VitoraTheme.ColorToken.secondaryText.opacity(0.16))
                    .frame(height: 46)
                    .padding(.horizontal, 10)

                CycleReviewSnapshotMetric(item: primaryItems[1], prominence: .primary)
            }

            Divider()
                .overlay(VitoraTheme.ColorToken.secondaryText.opacity(0.12))

            HStack(spacing: 0) {
                CycleReviewSnapshotMetric(item: secondaryItems[0], prominence: .secondary)

                Divider()
                    .overlay(VitoraTheme.ColorToken.secondaryText.opacity(0.12))
                    .frame(height: 28)
                    .padding(.horizontal, 10)

                CycleReviewSnapshotMetric(item: secondaryItems[1], prominence: .secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(VitoraTheme.ColorToken.paper.opacity(0.50), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.68), lineWidth: 0.7)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("周期摘要，黄体期第十八天，本周平均百分之六十二，低谷窗口十四点到十六点，仍需三天确认")
    }
}

private struct CycleReviewSnapshotMetric: View {
    enum Prominence {
        case primary
        case secondary
    }

    let item: CycleReviewSnapshotItem
    let prominence: Prominence

    var body: some View {
        VStack(alignment: .leading, spacing: prominence == .primary ? 4 : 2) {
            Text(item.title)
                .font(.system(size: prominence == .primary ? 10.5 : 9.5, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.76)

            Text(item.value)
                .font(.system(size: prominence == .primary ? 18 : 13, weight: .heavy))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            Text(item.caption)
                .font(.system(size: prominence == .primary ? 10 : 9.5, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CycleReviewSnapshotItem: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let caption: String
}

private struct CycleReviewRowModel {
    let icon: String
    let title: String
    let caption: String
    let value: String
    let tint: Color
}

private struct CycleReviewInsightRow: View {
    let row: CycleReviewRowModel

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: row.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(row.tint)
                .frame(width: 25, height: 25)
                .background(row.tint.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(row.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text(row.caption)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 8)

            Text(row.value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.64))
        }
        .frame(minHeight: 44)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(row.title)，\(row.caption)，\(row.value)")
    }
}

private struct CycleShareCardSnapshotView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 10) {
                PixelVitoraScene(
                    state: .idle,
                    size: 36,
                    accessory: .none,
                    showsSparkles: true,
                    showsBaseShadow: true
                )
                .frame(width: 50, height: 50)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Vitora 周期回顾")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Text("黄体期 Day 18 · 轻量分享卡")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("今日能量")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                Text("68%")
                    .font(.system(size: 44, weight: .heavy))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Spacer()
                Text("低谷 14:00")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .padding(.horizontal, 10)
                    .frame(height: 30)
                    .background(VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.62), in: Capsule())
            }

            VStack(alignment: .leading, spacing: 10) {
                CycleShareInsightLine(symbol: "clock", title: "低谷集中窗口", value: "14:00-16:00")
                CycleShareInsightLine(symbol: "sun.max", title: "恢复较好时段", value: "上午")
                CycleShareInsightLine(symbol: "waveform.path.ecg", title: "影响因素", value: "睡眠 + HRV + 周期")
            }
            .padding(14)
            .background(VitoraTheme.ColorToken.paper.opacity(0.58), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.70), lineWidth: 0.8)
            )

            Text("这张卡只包含当前可见的周期摘要，不包含记录原文或隐藏健康数据。")
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .frame(width: 360, alignment: .leading)
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 236 / 255, green: 250 / 255, blue: 255 / 255),
                        Color(red: 249 / 255, green: 253 / 255, blue: 252 / 255),
                        Color(red: 242 / 255, green: 248 / 255, blue: 255 / 255),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(VitoraTheme.ColorToken.auraCyan.opacity(0.22))
                    .frame(width: 180, height: 180)
                    .blur(radius: 42)
                    .offset(x: 96, y: -132)

                Circle()
                    .fill(VitoraTheme.ColorToken.lutealGold.opacity(0.16))
                    .frame(width: 160, height: 160)
                    .blur(radius: 42)
                    .offset(x: -108, y: 128)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.88), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

private struct CycleShareInsightLine: View {
    let symbol: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .frame(width: 26, height: 26)
                .background(VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.62), in: Circle())

            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
        }
    }
}

private struct CycleShareActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.view.accessibilityIdentifier = "cycle.share.sheet"
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private enum CycleRhythmInsight: String, CaseIterable, Identifiable {
    case regularity
    case support
    case adjustment

    var id: String { rawValue }

    var title: String {
        switch self {
        case .regularity:
            return "规律模式"
        case .support:
            return "有效助力"
        case .adjustment:
            return "下周期调整"
        }
    }

    var summary: String {
        switch self {
        case .regularity:
            return "稳定波动"
        case .support:
            return "轻量运动"
        case .adjustment:
            return "周一缓冲"
        }
    }

    var body: String {
        switch self {
        case .regularity:
            return "过去 30 天里，能量低谷更常集中在 14:00-16:00，上午恢复感通常更稳。"
        case .support:
            return "轻量运动和提前补充蛋白更容易让晚间反馈变成“有帮助”。"
        case .adjustment:
            return "下个周期的周一建议先留缓冲，把高强度安排放到上午。"
        }
    }

    var evidence: [String] {
        switch self {
        case .regularity:
            return ["低谷集中窗口 14:00-16:00", "恢复较好时段 上午", "仍需 3 天确认"]
        case .support:
            return ["轻走 10 分钟后反馈更好", "蛋白补充靠近低谷前", "不是任务完成率"]
        case .adjustment:
            return ["黄体期中段更需要余量", "周三后恢复变慢", "下周期先保留周一缓冲"]
        }
    }

    var recommendation: String {
        switch self {
        case .regularity:
            return "今天先把需要专注的事放到上午，午后只保留一件轻任务。"
        case .support:
            return "继续保留轻走和蛋白补充，但不把它变成每日任务。"
        case .adjustment:
            return "下周期第 1 周先把强安排拆小，等 Vitora 再确认三天趋势。"
        }
    }

    var symbol: String {
        switch self {
        case .regularity:
            return "calendar"
        case .support:
            return "leaf"
        case .adjustment:
            return "slider.horizontal.3"
        }
    }

    var tint: Color {
        switch self {
        case .regularity:
            return VitoraTheme.ColorToken.auraBlue
        case .support:
            return VitoraTheme.ColorToken.success
        case .adjustment:
            return VitoraTheme.ColorToken.actionPrimaryDeep
        }
    }
}

private struct CycleInsightSwitcher: View {
    @State private var selected: CycleRhythmInsight = .regularity
    let onOpenDetail: (CycleRhythmInsight) -> Void
    let onAskVitora: (CycleRhythmInsight) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 3) {
                ForEach(CycleRhythmInsight.allCases) { insight in
                    Button {
                        withAnimation(.easeOut(duration: 0.18)) {
                            selected = insight
                        }
                    } label: {
                        Text(insight.title)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(selected == insight ? VitoraTheme.ColorToken.strongText : VitoraTheme.ColorToken.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(selected == insight ? VitoraTheme.ColorToken.paper.opacity(0.86) : Color.clear, in: Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(selected == insight ? Color.white.opacity(0.72) : Color.clear, lineWidth: 0.7)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("cycle.insight.tab.\(insight.id)")
                }
            }
            .padding(4)
            .background(GlassSurface(cornerRadius: 20, opacity: 0.52, shadowStrength: 0.16, variant: .cleanResting))

            Button {
                onOpenDetail(selected)
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: selected.symbol)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(selected.tint)
                            .frame(width: 34, height: 34)
                            .background(selected.tint.opacity(0.13), in: Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(selected.title)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            Text(selected.summary)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(selected.tint)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.62))
                    }

                    Text(selected.body)
                        .font(.system(size: 14, weight: .semibold))
                        .lineSpacing(3)
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 7) {
                        ForEach(selected.evidence.prefix(2), id: \.self) { evidence in
                            Text(evidence)
                                .font(.system(size: 10.5, weight: .bold))
                                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                                .padding(.horizontal, 8)
                                .frame(height: 26)
                                .background(VitoraTheme.ColorToken.paper.opacity(0.42), in: Capsule())
                        }
                    }
                }
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(GlassSurface(cornerRadius: 24, opacity: 0.66, shadowStrength: 0.34, variant: .cleanResting))
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button("问 Vitora", action: { onAskVitora(selected) })
                Button("查看详情", action: { onOpenDetail(selected) })
            }
            .id(selected)
            .transition(.opacity)
            .accessibilityIdentifier("cycle.insight.open")
        }
        .padding(14)
        .background(GlassSurface(cornerRadius: 26, opacity: 0.66, shadowStrength: 0.42, variant: .cleanElevated))
    }
}
private struct CycleInsightDetailSheet: View {
    let insight: CycleRhythmInsight
    let onClose: () -> Void
    let onAskVitora: () -> Void

    var body: some View {
        cycleDetailContainer(title: insight.title, subtitle: "Vitora 如何把这条洞察联动到今天", onClose: onClose) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: insight.symbol)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(insight.tint)
                        .frame(width: 38, height: 38)
                        .background(insight.tint.opacity(0.13), in: Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text(insight.summary)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        Text("基于能量动态、周期阶段和晚间复盘。")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }
                }

                Text(insight.body)
                    .font(.subheadline.weight(.semibold))
                    .lineSpacing(4)
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GlassSurface(cornerRadius: 24, opacity: 0.70, shadowStrength: 0.32, variant: .cleanElevated))

            cycleInfoBlock(title: "Vitora 看到的证据", lines: insight.evidence)
            cycleInfoBlock(title: "今天怎么联动", lines: [insight.recommendation])

            Button(action: onAskVitora) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .bold))
                    Text("告诉 Vitora 这条洞察不准")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                }
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .padding(.horizontal, 15)
                .frame(minHeight: 48)
                .background(GlassSurface(cornerRadius: 20, opacity: 0.68, shadowStrength: 0.24, variant: .cleanResting))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("cycle.insight.askVitora")
        }
        .accessibilityIdentifier("cycle.insight.detail.sheet")
    }
}
private enum CycleSheet: Identifiable {
    case phase
    case energy
    case settings
    case insight(CycleRhythmInsight)

    var id: String {
        switch self {
        case .phase:
            return "phase"
        case .energy:
            return "energy"
        case .settings:
            return "settings"
        case let .insight(insight):
            return "insight.\(insight.id)"
        }
    }
}
