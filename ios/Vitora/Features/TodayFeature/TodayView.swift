import SwiftUI
import UIKit

struct TodayView: View {
    @ObservedObject var environment: AppEnvironment
    @StateObject private var viewModel: TodayViewModel
    @State private var sheet: TodaySheet?
    @State private var energyBowlEventID = 0
    @State private var hasPresentedEveningReviewPopup = false
    @State private var showsEnergyOrbFull = false
    @State private var homeInsightTopic: TodayInsightTopic = .launchOverride
    @State private var homeExpandedTopic: TodayInsightTopic? = TodayInsightTopic.launchExpandedTopic
    @State private var chatMode: TodayChatMode = .expanded
    @State private var dragProgress: CGFloat = 0
    @State private var activeDimension: DimensionType = .today
    @State private var showsCalendarDrawer = false
    @State private var hasOpenedHeroQuickRecordForUITest = false
    @State private var hasNormalizedHeroTopicLaunch = false
    @State private var chatScrollOffset: CGFloat = 0
    @State private var isReturningToA = false

    init(environment: AppEnvironment) {
        self.environment = environment
        _viewModel = StateObject(wrappedValue: TodayViewModel(isLowData: environment.navigationState.gate == .lowDataReady))
        _showsCalendarDrawer = State(initialValue: ProcessInfo.processInfo.arguments.contains("-vitoraUITestOpenCalendar"))
    }

    private let dragThreshold: CGFloat = 150

