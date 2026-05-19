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

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 6) {
                    topContext

                    TodayStatusCard(
                        selectedMode: .constant(homeMetricMode),
                        cycleDay: environment.selectedCycleDay,
                        cyclePhase: environment.selectedAuraVariant.phaseLabel,
                        eventTrigger: energyBowlEventID,
                        onOpenDetail: { sheet = .status },
                        onOpenEvidence: { sheet = .bodyFactors },
                        onAskVitora: { openVitora(source: homeMetricMode.topLabel, summary: "\(homeMetricMode.number)\(homeMetricMode.unit) · \(homeMetricMode.statusText)") },
                        onCalibrate: { value in openVitora(source: "今日状态", summary: value) }
                    )

                    VitoraDailySuggestionCard(
                        mode: homeMetricMode,
                        sleepSeed: nil,
                        onCommit: {
                            sheet = .seedPlanting
                        },
                        onOpenDetail: { sheet = .suggestion },
                        onAskVitora: { openVitora(source: "Vitora 今日建议", summary: homeMetricMode.suggestionTitle) }
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
                .padding(.bottom, 28)
            }
            .accessibilityIdentifier("today.pivot.surface")
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
                        environment.nurtureSleepSeedFromTodaySuggestion()
                        viewModel.openAnalysis()
                    },
                    onSwap: { openVitora(source: "今日建议", summary: "换一个方案") },
                    onAskVitora: { openVitora(source: "今日建议", summary: "这个建议不适合") }
                )
            case .seedPlanting:
                SeedPlantingSheet(
                    onClose: { self.sheet = nil },
                    onPlant: { _ in
                        self.sheet = nil
                        energyBowlEventID += 1
                    }
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

    private var selectedCycleContextText: String {
        "\(environment.selectedAuraVariant.phaseLabel) Day \(environment.selectedCycleDay)"
    }

    private var selectedDateText: String {
        let dateDay = ((environment.selectedCycleDay + 14) % 28) + 1
        return "5月\(dateDay)日"
    }
}

private enum TodaySheet: Identifiable {
    case calendar
    case status
    case bodyFactors
    case suggestion
    case seedPlanting

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
        case .seedPlanting:
            return "seedPlanting"
        }
    }
}
