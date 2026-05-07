import SwiftUI

struct LunaView: View {
    @ObservedObject var environment: AppEnvironment
    @StateObject private var viewModel: LunaViewModel

    init(environment: AppEnvironment) {
        self.environment = environment
        _viewModel = StateObject(
            wrappedValue: LunaViewModel(
                isLowData: environment.navigationState.gate == .lowDataReady,
                aiUnavailable: environment.isAIUnavailableForUITests
            )
        )
    }

    var body: some View {
        ZStack {
            VitoraTheme.ColorToken.canvas
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    VitoraTheme.ColorToken.actionPrimary.opacity(0.10),
                    .clear,
                ],
                startPoint: .top,
                endPoint: .center
            )
            .blur(radius: 42)
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: VitoraTheme.Spacing.md) {
                    LunaTopBar()
                        .padding(.top, 44)

                    LunaPixelHomeCard(
                        state: viewModel.homeState,
                        onOpenRecord: { viewModel.openRecordSheet() }
                    )
                    .padding(.top, VitoraTheme.Spacing.sm)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 28)
                            .onEnded { value in
                                if value.translation.height < -72 {
                                    openImmersiveChat()
                                }
                            }
                    )

                    LunaDateContextRow(text: viewModel.homeState.dateContext)

                    LunaContextBubble(
                        state: viewModel.homeState,
                        onOpenRecord: { viewModel.openRecordSheet() }
                    )

                    if let savedBannerText = viewModel.savedBannerText {
                        Text(savedBannerText)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.success)
                            .frame(maxWidth: VitoraTheme.Size.contentWidth, alignment: .leading)
                            .accessibilityIdentifier("luna.record.saved.banner")
                    }

                    if let recentRecordSummary = viewModel.homeState.recentRecordSummary {
                        LunaRecentRecordCard(summary: recentRecordSummary)
                    }

                    if let reviewPrompt = viewModel.homeState.reviewPrompt {
                        Text(reviewPrompt)
                            .font(.footnote)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            .padding(VitoraTheme.Spacing.md)
                            .frame(maxWidth: VitoraTheme.Size.contentWidth, alignment: .leading)
                            .background(VitoraTheme.ColorToken.paper.opacity(0.88))
                            .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.card, style: .continuous))
                    }

                    Spacer(minLength: 170)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, VitoraTheme.Spacing.screenMargin)
                .padding(.bottom, VitoraTheme.Size.tabBarHeight + VitoraTheme.Size.inputDockHeight + 36)
            }
            .accessibilityHidden(viewModel.isImmersiveChatPresented)
            .allowsHitTesting(!viewModel.isImmersiveChatPresented)

            VStack {
                Spacer()

                LunaInputDock {
                    viewModel.openRecordSheet()
                } onOpenChat: {
                    openImmersiveChat()
                }
                .padding(.horizontal, VitoraTheme.Spacing.screenMargin)
                .padding(.bottom, VitoraTheme.Size.tabBarHeight + 18)
            }
            .accessibilityHidden(viewModel.isImmersiveChatPresented)
            .allowsHitTesting(!viewModel.isImmersiveChatPresented)

            if viewModel.isImmersiveChatPresented {
                LunaImmersiveChatView(viewModel: viewModel) {
                    closeImmersiveChat()
                }
                .zIndex(2)
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 32)
                .onEnded { value in
                    guard !viewModel.isImmersiveChatPresented, !viewModel.isRecordSheetPresented else {
                        return
                    }
                    if value.translation.height < -86, abs(value.translation.width) < 80 {
                        openImmersiveChat()
                    }
                }
        )
        .onAppear(perform: schedulePendingRecordCheck)
        .onChange(of: environment.lunaRecordRequestID) { _, _ in
            schedulePendingRecordCheck()
        }
        .onChange(of: environment.navigationState.presentation) { _, presentation in
            if presentation == .lunaChat, !viewModel.isImmersiveChatPresented {
                viewModel.enterImmersiveChat()
            }
        }
        .sheet(isPresented: $viewModel.isRecordSheetPresented) {
            LunaRecordSheet(viewModel: viewModel)
                .presentationDetents([.height(536), .large])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(false)
        }
    }

    private func schedulePendingRecordCheck() {
        DispatchQueue.main.async {
            openPendingRecordIfNeeded()
        }
    }

    private func openPendingRecordIfNeeded() {
        guard environment.navigationState.presentation == .lunaRecord else {
            return
        }
        viewModel.openRecordSheet()
        environment.dismissPresentation()
    }

    private func openImmersiveChat() {
        environment.present(.lunaChat)
        viewModel.enterImmersiveChat()
    }

    private func closeImmersiveChat() {
        viewModel.exitImmersiveChat()
        environment.dismissPresentation()
    }
}
