import SwiftUI
import UIKit

struct AppRouter: View {
    @ObservedObject var environment: AppEnvironment

    var body: some View {
        switch environment.route {
        case .onboarding:
            AppGateView(environment: environment)
        case .today:
            MainTabShell(environment: environment)
        }
    }
}

private struct MainTabShell: View {
    @ObservedObject var environment: AppEnvironment
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var isChildSheetPresented = false

    var body: some View {
        currentTabContent
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if shouldShowGlobalDock {
                    GlobalVitoraDock(
                        selectedTab: environment.navigationState.selectedTab,
                        onSelectTab: environment.selectTab,
                        onQuickRecord: environment.openQuickRecord
                    )
                }
            }
        .onPreferenceChange(AppSheetPresentationPreferenceKey.self) { isPresented in
            isChildSheetPresented = isPresented
        }
        .overlay(alignment: .bottom) {
            if environment.navigationState.presentation == .vitoraContextualSheet {
                ZStack(alignment: .bottom) {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            environment.dismissPresentation()
                        }
                        .accessibilityIdentifier("vitora.context.backdrop")

                    VitoraContextualSheet(
                        context: environment.vitoraContext,
                        onClose: environment.dismissPresentation,
                        onSubmit: environment.submitQuickRecordFeedback
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(20)
            }
        }
        .animation(.easeOut(duration: 0.22), value: environment.navigationState.presentation == .vitoraContextualSheet)
        .onAppear {
            environment.consumePendingQuickRecordLaunchIfNeeded()
        }
        .sheet(
            isPresented: Binding(
                get: { environment.navigationState.presentation == .eveningReview },
                set: { isPresented in
                    if !isPresented {
                        environment.dismissPresentation()
                    }
                }
            )
        ) {
            EveningReviewSheet(
                review: environment.eveningReview,
                learningSignal: environment.reviewLearningSignal,
                onSubmit: environment.submitEveningReview,
                onTellVitora: {
                    environment.openVitoraContext(
                        sourceTitle: "晚间复盘",
                        sourceSummary: environment.eveningReview.afterSummary.isEmpty ? environment.eveningReview.beforeSummary : environment.eveningReview.afterSummary,
                        prompt: "你可以补充今天这个建议后来有没有改变你的状态。"
                    )
                },
                onClose: environment.dismissPresentation
            )
            .presentationDetents([.fraction(0.78), .large])
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var currentTabContent: some View {
        switch environment.navigationState.selectedTab {
        case .today:
            TodayView(environment: environment)
        case .cycle:
            CycleView(environment: environment)
        }
    }

    private var shouldShowGlobalDock: Bool {
        environment.navigationState.presentation == nil && !isChildSheetPresented
    }
}

struct AppSheetPresentationPreferenceKey: PreferenceKey {
    static let defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

private struct GlobalVitoraDock: View {
    let selectedTab: PrimaryTab
    let onSelectTab: (PrimaryTab) -> Void
    let onQuickRecord: (QuickRecordLaunchMode) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showVoiceLaunchCue = false
    @State private var suppressNextQuickTap = false

    private let dockWidth: CGFloat = 312
    private let dockHeight: CGFloat = 64
    private let dockTopInset: CGFloat = 18
    private let plusDiameter: CGFloat = 56

    var body: some View {
        ZStack(alignment: .top) {
            bottomEmbeddingRail
                .offset(y: dockTopInset + dockHeight - 18)

            dockBody
                .offset(y: dockTopInset)

            quickRecordButton
        }
        .frame(width: dockWidth, height: dockHeight + dockTopInset + 5, alignment: .top)
        .offset(y: 10)
        .padding(.bottom, -10)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("global.vitora.dock")
    }

    private var bottomEmbeddingRail: some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .overlay {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.42),
                                Color(red: 208 / 255, green: 246 / 255, blue: 239 / 255).opacity(0.30),
                                Color(red: 226 / 255, green: 238 / 255, blue: 255 / 255).opacity(0.22),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .overlay(Capsule().stroke(Color.white.opacity(0.48), lineWidth: 0.6))
            .frame(width: dockWidth - 46, height: 20)
            .blur(radius: 0.2)
            .shadow(color: Color(red: 87 / 255, green: 201 / 255, blue: 188 / 255).opacity(0.12), radius: 18, x: 0, y: 3)
            .allowsHitTesting(false)
    }

    private var dockBody: some View {
        ZStack {
            NotchedDockShape(notchRadius: 42, notchDepth: 26, cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .overlay {
                    NotchedDockShape(notchRadius: 42, notchDepth: 26, cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.88),
                                    Color(red: 255 / 255, green: 253 / 255, blue: 249 / 255).opacity(0.82),
                                    Color(red: 244 / 255, green: 252 / 255, blue: 250 / 255).opacity(0.78),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    NotchedDockShape(notchRadius: 42, notchDepth: 26, cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.92),
                                    Color(red: 202 / 255, green: 211 / 255, blue: 218 / 255).opacity(0.34),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.9
                        )
                }
                .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 10)
                .shadow(color: Color(red: 104 / 255, green: 214 / 255, blue: 206 / 255).opacity(0.09), radius: 16, x: -10, y: 6)
                .shadow(color: Color(red: 246 / 255, green: 139 / 255, blue: 184 / 255).opacity(0.08), radius: 16, x: 10, y: 6)

            HStack(spacing: 0) {
                dockTabButton(tab: .today, title: "今日") {
                    HomeTabGlyph(isSelected: selectedTab == .today)
                }

                Spacer(minLength: 68)

                dockTabButton(tab: .cycle, title: "周期") {
                    FlowerCycleGlyph(isSelected: selectedTab == .cycle)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 13)
            .frame(height: dockHeight, alignment: .top)
        }
        .frame(width: dockWidth, height: dockHeight)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("primary.tabbar")
    }

    private var quickRecordButton: some View {
        ZStack(alignment: .top) {
            if showVoiceLaunchCue {
                Label("语音记录", systemImage: "mic.fill")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .padding(.horizontal, 12)
                    .frame(height: 32)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.72), lineWidth: 0.8))
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                    .offset(y: -42)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.88, anchor: .bottom)))
                    .allowsHitTesting(false)
            }

            Button {
                if suppressNextQuickTap {
                    suppressNextQuickTap = false
                    return
                }
                onQuickRecord(.manual)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: plusDiameter, height: plusDiameter)
                    .background(quickRecordBackground)
                    .accessibilityHidden(true)
            }
            .buttonStyle(.plain)
            .frame(width: 68, height: 68)
            .contentShape(Circle())
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.42)
                    .onEnded { _ in
                        launchVoiceQuickRecord()
                    }
            )
            .accessibilityLabel("快捷记录")
            .accessibilityHint("点按打开手动记录，长按打开语音记录")
            .accessibilityIdentifier("global.record.quick")
            .accessibilityAction(named: Text("语音记录")) {
                onQuickRecord(.voice)
            }
            .accessibilityAction(named: Text("打字记录")) {
                onQuickRecord(.text)
            }
        }
        .frame(width: 68, height: 68)
    }

    private func launchVoiceQuickRecord() {
        suppressNextQuickTap = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        withAnimation(.spring(response: reduceMotion ? 0.01 : 0.24, dampingFraction: 0.82)) {
            showVoiceLaunchCue = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            onQuickRecord(.voice)
            withAnimation(.easeOut(duration: 0.12)) {
                showVoiceLaunchCue = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            suppressNextQuickTap = false
        }
    }

    private var quickRecordBackground: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 178 / 255, green: 255 / 255, blue: 246 / 255).opacity(0.42),
                            Color(red: 75 / 255, green: 207 / 255, blue: 213 / 255).opacity(0.34),
                            Color(red: 96 / 255, green: 150 / 255, blue: 230 / 255).opacity(0.28),
                        ],
                        center: UnitPoint(x: 0.30, y: 0.18),
                        startRadius: 2,
                        endRadius: 56
                    )
                )

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.28),
                            Color(red: 153 / 255, green: 235 / 255, blue: 227 / 255).opacity(0.11),
                            Color(red: 35 / 255, green: 101 / 255, blue: 180 / 255).opacity(0.06),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blendMode(.screen)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.50),
                            Color.white.opacity(0.14),
                            .clear,
                        ],
                        center: UnitPoint(x: 0.28, y: 0.18),
                        startRadius: 1,
                        endRadius: 36
                    )
                )
                .blendMode(.screen)

            Circle()
                .stroke(Color.white.opacity(0.50), lineWidth: 1)

            Circle()
                .stroke(Color(red: 24 / 255, green: 96 / 255, blue: 148 / 255).opacity(0.10), lineWidth: 0.7)
                .blur(radius: 0.3)
                .offset(y: 0.5)
        }
        .shadow(color: Color(red: 46 / 255, green: 190 / 255, blue: 184 / 255).opacity(0.14), radius: 15, x: 0, y: 8)
        .shadow(color: Color(red: 72 / 255, green: 120 / 255, blue: 228 / 255).opacity(0.08), radius: 12, x: 0, y: 5)
        .shadow(color: Color.white.opacity(0.68), radius: 1, x: 0, y: -0.5)
    }

    private func dockTabButton<Content: View>(
        tab: PrimaryTab,
        title: String,
        @ViewBuilder glyph: () -> Content
    ) -> some View {
        Button {
            onSelectTab(tab)
        } label: {
            HStack(spacing: 5) {
                glyph()
                    .frame(width: 18, height: 18)

                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .foregroundStyle(selectedTab == tab ? VitoraTheme.ColorToken.strongText : VitoraTheme.ColorToken.secondaryText.opacity(0.78))
            .frame(width: 84, height: 34)
            .background(tabButtonBackground(isSelected: selectedTab == tab))
        }
        .buttonStyle(.plain)
        .frame(width: 92, height: VitoraTheme.Size.touchTargetMin)
        .contentShape(Rectangle())
        .accessibilityLabel(title)
        .accessibilityIdentifier("tab.\(tab.rawValue)")
    }

    private func tabButtonBackground(isSelected: Bool) -> some View {
        Capsule()
            .fill(.ultraThinMaterial.opacity(isSelected ? 0.58 : 0.0))
            .overlay {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: isSelected ? [
                                Color.white.opacity(0.74),
                                Color(red: 255 / 255, green: 232 / 255, blue: 239 / 255).opacity(0.34),
                                Color(red: 226 / 255, green: 246 / 255, blue: 250 / 255).opacity(0.26),
                            ] : [
                                Color.clear,
                                Color.clear,
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay(Capsule().stroke(Color.white.opacity(isSelected ? 0.82 : 0.0), lineWidth: 0.58))
            .shadow(color: VitoraTheme.ColorToken.paper.opacity(isSelected ? 0.24 : 0.03), radius: 7, x: -1, y: -1)
    }
}

private struct NotchedDockShape: Shape {
    var notchRadius: CGFloat
    var notchDepth: CGFloat
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let radius = min(cornerRadius, rect.height / 2)
        let centerX = rect.midX
        let halfNotch = min(notchRadius, rect.width / 2 - radius - 18)
        let top = rect.minY
        let bottom = rect.maxY

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + radius, y: top))
        path.addLine(to: CGPoint(x: centerX - halfNotch, y: top))
        path.addCurve(
            to: CGPoint(x: centerX, y: top + notchDepth),
            control1: CGPoint(x: centerX - halfNotch * 0.54, y: top),
            control2: CGPoint(x: centerX - halfNotch * 0.50, y: top + notchDepth)
        )
        path.addCurve(
            to: CGPoint(x: centerX + halfNotch, y: top),
            control1: CGPoint(x: centerX + halfNotch * 0.50, y: top + notchDepth),
            control2: CGPoint(x: centerX + halfNotch * 0.54, y: top)
        )
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: top))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: top + radius),
            control: CGPoint(x: rect.maxX, y: top)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: bottom - radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - radius, y: bottom),
            control: CGPoint(x: rect.maxX, y: bottom)
        )
        path.addLine(to: CGPoint(x: rect.minX + radius, y: bottom))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: bottom - radius),
            control: CGPoint(x: rect.minX, y: bottom)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: top + radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: top),
            control: CGPoint(x: rect.minX, y: top)
        )
        path.closeSubpath()
        return path
    }
}