    var body: some View {
        ZStack(alignment: .top) {
            WaterAuraReferenceBackground(scene: .today, intensity: 1.04)

            VStack(spacing: 0) {
                // ── Scrollable content area ──
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        // Scroll offset tracker for B→A gesture detection
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ChatScrollOffsetKey.self,
                                value: proxy.frame(in: .named("todayScroll")).minY
                            )
                        }
                        .frame(height: 0)

                        let topContextOpacity = 1 - dragProgress.progressIn(from: 0.82, to: 1.0)
                        if topContextOpacity > 0.01 {
                            topContext
                                .opacity(topContextOpacity)
                                .frame(height: 54 * topContextOpacity)
                                .clipped()
                        }

                        // ═══════════════════════════════════════
                        // 区块 1 · 蛋复合组件（State A: 完整展示）
                        // 上滑时整体缩小+淡出，让位给 compact top bar
                        // ═══════════════════════════════════════
                        let block1Opacity = 1 - dragProgress.progressIn(from: 0.0, to: 0.4)
                        if block1Opacity > 0.01 {
                            TodayCreativeTrendCard(
                                cycleDay: environment.selectedCycleDay,
                                cyclePhase: environment.selectedAuraVariant.phaseLabel,
                                location: "深圳"
                            )
                            .opacity(block1Opacity)
                            .scaleEffect(1 - dragProgress * 0.035, anchor: .top)
                        }

                        // ═══════════════════════════════════════
                        // 区块 2 · 对话区
                        // State A: 浅米色容器(留言卡+能量上下文)
                        // State B: 聊天线程+快捷按钮
                        // ═══════════════════════════════════════

                        // State A 内容（淡出）
                        let block2AOpacity = 1 - dragProgress.progressIn(from: 0.2, to: 0.5)
                        if block2AOpacity > 0.01 {
                            TodayJournalChatCard(
                                timeText: todayChatTimeText,
                                location: "深圳",
                                phaseText: todayPhaseText,
                                showsContextHeader: false,
                                showsWarmNote: false,
                                usesCardChrome: false
                            )
                            .opacity(block2AOpacity)
                        }

                        // State B 内容（淡入）
                        let chatOpacity = dragProgress.progressIn(from: 0.5, to: 1.0)
                        if chatOpacity > 0.01 {
                            TodayInlineChatPlaceholder(
                                date: viewModel.todayState.day,
                                cycleDay: environment.selectedCycleDay,
                                cyclePhase: environment.selectedAuraVariant.phaseLabel,
                                location: "深圳",
                                onOpenCalendar: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                                        showsCalendarDrawer = true
                                    }
                                }
                            )
                                .opacity(chatOpacity)
                                .offset(y: (1 - chatOpacity) * 20)
                        }
                    }
                    .padding(.horizontal, (chatMode == .collapsed || dragProgress > 0.96) ? 0 : 18)
                    .padding(.top, (chatMode == .collapsed || dragProgress > 0.96) ? -10 : 4)
                    .padding(.bottom, 16)
                }
                .accessibilityIdentifier("today.pivot.surface")
                .coordinateSpace(name: "todayScroll")
                .onPreferenceChange(ChatScrollOffsetKey.self) { chatScrollOffset = $0 }
                .scrollDisabled(chatMode == .expanded || isReturningToA)

                Spacer(minLength: 0)
            }
        }
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    // Skip if drag started in the dial area (right side)
                    if value.startLocation.x > 300 && chatMode == .expanded { return }

                    if chatMode == .expanded {
                        // State A → B: swipe up drives progress 0→1
                        let delta = -value.translation.height / dragThreshold
                        dragProgress = min(max(delta, 0), 1)
                    } else {
                        // State B → A: pull down from scroll top
                        if !isReturningToA && chatScrollOffset >= -1 && value.translation.height > 10 {
                            isReturningToA = true
                        }
                        if isReturningToA {
                            let delta = value.translation.height / dragThreshold
                            dragProgress = min(max(1 - delta, 0), 1)
                        }
                    }
                }
                .onEnded { _ in
                    let shouldChat = dragProgress > 0.5
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        dragProgress = shouldChat ? 1.0 : 0.0
                        chatMode = shouldChat ? .collapsed : .expanded
                    }
                    isReturningToA = false
                }
        )
        .onAppear {
            normalizeHeroTopicLaunchIfNeeded()
            energyBowlEventID += 1
            presentEveningReviewPopupIfNeeded()
            triggerEnergyOrbIfNeeded()
            openHeroQuickRecordForUITestsIfNeeded()
            let launchArguments = ProcessInfo.processInfo.arguments
            if launchArguments.contains("-vitoraUITestOpenCalendar") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showsCalendarDrawer = true }
            } else if launchArguments.contains("-vitoraUITestCompletedOnboarding") {
                showsCalendarDrawer = false
            }
            if launchArguments.contains("-vitoraUITestTodayCollapsed") {
                dragProgress = 1
                chatMode = .collapsed
            }
        }
        .fullScreenCover(isPresented: $showsEnergyOrbFull) {
            EnergyOrbFullView(
                isFullVersion: isFirstOrbOpenToday(),
                onComplete: {
                    showsEnergyOrbFull = false
                    markOrbOpenedToday()
                }
            )
        }
        .overlay {
            CalendarDrawerOverlay(
                isOpen: $showsCalendarDrawer,
                selectedCycleDay: environment.selectedCycleDay,
                onSelectCycleDay: environment.selectCycleDay,
                onAskVitora: { openVitora(source: "周期日历", summary: "日期或周期感受不准") }
            )
        }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .calendar:
                EmptyView() // Calendar is now a left drawer, not a sheet
            case .status:
                TodayStateDetailSheet(
                    onClose: { self.sheet = nil },
                    onAskVitora: { openVitora(source: "今日状态详情", summary: "补充今天变化") }
                )
            case .bodyFactors:
                BodyFactorsDetailSheet(
                    onClose: { self.sheet = nil },
                    onAskVitora: { factor in openVitora(source: "身体要素", summary: factor) }
                )
            case .suggestion:
                SuggestionDetailSheet(
                    onClose: { self.sheet = nil },
                    onCommit: {
                        viewModel.openAnalysis()
                    },
                    onSwap: { openVitora(source: "今日建议", summary: "换一个方案") },
                    onAskVitora: { openVitora(source: "今日建议", summary: "这个建议不适合") }
                )
            }
        }
        .sheet(isPresented: $viewModel.isAnalysisPresented) {
            TodayAnalysisSheet(
                analysis: viewModel.analysis,
                dailyIntention: viewModel.dailyIntention,
                selectedABOption: viewModel.selectedABOption,
                reminderPreference: viewModel.reminderPreference,
                reminderInstance: viewModel.reminderInstance,
                onSelectABOption: viewModel.selectABOption,
                onRejectABOptions: viewModel.rejectABOptions,
                onSaveReminderPreference: viewModel.saveReminderPreference,
                onClose: viewModel.closeAnalysis
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
        .preference(
            key: AppSheetPresentationPreferenceKey.self,
            value: sheet != nil || viewModel.isAnalysisPresented || showsCalendarDrawer
        )
    }

    private var topContext: some View {
        HStack(alignment: .top, spacing: 10) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                    showsCalendarDrawer = true
                }
            } label: {
                TodayLowCodeDateTitle(
                    date: viewModel.todayState.day,
                    cycleDay: environment.selectedCycleDay,
                    cyclePhase: environment.selectedAuraVariant.phaseLabel
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("打开周期日历")
            .accessibilityIdentifier("today.top.context")

            Spacer()

            // State B: compact flower-pot energy status.
            let compactOpacity = dragProgress.progressIn(from: 0.3, to: 0.7)
            if compactOpacity > 0.01 {
                TodayCompactFlowerPotStatus(progress: 0.68)
                .opacity(compactOpacity)
            }

            // 低数据模式 and "..." removed per design spec
        }
        .frame(height: 54)
    }

    private struct TodayCompactFlowerPotStatus: View {
        let progress: CGFloat

        private var scoreText: String {
            "\(Int((min(max(progress, 0), 1) * 100).rounded()))"
        }

        var body: some View {
            HStack(spacing: 7) {
                MiniFlowerPotGlyph(progress: progress)
                    .frame(width: 30, height: 32)
                    .accessibilityHidden(true)

                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(scoreText)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 218 / 255, green: 130 / 255, blue: 9 / 255))
                        .monospacedDigit()
                    Text("/100")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.42), lineWidth: 0.6))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("今日能量花盆，\(scoreText)分")
            .accessibilityIdentifier("today.collapsed.flowerPotStatus")
        }
    }

    private struct MiniFlowerPotGlyph: View {
        let progress: CGFloat

        var body: some View {
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let centerX = w * 0.5
                let topY = h * 0.54
                let leftX = w * 0.18
                let rightX = w * 0.82
                let bottomY = h * 0.92
                let clamped = min(max(progress, 0), 1)

                var bowl = Path()
                bowl.move(to: CGPoint(x: leftX, y: topY))
                bowl.addLine(to: CGPoint(x: rightX, y: topY))
                bowl.addQuadCurve(
                    to: CGPoint(x: leftX, y: topY),
                    control: CGPoint(x: centerX, y: bottomY + 14)
                )
                bowl.closeSubpath()

                var fillContext = context
                fillContext.clip(to: bowl)
                let fillTop = bottomY - (bottomY - topY) * clamped
                fillContext.fill(
                    Path(CGRect(x: leftX - 1, y: fillTop, width: rightX - leftX + 2, height: bottomY - fillTop + 8)),
                    with: .linearGradient(
                        Gradient(colors: [
                            Color(red: 255 / 255, green: 238 / 255, blue: 150 / 255).opacity(0.78),
                            Color(red: 255 / 255, green: 172 / 255, blue: 19 / 255).opacity(0.66)
                        ]),
                        startPoint: CGPoint(x: centerX, y: fillTop),
                        endPoint: CGPoint(x: centerX, y: bottomY)
                    )
                )

                context.fill(
                    bowl,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color.white.opacity(0.36),
                            Color(red: 255 / 255, green: 228 / 255, blue: 140 / 255).opacity(0.18)
                        ]),
                        startPoint: CGPoint(x: centerX, y: topY),
                        endPoint: CGPoint(x: centerX, y: bottomY)
                    )
                )
                context.stroke(
                    bowl,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color(red: 255 / 255, green: 176 / 255, blue: 19 / 255),
                            Color(red: 231 / 255, green: 136 / 255, blue: 0)
                        ]),
                        startPoint: CGPoint(x: leftX, y: topY),
                        endPoint: CGPoint(x: rightX, y: bottomY)
                    ),
                    style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round)
                )

                var stem = Path()
                stem.move(to: CGPoint(x: centerX, y: topY + 1))
                stem.addLine(to: CGPoint(x: centerX, y: h * 0.20))
                context.stroke(stem, with: .color(Color(red: 72 / 255, green: 184 / 255, blue: 78 / 255)), style: StrokeStyle(lineWidth: 2, lineCap: .round))

                let leafColor = Color(red: 103 / 255, green: 205 / 255, blue: 90 / 255)
                context.fill(
                    Path(ellipseIn: CGRect(x: centerX - 11, y: h * 0.31, width: 9, height: 15)),
                    with: .color(leafColor.opacity(0.9))
                )
                context.fill(
                    Path(ellipseIn: CGRect(x: centerX + 3, y: h * 0.34, width: 12, height: 8)),
                    with: .color(leafColor.opacity(0.86))
                )

                context.fill(
                    Path(ellipseIn: CGRect(x: centerX - 4, y: topY - 4, width: 8, height: 8)),
                    with: .color(Color.white.opacity(0.92))
                )
                context.stroke(
                    Path(ellipseIn: CGRect(x: centerX - 4, y: topY - 4, width: 8, height: 8)),
                    with: .color(Color(red: 246 / 255, green: 155 / 255, blue: 0)),
                    style: StrokeStyle(lineWidth: 1.6)
                )
            }
            .accessibilityIdentifier("today.collapsed.flowerPot")
        }
    }

    private struct TodayHeaderMiniCalendarIcon: View {
        let date: Date
        let cycleDay: Int
        let cyclePhase: String

        private var monthText: String {
            "\(Calendar.current.component(.month, from: date))月"
        }

        private var weekdaySymbol: String {
            let symbols = ["日", "一", "二", "三", "四", "五", "六"]
            let index = Calendar.current.component(.weekday, from: date) - 1
            return symbols[min(max(index, 0), symbols.count - 1)]
        }

        private var dayText: String {
            "\(Calendar.current.component(.day, from: date))"
        }

        var body: some View {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 255 / 255, green: 252 / 255, blue: 248 / 255),
                                Color(red: 246 / 255, green: 245 / 255, blue: 236 / 255)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.85), lineWidth: 0.8)
                    )

                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 247 / 255, green: 99 / 255, blue: 159 / 255),
                                    Color(red: 255 / 255, green: 151 / 255, blue: 176 / 255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 15)
                        .overlay(alignment: .leading) {
                            Text(monthText)
                                .font(.system(size: 7.5, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white.opacity(0.94))
                                .padding(.leading, 5)
                        }

                    VStack(spacing: -2) {
                        Text(dayText)
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(Color(red: 250 / 255, green: 101 / 255, blue: 157 / 255))
                            .monospacedDigit()
                            .shadow(color: .white.opacity(0.92), radius: 0, x: 0, y: 1)

                        Text("周\(weekdaySymbol)")
                            .font(.system(size: 6.8, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(red: 204 / 255, green: 26 / 255, blue: 91 / 255).opacity(0.86))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .frame(width: 44, height: 44)
            .shadow(color: Color(red: 230 / 255, green: 116 / 255, blue: 154 / 255).opacity(0.17), radius: 8, x: 0, y: 5)
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("today.header.energyCalendarCard")
        }
    }

    private struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }

    /// Skeuomorphic calendar icon — red header + metal clips + ink-style date number
    private var calendarIcon: some View {
        let dateDay = ((environment.selectedCycleDay + 14) % 28) + 1
        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
        let weekdayIndex = (dateDay + 3) % 7
        let weekdayText = "星期\(weekdays[weekdayIndex])"

        return Canvas { context, size in
            let w = size.width
            let h = size.height
            let headerH: CGFloat = 18
            let r: CGFloat = 6

            // ── Shadow base ──
            let body = RoundedRectangle(cornerRadius: r, style: .continuous).path(in: CGRect(x: 0, y: 0, width: w, height: h))
            var shadowCtx = context
            shadowCtx.addFilter(.shadow(color: Color.black.opacity(0.18), radius: 5, x: 1, y: 4))
            shadowCtx.fill(body, with: .color(Color.white))

            // ── Red header ──
            var header = Path()
            header.addRoundedRect(in: CGRect(x: 0, y: 0, width: w, height: headerH + 4), cornerRadii: RectangleCornerRadii(topLeading: r, bottomLeading: 0, bottomTrailing: 0, topTrailing: r))
            context.fill(header, with: .linearGradient(
                Gradient(colors: [Color(red: 0.82, green: 0.14, blue: 0.14), Color(red: 0.72, green: 0.12, blue: 0.12)]),
                startPoint: CGPoint(x: w / 2, y: 0), endPoint: CGPoint(x: w / 2, y: headerH + 4)
            ))

            // Header text
            context.draw(
                Text(weekdayText).font(.system(size: 9.5, weight: .bold)).foregroundColor(.white),
                at: CGPoint(x: w / 2, y: headerH / 2 + 1), anchor: .center
            )

            // ── White body ──
            var bodyRect = Path()
            bodyRect.addRoundedRect(in: CGRect(x: 0, y: headerH, width: w, height: h - headerH), cornerRadii: RectangleCornerRadii(topLeading: 0, bottomLeading: r, bottomTrailing: r, topTrailing: 0))
            context.fill(bodyRect, with: .linearGradient(
                Gradient(colors: [Color.white, Color(red: 0.96, green: 0.955, blue: 0.94)]),
                startPoint: CGPoint(x: w / 2, y: headerH), endPoint: CGPoint(x: w / 2, y: h)
            ))

            // Paper grain lines
            for i in stride(from: headerH + 4, to: h - 2, by: 4) {
                var line = Path()
                line.move(to: CGPoint(x: 3, y: i))
                line.addLine(to: CGPoint(x: w - 3, y: i))
                context.stroke(line, with: .color(Color.black.opacity(0.018)), style: StrokeStyle(lineWidth: 0.4))
            }

            // Date number — large ink/serif style
            context.draw(
                Text("\(dateDay)")
                    .font(.system(size: 28, weight: .black, design: .serif))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15)),
                at: CGPoint(x: w / 2, y: headerH + (h - headerH) / 2), anchor: .center
            )

            // ── Metal ring clips ──
            let clipW: CGFloat = 5
            let clipH: CGFloat = 12
            let clipY: CGFloat = -2
            for clipX in [w * 0.28, w * 0.72] {
                let clipRect = CGRect(x: clipX - clipW / 2, y: clipY, width: clipW, height: clipH)
                let clipPath = Path(roundedRect: clipRect, cornerRadius: clipW / 2)

                // Clip shadow
                var clipShadow = context
                clipShadow.addFilter(.shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 1))
                clipShadow.fill(clipPath, with: .color(Color(red: 0.75, green: 0.75, blue: 0.75)))

                // Metal gradient
                context.fill(clipPath, with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 0.80, green: 0.80, blue: 0.80),
                        Color.white.opacity(0.95),
                        Color(red: 0.70, green: 0.70, blue: 0.70),
                    ]),
                    startPoint: CGPoint(x: clipX - clipW, y: clipY),
                    endPoint: CGPoint(x: clipX + clipW, y: clipY)
                ))

                // Clip border
                context.stroke(clipPath, with: .color(Color.gray.opacity(0.25)), style: StrokeStyle(lineWidth: 0.4))
            }

            // Outer border
            context.stroke(body, with: .color(Color.black.opacity(0.08)), style: StrokeStyle(lineWidth: 0.5))
        }
        .frame(width: 48, height: 50)
    }

    /// Phase sticky-note — washi tape feel with shadow, curl, and phase-specific color
    private var phaseStickyNote: some View {
        let phaseDay = environment.selectedCycleDay
        let phaseLabel = "黄体 D\(phaseDay)"
        // Phase colors: 黄体=warm yellow, 月经=pink, 排卵=blue, 卵泡=light blue
        let noteColor = Color(red: 255 / 255, green: 240 / 255, blue: 188 / 255)
        let textColor = Color(red: 110 / 255, green: 78 / 255, blue: 15 / 255)

        return Canvas { context, size in
            let w = size.width
            let h = size.height

            // Washi tape shape — slightly curved edges, lifted corner
            var tape = Path()
            tape.move(to: CGPoint(x: 0, y: 1))
            tape.addQuadCurve(to: CGPoint(x: w, y: 0), control: CGPoint(x: w * 0.5, y: -1.5))
            tape.addLine(to: CGPoint(x: w + 0.5, y: h - 6))
            // Bottom-right curl
            tape.addQuadCurve(to: CGPoint(x: w - 8, y: h), control: CGPoint(x: w + 2, y: h + 2))
            tape.addQuadCurve(to: CGPoint(x: 0, y: h - 0.5), control: CGPoint(x: w * 0.5, y: h + 1))
            tape.closeSubpath()

            // Drop shadow (deeper on right/bottom for curl effect)
            var shadowCtx = context
            shadowCtx.addFilter(.shadow(color: Color.black.opacity(0.16), radius: 4, x: 2, y: 3))
            shadowCtx.fill(tape, with: .color(noteColor))

            // Fill with subtle gradient for paper depth
            context.fill(tape, with: .linearGradient(
                Gradient(colors: [noteColor, noteColor.opacity(0.92)]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: w, y: h)
            ))

            // Paper fiber texture
            for i in stride(from: 2, to: h - 2, by: 3) {
                var fiber = Path()
                fiber.move(to: CGPoint(x: 2, y: i))
                fiber.addLine(to: CGPoint(x: w - 2, y: i + 0.3))
                context.stroke(fiber, with: .color(Color.black.opacity(0.015)), style: StrokeStyle(lineWidth: 0.3))
            }

            // Fold crease at curl
            var crease = Path()
            crease.move(to: CGPoint(x: w - 9, y: h - 7))
            crease.addLine(to: CGPoint(x: w - 2, y: h - 7))
            context.stroke(crease, with: .color(Color.black.opacity(0.05)), style: StrokeStyle(lineWidth: 0.5))

            // Label text — centered
            context.draw(
                Text(phaseLabel)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(textColor),
                at: CGPoint(x: w / 2, y: h / 2 - 0.5),
                anchor: .center
            )
        }
        .frame(width: 96, height: 30)
        .rotationEffect(.degrees(-2))
    }

    private func openVitora(source: String, summary: String) {
        environment.openVitoraContext(
            sourceTitle: source,
            sourceSummary: summary,
            prompt: "Vitora 会用你的补充校准今天的理解。"
        )
        sheet = nil
    }

    private func openUnifiedTodayAnalysis() {
        energyBowlEventID += 1
        viewModel.openAnalysis()
    }

    private func openHeroQuickRecord() {
        if let topic = homeExpandedTopic {
            openVitora(source: "\(topic.title)记录", summary: topic.recordSummary)
        } else {
            openVitora(source: "快捷记录", summary: "补充今天影响状态的事")
        }
    }

    private func normalizeHeroTopicLaunchIfNeeded() {
        guard !hasNormalizedHeroTopicLaunch else { return }

        hasNormalizedHeroTopicLaunch = true
        homeExpandedTopic = TodayInsightTopic.launchExpandedTopic
        if let expandedTopic = homeExpandedTopic {
            homeInsightTopic = expandedTopic
        }
    }

    private func openHeroQuickRecordForUITestsIfNeeded() {
        guard !hasOpenedHeroQuickRecordForUITest,
              ProcessInfo.processInfo.arguments.contains("-vitoraUITestOpenHeroQuickRecord")
        else {
            return
        }

        hasOpenedHeroQuickRecordForUITest = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            openHeroQuickRecord()
        }
    }

    // MARK: - Energy Orb Full

    private static let orbLastOpenKey = "vitora.energyOrb.lastOpenDate"

    private func triggerEnergyOrbIfNeeded() {
        guard !ProcessInfo.processInfo.arguments.contains("-vitoraUITestSkipOrb") else { return }
        showsEnergyOrbFull = true
    }

    private func isFirstOrbOpenToday() -> Bool {
        guard let lastDate = UserDefaults.standard.object(forKey: Self.orbLastOpenKey) as? Date else {
            return true
        }
        return !Calendar.current.isDateInToday(lastDate)
    }

    private func markOrbOpenedToday() {
        UserDefaults.standard.set(Date(), forKey: Self.orbLastOpenKey)
    }

    private func presentEveningReviewPopupIfNeeded() {
        guard !hasPresentedEveningReviewPopup,
              environment.isEveningReviewAvailable,
              shouldTriggerEveningReviewPopup
        else {
            return
        }

        hasPresentedEveningReviewPopup = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            environment.openEveningReview()
        }
    }

    private var shouldTriggerEveningReviewPopup: Bool {
        if ProcessInfo.processInfo.arguments.contains("-vitoraUITestEveningReviewPopup") {
            return true
        }

        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 18
    }

    private func focusSmartMonitorForUITests(with proxy: ScrollViewProxy) {
        guard ProcessInfo.processInfo.arguments.contains("-vitoraUITestFocusSmartMonitor") else { return }

        [0.35, 0.9, 1.45].forEach { delay in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.18)) {
                    proxy.scrollTo("today.insight.panel", anchor: .top)
                }
            }
        }
    }

    private var selectedCycleContextText: String {
        "\(environment.selectedAuraVariant.phaseLabel) Day \(environment.selectedCycleDay)"
    }

    private var selectedDateText: String {
        let dateDay = ((environment.selectedCycleDay + 14) % 28) + 1
        return "5月\(dateDay)日"
    }

    private var todayChatTimeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: viewModel.todayState.day)
    }

    private var todayPhaseText: String {
        let phase = environment.selectedAuraVariant.phaseLabel
        if phase.contains("D") {
            return phase
        }
        return "\(phase) D\(environment.selectedCycleDay)"
    }

    // MARK: - Gesture-Driven Chat Mode

    private func restoreExpanded() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            dragProgress = 0
            chatMode = .expanded
        }
    }
}

