import SwiftUI

struct VitoraAssistantSurfaceView: View {
    @ObservedObject var environment: AppEnvironment
    @ObservedObject var viewModel: VitoraViewModel
    @State private var hasEnteredChatFocus = false
    @State private var showsSettings = false
    @State private var activeTopicCard: String?
    @State private var isHeaderMuted = false
    @State private var showsCycleCalendar = false
    @State private var selectedCycleDay = 18

    var body: some View {
        ZStack(alignment: .bottom) {
            WaterAuraReferenceBackground(
                scene: .vitora,
                signal: viewModel.voiceSignal,
                isListening: viewModel.isVoiceRecording,
                intensity: 1.06
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: VitoraScrollOffsetPreferenceKey.self,
                                value: proxy.frame(in: .named("vitoraScroll")).minY
                            )
                    }
                    .frame(height: 0)

                    if hasEnteredChatFocus {
                        chatFocusDateContextStrip
                            .transition(.opacity.combined(with: .move(edge: .top)))

                        VitoraFocusPageLinks(
                            showsReview: environment.isEveningReviewAvailable,
                            onOpenCalendar: { showsCycleCalendar = true },
                            onOpenReview: environment.openEveningReviewInVitora
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    } else {
                        VitoraCompressedHeader(
                            mode: .docked,
                            isListening: viewModel.isVoiceRecording,
                            isMuted: isHeaderMuted,
                            onBack: { environment.selectTab(.today) },
                            onToggleMute: {
                                withAnimation(.easeOut(duration: 0.18)) {
                                    isHeaderMuted.toggle()
                                }
                            },
                            onOpenSupport: { showsSettings = true },
                            onOpenCalendar: { showsCycleCalendar = true }
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .zIndex(2)
                    }

                    ChatTopicSelector(
                        topics: viewModel.chatManagerTopics,
                        selectedTopic: activeTopicCard ?? viewModel.selectedContext,
                        onCancel: {
                            withAnimation(.easeOut(duration: 0.18)) {
                                activeTopicCard = nil
                            }
                        },
                        onSelect: { topic in
                            viewModel.chooseContext(topic)
                            withAnimation(.easeOut(duration: 0.18)) {
                                activeTopicCard = topic
                            }
                        }
                    )
                    .padding(.top, hasEnteredChatFocus ? 4 : 2)
                    .zIndex(1)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            messageBubble(message)
                        }
                    }
                    .accessibilityIdentifier("vitora.conversation")

                    if let activeTopicCard {
                        VitoraContextSummaryCard(
                            topic: activeTopicCard,
                            onCancel: {
                                withAnimation(.easeOut(duration: 0.18)) {
                                    self.activeTopicCard = nil
                                }
                            }
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    ForEach(viewModel.capabilityFeedbacks) { feedback in
                        CapabilityFeedbackCard(feedback: feedback)
                    }

                    if activeTopicCard != "周期", environment.canShowEveningReviewAnalysis {
                        EveningReviewAnalysisCard(
                            review: environment.eveningReview,
                            learningSignal: environment.reviewLearningSignal,
                            onFeedback: environment.submitEveningReview,
                            onTellVitora: {
                                environment.openVitoraContext(
                                    sourceTitle: "晚间复盘",
                                    sourceSummary: environment.eveningReview.afterSummary.isEmpty ? environment.eveningReview.beforeSummary : environment.eveningReview.afterSummary,
                                    prompt: "你可以补充今天这个建议后来有没有改变你的状态。"
                                )
                            }
                        )
                    }

                    ForEach(viewModel.richResponses.prefix(activeTopicCard == "周期" ? 0 : 1)) { response in
                        RichResponseCard(response: response)
                    }

                    Color.clear.frame(height: bottomContentSpacerHeight)
                }
                .padding(.horizontal, VitoraTheme.Spacing.screenMargin)
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
            .coordinateSpace(name: "vitoraScroll")
            .onPreferenceChange(VitoraScrollOffsetPreferenceKey.self) { minY in
                guard !hasEnteredChatFocus, minY < -70 else {
                    return
                }
                withAnimation(.easeOut(duration: 0.22)) {
                    hasEnteredChatFocus = true
                }
            }
            .animation(.easeOut(duration: 0.24), value: hasEnteredChatFocus)
        }
        .sheet(isPresented: $showsSettings) {
            SettingsPanel(onClose: { showsSettings = false })
        }
        .sheet(isPresented: $showsCycleCalendar) {
            TodayCalendarSheet(
                selectedCycleDay: selectedCycleDay,
                onSelectCycleDay: { selectedCycleDay = $0 },
                onClose: { showsCycleCalendar = false },
                onAskVitora: {
                    showsCycleCalendar = false
                    viewModel.chooseContext("周期")
                    withAnimation(.easeOut(duration: 0.18)) {
                        activeTopicCard = "周期"
                    }
                }
            )
        }
        .preference(
            key: AppSheetPresentationPreferenceKey.self,
            value: showsSettings || showsCycleCalendar
        )
        .onAppear {
            viewModel.updateCapability(
                AppCapabilityState(
                    dataSourceState: environment.hasRichTodayDataForUITests ? .authorized : .notAsked,
                    aiAvailability: environment.isAIUnavailableForUITests ? .unavailable : .available
                )
            )
        }
        .accessibilityIdentifier("vitora.assistant.surface")
    }

