import SwiftUI
import UIKit

struct CycleView: View {
    @ObservedObject var environment: AppEnvironment
    @State private var sheet: CycleSheet?
    @State private var shareImage: UIImage?
    @State private var isSharePresented = false
    @State private var shareFailurePresented = false
    @State private var isSidebarOpen = false

    var body: some View {
        ZStack {
            WaterAuraReferenceBackground(scene: .cycle, intensity: 1.02)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    cycleTopBar

                    CycleReviewInsightCard()
                }
                .padding(.horizontal, VitoraTheme.Spacing.screenMargin)
                .padding(.top, 4)
                .padding(.bottom, VitoraTheme.Size.tabBarHeight + 42)
            }

            // Sidebar overlay
            if isSidebarOpen {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.24)) { isSidebarOpen = false }
                    }
                    .transition(.opacity)

                SidebarProfileView(
                    onClose: { withAnimation(.easeOut(duration: 0.24)) { isSidebarOpen = false } },
                    onOpenSettings: {
                        withAnimation(.easeOut(duration: 0.24)) { isSidebarOpen = false }
                        sheet = .settings
                    }
                )
                .frame(width: 300)
                .frame(maxHeight: .infinity)
                .transition(.move(edge: .leading))
                .zIndex(10)
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
            case .hormoneCalendar:
                HormoneCalendarView(onClose: { self.sheet = nil })
            }
        }
        .preference(key: AppSheetPresentationPreferenceKey.self, value: sheet != nil || isSharePresented)
        .accessibilityIdentifier("cycle.pivot.surface")
    }

    private var cycleTopBar: some View {
        HStack {
            // 我的 (sidebar)
            Button { withAnimation(.easeOut(duration: 0.28)) { isSidebarOpen = true } } label: {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .frame(width: 38, height: 38)
                    .background(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.72), in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.62), lineWidth: 0.7))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("我的")
            .accessibilityIdentifier("cycle.settings")

            Spacer()

            // 激素日历
            Button { sheet = .hormoneCalendar } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .frame(width: 38, height: 38)
                    .background(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.72), in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.62), lineWidth: 0.7))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("激素日历")

            // 分享
            Button { presentCycleShareCard() } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .frame(width: 38, height: 38)
                    .background(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.72), in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.62), lineWidth: 0.7))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("分享周期卡片")
            .accessibilityIdentifier("cycle.share")
        }
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
            VStack(alignment: .leading, spacing: 0) {
                Image("PixelGarden")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 26, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 26, style: .continuous))

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("这 30 天，Vitora 看见的三件事")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            .accessibilityIdentifier("cycle.review.insights")
                        Text("Vitora 已更新 5月8日 的理解")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }

                    CycleReviewSnapshotGrid()

                    CyclePhaseDistributionBar()
                }
                .padding(14)
            }
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.88))
                    .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.10), radius: 14, x: 0, y: 6)
            )
            .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))

            segmentedTabs

            VStack(spacing: 12) {
                if selectedTab == .cycle {
                    CyclePeriodTabContent()
                } else if selectedTab == .trend {
                    CycleMonthComparisonView()
                } else {
                    // Week tab: insight rows + energy curve
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
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(GlassSurface(cornerRadius: 24, opacity: 0.70, shadowStrength: 0.34, variant: .cleanResting))

                    CycleWeeklyEnergyCurve()
                }
            }
            .id(selectedTab)
            .transition(.opacity)
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
            return "趋势（对比）"
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
    case hormoneCalendar

    var id: String {
        switch self {
        case .phase: return "phase"
        case .energy: return "energy"
        case .settings: return "settings"
        case let .insight(insight): return "insight.\(insight.id)"
        case .hormoneCalendar: return "hormoneCalendar"
        }
    }
}

// MARK: - 30天成长册

