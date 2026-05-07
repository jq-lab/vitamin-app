import SwiftUI

struct TodayView: View {
    @ObservedObject var environment: AppEnvironment
    @StateObject private var viewModel: TodayViewModel
    @State private var sheet: TodaySheet?
    @State private var energyExpanded = false

    init(environment: AppEnvironment) {
        self.environment = environment
        _viewModel = StateObject(wrappedValue: TodayViewModel(isLowData: environment.navigationState.gate == .lowDataReady))
    }

    var body: some View {
        ZStack(alignment: .top) {
            AuraBackground(intensity: 1.05)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    topContext

                    EnergyRevealHeader(
                        isExpanded: energyExpanded,
                        onOpenDetail: { sheet = .status },
                        onAskVitora: { openVitora(source: "今日能量球", summary: "68% · 能量平稳") }
                    )

                    TodayStatusCard(
                        onOpenDetail: { sheet = .status },
                        onAskVitora: { openVitora(source: "今日状态", summary: "68% · 14:00 可能低谷") },
                        onCalibrate: { value in openVitora(source: "今日状态", summary: value) }
                    )

                    ComplianceLabel(.defaultLifestyle)
                        .padding(.horizontal, 4)

                    BodyFactorTiles(
                        onOpenDetail: { sheet = .bodyFactors },
                        onAskVitora: { factor in openVitora(source: "身体要素", summary: factor) }
                    )

                    VitoraDailySuggestionCard(
                        onCommit: viewModel.openAnalysis,
                        onSwap: { openVitora(source: "Vitora 今日建议", summary: "用户想换一个更轻方案") },
                        onOpenDetail: { sheet = .suggestion },
                        onAskVitora: { openVitora(source: "Vitora 今日建议", summary: "13:30 蛋白 + 轻走 10 分钟") }
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
                        .background(GlassSurface(cornerRadius: 22, opacity: 0.38))
                        .accessibilityIdentifier("today.intention.confirmation")
                    }
                }
                .padding(.horizontal, VitoraTheme.Spacing.screenMargin)
                .padding(.top, 12)
                .padding(.bottom, VitoraTheme.Size.tabBarHeight + 38)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 14)
                    .onEnded { value in
                        if value.translation.height > 58 {
                            energyExpanded = true
                        } else if value.translation.height < -42 {
                            energyExpanded = false
                        }
                    }
            )
            .accessibilityIdentifier("today.pivot.surface")
        }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .calendar:
                TodayCalendarSheet(
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
                    onCommit: viewModel.openAnalysis,
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
    }

    private var topContext: some View {
        HStack(spacing: 10) {
            Button {
                sheet = .calendar
            } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("打开周期日历")
            .accessibilityIdentifier("today.calendar.open")

            Text(viewModel.isLowData ? "低数据模式" : viewModel.cycleContextText)
                .font(.headline.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(GlassSurface(cornerRadius: 17, opacity: 0.28))

            Spacer()

            Text("5月5日")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
        }
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