// MARK: - Scroll Offset Tracking

private struct ChatScrollOffsetKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Progress Mapping Helper

extension CGFloat {
    /// Maps self (0→1 global progress) into a sub-range [start, end] → 0→1
    func progressIn(from start: CGFloat, to end: CGFloat) -> CGFloat {
        guard end > start else { return 0 }
        let clamped = Swift.max((self - start) / (end - start), 0)
        return Swift.min(clamped, 1)
    }
}

// MARK: - Calendar Drawer (左侧 2/3 屏抽屉)

/// Left-side drawer overlay that presents the calendar sliding from leading edge.
/// Covers about 3/4 of the screen while leaving a blurred Today backdrop visible.
struct CalendarDrawerOverlay: View {
    @Binding var isOpen: Bool
    let selectedCycleDay: Int
    let onSelectCycleDay: (Int) -> Void
    let onAskVitora: () -> Void
    @State private var keepsHitTesting = false

    var body: some View {
        GeometryReader { proxy in
            let drawerWidth = min(proxy.size.width * 0.765, 332)
            let shouldCapture = isOpen || keepsHitTesting

            ZStack(alignment: .leading) {
                if shouldCapture {
                    Color(red: 250 / 255, green: 240 / 255, blue: 226 / 255)
                        .opacity(isOpen ? 0.26 : 0.001)
                        .background(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture { closeDrawer() }
                        .accessibilityIdentifier("calendar.drawer.backdrop")
                        .transition(.opacity)
                }

                // Drawer panel
                HStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            TodayCalendarSheet(
                                selectedCycleDay: selectedCycleDay,
                                onSelectCycleDay: onSelectCycleDay,
                                onClose: { closeDrawer() },
                                onAskVitora: {
                                    closeDrawer()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                        onAskVitora()
                                    }
                                }
                            )
                        }
                        .padding(.bottom, 40)
                    }
                    .frame(width: drawerWidth)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 255 / 255, green: 253 / 255, blue: 248 / 255),
                                        Color(red: 248 / 255, green: 238 / 255, blue: 226 / 255),
                                        Color(red: 255 / 255, green: 248 / 255, blue: 239 / 255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.white.opacity(0.72), lineWidth: 0.8))
                            .shadow(color: .black.opacity(0.16), radius: 24, x: 10, y: 16)
                            .ignoresSafeArea()
                    )

                    Spacer(minLength: 0)
                }
                .offset(x: isOpen ? 0 : -drawerWidth - 30)
                .accessibilityIdentifier("calendar.drawer.panel")
            }
        }
        .allowsHitTesting(isOpen || keepsHitTesting)
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: isOpen)
        .onAppear {
            keepsHitTesting = isOpen
        }
        .onChange(of: isOpen) { _, newValue in
            if newValue {
                keepsHitTesting = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.48) {
                    keepsHitTesting = false
                }
            }
        }
    }

    private func closeDrawer() {
        keepsHitTesting = true
        withAnimation(.spring(response: 0.38, dampingFraction: 0.88)) {
            isOpen = false
        }
    }
}