private struct CycleGrowthJournal: View {
    let currentDay: Int
    let recordedDays: Set<Int>
    let confirmedDays: Set<Int>

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 5)

    private var completedCount: Int {
        (1...30).filter { recordedDays.contains($0) || confirmedDays.contains($0) }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("30天成长册")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                Spacer()

                Text("\(completedCount) / 30")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.12))
                    )
            }

            Text("每天一张能量花卡，回看哪里更像你")
                .font(.caption)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            // Grid
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(1...30, id: \.self) { day in
                    FlowerDayCell(
                        day: day,
                        state: flowerState(for: day),
                        isCurrent: day == currentDay,
                        isFuture: day > currentDay
                    )
                }
            }

            // Legend
            HStack(spacing: 16) {
                legendItem(emoji: "🌱", label: "花苞", caption: "待确认")
                legendItem(emoji: "🌸", label: "半开", caption: "已记录")
                legendItem(emoji: "🌺", label: "盛开", caption: "已反馈")
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.72), lineWidth: 0.8)
                )
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .accessibilityIdentifier("cycle.growth.journal")
    }

    private func flowerState(for day: Int) -> FlowerDayCell.FlowerState {
        if confirmedDays.contains(day) { return .fullBloom }
        if recordedDays.contains(day) { return .halfBloom }
        return .bud
    }

    private func legendItem(emoji: String, label: String, caption: String) -> some View {
        HStack(spacing: 5) {
            Text(emoji)
                .font(.system(size: 16))
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text(caption)
                    .font(.caption2)
                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
            }
        }
    }
}

private struct FlowerDayCell: View {
    enum FlowerState {
        case bud, halfBloom, fullBloom
    }

    let day: Int
    let state: FlowerState
    let isCurrent: Bool
    let isFuture: Bool

    private var flowerEmoji: String {
        if isFuture { return "🪴" }
        switch state {
        case .bud: return "🌱"
        case .halfBloom: return "🌸"
        case .fullBloom: return "🌺"
        }
    }

    var body: some View {
        VStack(spacing: 2) {
            Text("\(day)")
                .font(.system(size: 11, weight: isCurrent ? .bold : .medium))
                .foregroundStyle(isCurrent
                    ? VitoraTheme.ColorToken.actionPrimaryDeep
                    : (isFuture ? VitoraTheme.ColorToken.tertiaryText : VitoraTheme.ColorToken.strongText))

            Text(flowerEmoji)
                .font(.system(size: isFuture ? 18 : 22))
                .opacity(isFuture ? 0.35 : 1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isCurrent ? VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.06) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isCurrent ? VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.52) : Color.clear, lineWidth: 1.5)
                )
        )
        .overlay(alignment: .bottomTrailing) {
            if isCurrent {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .offset(x: 2, y: 2)
            }
        }
    }
}

// MARK: - Weekly Energy Curve

private struct CycleWeeklyEnergyCurve: View {
    @State private var selectedPoint: Int? = nil

    private struct PointData {
        let day: String
        let pct: Int
        let tag: String
        let tagColor: Color
        let relation: String
        let observation: String
    }

    private let points: [PointData] = [
        PointData(day: "周日", pct: 68, tag: "", tagColor: .clear, relation: "状态平稳", observation: "基线水平"),
        PointData(day: "周一", pct: 48, tag: "低谷", tagColor: Color(red: 0.95, green: 0.72, blue: 0.28), relation: "睡眠偏短 · HRV 回落", observation: "恢复变慢"),
        PointData(day: "周二", pct: 64, tag: "恢复", tagColor: Color(red: 0.38, green: 0.78, blue: 0.52), relation: "深睡增加", observation: "开始回升"),
        PointData(day: "周三", pct: 36, tag: "", tagColor: .clear, relation: "睡眠偏短 · HRV 回落", observation: "恢复变慢"),
        PointData(day: "周四", pct: 82, tag: "高点", tagColor: Color(red: 0.92, green: 0.52, blue: 0.52), relation: "运动 + 深睡充足", observation: "能量峰值"),
        PointData(day: "周五", pct: 72, tag: "", tagColor: .clear, relation: "节奏平稳", observation: "维持较好"),
        PointData(day: "周六", pct: 70, tag: "今天", tagColor: Color(red: 0.42, green: 0.62, blue: 0.90), relation: "周期黄体期", observation: "适合留余量"),
    ]

