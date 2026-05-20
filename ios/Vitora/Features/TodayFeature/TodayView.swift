import SwiftUI

struct TodayView: View {
    @ObservedObject var environment: AppEnvironment
    @StateObject private var viewModel: TodayViewModel
    @State private var sheet: TodaySheet?
    @State private var energyBowlEventID = 0
    private let homeMetricMode: TodayMetricMode = .energy

    init(environment: AppEnvironment) {
        self.environment = environment
        _viewModel = StateObject(wrappedValue: TodayViewModel(isLowData: environment.navigationState.gate == .lowDataReady))
    }

    var body: some View {
        ZStack(alignment: .top) {
            WaterAuraReferenceBackground(scene: .today, intensity: 1.04)

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 6) {
                        topContext

                        TodayStatusCard(
                            selectedMode: .constant(homeMetricMode),
                            cycleDay: environment.selectedCycleDay,
                            cyclePhase: environment.selectedAuraVariant.phaseLabel,
                            eventTrigger: energyBowlEventID,
                            onOpenDetail: openUnifiedTodayAnalysis,
                            onOpenEvidence: openUnifiedTodayAnalysis,
                            onAskVitora: { openVitora(source: homeMetricMode.topLabel, summary: "\(homeMetricMode.number)\(homeMetricMode.unit) · \(homeMetricMode.statusText)") },
                            onCalibrate: { value in openVitora(source: "今日状态", summary: value) }
                        )

                        VitoraDailySuggestionCard(
                            mode: homeMetricMode,
                            cycleDay: environment.selectedCycleDay,
                            cyclePhase: environment.selectedAuraVariant.phaseLabel,
                            onCommit: {
                                viewModel.openAnalysis()
                            },
                            onOpenDetail: { sheet = .suggestion },
                            onAskVitora: { openVitora(source: "智能监测", summary: homeMetricMode.suggestionTitle) }
                        )
                        .id("today.smartMonitor")

                        EveningReviewCard(
                            onStartReview: {
                                environment.openEveningReviewInVitora()
                            }
                        )

                        if let selectedTitle = viewModel.selectedABOption?.title {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("今天的小尝试")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                                Text(selectedTitle)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                                Text("晚间 Vitora 会用这个选择做一次轻复盘。")
                                    .font(.footnote)
                                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(GlassSurface(cornerRadius: 22, opacity: 0.62, shadowStrength: 0.56, variant: .cleanElevated))
                            .accessibilityIdentifier("today.intention.confirmation")
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 4)
                    .padding(.bottom, VitoraTheme.Size.tabBarHeight + 70)
                }
                .accessibilityIdentifier("today.pivot.surface")
                .onAppear {
                    focusSmartMonitorForUITests(with: proxy)
                }
            }
        }
        .onAppear {
            energyBowlEventID += 1
        }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .calendar:
                TodayCalendarSheet(
                    selectedCycleDay: environment.selectedCycleDay,
                    onSelectCycleDay: environment.selectCycleDay,
                    onClose: { self.sheet = nil },
                    onAskVitora: { openVitora(source: "周期日历", summary: "日期或周期感受不准") }
                )
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
            value: sheet != nil || viewModel.isAnalysisPresented
        )
    }

    private var topContext: some View {
        HStack(alignment: .center, spacing: 10) {
            Button {
                sheet = .calendar
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .frame(width: 34, height: 34)
                        .background(VitoraTheme.ColorToken.paper.opacity(0.28), in: Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.46), lineWidth: 0.6))

                    VStack(alignment: .leading, spacing: 1) {
                        Text("\(selectedDateText) · \(selectedCycleContextText)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                        Text("黄体期中段 · 今天适合留余量")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("打开周期日历")
            .accessibilityIdentifier("today.top.context")

            Spacer()

            if viewModel.isLowData {
                Text("today.lowdata.badge")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .padding(.horizontal, 9)
                    .frame(height: 28)
                    .background(VitoraTheme.ColorToken.paper.opacity(0.58), in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.62), lineWidth: 0.7))
                    .accessibilityIdentifier("today.lowdata.badge")
            }
        }
        .frame(height: 38)
        .accessibilityIdentifier("today.top.context")
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

    private func focusSmartMonitorForUITests(with proxy: ScrollViewProxy) {
        guard ProcessInfo.processInfo.arguments.contains("-vitoraUITestFocusSmartMonitor") else { return }

        [0.35, 0.9, 1.45].forEach { delay in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.18)) {
                    proxy.scrollTo("today.smartMonitor", anchor: .top)
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
}