private struct VitoraInputShortcutBar<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: 370)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("vitora.input.shortcutBar")
    }
}

private struct PrimaryTabBar: View {
    let selectedTab: PrimaryTab
    let onSelect: (PrimaryTab) -> Void

    var body: some View {
        HStack(spacing: 10) {
            tabButton(tab: .today)
            tabButton(tab: .cycle)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 8)
        .frame(height: 62)
        .background(tabCapsuleBackground)
        .clipShape(Capsule(style: .continuous))
        .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(0.56), lineWidth: 0.8))
        .shadow(color: Color(red: 244 / 255, green: 87 / 255, blue: 151 / 255).opacity(0.15), radius: 20, x: 14, y: 8)
        .shadow(color: Color(red: 104 / 255, green: 218 / 255, blue: 188 / 255).opacity(0.12), radius: 18, x: -12, y: 7)
        .padding(.horizontal, 28)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("primary.tabbar")
    }

    private func tabButton(tab: PrimaryTab) -> some View {
        Button {
            onSelect(tab)
        } label: {
            ZStack {
                switch tab {
                case .today:
                    HomeTabGlyph(isSelected: selectedTab == tab)
                case .cycle:
                    FlowerCycleGlyph(isSelected: selectedTab == tab)
                }
            }
            .foregroundStyle(selectedTab == tab ? VitoraTheme.ColorToken.strongText : VitoraTheme.ColorToken.paper.opacity(0.88))
            .frame(width: 58, height: VitoraTheme.Size.touchTargetMin)
            .background {
                Capsule()
                    .fill(selectedTab == tab ? VitoraTheme.ColorToken.paper.opacity(0.52) : VitoraTheme.ColorToken.paper.opacity(0.13))
                    .background(.ultraThinMaterial.opacity(selectedTab == tab ? 0.42 : 0.16), in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(selectedTab == tab ? 0.76 : 0.24), lineWidth: 0.58))
                    .shadow(color: selectedHaloColor(for: tab).opacity(selectedTab == tab ? 0.16 : 0.04), radius: 10, x: 0, y: 5)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 58, height: VitoraTheme.Size.touchTargetMin)
        .contentShape(Rectangle())
        .accessibilityLabel(tab == .today ? "今日" : "周期")
        .accessibilityIdentifier("tab.\(tab.rawValue)")
    }

    private func selectedHaloColor(for tab: PrimaryTab) -> Color {
        switch tab {
        case .today:
            return Color(red: 128 / 255, green: 216 / 255, blue: 184 / 255)
        case .cycle:
            return Color(red: 151 / 255, green: 135 / 255, blue: 255 / 255)
        }
    }

    private var tabCapsuleBackground: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)

            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 118 / 255, green: 222 / 255, blue: 181 / 255).opacity(0.56),
                            Color(red: 246 / 255, green: 219 / 255, blue: 88 / 255).opacity(0.42),
                            Color(red: 246 / 255, green: 101 / 255, blue: 157 / 255).opacity(0.48),
                            Color(red: 151 / 255, green: 135 / 255, blue: 255 / 255).opacity(0.44),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            VitoraTheme.ColorToken.paper.opacity(0.22),
                            VitoraTheme.ColorToken.paper.opacity(0.06),
                            VitoraTheme.ColorToken.paper.opacity(0.18),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blendMode(.screen)
        }
    }
}