    private var values: [CGFloat] { points.map { CGFloat($0.pct) / 100.0 } }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { proxy in
                let w = proxy.size.width
                let h = proxy.size.height
                let padL: CGFloat = 36, padR: CGFloat = 8, padT: CGFloat = 28, padB: CGFloat = 24
                let chartW = w - padL - padR, chartH = h - padT - padB

                ZStack(alignment: .topLeading) {
                    // Y-axis
                    ForEach([("100%", 0.0), ("50%", 0.5), ("0%", 1.0)], id: \.0) { label, frac in
                        Text(label).font(.system(size: 9, weight: .medium)).foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                            .position(x: 16, y: padT + chartH * frac)
                    }

                    // Grid + curve
                    Canvas { ctx, _ in
                        for frac in [0.0, 0.5, 1.0] {
                            let y = padT + chartH * frac
                            var p = Path(); p.move(to: CGPoint(x: padL, y: y)); p.addLine(to: CGPoint(x: w - padR, y: y))
                            ctx.stroke(p, with: .color(Color.gray.opacity(0.12)), style: StrokeStyle(lineWidth: 0.8, dash: [3, 5]))
                        }
                        var curve = Path()
                        for (i, val) in values.enumerated() {
                            let x = padL + chartW * CGFloat(i) / CGFloat(values.count - 1)
                            let y = padT + chartH * (1 - val)
                            if i == 0 { curve.move(to: CGPoint(x: x, y: y)) } else { curve.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        ctx.stroke(curve, with: .color(VitoraTheme.ColorToken.actionPrimaryDeep), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    }

                    // Dots + tap targets
                    ForEach(0..<points.count, id: \.self) { i in
                        let pt = points[i]
                        let x = padL + chartW * CGFloat(i) / CGFloat(values.count - 1)
                        let y = padT + chartH * (1 - values[i])
                        let hasTag = !pt.tag.isEmpty

                        // Dot
                        Circle().fill(hasTag ? pt.tagColor : VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.6))
                            .frame(width: hasTag ? 10 : 6, height: hasTag ? 10 : 6)
                            .position(x: x, y: y)

                        // Tag above dot
                        if hasTag {
                            Text(pt.tag).font(.system(size: 10, weight: .bold)).foregroundStyle(pt.tagColor)
                                .position(x: x, y: y - 16)
                        }

                        // Tap area
                        Color.clear.frame(width: 44, height: 44).contentShape(Rectangle())
                            .position(x: x, y: y)
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.18)) {
                                    selectedPoint = selectedPoint == i ? nil : i
                                }
                            }

                        // X-axis label
                        Text(pt.day).font(.system(size: 9, weight: .medium)).foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                            .position(x: x, y: h - 6)
                    }

                    // Bubble popup
                    if let sel = selectedPoint, sel < points.count {
                        let pt = points[sel]
                        let x = padL + chartW * CGFloat(sel) / CGFloat(values.count - 1)
                        let y = padT + chartH * (1 - values[sel])
                        let bubbleX = min(max(x, 90), w - 90)

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(pt.day).font(.system(size: 15, weight: .bold)).foregroundStyle(VitoraTheme.ColorToken.strongText)
                                Text("\(pt.pct)%").font(.system(size: 15, weight: .bold)).foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                            }
                            Text("可能关联：\(pt.relation)")
                                .font(.system(size: 12, weight: .medium)).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            Text("Vitora 看到：\(pt.observation)")
                                .font(.system(size: 12, weight: .medium)).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            Text("问 Vitora >")
                                .font(.system(size: 13, weight: .bold)).foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
                        )
                        .position(x: bubbleX, y: max(8, y - 72))
                        .transition(.opacity)
                    }
                }
            }
            .frame(height: 190)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.82))
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .accessibilityIdentifier("cycle.weekly.energy.curve")
    }
}

// MARK: - Period Tab Content

private struct CyclePeriodTabContent: View {
    private let cardBg = VitoraTheme.ColorToken.surfacePearlMain.opacity(0.82)
    private let cardRadius: CGFloat = 22