// TodayScrollOffsetKey removed — replaced by DragGesture-driven progress

/// Folded Today state: journal card with a timeline chat surface.
struct TodayInlineChatPlaceholder: View {
    var date: Date = Date()
    var cycleDay: Int = 18
    var cyclePhase: String = "黄体期"
    var location: String = "深圳"
    var onOpenCalendar: () -> Void = {}

    var body: some View {
        TodayCollapsedJournalSurface(
            date: date,
            cycleDay: cycleDay,
            cyclePhase: cyclePhase,
            location: location,
            onOpenCalendar: onOpenCalendar
        )
        .accessibilityIdentifier("today.inline.chat")
    }
}

private struct TodayCollapsedJournalSurface: View {
    let date: Date
    let cycleDay: Int
    let cyclePhase: String
    let location: String
    let onOpenCalendar: () -> Void

    private var monthDayText: String {
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        return "\(month)月 \(day)"
    }

    private var timeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private var phaseText: String {
        if cyclePhase.contains("D") {
            return cyclePhase
        }
        return "\(cyclePhase) D\(cycleDay)"
    }

    private var cardMinHeight: CGFloat {
        max(UIScreen.main.bounds.height - 36, 776)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Button(action: onOpenCalendar) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 5) {
                            Text(monthDayText)
                                .font(.system(size: 14.5, weight: .semibold, design: .rounded))
                                .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.82))
                                .monospacedDigit()
                            Circle()
                                .fill(Color(red: 255 / 255, green: 103 / 255, blue: 68 / 255))
                                .frame(width: 5, height: 5)
                        }

                        PixelTodayTitle(pixel: 5.4, gap: 1.2, letterSpacing: 3.2)
                            .frame(height: 46, alignment: .leading)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("打开周期日历")

                Spacer(minLength: 0)

                Button(action: onOpenCalendar) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 29, weight: .light))
                        .foregroundStyle(Color.black.opacity(0.25))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.top, 15)
                .accessibilityLabel("打开周期日历")
                .accessibilityIdentifier("today.collapsed.calendarMenu")
            }
            .padding(.horizontal, 9)
            .padding(.top, 8)

            TodayJournalChatCard(
                timeText: timeText,
                location: location,
                phaseText: phaseText,
                showsContextHeader: true,
                showsWarmNote: true,
                usesCardChrome: true,
                fillsAvailableHeight: true
            )
        }
        .frame(maxWidth: .infinity, minHeight: cardMinHeight, alignment: .top)
        .padding(.top, 0)
        .accessibilityIdentifier("today.collapsed.journal")
    }
}

