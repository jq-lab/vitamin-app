import SwiftUI

struct VitoraAssistantSurfaceView: View {
    @ObservedObject var environment: AppEnvironment
    @StateObject private var viewModel = VitoraViewModel()
    @State private var compressed = false
    @State private var showsSettings = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AuraBackground(intensity: 1.18)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    VitoraCompressedHeader(compressed: compressed, onOpenSupport: { showsSettings = true })

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            messageBubble(message)
                        }
                    }
                    .accessibilityIdentifier("vitora.conversation")

                    if environment.isEveningReviewAvailable {
                        EveningReviewEntryCard(review: environment.eveningReview, onOpen: environment.openEveningReview)
                    }

                    ForEach(viewModel.capabilityFeedbacks) { feedback in
                        CapabilityFeedbackCard(feedback: feedback)
                    }

                    DirectQuestionStrips(
                        questions: viewModel.directQuestions,
                        onSelect: viewModel.chooseQuestion
                    )

                    ForEach(viewModel.richResponses.prefix(2)) { response in
                        RichResponseCard(response: response)
                    }

                    QuickContextChips(
                        contexts: viewModel.quickContexts,
                        selected: viewModel.selectedContext,
                        onSelect: viewModel.chooseContext
                    )

                    Color.clear.frame(height: 108)
                }
                .padding(.horizontal, VitoraTheme.Spacing.screenMargin)
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 18)
                    .onChanged { value in
                        compressed = value.translation.height < -18
                    }
            )

            VitoraInputDock(
                text: $viewModel.inputText,
                isVoiceRecording: viewModel.isVoiceRecording,
                onPlus: { viewModel.chooseContext("+") },
                onVoice: viewModel.toggleVoice,
                onSend: viewModel.send
            )
            .padding(.horizontal, VitoraTheme.Spacing.screenMargin)
            .padding(.bottom, VitoraTheme.Size.tabBarHeight + 12)
        }
        .sheet(isPresented: $showsSettings) {
            SettingsPanel(onClose: { showsSettings = false })
        }
        .onAppear {
            viewModel.updateCapability(
                AppCapabilityState(
                    dataSourceState: environment.hasRichTodayDataForUITests ? .authorized : .notAsked,
                    aiAvailability: environment.isAIUnavailableForUITests ? .unavailable : .available
                )
            )
        }
    }

    private func messageBubble(_ message: VitoraMessage) -> some View {
        HStack(alignment: .top, spacing: 9) {
            if message.author == .vitora {
                PixelVitoraView(state: .idle, size: 30, showsGlow: false)
            }

            Text(message.text)
                .font(.subheadline)
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineSpacing(3)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(messageBackground(for: message.author))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            if message.author == .user {
                Spacer(minLength: 24)
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: message.author == .user ? .trailing : .leading)
        .accessibilityIdentifier("vitora.message.\(message.author)")
    }

    private func messageBackground(for author: VitoraMessage.Author) -> some ShapeStyle {
        switch author {
        case .vitora:
            return AnyShapeStyle(.ultraThinMaterial)
        case .user:
            return AnyShapeStyle(VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.72))
        case .system:
            return AnyShapeStyle(VitoraTheme.ColorToken.paper.opacity(0.34))
        }
    }
}

private struct CapabilityFeedbackCard: View {
    let feedback: AppCapabilityFeedback

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 9) {
                Image(systemName: feedback.kind == .aiUnavailable ? "wifi.exclamationmark" : "info.circle")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                Text(feedback.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }

            Text(feedback.message)
                .font(.subheadline)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .lineSpacing(3)

            if feedback.complianceLabelID == "CL-AI-UNAVAILABLE" {
                ComplianceLabel(.aiUnavailable)
            } else if feedback.complianceLabelID == "CL-LOW-DATA" {
                ComplianceLabel(.lowData)
            }
        }
        .padding(14)
        .background(GlassSurface(cornerRadius: 20, opacity: 0.36))
        .accessibilityIdentifier("vitora.capability.\(feedback.kind.rawValue)")
    }
}

private struct EveningReviewEntryCard: View {
    let review: EveningReview
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(alignment: .center, spacing: 14) {
                PixelVitoraView(state: .confirming, size: 44, showsGlow: true)
                    .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 5) {
                    Text("今晚复盘")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)

                    Text("回看今天的建议和晚间感受，让 Vitora 学会更贴近你。")
                        .font(.footnote)
                        .lineSpacing(2)
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
            }
            .padding(14)
            .background(GlassSurface(cornerRadius: 22, opacity: 0.42))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("vitora.review.open")
    }
}
