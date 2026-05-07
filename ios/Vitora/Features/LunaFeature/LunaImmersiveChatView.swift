import SwiftUI

struct LunaImmersiveChatView: View {
    @ObservedObject var viewModel: LunaViewModel
    let onExit: () -> Void

    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            VitoraTheme.ColorToken.canvas
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    VitoraTheme.ColorToken.actionPrimary.opacity(0.08),
                    .clear,
                    VitoraTheme.ColorToken.paper.opacity(0.5),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                chatTopBar
                    .padding(.top, 54)
                    .padding(.horizontal, VitoraTheme.Spacing.screenMargin)

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.md) {
                            compactPixelCard
                                .padding(.top, VitoraTheme.Spacing.lg)

                            LunaDateContextRow(text: viewModel.homeState.dateContext)

                            dailyNoteCard

                            ForEach(viewModel.chatMessages) { message in
                                LunaChatBubble(message: message)
                                    .id(message.id)
                            }

                            if viewModel.isChatResponding {
                                LunaTypingIndicator()
                                    .id("luna.chat.typing")
                            }

                            actionChips

                            Spacer(minLength: 112)
                        }
                        .frame(maxWidth: VitoraTheme.Size.contentWidth)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, VitoraTheme.Spacing.screenMargin)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: viewModel.chatMessages.count) { _, _ in
                        scrollToLatest(proxy)
                    }
                    .onChange(of: isInputFocused) { _, focused in
                        if focused {
                            scrollToLatest(proxy)
                        }
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            chatInputDock
                .padding(.horizontal, VitoraTheme.Spacing.screenMargin)
                .padding(.top, VitoraTheme.Spacing.xs)
                .padding(.bottom, VitoraTheme.Spacing.sm)
                .background(
                    VitoraTheme.ColorToken.canvas
                        .opacity(0.94)
                        .ignoresSafeArea(edges: .bottom)
                )
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .gesture(
            DragGesture(minimumDistance: 28)
                .onEnded { value in
                    if value.translation.height > 84 {
                        isInputFocused = false
                        onExit()
                    }
                }
        )
    }

    private var chatTopBar: some View {
        HStack(spacing: VitoraTheme.Spacing.md) {
            Button {
                isInputFocused = false
                onExit()
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                    .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("luna.chat.exit")

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: VitoraTheme.Spacing.md) {
                    Text("AI 对话")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                        .overlay(alignment: .bottomLeading) {
                            Capsule()
                                .fill(VitoraTheme.ColorToken.actionPrimaryDeep)
                                .frame(width: 40, height: 2)
                                .offset(y: 7)
                        }

                    Text("记录本")
                        .font(.subheadline)
                        .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                }
            }

            Spacer()

            Text("主题·总账 ∨")
                .font(.caption)
                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
        }
        .frame(maxWidth: VitoraTheme.Size.contentWidth)
        .frame(maxWidth: .infinity)
    }

    private var compactPixelCard: some View {
        RoundedRectangle(cornerRadius: VitoraTheme.Radius.sheet, style: .continuous)
            .fill(VitoraTheme.ColorToken.cardGlass)
            .overlay(
                RoundedRectangle(cornerRadius: VitoraTheme.Radius.sheet, style: .continuous)
                    .stroke(Color(red: 191 / 255, green: 209 / 255, blue: 224 / 255).opacity(0.30), lineWidth: 0.5)
            )
            .overlay {
                VStack {
                    HStack {
                        Spacer()
                        Text(viewModel.homeState.isLowData ? "信息较少也可以聊" : "今天有点累但还 OK")
                            .font(.caption2)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }

                    Spacer()

                    PixelLunaGlyph(block: 7)
                        .accessibilityHidden(true)

                    Spacer()
                }
                .padding(VitoraTheme.Spacing.md)
            }
            .frame(maxWidth: VitoraTheme.Size.contentWidth)
            .frame(height: 152)
            .accessibilityIdentifier("luna.chat.pixel.card")
    }

    private var dailyNoteCard: some View {
        Button {
            viewModel.openRecordSheetFromChat()
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(red: 255 / 255, green: 248 / 255, blue: 231 / 255))
                    .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 7) {
                    Text("今天发生了什么呢？")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(VitoraTheme.ColorToken.primaryText)

                    Text("随时随心，你来说，我来记  →")
                        .font(.caption2)
                        .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)

                    Spacer()

                    HStack {
                        Spacer()
                        PixelLunaGlyph(block: 3)
                    }
                }
                .padding(VitoraTheme.Spacing.md)
            }
            .frame(height: 106)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("luna.chat.note.record")
    }

    private var actionChips: some View {
        HStack(spacing: VitoraTheme.Spacing.sm) {
            LunaChatActionChip(title: "记录经期", tint: Color(red: 255 / 255, green: 229 / 255, blue: 236 / 255), text: Color(red: 192 / 255, green: 64 / 255, blue: 96 / 255)) {
                viewModel.selectQuickType(.cycle)
                viewModel.openRecordSheetFromChat()
            }

            LunaChatActionChip(title: "睡眠分析", tint: Color(red: 232 / 255, green: 228 / 255, blue: 245 / 255), text: Color(red: 80 / 255, green: 64 / 255, blue: 160 / 255)) {
                viewModel.selectQuickType(.sleep)
                viewModel.openRecordSheetFromChat()
            }

            LunaChatActionChip(title: "能量建议", tint: Color(red: 255 / 255, green: 243 / 255, blue: 214 / 255), text: Color(red: 176 / 255, green: 127 / 255, blue: 0)) {
                viewModel.chatInputText = "我想要一个轻一点的能量建议"
                viewModel.sendChatMessage()
            }
        }
        .accessibilityIdentifier("luna.chat.action.chips")
    }

    private var chatInputDock: some View {
        HStack(spacing: VitoraTheme.Spacing.xs) {
            Button {
                isInputFocused = false
                viewModel.openRecordSheetFromChat()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .frame(width: 38, height: 38)
                    .background(VitoraTheme.ColorToken.softSurface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("luna.chat.record")

            TextField("问 Vitora，或按住录音说...", text: $viewModel.chatInputText)
                .font(.caption)
                .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                .textFieldStyle(.plain)
                .padding(.horizontal, VitoraTheme.Spacing.md)
                .frame(maxWidth: .infinity, minHeight: 38)
                .background(VitoraTheme.ColorToken.softSurface)
                .clipShape(Capsule())
                .focused($isInputFocused)
                .submitLabel(.send)
                .onSubmit(viewModel.sendChatMessage)
                .accessibilityIdentifier("luna.chat.input")

            Button {
                viewModel.sendChatMessage()
                isInputFocused = false
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.paper)
                    .frame(width: 38, height: 38)
                    .background(VitoraTheme.ColorToken.shell)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("luna.chat.send")
        }
        .frame(maxWidth: VitoraTheme.Size.contentWidth)
        .frame(height: VitoraTheme.Size.inputDockHeight)
    }

    private func scrollToLatest(_ proxy: ScrollViewProxy) {
        guard let id = viewModel.chatMessages.last?.id else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.22)) {
                proxy.scrollTo(id, anchor: .bottom)
            }
        }
    }
}