    private var bottomContentSpacerHeight: CGFloat {
        28
    }

    private var chatFocusDateContextStrip: some View {
        Button(action: { showsCycleCalendar = true }) {
            HStack(spacing: 7) {
                Text("今日")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                Text("·")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.72))

                Text("5月5日 周二")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

                Text("·")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.72))

                Text("黄体期 Day18")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)

                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 2)
        .frame(height: 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityLabel("打开周期日历")
        .accessibilityIdentifier("vitora.date.context.openCalendar")
    }

    private func messageBubble(_ message: VitoraMessage) -> some View {
        HStack(alignment: .top, spacing: 9) {
            if message.author == .vitora {
                PixelVitoraMessageAvatar(size: 36)
                    .frame(width: 36, height: 36)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Vitora 留言头像")
                    .accessibilityIdentifier("pixel.vitora.message.avatar")
            }

            VStack(alignment: message.author == .user ? .trailing : .leading, spacing: 6) {
                if message.author == .vitora {
                    Text("Vitora 留言")
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.78))
                        .padding(.leading, 4)
                }

                Text(message.text)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .lineSpacing(4)

                if message.author == .vitora {
                    Text("本内容仅供生活方式参考，不构成医疗建议")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .padding(.top, 1)
                }
            }
            .padding(.horizontal, message.author == .system ? 12 : 14)
            .padding(.vertical, message.author == .system ? 8 : 11)
            .background(alignment: message.author == .user ? .topTrailing : .topLeading) {
                messageBubbleSurface(for: message.author)
            }
            .overlay(
                RoundedRectangle(cornerRadius: message.author == .system ? 16 : 18, style: .continuous)
                    .stroke(messageStroke(for: message.author), lineWidth: 0.7)
            )

            if message.author == .user {
                Spacer(minLength: 24)
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: message.author == .user ? .trailing : .leading)
        .accessibilityIdentifier("vitora.message.\(message.author)")
    }

    private func messageBubbleSurface(for author: VitoraMessage.Author) -> some View {
        ZStack(alignment: author == .user ? .topTrailing : .topLeading) {
            RoundedRectangle(cornerRadius: author == .system ? 16 : 18, style: .continuous)
                .fill(messageFill(for: author))
                .background(.ultraThinMaterial.opacity(author == .system ? 0.12 : 0.18), in: RoundedRectangle(cornerRadius: author == .system ? 16 : 18, style: .continuous))
                .shadow(color: messageShadow(for: author), radius: author == .system ? 6 : 11, x: 0, y: author == .system ? 3 : 6)

            if author != .system {
                ChatBubbleTail(isUser: author == .user)
                    .fill(messageFill(for: author))
                    .frame(width: 11, height: 15)
                    .offset(x: author == .user ? 7 : -7, y: 15)
                    .shadow(color: messageShadow(for: author).opacity(0.8), radius: 5, x: 0, y: 3)
            }
        }
    }

    private func messageFill(for author: VitoraMessage.Author) -> AnyShapeStyle {
        switch author {
        case .vitora:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        VitoraTheme.ColorToken.surfacePearlMain.opacity(0.82),
                        VitoraTheme.ColorToken.paper.opacity(0.66),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .user:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.78),
                        VitoraTheme.ColorToken.paperWarmCyanMist.opacity(0.34),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .system:
            return AnyShapeStyle(VitoraTheme.ColorToken.paper.opacity(0.50))
        }
    }

    private func messageStroke(for author: VitoraMessage.Author) -> Color {
        switch author {
        case .vitora:
            return Color.white.opacity(0.74)
        case .user:
            return VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.16)
        case .system:
            return Color.white.opacity(0.46)
        }
    }

    private func messageShadow(for author: VitoraMessage.Author) -> Color {
        switch author {
        case .vitora:
            return VitoraTheme.ColorToken.paperLiftShadow.opacity(0.14)
        case .user:
            return VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.10)
        case .system:
            return VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06)
        }
    }
}

