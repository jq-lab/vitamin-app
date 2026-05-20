import SwiftUI

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
    @StateObject private var vitoraViewModel = VitoraViewModel()
    @State private var isChildSheetPresented = false

    var body: some View {
        currentTabContent
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if shouldShowGlobalDock {
                    GlobalVitoraDock(
                        selectedTab: environment.navigationState.selectedTab,
                        viewModel: vitoraViewModel,
                        onSelectTab: environment.selectTab,
                        onQuickRecord: environment.openQuickRecord,
                        onSubmitted: {
                            if environment.navigationState.selectedTab != .vitora {
                                environment.selectTab(.vitora)
                            }
                        }
                    )
                }
            }
        .onPreferenceChange(AppSheetPresentationPreferenceKey.self) { isPresented in
            isChildSheetPresented = isPresented
        }
        .sheet(
            isPresented: Binding(
                get: { environment.navigationState.presentation == .vitoraContextualSheet },
                set: { isPresented in
                    if !isPresented {
                        environment.dismissPresentation()
                    }
                }
            )
        ) {
            VitoraContextualSheet(
                context: environment.vitoraContext,
                onClose: environment.dismissPresentation
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
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
        case .vitora:
            VitoraAssistantSurfaceView(environment: environment, viewModel: vitoraViewModel)
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
    @ObservedObject var viewModel: VitoraViewModel
    let onSelectTab: (PrimaryTab) -> Void
    let onQuickRecord: () -> Void
    let onSubmitted: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shimmer = false
    @State private var promptIndex = 0

    private let rotatingPrompts = [
        "我可以补充一件事...",
        "为什么今天容易低谷？",
        "今天怎么安排更轻一点？",
    ]
    private let promptTimer = Timer.publish(every: 120, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: selectedTab == .vitora ? 8 : 0) {
            if selectedTab == .vitora {
                VitoraInputShortcutBar {
                    VitoraInputDock(
                        text: $viewModel.inputText,
                        placeholder: rotatingPrompts[promptIndex],
                        style: .assistantFloating,
                        isVoiceRecording: viewModel.isVoiceRecording,
                        voiceSignal: viewModel.voiceSignal,
                        isProcessing: viewModel.isProcessing,
                        exposesAccessibility: true,
                        onVoice: viewModel.toggleVoice,
                        onSend: submit
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            dockTopRow
        }
        .padding(.horizontal, 8)
        .padding(.top, selectedTab == .vitora ? 8 : 7)
        .padding(.bottom, 6)
        .background(alignment: .bottom) {
            dockAmbientGlow
        }
        .offset(y: reduceMotion ? 0 : (shimmer ? -1 : 0))
        .padding(.horizontal, 14)
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("global.vitora.dock")
        .onAppear {
            guard !reduceMotion else {
                return
            }
            withAnimation(.easeInOut(duration: 6.5).repeatForever(autoreverses: true)) {
                shimmer = true
            }
        }
        .onReceive(promptTimer) { _ in
            guard viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !viewModel.isVoiceRecording,
                  selectedTab == .vitora
            else {
                return
            }

            withAnimation(.easeInOut(duration: 0.22)) {
                promptIndex = (promptIndex + 1) % rotatingPrompts.count
            }
        }
    }

    private var dockTopRow: some View {
        ZStack {
            tabSwitcher

            HStack {
                Spacer(minLength: 0)
                quickRecordButton
            }
        }
        .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
    }

    private var tabSwitcher: some View {
        HStack(spacing: 2) {
            dockTabButton(tab: .today, title: "今日") {
                HomeTabGlyph(isSelected: selectedTab == .today)
            }

            Button {
                onSelectTab(.vitora)
            } label: {
                HStack(spacing: 6) {
                    VitoraFaceTabButton(isSelected: selectedTab == .vitora)
                        .frame(width: 28, height: 26)

                    Text("AI管家")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
                .padding(.leading, 7)
                .padding(.trailing, 9)
                .frame(width: 88)
                .frame(minHeight: 35)
                .background(tabButtonBackground(isSelected: selectedTab == .vitora))
            }
            .buttonStyle(.plain)
            .frame(minHeight: VitoraTheme.Size.touchTargetMin)
            .accessibilityLabel("AI管家")
            .accessibilityIdentifier("tab.vitora")

            dockTabButton(tab: .cycle, title: "周期") {
                FlowerCycleGlyph(isSelected: selectedTab == .cycle)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .frame(width: 208)
        .frame(height: 47)
        .background(tabSwitcherBackground)
        .clipShape(Capsule(style: .continuous))
        .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(0.70), lineWidth: 0.78))
        .shadow(color: Color(red: 92 / 255, green: 190 / 255, blue: 220 / 255).opacity(0.13), radius: 13, x: -5, y: 6)
        .shadow(color: Color(red: 246 / 255, green: 139 / 255, blue: 184 / 255).opacity(0.10), radius: 11, x: 5, y: 5)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("primary.tabbar")
    }

    private var quickRecordButton: some View {
        Button(action: onQuickRecord) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .frame(width: 43, height: 43)
                .background(quickRecordBackground)
                .accessibilityHidden(true)
        }
        .buttonStyle(.plain)
        .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
        .contentShape(Circle())
        .accessibilityLabel("快捷记录")
        .accessibilityHint("打开 Vitora 快捷补充，不切换页面")
        .accessibilityIdentifier("global.record.quick")
    }

    private var quickRecordBackground: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.0),
                            Color(red: 202 / 255, green: 214 / 255, blue: 218 / 255).opacity(0.16),
                            Color.black.opacity(0.10),
                            .clear,
                        ],
                        center: UnitPoint(x: 0.66, y: 0.64),
                        startRadius: 6,
                        endRadius: 42
                    )
                )
                .scaleEffect(1.42)
                .offset(x: 8, y: 9)

            Circle()
                .fill(.ultraThinMaterial)
                .overlay(Circle().fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.42)))

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.58),
                            Color(red: 255 / 255, green: 224 / 255, blue: 234 / 255).opacity(0.44),
                            Color(red: 226 / 255, green: 245 / 255, blue: 250 / 255).opacity(0.44),
                            Color(red: 228 / 255, green: 220 / 255, blue: 255 / 255).opacity(0.30),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.84),
                            Color.white.opacity(0.30),
                            .clear,
                        ],
                        center: UnitPoint(x: 0.28, y: 0.22),
                        startRadius: 1,
                        endRadius: 28
                    )
                )
                .blendMode(.screen)

            Circle()
                .stroke(Color(red: 190 / 255, green: 199 / 255, blue: 210 / 255).opacity(0.18), lineWidth: 5)
                .blur(radius: 3)
                .offset(x: 6, y: 8)
                .mask {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .black],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

            Circle()
                .stroke(Color.white.opacity(0.76), lineWidth: 0.82)
        }
        .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.16), radius: 13, x: 0, y: 9)
        .shadow(color: Color(red: 104 / 255, green: 214 / 255, blue: 206 / 255).opacity(0.10), radius: 12, x: -6, y: 5)
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
            .frame(width: 58, height: 35)
            .background(tabButtonBackground(isSelected: selectedTab == tab))
        }
        .buttonStyle(.plain)
        .frame(width: 58, height: VitoraTheme.Size.touchTargetMin)
        .contentShape(Rectangle())
        .accessibilityLabel(title)
        .accessibilityIdentifier("tab.\(tab.rawValue)")
    }

    private var tabSwitcherBackground: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Capsule(style: .continuous).fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.38)))

            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 223 / 255, green: 245 / 255, blue: 250 / 255).opacity(0.44),
                            Color(red: 118 / 255, green: 224 / 255, blue: 199 / 255).opacity(0.28),
                            Color(red: 252 / 255, green: 228 / 255, blue: 144 / 255).opacity(0.24),
                            Color(red: 255 / 255, green: 217 / 255, blue: 232 / 255).opacity(0.36),
                            Color(red: 226 / 255, green: 219 / 255, blue: 255 / 255).opacity(0.30),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.70),
                            Color.white.opacity(0.18),
                            Color.white.opacity(0.44),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blendMode(.screen)
        }
    }

    private func tabButtonBackground(isSelected: Bool) -> some View {
        Capsule()
            .fill(.ultraThinMaterial.opacity(isSelected ? 0.74 : 0.18))
            .overlay {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: isSelected ? [
                                Color.white.opacity(0.72),
                                Color(red: 255 / 255, green: 232 / 255, blue: 239 / 255).opacity(0.40),
                                Color(red: 226 / 255, green: 246 / 255, blue: 250 / 255).opacity(0.34),
                            ] : [
                                Color.white.opacity(0.18),
                                Color(red: 255 / 255, green: 231 / 255, blue: 239 / 255).opacity(0.15),
                                Color(red: 226 / 255, green: 246 / 255, blue: 250 / 255).opacity(0.12),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay(Capsule().stroke(Color.white.opacity(isSelected ? 0.80 : 0.24), lineWidth: 0.58))
            .shadow(color: VitoraTheme.ColorToken.paper.opacity(isSelected ? 0.24 : 0.03), radius: 7, x: -1, y: -1)
    }

    private var dockAmbientGlow: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 211 / 255, green: 244 / 255, blue: 250 / 255).opacity(0.22),
                            Color(red: 122 / 255, green: 226 / 255, blue: 199 / 255).opacity(0.14),
                            Color(red: 250 / 255, green: 225 / 255, blue: 143 / 255).opacity(0.13),
                            Color(red: 255 / 255, green: 214 / 255, blue: 231 / 255).opacity(0.18),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 248, height: selectedTab == .vitora ? 126 : 52)
                .blur(radius: selectedTab == .vitora ? 20 : 15)
                .offset(y: 10)

            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.10))
                .frame(width: 176, height: 22)
                .blur(radius: 12)
                .offset(y: -2)
        }
        .allowsHitTesting(false)
    }

    private func submit() {
        guard viewModel.send() else {
            return
        }
        onSubmitted()
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

            Button {
                onSelect(.vitora)
            } label: {
                HStack(spacing: 8) {
                    VitoraFaceTabButton(isSelected: true)
                        .frame(width: 38, height: 34)

                    Text("AI管家")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .frame(minHeight: VitoraTheme.Size.touchTargetMin)
                .layoutPriority(1)
                .background(
                    Capsule()
                        .fill(VitoraTheme.ColorToken.paper.opacity(0.56))
                        .background(.ultraThinMaterial.opacity(0.46), in: Capsule())
                )
                .overlay(Capsule().stroke(Color.white.opacity(0.82), lineWidth: 0.7))
                .shadow(color: VitoraTheme.ColorToken.paper.opacity(0.34), radius: 10, x: -2, y: -2)
            }
            .buttonStyle(.plain)
            .frame(minHeight: VitoraTheme.Size.touchTargetMin)
            .accessibilityLabel("AI管家")
            .accessibilityIdentifier("tab.vitora")

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
                case .vitora:
                    EmptyView()
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
        case .vitora:
            return Color(red: 242 / 255, green: 105 / 255, blue: 164 / 255)
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