private struct TodayJournalChatCard: View {
    let timeText: String
    let location: String
    let phaseText: String
    var showsContextHeader = true
    var showsWarmNote = true
    var usesCardChrome = true
    var fillsAvailableHeight = false

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if showsContextHeader {
                TodayPixelContextStrip(
                    timeText: timeText,
                    location: location,
                    phaseText: phaseText
                )
            }

            VStack(alignment: .leading, spacing: 18) {
                if showsWarmNote {
                    TodayJournalNote(
                        text: "今天是创意日。黄体期的联想力更容易被细节点亮，先把灵感写下来，不急着把自己推满。"
                    )
                    .padding(.horizontal, 7)
                }

                TodayJournalVitoraEntry(
                    message: "HRV 偏低但深睡充足，身体还在恢复中。今天适合做轻整理，把想法留住就好。",
                    timestamp: "21:30"
                )

                TodayJournalUserEntry(
                    message: "下午总是很累，有什么改善建议吗？",
                    timestamp: "21:32"
                )

                TodayJournalVitoraEntry(
                    message: "可以尝试在午后补充蛋白质和坚果，搭配 10 分钟散步，让创意慢慢落地。",
                    timestamp: "21:33"
                )
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, usesCardChrome ? 15 : 0)
        .padding(.top, usesCardChrome ? 12 : 4)
        .padding(.bottom, usesCardChrome ? 18 : 6)
        .frame(maxWidth: .infinity, maxHeight: fillsAvailableHeight ? CGFloat.infinity : nil, alignment: .top)
        .background {
            if usesCardChrome {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color.white.opacity(0.96))
            }
        }
        .overlay {
            if usesCardChrome {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color(red: 232 / 255, green: 233 / 255, blue: 229 / 255), lineWidth: 1)
            }
        }
        .shadow(color: usesCardChrome ? Color.black.opacity(0.04) : .clear, radius: usesCardChrome ? 12 : 0, x: 0, y: usesCardChrome ? 6 : 0)
        .accessibilityIdentifier("today.collapsed.chatCard")
    }
}