private struct VitoraScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct ChatBubbleTail: Shape {
    let isUser: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if isUser {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.12))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.midY),
                control: CGPoint(x: rect.maxX * 0.56, y: rect.minY + rect.height * 0.18)
            )
            path.addQuadCurve(
                to: CGPoint(x: rect.minX, y: rect.maxY * 0.92),
                control: CGPoint(x: rect.maxX * 0.46, y: rect.maxY * 0.82)
            )
        } else {
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.12))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX, y: rect.midY),
                control: CGPoint(x: rect.maxX * 0.44, y: rect.minY + rect.height * 0.18)
            )
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.maxY * 0.92),
                control: CGPoint(x: rect.maxX * 0.54, y: rect.maxY * 0.82)
            )
        }
        path.closeSubpath()
        return path
    }
}

private struct VitoraFocusPageLinks: View {
    let showsReview: Bool
    let onOpenCalendar: () -> Void
    let onOpenReview: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            pageLink(
                identifier: "vitora.focus.page.todayData",
                title: "5月5日 黄体期",
                subtitle: "周期日历",
                symbol: "calendar",
                tint: VitoraTheme.ColorToken.actionPrimaryDeep,
                action: onOpenCalendar
            )

            if showsReview {
                pageLink(
                    identifier: "vitora.focus.page.review",
                    title: "晚间复盘",
                    subtitle: "回看建议",
                    symbol: "moon.stars.fill",
                    tint: Color(red: 128 / 255, green: 120 / 255, blue: 236 / 255),
                    action: onOpenReview
                )
            }
        }
        .accessibilityIdentifier("vitora.focus.pageLinks")
    }

    private func pageLink(
        identifier: String,
        title: String,
        subtitle: String,
        symbol: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(tint)
                    .frame(width: 27, height: 27)
                    .background(VitoraTheme.ColorToken.paper.opacity(0.54), in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.62), lineWidth: 0.6))

                Text(title)
                    .font(.system(size: 12.5, weight: .heavy))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Text(subtitle)
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.54))
                    .background(.ultraThinMaterial.opacity(0.18), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.56), lineWidth: 0.65)
            )
            .shadow(color: tint.opacity(0.08), radius: 9, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityIdentifier(identifier)
    }
}