    var body: some View {
        VStack(spacing: 14) {
            // Combined phase + dominance card
            phaseOverviewCard

            // Nutrient supplement card
            nutrientCard

            // CTA
            Button {} label: {
                HStack {
                    Text("告诉 Vitora 这个阶段不准")
                        .font(.subheadline.weight(.bold))
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .frame(maxWidth: .infinity).frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.38), lineWidth: 1.5)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.white.opacity(0.52)))
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Phase Overview (merged phase + dominance)

    private var phaseOverviewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("当前周期阶段与今天")
                .font(.caption.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            Text("Day 18 · 黄体期中段")
                .font(.title2.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            phaseAxis

            Divider().overlay(Color.white.opacity(0.5))

            // Dominance inline
            HStack(alignment: .top, spacing: 10) {
                PixelVitoraView(state: .idle, size: 30, showsGlow: false)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("黄体期占比")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        Text("57%")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color(red: 0.90, green: 0.68, blue: 0.22))
                    }
                    Text("能量波动更多出现在黄体期中后段，建议稳定补给。")
                        .font(.caption)
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: cardRadius, style: .continuous).fill(cardBg)
                .overlay(RoundedRectangle(cornerRadius: cardRadius, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }

    private var phaseAxis: some View {
        VStack(spacing: 6) {
            HStack { Spacer(); Text("黄体中段").font(.caption2.weight(.bold)).foregroundStyle(Color(red: 0.90, green: 0.68, blue: 0.22)).padding(.trailing, 12) }
            GeometryReader { proxy in
                let w = proxy.size.width
                ZStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Capsule().fill(Color(red: 0.88, green: 0.42, blue: 0.44)).frame(width: w * 0.18)
                        Capsule().fill(Color(red: 0.55, green: 0.75, blue: 0.90)).frame(width: w * 0.29)
                        Capsule().fill(Color(red: 0.60, green: 0.80, blue: 0.56)).frame(width: w * 0.14)
                        Capsule().fill(Color(red: 0.95, green: 0.78, blue: 0.38)).frame(width: w * 0.39)
                    }.frame(height: 6)
                    Circle().fill(Color(red: 0.88, green: 0.42, blue: 0.44)).frame(width: 10, height: 10).position(x: w * 0.0, y: 3)
                    Circle().fill(Color(red: 0.55, green: 0.75, blue: 0.90)).frame(width: 10, height: 10).position(x: w * 0.18, y: 3)
                    Circle().fill(Color(red: 0.60, green: 0.80, blue: 0.56)).frame(width: 10, height: 10).position(x: w * 0.47, y: 3)
                    Circle().fill(Color(red: 0.95, green: 0.78, blue: 0.38)).frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2)).position(x: w * 0.82, y: 3)
                }
            }.frame(height: 14)
            HStack {
                Text("月经").font(.caption2.weight(.medium)).foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                Spacer()
                Text("卵泡").font(.caption2.weight(.medium)).foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                Spacer()
                Text("排卵").font(.caption2.weight(.medium)).foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                Spacer()
                Text("今天").font(.caption2.weight(.bold)).foregroundStyle(VitoraTheme.ColorToken.strongText)
            }
        }
    }

    // MARK: Nutrient Supplement Card

    private struct NutrientItem {
        let symbol: String
        let name: String
        let effect: String
        let color: Color
    }

    private let nutrients: [NutrientItem] = [
        NutrientItem(symbol: "drop.fill", name: "铁", effect: "补充经期流失，改善疲惫感", color: Color(red: 0.85, green: 0.38, blue: 0.38)),
        NutrientItem(symbol: "leaf.fill", name: "镁", effect: "缓解痛经和肌肉紧张", color: Color(red: 0.38, green: 0.72, blue: 0.52)),
        NutrientItem(symbol: "circle.hexagongrid.fill", name: "钙", effect: "稳定情绪，减轻经前不适", color: Color(red: 0.52, green: 0.68, blue: 0.88)),
        NutrientItem(symbol: "bolt.fill", name: "维生素 B6", effect: "调节激素平衡，减少水肿", color: Color(red: 0.92, green: 0.72, blue: 0.32)),
    ]

    private var nutrientCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                Text("经期营养补充建议")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }

            Text("黄体期中后段，这些微量元素对身体恢复尤为重要：")
                .font(.caption)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            ForEach(nutrients, id: \.name) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.symbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(item.color)
                        .frame(width: 36, height: 36)
                        .background(item.color.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        Text(item.effect)
                            .font(.caption)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            .lineLimit(2)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: cardRadius, style: .continuous).fill(cardBg)
                .overlay(RoundedRectangle(cornerRadius: cardRadius, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }
}