private struct TodayPixelContextStrip: View {
    let timeText: String
    let location: String
    let phaseText: String

    var body: some View {
        HStack(spacing: 10) {
            TodayPixelTimeRegionGlyph()
                .frame(width: 35, height: 29)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(timeText) · \(location) · \(phaseText)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)

                    Spacer(minLength: 6)

                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("68")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(red: 218 / 255, green: 130 / 255, blue: 9 / 255))
                            .monospacedDigit()
                        Text("/100")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                    }
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(red: 232 / 255, green: 229 / 255, blue: 220 / 255).opacity(0.74))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 255 / 255, green: 126 / 255, blue: 178 / 255),
                                        Color(red: 238 / 255, green: 145 / 255, blue: 0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: proxy.size.width * 0.68)
                    }
                }
                .frame(height: 4)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
        .padding(.top, 2)
        .padding(.bottom, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.04))
                .frame(height: 0.7)
                .padding(.leading, 45)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("现在 \(timeText)，\(location)，\(phaseText)，今日能量 68 分")
        .accessibilityIdentifier("today.collapsed.pixelContext")
    }
}

private struct TodayLowCodeDateTitle: View {
    let date: Date
    let cycleDay: Int
    let cyclePhase: String

    private var monthDayText: String {
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        return "\(month)月 \(day)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 5) {
                Text(monthDayText)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.78))
                    .monospacedDigit()
                Circle()
                    .fill(Color(red: 255 / 255, green: 103 / 255, blue: 68 / 255))
                    .frame(width: 5, height: 5)
            }

            PixelTodayTitle(pixel: 4.15, gap: 1.0, letterSpacing: 2.3)
                .frame(height: 36, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(monthDayText)，Today，\(cyclePhase) D\(cycleDay)")
    }
}