private struct ChatTopicSelector: View {
    let topics: [String]
    let selectedTopic: String
    let onCancel: () -> Void
    let onSelect: (String) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let icons: [String: String] = [
        "周期": "drop.fill",
        "睡眠": "moon.fill",
        "营养": "apple.logo",
        "情绪": "face.smiling.fill",
        "能量": "bolt.fill",
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityElement()
                .accessibilityLabel("聊天主题")
                .accessibilityIdentifier("vitora.chat.manager.topics")
                .allowsHitTesting(false)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(topics, id: \.self) { topic in
                        Button {
                            onSelect(topic)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: icons[topic, default: "circle.fill"])
                                    .font(.system(size: 12, weight: .semibold))
                                Text(topic)
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundStyle(selectedTopic == topic ? VitoraTheme.ColorToken.strongText : VitoraTheme.ColorToken.secondaryText)
                            .padding(.horizontal, 12)
                            .frame(height: 36)
                            .background(topicBackground(for: topic), in: Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(selectedTopic == topic ? 0.92 : 0.48), lineWidth: selectedTopic == topic ? 0.9 : 0.55)
                            )
                            .shadow(color: topicColor(for: topic).opacity(selectedTopic == topic ? 0.22 : 0.06), radius: selectedTopic == topic ? 8 : 3, x: 0, y: 3)
                            .scaleEffect(selectedTopic == topic && !reduceMotion ? 1.02 : 1)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("聊天话题 \(topic)")
                        .accessibilityIdentifier("vitora.chat.topic.\(topic)")
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 7)
            }
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(VitoraTheme.ColorToken.paper.opacity(0.20))
                    .background(.ultraThinMaterial.opacity(0.30), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.44), lineWidth: 0.55))
            )
        }
        .animation(.easeOut(duration: 0.18), value: selectedTopic)
    }

    private func topicBackground(for topic: String) -> AnyShapeStyle {
        if selectedTopic == topic {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        VitoraTheme.ColorToken.paper.opacity(0.82),
                        topicColor(for: topic).opacity(0.32),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        return AnyShapeStyle(VitoraTheme.ColorToken.paper.opacity(0.40))
    }

    private func topicColor(for topic: String) -> Color {
        switch topic {
        case "周期":
            return Color(red: 96 / 255, green: 177 / 255, blue: 238 / 255)
        case "睡眠":
            return Color(red: 128 / 255, green: 120 / 255, blue: 236 / 255)
        case "营养":
            return Color(red: 246 / 255, green: 169 / 255, blue: 74 / 255)
        case "情绪":
            return Color(red: 235 / 255, green: 119 / 255, blue: 177 / 255)
        case "能量":
            return Color(red: 96 / 255, green: 203 / 255, blue: 218 / 255)
        default:
            return VitoraTheme.ColorToken.actionPrimaryDeep
        }
    }
}

private struct VitoraContextSummaryCard: View {
    let topic: String
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 34, height: 34)
                    .background(VitoraTheme.ColorToken.paper.opacity(0.50), in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.62), lineWidth: 0.7))

                VStack(alignment: .leading, spacing: 4) {
                    Text(topicTitle)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)

                    Text(summary)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(tint)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }

                Spacer(minLength: 8)

                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .frame(width: 28, height: 28)
                        .background(VitoraTheme.ColorToken.paper.opacity(0.42), in: Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.58), lineWidth: 0.65))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("取消\(topic)卡片")
                .accessibilityIdentifier("vitora.context.card.cancel")
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(bullets, id: \.self) { bullet in
                    bulletRow(bullet)
                }
            }

            Text(topicBody)
                .font(.footnote.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(GlassSurface(cornerRadius: 22, opacity: 0.60, shadowStrength: 0.58, variant: .cleanResting))
        .accessibilityIdentifier("vitora.context.card.\(topic)")
    }

    private var topicTitle: String {
        "\(topic)上下文"
    }

    private var summary: String {
        switch topic {
        case "周期":
            return "当前黄体期，作为本次提问背景"
        case "睡眠":
            return "昨晚恢复和今天能量一起参考"
        case "营养":
            return "围绕补充、饮食和午后低谷"
        default:
            return "Vitora 会带入本次聊天"
        }
    }

    private var bullets: [String] {
        switch topic {
        case "周期":
            return ["黄体期 Day18", "经期窗口 5月8日-5月12日", "今晚适合轻量复盘"]
        case "睡眠":
            return ["睡眠 7.2h · 略低", "深睡相对够", "HRV ↓8%"]
        case "营养":
            return ["今日补给未记录", "午后低谷前可加蛋白", "补水和蛋白作为生活方式参考"]
        default:
            return ["当前信息较少", "可继续补充", "Vitora 会更新理解"]
        }
    }

    private var topicBody: String {
        switch topic {
        case "周期":
            return "Vitora 会把周期阶段和接下来几天的身体节律一起带入这次聊天。"
        case "睡眠":
            return "Vitora 会把昨晚睡眠、深睡和今天能量一起带入这次提问。"
        case "营养":
            return "Vitora 会把补充和饮食作为生活方式参考，不会变成任务或打卡。"
        default:
            return "Vitora 会把这个主题作为本次聊天的上下文。"
        }
    }

    private var icon: String {
        switch topic {
        case "周期": return "drop.fill"
        case "睡眠": return "moon.fill"
        case "营养": return "apple.logo"
        default: return "sparkles"
        }
    }

    private var tint: Color {
        switch topic {
        case "周期": return Color(red: 96 / 255, green: 177 / 255, blue: 238 / 255)
        case "睡眠": return Color(red: 128 / 255, green: 120 / 255, blue: 236 / 255)
        case "营养": return Color(red: 246 / 255, green: 169 / 255, blue: 74 / 255)
        default: return VitoraTheme.ColorToken.actionPrimaryDeep
        }
    }

    private func bulletRow(_ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Circle()
                .fill(tint.opacity(0.82))
                .frame(width: 6, height: 6)

            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
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
        .background(GlassSurface(cornerRadius: 20, opacity: 0.60, shadowStrength: 0.62, variant: .cleanResting))
        .accessibilityIdentifier("vitora.capability.\(feedback.kind.rawValue)")
    }
}