private struct PrimaryTabGlassBase: View {
    var body: some View {
        Rectangle()
            .fill(.clear)
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [
                        Color(red: 118 / 255, green: 222 / 255, blue: 181 / 255).opacity(0.24),
                        Color(red: 246 / 255, green: 219 / 255, blue: 88 / 255).opacity(0.18),
                        Color(red: 246 / 255, green: 101 / 255, blue: 157 / 255).opacity(0.24),
                        Color(red: 151 / 255, green: 135 / 255, blue: 255 / 255).opacity(0.20),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 18)
                .blur(radius: 12)
                .padding(.horizontal, 30)
                .blendMode(.screen)
            }
            .ignoresSafeArea(edges: .bottom)
    }
}

private struct PlaceholderScreen: View {
    let titleKey: LocalizedStringKey
    let subtitleKey: LocalizedStringKey
    var badgeKey: LocalizedStringKey?

    var body: some View {
        ZStack {
            VitoraTheme.ColorToken.canvas
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text(titleKey)
                    .font(.title.weight(.semibold))

                if let badgeKey {
                    Text(badgeKey)
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, VitoraTheme.Spacing.sm)
                        .padding(.vertical, VitoraTheme.Spacing.xs)
                        .background(VitoraTheme.ColorToken.softSurface)
                        .clipShape(Capsule())
                        .accessibilityIdentifier("today.lowdata.badge")
                }

                Text(subtitleKey)
                    .font(.body)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .padding(.bottom, VitoraTheme.Size.tabBarHeight)
        }
    }
}