// MARK: - Phase Distribution Bar

private struct CyclePhaseDistributionBar: View {
    private let phases: [(label: String, pct: Double, color: Color)] = [
        ("月经", 0.00, Color(red: 0.88, green: 0.42, blue: 0.44)),
        ("卵泡", 0.29, Color(red: 0.55, green: 0.75, blue: 0.90)),
        ("排卵", 0.14, Color(red: 0.72, green: 0.62, blue: 0.88)),
        ("黄体", 0.57, Color(red: 0.95, green: 0.78, blue: 0.38)),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("阶段分布")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            // Bar
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    ForEach(phases, id: \.label) { phase in
                        if phase.pct > 0 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(phase.color)
                                .frame(width: max(4, proxy.size.width * phase.pct))
                        }
                    }
                }
                .clipShape(Capsule())
            }
            .frame(height: 10)

            // Legend
            HStack(spacing: 14) {
                ForEach(phases, id: \.label) { phase in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(phase.color)
                            .frame(width: 8, height: 8)
                        Text("\(phase.label) \(Int(phase.pct * 100))%")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.82))
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .accessibilityIdentifier("cycle.phase.distribution")
    }
}

// MARK: - Month Comparison View

private struct CycleMonthComparisonView: View {
    private let cardBg = VitoraTheme.ColorToken.surfacePearlMain.opacity(0.82)
    private let cardRadius: CGFloat = 22

    private struct CompareRow {
        let label: String
        let icon: String
        let lastMonth: String
        let thisMonth: String
        let trend: Trend

        enum Trend { case up, down, same }
    }

    private let rows: [CompareRow] = [
        CompareRow(label: "平均能量", icon: "bolt.fill", lastMonth: "58%", thisMonth: "62%", trend: .up),
        CompareRow(label: "低谷天数", icon: "arrow.down.right", lastMonth: "8 天", thisMonth: "5 天", trend: .up),
        CompareRow(label: "深睡平均", icon: "moon.fill", lastMonth: "1.2h", thisMonth: "1.5h", trend: .up),
        CompareRow(label: "HRV 均值", icon: "waveform.path.ecg", lastMonth: "42 ms", thisMonth: "48 ms", trend: .up),
        CompareRow(label: "痛经天数", icon: "cross.fill", lastMonth: "3 天", thisMonth: "2 天", trend: .up),
        CompareRow(label: "周期长度", icon: "calendar", lastMonth: "30 天", thisMonth: "28 天", trend: .same),
    ]

    var body: some View {
        VStack(spacing: 14) {
            summaryCard
            comparisonTable
            vitoraInsight
        }
    }