private struct EveningReviewAnalysisCard: View {
    let review: EveningReview
    let learningSignal: VitoraLearningSignal?
    let onFeedback: (EveningReviewFeedback, String?) -> Void
    let onTellVitora: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            analysisBlock
            feedbackBlock

            if hasFeedback {
                incubationBlock
            }

            Button(action: onTellVitora) {
                HStack(spacing: 9) {
                    ReviewPixelGlyphView(kind: .chat, tint: VitoraTheme.ColorToken.actionPrimaryDeep, size: 26)
                    Text("补充今天的真实感受")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(VitoraTheme.ColorToken.paper.opacity(0.48), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.58), lineWidth: 0.65))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("vitora.review.tell.inline")
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.78))
                .background(.ultraThinMaterial.opacity(0.18), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(Color.white.opacity(0.68), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.12), radius: 18, x: 0, y: 8)
        )
        .accessibilityIdentifier("vitora.review.analysis.card")
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            ReviewPixelGlyphView(
                kind: .moon,
                tint: Color(red: 124 / 255, green: 115 / 255, blue: 236 / 255),
                size: 38
            )

            VStack(alignment: .leading, spacing: 3) {
                Text("晚间复盘")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                Text("Vitora 根据今日能量、提醒偏好和已保存选择整理")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)
        }
    }

    private var analysisBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("早上预测 vs 晚上感受")
                .font(.headline.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            HStack(alignment: .top, spacing: 10) {
                VStack(spacing: 16) {
                    timelineIcon(.sun, tint: Color(red: 247 / 255, green: 180 / 255, blue: 62 / 255))
                    timelineIcon(.idea, tint: Color(red: 148 / 255, green: 117 / 255, blue: 238 / 255))
                    timelineIcon(.chart, tint: VitoraTheme.ColorToken.actionPrimaryDeep)
                    timelineIcon(.moon, tint: Color(red: 124 / 255, green: 115 / 255, blue: 236 / 255))
                }

                VStack(alignment: .leading, spacing: 11) {
                    analysisRow(
                        title: "早上 Vitora 判断",
                        value: "68% · 下午容易掉电",
                        trailing: EmptyView()
                    )

                    Divider().opacity(0.32)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("今天建议")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        HStack(spacing: 8) {
                            suggestionPill(kind: .fork, text: "补一份蛋白", tint: Color(red: 148 / 255, green: 117 / 255, blue: 238 / 255))
                            suggestionPill(kind: .walk, text: "10 分钟轻走", tint: VitoraTheme.ColorToken.actionPrimaryDeep)
                        }
                    }

                    Divider().opacity(0.32)

                    VStack(alignment: .leading, spacing: 7) {
                        Text("你今天用过的设定")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        compactFact(kind: .chart, text: "查看了今日数据")
                        compactFact(kind: .bell, text: "保存了提醒偏好")
                        compactFact(kind: .chat, text: hasFeedback ? "已反馈：\(submittedFeedback?.displayText ?? "有帮助")" : "反馈待确认")
                    }

                    Divider().opacity(0.32)

                    Text(learningSignal?.summary ?? "Vitora 会用这次反馈判断，轻走和留余量是不是更像你。")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .lineSpacing(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(14)
        .background(GlassSurface(cornerRadius: 22, opacity: 0.58, shadowStrength: 0.30, variant: .cleanResting))
    }

    private var feedbackBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("晚上你的反馈")
                .font(.headline.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            HStack(spacing: 9) {
                feedbackButton(.helpful, kind: .check)
                feedbackButton(.neutral, kind: .clock)
                feedbackButton(.notSuitable, kind: .chat)
            }
        }
    }

    private var incubationBlock: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 10) {
                ReviewPixelGlyphView(kind: .water, tint: VitoraTheme.ColorToken.auraCyan, size: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text("复盘已记录")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Text("Vitora 会根据反馈优化后续建议")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }
            }

            Text(learningSignal?.summary ?? "Vitora 会用这次反馈判断哪类建议更像你。")
                .font(.caption.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .lineSpacing(3)
        }
        .padding(14)
        .background(GlassSurface(cornerRadius: 22, opacity: 0.60, shadowStrength: 0.30, variant: .cleanElevated))
    }

    private var hasFeedback: Bool {
        review.status == .submitted || submittedFeedback != nil
    }

    private var submittedFeedback: EveningReviewFeedback? {
        [.helpful, .neutral, .notSuitable].first { review.afterSummary.contains($0.displayText) }
    }

    private func timelineIcon(_ kind: ReviewPixelGlyphKind, tint: Color) -> some View {
        VStack(spacing: 0) {
            ReviewPixelGlyphView(kind: kind, tint: tint, size: 32)
            if kind != .moon {
                Rectangle()
                    .fill(Color.gray.opacity(0.18))
                    .frame(width: 2, height: 18)
            }
        }
    }

    private func analysisRow<Trailing: View>(title: String, value: String, trailing: Trailing) -> some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text(value)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }
            Spacer()
            trailing
        }
    }

    private func suggestionPill(kind: ReviewPixelGlyphKind, text: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            ReviewPixelGlyphView(kind: kind, tint: tint, size: 24)
            Text(text)
                .font(.caption.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .padding(.leading, 7)
        .padding(.trailing, 10)
        .frame(height: 36)
        .background(VitoraTheme.ColorToken.paper.opacity(0.52), in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.62), lineWidth: 0.6))
    }

    private func compactFact(kind: ReviewPixelGlyphKind, text: String) -> some View {
        HStack(spacing: 7) {
            ReviewPixelGlyphView(kind: kind, tint: VitoraTheme.ColorToken.actionPrimaryDeep, size: 20)
            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
        }
    }

    private func feedbackButton(_ feedback: EveningReviewFeedback, kind: ReviewPixelGlyphKind) -> some View {
        let isSelected = submittedFeedback == feedback

        return Button {
            onFeedback(feedback, nil)
        } label: {
            VStack(spacing: 5) {
                ReviewPixelGlyphView(
                    kind: kind,
                    tint: isSelected ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.secondaryText,
                    size: 28
                )
                Text(feedback.displayText)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isSelected ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.72) : VitoraTheme.ColorToken.paper.opacity(0.48))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.44) : Color.white.opacity(0.58), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("vitora.review.feedback.inline.\(feedback.rawValue)")
    }

}