// MARK: - Health Metrics Strip

private struct HealthMetricsStrip: View {
    private struct Metric {
        let title: String
        let value: String
        let fill: Double
        let gradient: [Color]
    }

    private let metrics: [Metric] = [
        Metric(title: "综合", value: "68%", fill: 0.68, gradient: [Color(red: 0.95, green: 0.62, blue: 0.42), Color(red: 0.88, green: 0.42, blue: 0.38)]),
        Metric(title: "恢复", value: "75%", fill: 0.75, gradient: [Color(red: 0.62, green: 0.88, blue: 0.78), Color(red: 0.42, green: 0.78, blue: 0.62)]),
        Metric(title: "睡眠", value: "7.2h", fill: 0.52, gradient: [Color(red: 0.62, green: 0.68, blue: 0.92), Color(red: 0.48, green: 0.52, blue: 0.86)]),
        Metric(title: "能量", value: "53%", fill: 0.53, gradient: [Color(red: 0.95, green: 0.85, blue: 0.52), Color(red: 0.92, green: 0.72, blue: 0.38)]),
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(metrics, id: \.title) { metric in
                VStack(alignment: .leading, spacing: 6) {
                    Text(metric.value)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.10))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient(colors: metric.gradient, startPoint: .leading, endPoint: .trailing))
                                .frame(width: proxy.size.width * metric.fill)
                        }
                    }
                    .frame(height: 8)

                    Text(metric.title)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.62))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.52), lineWidth: 0.7))
                )
            }
        }
        .accessibilityIdentifier("today.health.metrics")
    }
}

// MARK: - Evening Review Card

private struct EveningReviewCard: View {
    let onStartReview: () -> Void

    var body: some View {
        Button(action: onStartReview) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    ReviewPixelGlyphView(
                        kind: .moon,
                        tint: Color(red: 124 / 255, green: 115 / 255, blue: 236 / 255),
                        size: 38
                    )
                    .frame(width: 38, height: 38)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("今晚复盘")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        Text("看看 Vitora 今天有没有更懂你")
                            .font(.caption)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }
                }

                HStack(spacing: 14) {
                    HStack(spacing: 8) {
                        energyCircle(value: "68%", label: "早上")
                        Image(systemName: "arrow.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                        energyCircle(value: "86%", label: "现在")
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 6) {
                        statusBadge(kind: .check, text: "已设置提醒", tint: VitoraTheme.ColorToken.success)
                        statusBadge(kind: .clock, text: "反馈待确认", tint: Color(red: 0.92, green: 0.62, blue: 0.28))
                    }
                }

                HStack {
                    Text("去 AI 管家复盘")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                }
                .padding(.horizontal, 20)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.32), lineWidth: 1.5)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.white.opacity(0.52)))
                )
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.82))
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                    .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.08), radius: 12, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("today.evening.review.cta")
        .accessibilityIdentifier("today.evening.review.card")
    }

    private func energyCircle(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.96),
                                VitoraTheme.ColorToken.auraCyan.opacity(0.42),
                                VitoraTheme.ColorToken.auraBlue.opacity(0.48),
                            ],
                            center: .topLeading,
                            startRadius: 1,
                            endRadius: 40
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: VitoraTheme.ColorToken.auraBlue.opacity(0.14), radius: 10, x: 0, y: 4)

                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
        }
    }

    private func statusBadge(kind: ReviewPixelGlyphKind, text: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            ReviewPixelGlyphView(kind: kind, tint: tint, size: 18)
                .frame(width: 18, height: 18)
            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
        }
        .padding(.horizontal, 9)
        .frame(height: 28)
        .background(VitoraTheme.ColorToken.paper.opacity(0.54), in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.62), lineWidth: 0.6))
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