private struct PixelTodayTitle: View {
    var pixel: CGFloat = 5
    var gap: CGFloat = 1.2
    var letterSpacing: CGFloat = 3
    var color: Color = Color(red: 29 / 255, green: 30 / 255, blue: 36 / 255)

    private let letters: [String] = ["T", "o", "d", "a", "y"]

    var body: some View {
        HStack(alignment: .top, spacing: letterSpacing) {
            ForEach(Array(letters.enumerated()), id: \.offset) { _, letter in
                PixelGlyph(rows: glyph(for: letter), pixel: pixel, gap: gap, color: color)
            }
        }
        .fixedSize()
        .accessibilityHidden(true)
    }

    private func glyph(for letter: String) -> [String] {
        switch letter {
        case "T":
            return [
                "11111",
                "00100",
                "00100",
                "00100",
                "00100",
                "00100",
                "00100"
            ]
        case "o":
            return [
                "00000",
                "01110",
                "10001",
                "10001",
                "10001",
                "01110",
                "00000"
            ]
        case "d":
            return [
                "00001",
                "00001",
                "01111",
                "10001",
                "10001",
                "10001",
                "01111"
            ]
        case "a":
            return [
                "00000",
                "01110",
                "00001",
                "01111",
                "10001",
                "10011",
                "01101"
            ]
        default:
            return [
                "00000",
                "10001",
                "10001",
                "01111",
                "00001",
                "10001",
                "01110"
            ]
        }
    }
}

private struct PixelGlyph: View {
    let rows: [String]
    let pixel: CGFloat
    let gap: CGFloat
    let color: Color

    var body: some View {
        VStack(spacing: gap) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: gap) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, value in
                        RoundedRectangle(cornerRadius: pixel * 0.16, style: .continuous)
                            .fill(color.opacity(value == "1" ? 1 : 0))
                            .frame(width: pixel, height: pixel)
                    }
                }
            }
        }
    }
}

private struct TodayCreativeTrendCard: View {
    let cycleDay: Int
    let cyclePhase: String
    let location: String

    private let values: [CGFloat] = [0.50, 0.56, 0.54, 0.60, 0.68, 0.62, 0.72]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("今天的创意能量")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text("\(cyclePhase) D\(cycleDay) · \(location)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }

                Spacer(minLength: 0)

                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("68")
                        .font(.system(size: 27, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 235 / 255, green: 68 / 255, blue: 139 / 255))
                    Text("/100")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                }
            }

            Text("今天先把灵感写下来，慢慢整理就好。")
                .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            TodayCreativeTrendChart(values: values)
                .frame(height: 130)

            HStack(spacing: 6) {
                ForEach(["一", "二", "三", "四", "五", "六", "今"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: day == "今" ? .black : .bold, design: .rounded))
                        .foregroundStyle(day == "今" ? Color(red: 235 / 255, green: 68 / 255, blue: 139 / 255) : VitoraTheme.ColorToken.tertiaryText)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(Color.white.opacity(0.78), in: Capsule())
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity)
        .frame(height: 238, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.82))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.86), lineWidth: 1)
        )
        .shadow(color: Color(red: 236 / 255, green: 122 / 255, blue: 171 / 255).opacity(0.12), radius: 18, x: 0, y: 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("今天的创意能量，68分，\(cyclePhase) D\(cycleDay)，\(location)")
        .accessibilityIdentifier("today.creativeTrend.card")
    }
}

private struct TodayCreativeTrendChart: View {
    let values: [CGFloat]

    var body: some View {
        Canvas { context, size in
            drawDotGrid(context: &context, size: size)

            let insetX: CGFloat = 6
            let topY: CGFloat = 10
            let bottomY = size.height - 12
            let width = size.width - insetX * 2
            let points = values.enumerated().map { index, value in
                CGPoint(
                    x: insetX + width * CGFloat(index) / CGFloat(max(values.count - 1, 1)),
                    y: bottomY - (bottomY - topY) * min(max(value, 0), 1)
                )
            }

            guard let first = points.first, let last = points.last else { return }

            var line = Path()
            line.move(to: first)
            for index in 1..<points.count {
                let previous = points[index - 1]
                let current = points[index]
                let midX = (previous.x + current.x) / 2
                line.addCurve(
                    to: current,
                    control1: CGPoint(x: midX, y: previous.y),
                    control2: CGPoint(x: midX, y: current.y)
                )
            }

            var fill = line
            fill.addLine(to: CGPoint(x: last.x, y: bottomY))
            fill.addLine(to: CGPoint(x: first.x, y: bottomY))
            fill.closeSubpath()

            context.fill(
                fill,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 255 / 255, green: 82 / 255, blue: 153 / 255).opacity(0.30),
                        Color(red: 255 / 255, green: 176 / 255, blue: 206 / 255).opacity(0.16),
                        Color.white.opacity(0.02)
                    ]),
                    startPoint: CGPoint(x: size.width / 2, y: topY),
                    endPoint: CGPoint(x: size.width / 2, y: bottomY)
                )
            )

            var glow = context
            glow.addFilter(.blur(radius: 5))
            glow.stroke(line, with: .color(Color(red: 255 / 255, green: 83 / 255, blue: 153 / 255).opacity(0.24)), style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
            context.stroke(line, with: .color(Color(red: 244 / 255, green: 48 / 255, blue: 133 / 255)), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

            let activeIndex = min(4, points.count - 1)
            let active = points[activeIndex]
            var markerLine = Path()
            markerLine.move(to: CGPoint(x: active.x, y: active.y + 8))
            markerLine.addLine(to: CGPoint(x: active.x, y: bottomY - 4))
            context.stroke(markerLine, with: .color(Color(red: 244 / 255, green: 48 / 255, blue: 133 / 255).opacity(0.42)), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [5, 5]))

            context.fill(Path(ellipseIn: CGRect(x: active.x - 7, y: active.y - 7, width: 14, height: 14)), with: .color(Color(red: 244 / 255, green: 48 / 255, blue: 133 / 255)))
            context.stroke(Path(ellipseIn: CGRect(x: active.x - 8, y: active.y - 8, width: 16, height: 16)), with: .color(Color.white), lineWidth: 3)

            let calloutRect = CGRect(x: min(active.x + 16, size.width - 120), y: max(active.y - 24, 4), width: 112, height: 34)
            context.fill(Path(roundedRect: calloutRect, cornerRadius: 10), with: .color(Color.white.opacity(0.94)))
            context.draw(
                Text("68/100 创意日")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(VitoraTheme.ColorToken.strongText)
                ,
                at: CGPoint(x: calloutRect.midX, y: calloutRect.midY),
                anchor: .center
            )
        }
    }

    private func drawDotGrid(context: inout GraphicsContext, size: CGSize) {
        let dot = Path(ellipseIn: CGRect(x: 0, y: 0, width: 3.5, height: 3.5))
        var y: CGFloat = 7
        while y < size.height {
            var x: CGFloat = 7
            while x < size.width {
                var translated = context
                translated.translateBy(x: x, y: y)
                translated.fill(dot, with: .color(Color.black.opacity(0.035)))
                x += 24
            }
            y += 22
        }
    }
}