    private var summaryCard: some View {
        HStack(spacing: 12) {
            PixelVitoraView(state: .idle, size: 30, showsGlow: false)
            VStack(alignment: .leading, spacing: 4) {
                Text("本月整体优于上月")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text("平均能量 ↑4%，低谷天数减少 3 天，深睡改善明显。")
                    .font(.caption)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: cardRadius, style: .continuous).fill(cardBg)
                .overlay(RoundedRectangle(cornerRadius: cardRadius, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }

    private var comparisonTable: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("上月")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                    .frame(width: 60)
                Text("本月")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .frame(width: 60)
                Text("")
                    .frame(width: 28)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

            ForEach(rows, id: \.label) { row in
                VStack(spacing: 0) {
                    Divider().overlay(Color.white.opacity(0.5))
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: row.icon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                                .frame(width: 24)
                            Text(row.label)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Text(row.lastMonth)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                            .frame(width: 60)

                        Text(row.thisMonth)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            .frame(width: 60)

                        Image(systemName: trendIcon(row.trend))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(trendColor(row.trend))
                            .frame(width: 28)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: cardRadius, style: .continuous).fill(cardBg)
                .overlay(RoundedRectangle(cornerRadius: cardRadius, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }

    private var vitoraInsight: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vitora 看到的变化")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            VStack(alignment: .leading, spacing: 6) {
                insightBullet("深睡时长增加约 15 分钟，恢复弹性改善")
                insightBullet("低谷天从上月 8 天降到 5 天，节奏更稳")
                insightBullet("痛经天数减少，可能与补铁和轻运动有关")
                insightBullet("周期长度回到 28 天，接近你的平均水平")
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: cardRadius, style: .continuous).fill(cardBg)
                .overlay(RoundedRectangle(cornerRadius: cardRadius, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }

    private func insightBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.6))
                .frame(width: 5, height: 5)
                .offset(y: 6)
            Text(text)
                .font(.caption)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func trendIcon(_ trend: CompareRow.Trend) -> String {
        switch trend {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .same: return "equal"
        }
    }

    private func trendColor(_ trend: CompareRow.Trend) -> Color {
        switch trend {
        case .up: return Color(red: 0.28, green: 0.76, blue: 0.52)
        case .down: return Color(red: 0.92, green: 0.48, blue: 0.42)
        case .same: return VitoraTheme.ColorToken.tertiaryText
        }
    }
}

// MARK: - Sidebar Profile

private struct SidebarProfileView: View {
    let onClose: () -> Void
    let onOpenSettings: () -> Void

    private struct MenuItem {
        let icon: String
        let title: String
        let color: Color
    }

    private let items: [MenuItem] = [
        MenuItem(icon: "heart.text.square", title: "数据来源", color: Color(red: 0.88, green: 0.44, blue: 0.62)),
        MenuItem(icon: "leaf.fill", title: "营养管理", color: Color(red: 0.42, green: 0.76, blue: 0.52)),
        MenuItem(icon: "bell.fill", title: "提醒设置", color: Color(red: 0.92, green: 0.72, blue: 0.32)),
        MenuItem(icon: "square.and.arrow.up", title: "数据导出", color: Color(red: 0.52, green: 0.68, blue: 0.88)),
        MenuItem(icon: "lock.shield", title: "隐私与账号", color: Color(red: 0.62, green: 0.58, blue: 0.82)),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    }
                    Spacer()
                    Text("我的")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Spacer()
                    Color.clear.frame(width: 18)
                }

                // Profile row
                HStack(spacing: 14) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.90, green: 0.76, blue: 0.92),
                                    Color(red: 0.72, green: 0.82, blue: 0.95),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 54, height: 54)
                        .overlay(
                            Text("🌸")
                                .font(.system(size: 26))
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text("小雨")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                        }
                        Text("本地模式")
                            .font(.caption)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }

                    Spacer()
                }

                // VIP-style card
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vitora Pro")
                            .font(.headline.weight(.black))
                            .foregroundStyle(.white)
                        Text("解锁完整营养分析与长周期对比")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.78))
                    }

                    Spacer()

                    Text("了解更多")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(red: 0.22, green: 0.18, blue: 0.14))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(Color(red: 0.95, green: 0.88, blue: 0.72))
                        )
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.18, green: 0.16, blue: 0.22),
                                    Color(red: 0.28, green: 0.24, blue: 0.32),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .padding(20)
            .padding(.top, 8)

            Divider().padding(.horizontal, 20)

            // Menu items
            VStack(spacing: 0) {
                ForEach(items, id: \.title) { item in
                    Button(action: onOpenSettings) {
                        HStack(spacing: 14) {
                            Image(systemName: item.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(item.color)
                                .frame(width: 34, height: 34)
                                .background(item.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                            Text(item.title)
                                .font(.body.weight(.medium))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)

            Spacer()
        }
        .background(VitoraTheme.ColorToken.surfacePearlMain)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 24, topTrailingRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.14), radius: 20, x: 8, y: 0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("sidebar.profile")
    }
}