private struct LunaChatBubble: View {
    let message: LunaConversationMessage

    var body: some View {
        switch message.role {
        case .luna:
            HStack(alignment: .top, spacing: VitoraTheme.Spacing.xs) {
                PixelLunaMiniBadge()
                Text(message.contentSummary)
                    .font(.subheadline)
                    .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                    .lineSpacing(3)
                    .padding(.horizontal, VitoraTheme.Spacing.md)
                    .padding(.vertical, VitoraTheme.Spacing.sm)
                    .background(VitoraTheme.ColorToken.softSurface)
                    .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.lg, style: .continuous))
                    .accessibilityIdentifier("luna.chat.message.luna")
                Spacer(minLength: 22)
            }
        case .user:
            HStack {
                Spacer(minLength: 54)
                Text(message.contentSummary)
                    .font(.subheadline)
                    .foregroundStyle(VitoraTheme.ColorToken.paper)
                    .lineSpacing(3)
                    .padding(.horizontal, VitoraTheme.Spacing.md)
                    .padding(.vertical, VitoraTheme.Spacing.sm)
                    .background(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.lg, style: .continuous))
                    .accessibilityIdentifier("luna.chat.message.user")
            }
        case .system:
            Text(message.contentSummary)
                .font(.caption)
                .foregroundStyle(VitoraTheme.ColorToken.success)
                .padding(.horizontal, VitoraTheme.Spacing.sm)
                .padding(.vertical, VitoraTheme.Spacing.xs)
                .background(VitoraTheme.ColorToken.paper.opacity(0.88))
                .clipShape(Capsule())
                .accessibilityIdentifier("luna.chat.message.system")
        }
    }
}

private struct LunaChatActionChip: View {
    let title: String
    let tint: Color
    let text: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .foregroundStyle(text)
                .padding(.horizontal, VitoraTheme.Spacing.sm)
                .frame(height: 28)
                .background(tint)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("luna.chat.chip.\(title)")
    }
}

private struct LunaTypingIndicator: View {
    var body: some View {
        HStack(spacing: 6) {
            PixelLunaMiniBadge()
            Text("Luna 正在整理...")
                .font(.caption)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
        }
        .accessibilityIdentifier("luna.chat.typing")
    }
}

private struct PixelLunaMiniBadge: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(VitoraTheme.ColorToken.actionPrimarySoft)
            .frame(width: 28, height: 28)
            .overlay {
                PixelLunaGlyph(block: 2)
            }
    }
}