private struct TodayPixelTimeRegionGlyph: View {
    var body: some View {
        Canvas { context, size in
            let step = min(size.width / 9, size.height / 7)
            let originX = (size.width - step * 8) * 0.5
            let originY = (size.height - step * 6) * 0.5

            func pixel(_ column: Int, _ row: Int, _ color: Color, opacity: Double = 1) {
                let rect = CGRect(
                    x: originX + CGFloat(column) * step,
                    y: originY + CGFloat(row) * step,
                    width: step * 0.78,
                    height: step * 0.78
                )
                context.fill(Path(roundedRect: rect, cornerRadius: step * 0.16), with: .color(color.opacity(opacity)))
            }

            let cloud = Color(red: 204 / 255, green: 229 / 255, blue: 235 / 255)
            let green = Color(red: 111 / 255, green: 193 / 255, blue: 119 / 255)
            let darkGreen = Color(red: 47 / 255, green: 129 / 255, blue: 74 / 255)
            let orange = Color(red: 240 / 255, green: 150 / 255, blue: 22 / 255)
            let grey = Color(red: 151 / 255, green: 164 / 255, blue: 169 / 255)

            pixel(1, 1, cloud, opacity: 0.65)
            pixel(2, 1, cloud, opacity: 0.78)
            pixel(3, 1, cloud, opacity: 0.58)
            pixel(6, 1, orange, opacity: 0.92)
            pixel(5, 2, orange, opacity: 0.55)
            pixel(6, 2, orange, opacity: 0.86)

            pixel(1, 4, darkGreen)
            pixel(2, 4, green)
            pixel(3, 3, grey, opacity: 0.72)
            pixel(3, 4, grey, opacity: 0.88)
            pixel(4, 2, grey, opacity: 0.55)
            pixel(4, 3, grey, opacity: 0.78)
            pixel(4, 4, grey, opacity: 0.86)
            pixel(5, 3, grey, opacity: 0.62)
            pixel(5, 4, green, opacity: 0.9)
            pixel(6, 4, darkGreen, opacity: 0.9)

            var marker = Path()
            marker.addEllipse(in: CGRect(x: originX + step * 1.72, y: originY + step * 2.35, width: step * 1.16, height: step * 1.16))
            marker.move(to: CGPoint(x: originX + step * 2.3, y: originY + step * 4.0))
            marker.addLine(to: CGPoint(x: originX + step * 1.86, y: originY + step * 3.24))
            marker.addLine(to: CGPoint(x: originX + step * 2.74, y: originY + step * 3.24))
            marker.closeSubpath()
            context.fill(marker, with: .color(Color(red: 253 / 255, green: 121 / 255, blue: 155 / 255).opacity(0.92)))
            context.fill(
                Path(ellipseIn: CGRect(x: originX + step * 2.08, y: originY + step * 2.7, width: step * 0.44, height: step * 0.44)),
                with: .color(.white.opacity(0.92))
            )
        }
    }
}

private struct TodayJournalNote: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(Color(red: 44 / 255, green: 45 / 255, blue: 52 / 255))
            .lineSpacing(5)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.trailing, 2)
    }
}

private struct TodayJournalVitoraEntry: View {
    let message: String
    let timestamp: String

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            VitoraAvatarGlow(size: 31)
                .opacity(0.72)
                .shadow(color: Color(red: 255 / 255, green: 220 / 255, blue: 205 / 255).opacity(0.32), radius: 9, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 5) {
                Text("Vitora")
                    .font(.system(size: 12.5, weight: .bold, design: .rounded))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

                Text(message)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 11)
                    .background(
                        Color(red: 244 / 255, green: 245 / 255, blue: 250 / 255),
                        in: RoundedRectangle(cornerRadius: 15, style: .continuous)
                    )

                Text(timestamp)
                    .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                    .monospacedDigit()
                    .padding(.leading, 2)
            }
        }
    }
}

private struct TodayJournalUserEntry: View {
    let message: String
    let timestamp: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            HStack {
                Spacer(minLength: 18)
                Text(message)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 11)
                    .background(
                        Color(red: 249 / 255, green: 245 / 255, blue: 236 / 255),
                        in: RoundedRectangle(cornerRadius: 15, style: .continuous)
                    )
            }

            HStack(spacing: 4) {
                Text(timestamp)
                    .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                    .monospacedDigit()
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
            }
            .padding(.trailing, 4)
        }
    }
}
private enum TodaySheet: Identifiable {
    case calendar
    case status
    case bodyFactors
    case suggestion

    var id: String {
        switch self {
        case .calendar:
            return "calendar"
        case .status:
            return "status"
        case .bodyFactors:
            return "bodyFactors"
        case .suggestion:
            return "suggestion"
        }
    }
}
