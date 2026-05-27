import Foundation
import SwiftUI
import AVFoundation
import Speech

struct VitoraContextualSheet: View {
    let context: VitoraContextPayload
    let onClose: () -> Void
    let onSubmit: (RecentRecordFeedback) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @GestureState private var sheetDragOffset: CGFloat = 0
    @State private var mode: VitoraRecordMode = .manual
    @State private var periodState: ManualPeriodState = .period
    @State private var expandedOutlineID: String?
    @State private var expandedAllOutlineIDs: Set<String> = []
    @State private var selectedOptionIDs: Set<String> = []
    @State private var selectedMediaAction: ManualMediaAction?
    @State private var aiInputMode: VitoraAIInputMode = .text
    @State private var aiInput = ""
    @State private var aiPreview: AccountingAIParseResult?
    @State private var aiFallbackNotice: String?
    @State private var recordNote = ""
    @State private var showsSaved = false
    @StateObject private var voiceCapture = VitoraVoiceCapture()

    init(
        context: VitoraContextPayload,
        onClose: @escaping () -> Void,
        onSubmit: @escaping (RecentRecordFeedback) -> Void
    ) {
        self.context = context
        self.onClose = onClose
        self.onSubmit = onSubmit
        _mode = State(initialValue: context.initialRecordMode)
        _aiInputMode = State(initialValue: context.initialAIInputMode)

        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-vitoraUITestRecordModeAI") {
            _mode = State(initialValue: .ai)
            _aiInputMode = State(initialValue: .text)
        }
        if arguments.contains("-vitoraUITestRecordAIPreview") {
            let input = "中午吃饭 38"
            _mode = State(initialValue: .ai)
            _aiInputMode = State(initialValue: .text)
            _aiInput = State(initialValue: input)
            _aiPreview = State(initialValue: AccountingAIParser.parse(input))
        }
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Spacer(minLength: 0)

                sheetCard
                    .frame(maxHeight: min(proxy.size.height * 0.92, 790))
                    .padding(.horizontal, 10)
                    .padding(.bottom, max(proxy.safeAreaInsets.bottom, 8))
                    .offset(y: max(sheetDragOffset, 0))
                    .gesture(dismissDragGesture)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .animation(.easeOut(duration: reduceMotion ? 0.12 : 0.22), value: mode)
        .animation(.easeOut(duration: reduceMotion ? 0.12 : 0.22), value: periodState)
        .animation(.easeOut(duration: reduceMotion ? 0.12 : 0.22), value: aiInputMode)
        .animation(.easeOut(duration: reduceMotion ? 0.12 : 0.22), value: expandedOutlineID)
        .animation(.easeOut(duration: reduceMotion ? 0.12 : 0.22), value: selectedOptionIDs)
        .onChange(of: voiceCapture.transcript) { _, transcript in
            if aiInputMode == .voice, !transcript.isEmpty {
                aiInput = transcript
                aiPreview = nil
            }
        }
        .onChange(of: voiceCapture.shouldFallbackToText) { _, shouldFallback in
            guard shouldFallback else { return }
            aiFallbackNotice = voiceCapture.statusMessage
            aiInputMode = .text
        }
    }

    private var sheetCard: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.black.opacity(0.16))
                .frame(width: 46, height: 5)
                .padding(.top, 11)
                .padding(.bottom, 4)

            modeSwitcher
                .padding(.horizontal, 18)
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                Group {
                    switch mode {
                    case .manual:
                        manualContent
                    case .ai:
                        aiContent
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 18)
            }

            bottomActions
        }
        .overlay(alignment: .topLeading) {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(Color.black.opacity(0.52))
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.72), in: Circle())
            }
            .buttonStyle(.plain)
            .padding(.top, 10)
            .padding(.leading, 16)
            .accessibilityLabel("关闭快捷记录")
            .accessibilityIdentifier("vitora.context.close")
        }
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color.white)
                .overlay(
                    LinearGradient(
                        colors: [
                            currentManualSoft.opacity(0.34),
                            Color.white.opacity(0.96),
                            Color(accountingHex: "F7FBFF").opacity(mode == .manual ? 0.42 : 0.0),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.black.opacity(0.07), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 14)
        )
        .accessibilityIdentifier("vitora.accounting.sheet")
    }

    private var dismissDragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .updating($sheetDragOffset) { value, state, _ in
                if value.translation.height > 0 {
                    state = value.translation.height
                }
            }
            .onEnded { value in
                let shouldDismiss = value.translation.height > 86 || value.predictedEndTranslation.height > 150
                if shouldDismiss {
                    onClose()
                }
            }
    }

    private var modeSwitcher: some View {
        HStack(spacing: 8) {
            modeButton(.manual, accent: currentManualAccent)
            modeButton(.ai, accent: AccountingPalette.aiAccent)
        }
        .padding(7)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(accountingHex: "F9FBFE"))
                .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 8)
        )
    }

    private func modeButton(_ item: VitoraRecordMode, accent: Color) -> some View {
        let isSelected = mode == item

        return Button {
            withAnimation(.easeOut(duration: reduceMotion ? 0.12 : 0.22)) {
                mode = item
                showsSaved = false
            }
        } label: {
            VStack(spacing: 6) {
                HStack(spacing: 5) {
                    Text(item.title)
                    if item == .ai && isSelected {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .heavy))
                    }
                }
                .font(.system(size: 19, weight: isSelected ? .heavy : .semibold, design: .rounded))
                .foregroundStyle(isSelected ? VitoraTheme.ColorToken.strongText : Color.black.opacity(0.46))

                Capsule()
                    .fill(isSelected ? accent : Color.clear)
                    .frame(width: 52, height: 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 62)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isSelected ? accent.opacity(0.15) : Color.white.opacity(0.52))
            )
        }
        .buttonStyle(.plain)
        .accessibilityValue(isSelected ? "已选择" : "未选择")
        .accessibilityIdentifier("vitora.record.mode.\(item.rawValue)")
    }

    // MARK: - Manual

    private var manualContent: some View {
        VStack(spacing: 14) {
            periodStateSwitch
            manualGuide

            ForEach(currentOutlines) { outline in
                outlineCard(outline)
            }

            quickFields
            mediaRecordCard
            recordNoteBar(accent: currentManualAccent)
        }
    }

    private var periodStateSwitch: some View {
        HStack(spacing: 10) {
            ForEach(ManualPeriodState.allCases) { item in
                let isSelected = periodState == item

                Button {
                    changePeriodState(item)
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: item.systemImage)
                            .font(.system(size: 14, weight: .heavy))
                        Text(item.title)
                            .font(.system(size: 16, weight: isSelected ? .heavy : .semibold, design: .rounded))
                    }
                    .foregroundStyle(isSelected ? item.color : Color.black.opacity(0.52))
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(isSelected ? item.soft : Color.white.opacity(0.54), in: Capsule())
                    .overlay(Capsule().stroke(isSelected ? item.color.opacity(0.18) : Color.black.opacity(0.06), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityValue(isSelected ? "已选择" : "未选择")
                .accessibilityIdentifier("vitora.record.periodState.\(item.rawValue)")
            }
        }
        .padding(5)
        .background(Color.white.opacity(0.72), in: Capsule())
        .overlay(Capsule().stroke(Color.black.opacity(0.05), lineWidth: 1))
    }

    private var manualGuide: some View {
        HStack(spacing: 10) {
            Image(systemName: "list.bullet.rectangle.portrait")
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(currentManualAccent)
                .frame(width: 34, height: 34)
                .background(currentManualSoft, in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text("先选一个大纲，再点下方词条")
                    .font(.system(size: 14.5, weight: .heavy, design: .rounded))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text("默认显示高频 5 项；更多里是完整支线。")
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.44))
            }

            Spacer()
        }
        .padding(13)
        .background(Color(accountingHex: "F8FAFC").opacity(0.86), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.black.opacity(0.05), lineWidth: 1))
    }

    private func outlineCard(_ outline: HealthRecordOutline) -> some View {
        let isExpanded = expandedOutlineID == outline.id || expandedAllOutlineIDs.contains(outline.id)
        let selectedCount = outline.selectedCount(in: selectedOptionIDs)

        return VStack(alignment: .leading, spacing: 12) {
            Button {
                toggleOutline(outline.id)
            } label: {
                HStack(spacing: 11) {
                    Image(systemName: outline.systemImage)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(outline.color)
                        .frame(width: 38, height: 38)
                        .background(outline.soft, in: Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 7) {
                            Text(outline.title)
                                .font(.system(size: 16.5, weight: .heavy, design: .rounded))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            if selectedCount > 0 {
                                Text("\(selectedCount)")
                                    .font(.caption2.weight(.heavy))
                                    .foregroundStyle(.white)
                                    .frame(width: 20, height: 20)
                                    .background(outline.color, in: Circle())
                            }
                        }
                        Text(outline.subtitle)
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.42))
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Color.black.opacity(0.38))
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.74), in: Circle())
                }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("vitora.record.outline.\(outline.id)")

            optionGrid(options: outline.defaultOptions, outline: outline)

            if isExpanded {
                expandedOptionSections(outline)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }

            if !isExpanded {
                Button {
                    withAnimation(.easeOut(duration: reduceMotion ? 0.12 : 0.22)) {
                        expandedAllOutlineIDs.insert(outline.id)
                        expandedOutlineID = outline.id
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text("更多")
                        Image(systemName: "plus.circle.fill")
                    }
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(outline.color)
                    .padding(.horizontal, 11)
                    .frame(height: 29)
                    .background(outline.soft.opacity(0.72), in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("vitora.record.outline.\(outline.id).more")
            }
        }
        .padding(13)
        .background(Color.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 23, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 23, style: .continuous).stroke(outline.color.opacity(selectedCount > 0 ? 0.20 : 0.08), lineWidth: 1))
        .shadow(color: outline.color.opacity(selectedCount > 0 ? 0.09 : 0.04), radius: selectedCount > 0 ? 12 : 8, x: 0, y: 6)
    }

    private func optionGrid(options: [HealthRecordOption], outline: HealthRecordOutline) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 11) {
            ForEach(options) { option in
                optionButton(option, outline: outline)
            }
        }
    }

    @ViewBuilder
    private func expandedOptionSections(_ outline: HealthRecordOutline) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(outline.sections) { section in
                VStack(alignment: .leading, spacing: 8) {
                    Text(section.title)
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Color.black.opacity(0.48))
                    optionGrid(options: section.options, outline: outline)
                }
            }
        }
        .padding(12)
        .background(outline.soft.opacity(0.42), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func optionButton(_ option: HealthRecordOption, outline: HealthRecordOutline) -> some View {
        let isSelected = selectedOptionIDs.contains(option.id)

        return Button {
            withAnimation(.easeOut(duration: reduceMotion ? 0.12 : 0.22)) {
                toggleOption(option.id)
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: option.systemImage)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(isSelected ? .white : outline.color)
                    .frame(width: 46, height: 46)
                    .background(isSelected ? outline.color : outline.soft, in: Circle())
                    .overlay(Circle().stroke(isSelected ? Color.white.opacity(0.72) : outline.color.opacity(0.16), lineWidth: isSelected ? 2.2 : 1))
                    .shadow(color: outline.color.opacity(isSelected ? 0.18 : 0.06), radius: isSelected ? 8 : 4, x: 0, y: 4)

                Text(option.title)
                    .font(.system(size: 11.5, weight: isSelected ? .heavy : .semibold))
                    .foregroundStyle(isSelected ? outline.color : VitoraTheme.ColorToken.strongText.opacity(0.72))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.72)
                    .frame(height: 28, alignment: .top)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityValue(isSelected ? "已选择" : "未选择")
        .accessibilityIdentifier("vitora.record.option.\(option.id)")
    }

    private var quickFields: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AccountingQuickField.defaults) { field in
                    Label(field.title, systemImage: field.systemImage)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Color.black.opacity(0.66))
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(Color.black.opacity(0.10), lineWidth: 1))
                }
            }
            .padding(.vertical, 1)
        }
        .accessibilityIdentifier("vitora.accounting.quickFields")
    }

    private var mediaRecordCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("补充记录素材")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Text("可以只选分类完成，图片、拍照和语音是可选入口。")
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.45))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                ForEach(ManualMediaAction.allCases) { action in
                    mediaActionButton(action)
                }
            }

            if let selectedMediaAction {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("已选择 \(selectedMediaAction.title)，可继续完成记录")
                }
                .font(.caption.weight(.heavy))
                .foregroundStyle(currentManualAccent)
                .transition(.opacity)
            }
        }
        .padding(16)
        .background(currentManualSoft.opacity(0.52), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(currentManualAccent.opacity(0.12), lineWidth: 1))
        .accessibilityIdentifier("vitora.accounting.mediaCard")
    }

    private func mediaActionButton(_ action: ManualMediaAction) -> some View {
        let isSelected = selectedMediaAction == action

        return Button {
            withAnimation(.easeOut(duration: reduceMotion ? 0.12 : 0.22)) {
                selectedMediaAction = action
                showsSaved = false
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: action.systemImage)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(isSelected ? .white : currentManualAccent)
                    .frame(width: 54, height: 54)
                    .background(isSelected ? currentManualAccent : Color.white, in: Circle())
                    .overlay(Circle().stroke(currentManualAccent.opacity(isSelected ? 0 : 0.18), lineWidth: 1))

                Text(action.title)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(isSelected ? currentManualAccent : VitoraTheme.ColorToken.strongText.opacity(0.74))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityValue(isSelected ? "已选择" : "未选择")
        .accessibilityIdentifier("vitora.accounting.media.\(action.rawValue)")
    }

    // MARK: - AI

    private var aiContent: some View {
        VStack(spacing: 16) {
            aiInputModeSwitcher

            if let aiFallbackNotice {
                Label(aiFallbackNotice, systemImage: "keyboard")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(AccountingPalette.aiDeep)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
                    .background(AccountingPalette.aiSoft.opacity(0.72), in: Capsule())
                    .transition(.opacity)
            }

            switch aiInputMode {
            case .voice:
                aiVoiceBox
            case .text:
                aiInputBox
            }

            aiExampleChips
            aiPreviewCard
            recordNoteBar(accent: AccountingPalette.aiAccent)
        }
    }

    private var aiInputModeSwitcher: some View {
        HStack(spacing: 8) {
            aiInputModeButton(.voice)
            aiInputModeButton(.text)
        }
        .padding(5)
        .background(Color.white.opacity(0.78), in: Capsule())
        .overlay(Capsule().stroke(AccountingPalette.aiAccent.opacity(0.10), lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("vitora.record.ai.inputMode")
    }

    private func aiInputModeButton(_ item: VitoraAIInputMode) -> some View {
        let isSelected = aiInputMode == item

        return Button {
            withAnimation(.easeOut(duration: reduceMotion ? 0.12 : 0.22)) {
                if item == .text, !voiceCapture.transcript.isEmpty {
                    aiInput = voiceCapture.transcript
                }
                aiInputMode = item
                aiFallbackNotice = nil
                showsSaved = false
            }
        } label: {
            Label(item.title, systemImage: item.systemImage)
                .font(.system(size: 14.5, weight: isSelected ? .heavy : .semibold, design: .rounded))
                .foregroundStyle(isSelected ? AccountingPalette.aiDeep : Color.black.opacity(0.48))
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(isSelected ? AccountingPalette.aiSoft : Color.clear, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityValue(isSelected ? "已选择" : "未选择")
        .accessibilityIdentifier("vitora.record.ai.mode.\(item.rawValue)")
    }

    private var aiVoiceBox: some View {
        VStack(spacing: 15) {
            VStack(spacing: 9) {
                Button {
                    toggleVoiceCapture()
                } label: {
                    ZStack {
                        Circle()
                            .fill(AccountingPalette.aiSoft)
                            .frame(width: 90, height: 90)
                            .overlay(Circle().stroke(AccountingPalette.aiAccent.opacity(0.18), lineWidth: 1))

                        if voiceCapture.state == .recording && !reduceMotion {
                            Circle()
                                .stroke(AccountingPalette.aiAccent.opacity(0.22), lineWidth: 7)
                                .frame(width: 104, height: 104)
                                .scaleEffect(1.08)
                                .opacity(0.62)
                        }

                        Image(systemName: voiceCapture.state == .recording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 31, weight: .heavy))
                            .foregroundStyle(AccountingPalette.aiAccent)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(voiceCapture.state == .recording ? "停止语音记录" : "开始语音记录")
                .accessibilityIdentifier("vitora.record.ai.voice.toggle")

                Text(voiceCapture.state.statusTitle)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                Text(voiceCapture.statusMessage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.48))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("实时转写")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Color.black.opacity(0.44))

                Text(voiceCapture.transcript.isEmpty ? "说一句今天的身体感受、情绪或经期变化。" : voiceCapture.transcript)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(voiceCapture.transcript.isEmpty ? Color.black.opacity(0.28) : VitoraTheme.ColorToken.strongText)
                    .frame(maxWidth: .infinity, minHeight: 58, alignment: .topLeading)
                    .padding(13)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AccountingPalette.aiAccent.opacity(0.12), lineWidth: 1))
            }

            HStack(spacing: 10) {
                Button {
                    voiceCapture.reset()
                    aiPreview = nil
                    showsSaved = false
                } label: {
                    Text("重新说")
                        .font(.system(size: 14, weight: .heavy))
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .accessibilityIdentifier("vitora.record.ai.voice.reset")

                Button {
                    aiInput = voiceCapture.transcript
                    aiInputMode = .text
                    showsSaved = false
                } label: {
                    Text("转打字")
                        .font(.system(size: 14, weight: .heavy))
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .foregroundStyle(AccountingPalette.aiDeep)
                .accessibilityIdentifier("vitora.record.ai.voice.toText")

                Button {
                    parseVoiceTranscript()
                } label: {
                    Text("解析")
                        .font(.system(size: 14, weight: .heavy))
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(voiceCapture.transcript.isEmpty ? Color.white.opacity(0.62) : AccountingPalette.aiAccent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .foregroundStyle(voiceCapture.transcript.isEmpty ? Color.black.opacity(0.34) : .white)
                .disabled(voiceCapture.transcript.isEmpty)
                .accessibilityIdentifier("vitora.record.ai.voice.parse")
            }
        }
        .padding(16)
        .background(AccountingPalette.aiSoft, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(AccountingPalette.aiAccent.opacity(0.12), lineWidth: 1))
    }

    private func recordNoteBar(accent: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "text.bubble")
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(accent)
                .frame(width: 34, height: 34)
                .background(accent.opacity(0.12), in: Circle())

            TextField("留言给 Vitora：比如今晚担心侧漏、想轻一点安排…", text: $recordNote)
                .font(.system(size: 14.5, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                .accessibilityIdentifier("vitora.record.note.input")
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 52)
        .background(Color.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(accent.opacity(0.13), lineWidth: 1))
    }

    private var aiInputBox: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $aiInput)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .scrollContentBackground(.hidden)
                .padding(12)
                .frame(minHeight: 150)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(AccountingPalette.aiAccent.opacity(0.18), lineWidth: 1)
                )
                .accessibilityIdentifier("vitora.record.ai.input")

            if aiInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("用一句话记录：今天有点头痛，吃了 B6 和镁…")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.28))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 21)
                    .allowsHitTesting(false)
            }

            HStack(spacing: 12) {
                Image(systemName: "photo")
                    .font(.system(size: 20, weight: .semibold))
                Image(systemName: "mic")
                    .font(.system(size: 20, weight: .semibold))

                Spacer()

                Button {
                    parseAIInput()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 21, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(AccountingPalette.aiAccent, in: Circle())
                }
                .buttonStyle(.plain)
                .disabled(aiInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(aiInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.48 : 1)
                .accessibilityLabel("解析 AI 记录")
                .accessibilityIdentifier("vitora.record.ai.send")
            }
            .foregroundStyle(Color.black.opacity(0.50))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .padding(10)
        .background(AccountingPalette.aiSoft, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
    }

    private var aiExampleChips: some View {
        FlowWrapLayout(spacing: 8) {
            ForEach(["头有点痛", "吃了 B6 和镁", "情绪低落", "月经晚来 2 天", "小腹坠胀 中度"], id: \.self) { example in
                Button {
                    withAnimation(.easeOut(duration: reduceMotion ? 0.12 : 0.22)) {
                        aiInput = example
                        aiInputMode = .text
                        aiFallbackNotice = nil
                        aiPreview = nil
                    }
                } label: {
                    Text(example)
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(AccountingPalette.aiDeep)
                        .padding(.horizontal, 12)
                        .frame(height: 32)
                        .background(AccountingPalette.aiSoft, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var aiPreviewCard: some View {
        if let aiPreview {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("AI 已拆出字段", systemImage: "sparkles")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(AccountingPalette.aiDeep)
                        .padding(.horizontal, 10)
                        .frame(height: 28)
                        .background(AccountingPalette.aiSoft, in: Capsule())

                    Spacer()

                    Text("保存前可确认")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.black.opacity(0.48))
                }

                Text("“\(aiPreview.note)”")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
                    .background(Color(accountingHex: "F6F3EF"), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                HStack(spacing: 8) {
                    parsedPill(label: "类别", value: aiPreview.type)
                    parsedPill(label: "项目", value: aiPreview.category)
                    parsedPill(label: "细节", value: aiPreview.amount)
                }
            }
            .padding(14)
            .background(Color(accountingHex: "F8FAFC"), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.black.opacity(0.05), lineWidth: 1))
            .accessibilityIdentifier("vitora.record.ai.preview")
        } else {
            Text("AI记录会从一句话里提取身体感受、情绪、经期变化和补给信息；解析结果会以小卡片出现，保存前可确认。")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.black.opacity(0.48))
                .lineSpacing(5)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(accountingHex: "F8FAFC"), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    private func parsedPill(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Color.black.opacity(0.40))
            Text(value)
                .font(.caption.weight(.heavy))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(Color.black.opacity(0.04), lineWidth: 1))
    }

    // MARK: - Bottom Actions

    private var bottomActions: some View {
        VStack(spacing: 8) {
            if showsSaved {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("已保存")
                    Spacer()
                }
                .font(.caption.weight(.heavy))
                .foregroundStyle(Color(accountingHex: "13855E"))
                .padding(.horizontal, 18)
                .transition(.opacity)
            }

            HStack(spacing: 12) {
                Button {
                    resetDraft()
                } label: {
                    Text("再记")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(Color.black.opacity(0.14), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("vitora.record.reset")

                Button {
                    finishRecord()
                } label: {
                    Text("完成")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(canSubmit ? .white : Color.black.opacity(0.38))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(canSubmit ? activeSubmitColor : Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(Color.black.opacity(canSubmit ? 0 : 0.10), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(!canSubmit)
                .accessibilityIdentifier("vitora.record.done")
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.66), Color(accountingHex: "F7FBFF").opacity(0.82)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Helpers

    private var currentManualAccent: Color {
        periodState.color
    }

    private var currentManualSoft: Color {
        periodState.soft
    }

    private var currentOutlines: [HealthRecordOutline] {
        periodState.outlines
    }

    private var selectedHealthOptions: [HealthRecordOption] {
        currentOutlines.flatMap(\.allOptions).filter { selectedOptionIDs.contains($0.id) }
    }

    private var activeSubmitColor: Color {
        mode == .manual ? currentManualAccent : AccountingPalette.aiAccent
    }

    private var canSubmit: Bool {
        switch mode {
        case .manual:
            return true
        case .ai:
            return aiPreview != nil
        }
    }

    private func changePeriodState(_ nextState: ManualPeriodState) {
        withAnimation(.easeOut(duration: reduceMotion ? 0.12 : 0.22)) {
            periodState = nextState
            expandedOutlineID = nil
            expandedAllOutlineIDs.removeAll()
            selectedOptionIDs.removeAll()
            selectedMediaAction = nil
            showsSaved = false
        }
    }

    private func toggleOutline(_ outlineID: String) {
        withAnimation(.easeOut(duration: reduceMotion ? 0.12 : 0.22)) {
            expandedOutlineID = expandedOutlineID == outlineID ? nil : outlineID
            showsSaved = false
        }
    }

    private func toggleOption(_ optionID: String) {
        if selectedOptionIDs.contains(optionID) {
            selectedOptionIDs.remove(optionID)
        } else {
            selectedOptionIDs.insert(optionID)
        }
        showsSaved = false
    }

    private func parseAIInput() {
        let text = aiInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        withAnimation(.easeOut(duration: reduceMotion ? 0.12 : 0.22)) {
            aiPreview = AccountingAIParser.parse(text)
            aiFallbackNotice = nil
            showsSaved = false
        }
    }

    private func toggleVoiceCapture() {
        switch voiceCapture.state {
        case .recording, .requestingPermission:
            voiceCapture.stop()
        case .idle, .ready, .unavailable:
            aiFallbackNotice = nil
            voiceCapture.start()
        }
        showsSaved = false
    }

    private func parseVoiceTranscript() {
        let text = voiceCapture.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        aiInput = text
        withAnimation(.easeOut(duration: reduceMotion ? 0.12 : 0.22)) {
            aiPreview = AccountingAIParser.parse(text)
            aiFallbackNotice = nil
            showsSaved = false
        }
    }

    private func resetDraft() {
        withAnimation(.easeOut(duration: reduceMotion ? 0.12 : 0.22)) {
            expandedOutlineID = nil
            expandedAllOutlineIDs.removeAll()
            selectedOptionIDs.removeAll()
            selectedMediaAction = nil
            aiInput = ""
            aiPreview = nil
            aiFallbackNotice = nil
            recordNote = ""
            showsSaved = false
            voiceCapture.reset()
        }
    }

    private func finishRecord() {
        guard canSubmit else { return }
        voiceCapture.stop()
        onSubmit(makeRecordFeedback())
    }

    private func makeRecordFeedback() -> RecentRecordFeedback {
        let summary: String
        let evidenceText: String

        switch mode {
        case .manual:
            let optionTitles = selectedHealthOptions.map(\.title)
            let category = optionTitles.isEmpty ? "快捷记录" : optionTitles.prefix(4).joined(separator: "、")
            let mediaPart = selectedMediaAction.map { " · \($0.title)" } ?? ""
            summary = "\(periodState.title) · \(category)\(mediaPart)"
            evidenceText = [periodState.title, category, recordNote, context.sourceTitle, context.sourceSummary]
                .joined(separator: " ")
        case .ai:
            let preview = aiPreview ?? AccountingAIParser.parse(aiInput)
            summary = "AI记录 · \(preview.type) · \(preview.category)"
            evidenceText = [preview.note, preview.category, recordNote, context.sourceTitle, context.sourceSummary]
                .joined(separator: " ")
        }

        return RecentRecordFeedback(
            source: context.sourceTitle,
            summary: summary,
            message: warmFeedbackMessage(for: evidenceText),
            createdAt: Date()
        )
    }

    private func warmFeedbackMessage(for text: String) -> String {
        if text.contains("月经") || text.contains("姨妈") || text.contains("经期") || text.contains("侧漏") || text.contains("量") {
            return "已记下今天的经期相关变化。当前阶段夜间量感可能更明显，今晚可以提前准备夜用用品，睡前把咖啡因和大量饮水放轻一点，减少夜里起身压力。"
        }

        if text.contains("头痛") || text.contains("眩晕") || text.contains("腰酸") || text.contains("小腹") || text.contains("乳房") || text.contains("腹泻") || text.contains("便秘") {
            return "已记下身体感受。今天先把强度放低一点，给自己留出短休和热敷窗口；如果变化持续或明显加重，建议及时咨询专业医生。"
        }

        if text.contains("B6") || text.contains("镁") || text.contains("维生素") || text.contains("钙") || text.contains("铁") || text.contains("蛋白") || text.contains("DHA") || text.contains("益生菌") || text.contains("叶酸") {
            return "已把补给记录进今天的恢复背景。Vitora 只记录你已在使用的内容，不做购买引导；晚点可以补充服用时间和身体感受。"
        }

        if text.contains("焦虑") || text.contains("烦躁") || text.contains("压力") || text.contains("低落") || text.contains("难过") || text.contains("不开心") {
            return "已记下情绪变化。今晚可以先把待办往后放一点，用 10 分钟低刺激整理或呼吸练习，帮助身体从紧绷里退出来。"
        }

        if text.contains("熬夜") || text.contains("久坐") || text.contains("过度运动") || text.contains("生冷") || text.contains("辛辣") || text.contains("喝酒") || text.contains("腹部受凉") {
            return "已记下今天可能影响状态的因素。接下来优先补水、保暖和低强度活动，把恢复窗口留给睡前。"
        }

        return "已记下这件事。Vitora 会把它作为今天状态背景，晚点可以再补充身体感受，帮助判断更贴近你。"
    }
}

// MARK: - Accounting Sheet Models

enum VitoraRecordMode: String, CaseIterable, Identifiable {
    case manual
    case ai

    var id: String { rawValue }

    var title: String {
        switch self {
        case .manual: return "手动记账"
        case .ai: return "AI记录"
        }
    }
}

enum VitoraAIInputMode: String, CaseIterable, Identifiable {
    case voice
    case text

    var id: String { rawValue }

    var title: String {
        switch self {
        case .voice: return "语音"
        case .text: return "打字"
        }
    }

    var systemImage: String {
        switch self {
        case .voice: return "mic.fill"
        case .text: return "keyboard"
        }
    }
}

private enum VitoraVoiceCaptureState: Equatable {
    case idle
    case requestingPermission
    case recording
    case ready
    case unavailable

    var statusTitle: String {
        switch self {
        case .idle: return "语音记录"
        case .requestingPermission: return "正在准备麦克风"
        case .recording: return "正在听你说"
        case .ready: return "已生成转写草稿"
        case .unavailable: return "语音暂不可用"
        }
    }
}

@MainActor
private final class VitoraVoiceCapture: ObservableObject {
    @Published private(set) var state: VitoraVoiceCaptureState = .idle
    @Published private(set) var transcript = ""
    @Published private(set) var statusMessage = "点一下麦克风，说一句今天的身体感受。"
    @Published var shouldFallbackToText = false

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh_CN"))
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func start() {
        shouldFallbackToText = false
        state = .requestingPermission
        statusMessage = "正在请求语音和麦克风权限。"

        SFSpeechRecognizer.requestAuthorization { [weak self] speechStatus in
            Task { @MainActor in
                guard let self else { return }
                guard speechStatus == .authorized else {
                    self.fallbackToText("没有语音识别权限，可以直接打字记录。")
                    return
                }
                self.requestMicrophonePermission()
            }
        }
    }

    func stop() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        audioEngine = nil

        if transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            state = .idle
            statusMessage = "点一下麦克风，说一句今天的身体感受。"
        } else {
            state = .ready
            statusMessage = "可以解析，或转成打字继续修改。"
        }
    }

    func reset() {
        stop()
        transcript = ""
        shouldFallbackToText = false
        state = .idle
        statusMessage = "点一下麦克风，说一句今天的身体感受。"
    }

    private func requestMicrophonePermission() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                Task { @MainActor in
                    guard let self else { return }
                    granted ? self.beginRecognition() : self.fallbackToText("没有麦克风权限，可以直接打字记录。")
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                Task { @MainActor in
                    guard let self else { return }
                    granted ? self.beginRecognition() : self.fallbackToText("没有麦克风权限，可以直接打字记录。")
                }
            }
        }
    }

    private func beginRecognition() {
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            fallbackToText("当前语音识别不可用，可以直接打字记录。")
            return
        }

        stop()
        transcript = ""

        let audioEngine = AVAudioEngine()
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

            self.audioEngine = audioEngine
            recognitionRequest = request
            state = .recording
            statusMessage = "说完后点停止，或直接点解析。"

            recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }
                    if let result {
                        self.transcript = result.bestTranscription.formattedString
                        self.state = result.isFinal ? .ready : .recording
                        self.statusMessage = result.isFinal ? "可以解析，或转成打字继续修改。" : "说完后点停止，或直接点解析。"
                    }
                    if error != nil {
                        self.stop()
                    }
                }
            }
        } catch {
            fallbackToText("当前无法使用麦克风，可以直接打字记录。")
        }
    }

    private func fallbackToText(_ message: String) {
        stop()
        state = .unavailable
        statusMessage = message
        shouldFallbackToText = true
    }
}

private enum ManualPeriodState: String, CaseIterable, Identifiable {
    case period
    case nonPeriod

    var id: String { rawValue }

    var title: String {
        switch self {
        case .period: return "是经期"
        case .nonPeriod: return "否经期"
        }
    }

    var systemImage: String {
        switch self {
        case .period: return "drop.fill"
        case .nonPeriod: return "leaf.fill"
        }
    }

    var color: Color {
        switch self {
        case .period: return Color(accountingHex: "D65086")
        case .nonPeriod: return Color(accountingHex: "2F7DE1")
        }
    }

    var soft: Color {
        switch self {
        case .period: return Color(accountingHex: "FDEAF2")
        case .nonPeriod: return Color(accountingHex: "EAF3FF")
        }
    }

    var outlines: [HealthRecordOutline] {
        switch self {
        case .period: return HealthRecordCatalog.periodOutlines
        case .nonPeriod: return HealthRecordCatalog.nonPeriodOutlines
        }
    }
}

private struct HealthRecordOutline: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color
    let soft: Color
    let defaultOptions: [HealthRecordOption]
    let sections: [HealthRecordOptionSection]

    var allOptions: [HealthRecordOption] {
        var result = defaultOptions
        for section in sections {
            for option in section.options where !result.contains(where: { $0.id == option.id }) {
                result.append(option)
            }
        }
        return result
    }

    func selectedCount(in selectedIDs: Set<String>) -> Int {
        allOptions.filter { selectedIDs.contains($0.id) }.count
    }
}

private struct HealthRecordOptionSection: Identifiable {
    let id: String
    let title: String
    let options: [HealthRecordOption]
}

private struct HealthRecordOption: Identifiable, Equatable {
    let id: String
    let title: String
    let systemImage: String
}

private enum HealthRecordCatalog {
    static let periodOutlines: [HealthRecordOutline] = [
        periodFlow,
        body,
        mood,
        medication,
        nutrition,
        healthHabits,
    ]

    static let nonPeriodOutlines: [HealthRecordOutline] = [
        discharge,
        body,
        mood,
        skin,
        intimacy,
        nutrition,
        healthHabits,
    ]

    private static let periodFlow = HealthRecordOutline(
        id: "periodFlow",
        title: "经期情况",
        subtitle: "量感、颜色、痛感和防侧漏",
        systemImage: "drop.fill",
        color: Color(accountingHex: "D65086"),
        soft: Color(accountingHex: "FDEAF2"),
        defaultOptions: [
            .init(id: "periodFlow.tiny", title: "极少", systemImage: "drop"),
            .init(id: "periodFlow.low", title: "少", systemImage: "drop.fill"),
            .init(id: "periodFlow.medium", title: "中等", systemImage: "circle.fill"),
            .init(id: "periodFlow.high", title: "多", systemImage: "drop.circle.fill"),
            .init(id: "periodFlow.heavy", title: "极多", systemImage: "exclamationmark.triangle.fill"),
        ],
        sections: [
            .init(
                id: "periodFlow.color",
                title: "颜色",
                options: [
                    .init(id: "periodFlow.color.lightRed", title: "浅红", systemImage: "circle.fill"),
                    .init(id: "periodFlow.color.red", title: "鲜红", systemImage: "circle.fill"),
                    .init(id: "periodFlow.color.darkRed", title: "深红", systemImage: "circle.fill"),
                    .init(id: "periodFlow.color.brown", title: "褐色", systemImage: "circle.fill"),
                    .init(id: "periodFlow.color.black", title: "黑色", systemImage: "circle.fill"),
                ]
            ),
            .init(
                id: "periodFlow.pain",
                title: "痛感",
                options: [
                    .init(id: "periodFlow.pain.none", title: "不痛", systemImage: "checkmark.circle.fill"),
                    .init(id: "periodFlow.pain.light", title: "轻微", systemImage: "waveform.path.ecg"),
                    .init(id: "periodFlow.pain.medium", title: "中度", systemImage: "bolt.fill"),
                    .init(id: "periodFlow.pain.strong", title: "剧烈", systemImage: "flame.fill"),
                ]
            ),
            .init(
                id: "periodFlow.night",
                title: "夜间",
                options: [
                    .init(id: "periodFlow.night.leakConcern", title: "担心侧漏", systemImage: "moon.fill"),
                    .init(id: "periodFlow.night.changed", title: "已更换", systemImage: "checkmark.seal.fill"),
                    .init(id: "periodFlow.night.woke", title: "夜里醒来", systemImage: "bed.double.fill"),
                ]
            ),
        ]
    )

    private static let discharge = HealthRecordOutline(
        id: "discharge",
        title: "白带",
        subtitle: "非经期常见分泌物变化",
        systemImage: "drop.degreesign.fill",
        color: Color(accountingHex: "2F7DE1"),
        soft: Color(accountingHex: "EAF3FF"),
        defaultOptions: [
            .init(id: "discharge.dry", title: "干燥", systemImage: "sun.min.fill"),
            .init(id: "discharge.sticky", title: "粘稠", systemImage: "drop.fill"),
            .init(id: "discharge.creamy", title: "稀糊状", systemImage: "cloud.fill"),
            .init(id: "discharge.watery", title: "水状", systemImage: "water.waves"),
            .init(id: "discharge.eggwhite", title: "蛋清状", systemImage: "sparkles"),
        ],
        sections: [
            .init(
                id: "discharge.amount",
                title: "流量",
                options: [
                    .init(id: "discharge.amount.low", title: "少量", systemImage: "drop"),
                    .init(id: "discharge.amount.medium", title: "适中", systemImage: "drop.fill"),
                    .init(id: "discharge.amount.high", title: "大量", systemImage: "drop.circle.fill"),
                ]
            ),
            .init(
                id: "discharge.abnormal",
                title: "异常观察",
                options: [
                    .init(id: "discharge.blood", title: "带血丝", systemImage: "plus.circle.fill"),
                    .init(id: "discharge.more", title: "白带增多", systemImage: "arrow.up.circle.fill"),
                    .init(id: "discharge.foam", title: "泡沫状", systemImage: "bubbles.and.sparkles.fill"),
                    .init(id: "discharge.curds", title: "渣渣多", systemImage: "circle.grid.2x2.fill"),
                    .init(id: "discharge.yellow", title: "偏黄", systemImage: "circle.fill"),
                    .init(id: "discharge.green", title: "偏绿", systemImage: "circle.fill"),
                    .init(id: "discharge.smell", title: "异味", systemImage: "nose.fill"),
                ]
            ),
        ]
    )

    private static let body = HealthRecordOutline(
        id: "body",
        title: "身体状态",
        subtitle: "疼痛、消化、食欲和恢复感",
        systemImage: "figure.mind.and.body",
        color: Color(accountingHex: "2F7DE1"),
        soft: Color(accountingHex: "EAF3FF"),
        defaultOptions: [
            .init(id: "body.normal", title: "一切正常", systemImage: "checkmark.circle.fill"),
            .init(id: "body.headache", title: "头痛", systemImage: "brain.head.profile"),
            .init(id: "body.dizzy", title: "眩晕", systemImage: "arrow.triangle.2.circlepath"),
            .init(id: "body.waist", title: "腰酸", systemImage: "figure.core.training"),
            .init(id: "body.belly", title: "小腹坠胀", systemImage: "drop.fill"),
        ],
        sections: [
            .init(
                id: "body.common",
                title: "常见感受",
                options: [
                    .init(id: "body.breast", title: "乳房胀痛", systemImage: "heart.fill"),
                    .init(id: "body.appetiteHigh", title: "食欲旺盛", systemImage: "fork.knife"),
                    .init(id: "body.appetiteLow", title: "食欲不振", systemImage: "leaf.fill"),
                    .init(id: "body.diarrhea", title: "腹泻", systemImage: "water.waves"),
                    .init(id: "body.constipation", title: "便秘", systemImage: "circle.grid.2x2.fill"),
                ]
            ),
            .init(
                id: "body.extra",
                title: "补充",
                options: [
                    .init(id: "body.tired", title: "疲惫", systemImage: "zzz"),
                    .init(id: "body.cold", title: "发冷", systemImage: "snowflake"),
                    .init(id: "body.hot", title: "发热", systemImage: "thermometer.medium"),
                    .init(id: "body.swollen", title: "水肿", systemImage: "drop.circle"),
                    .init(id: "body.craving", title: "嘴馋", systemImage: "takeoutbag.and.cup.and.straw.fill"),
                ]
            ),
        ]
    )

    private static let mood = HealthRecordOutline(
        id: "mood",
        title: "心情",
        subtitle: "开心、平静、焦虑和压力",
        systemImage: "face.smiling",
        color: Color(accountingHex: "B57620"),
        soft: Color(accountingHex: "FFF3D8"),
        defaultOptions: [
            .init(id: "mood.superHappy", title: "超开心", systemImage: "sparkles"),
            .init(id: "mood.happy", title: "开心", systemImage: "face.smiling"),
            .init(id: "mood.calm", title: "平静", systemImage: "leaf.fill"),
            .init(id: "mood.unhappy", title: "不开心", systemImage: "cloud.fill"),
            .init(id: "mood.sad", title: "难过", systemImage: "cloud.rain.fill"),
        ],
        sections: [
            .init(
                id: "mood.positive",
                title: "偏积极",
                options: [
                    .init(id: "mood.excited", title: "兴奋", systemImage: "bolt.fill"),
                    .init(id: "mood.surprised", title: "惊喜", systemImage: "gift.fill"),
                    .init(id: "mood.satisfied", title: "满足", systemImage: "heart.fill"),
                    .init(id: "mood.confident", title: "自信", systemImage: "star.fill"),
                    .init(id: "mood.relaxed", title: "放松", systemImage: "moon.fill"),
                ]
            ),
            .init(
                id: "mood.pressure",
                title: "偏压力",
                options: [
                    .init(id: "mood.irritable", title: "烦躁", systemImage: "flame.fill"),
                    .init(id: "mood.angry", title: "生气", systemImage: "exclamationmark.bubble.fill"),
                    .init(id: "mood.anxious", title: "焦虑", systemImage: "waveform.path.ecg"),
                    .init(id: "mood.stressed", title: "压力", systemImage: "speedometer"),
                    .init(id: "mood.empty", title: "冷漠", systemImage: "circle"),
                ]
            ),
        ]
    )

    private static let medication = HealthRecordOutline(
        id: "medication",
        title: "服药",
        subtitle: "止痛、避孕药和助眠记录",
        systemImage: "pills.fill",
        color: Color(accountingHex: "5A4FCF"),
        soft: Color(accountingHex: "EFECFF"),
        defaultOptions: [
            .init(id: "medication.ibuprofen", title: "布洛芬", systemImage: "cross.case.fill"),
            .init(id: "medication.shortPill", title: "短效避孕药", systemImage: "arrow.triangle.2.circlepath"),
            .init(id: "medication.longPill", title: "长效避孕药", systemImage: "calendar.circle.fill"),
            .init(id: "medication.emergencyPill", title: "紧急避孕药", systemImage: "bolt.circle.fill"),
            .init(id: "medication.otherPill", title: "其他避孕药", systemImage: "pills.fill"),
        ],
        sections: [
            .init(
                id: "medication.extra",
                title: "常见补充",
                options: [
                    .init(id: "medication.progesterone", title: "黄体酮", systemImage: "capsule.fill"),
                    .init(id: "medication.cold", title: "感冒药", systemImage: "cross.fill"),
                    .init(id: "medication.antiInflammatory", title: "消炎药", systemImage: "bandage.fill"),
                    .init(id: "medication.gastro", title: "肠胃药", systemImage: "leaf.circle.fill"),
                    .init(id: "medication.herbal", title: "中药", systemImage: "leaf.fill"),
                    .init(id: "medication.melatonin", title: "褪黑素", systemImage: "moon.zzz.fill"),
                    .init(id: "medication.sleep", title: "安眠药", systemImage: "bed.double.fill"),
                ]
            ),
        ]
    )

    private static let nutrition = HealthRecordOutline(
        id: "nutrition",
        title: "营养补充剂",
        subtitle: "只记录已在使用内容",
        systemImage: "leaf.fill",
        color: Color(accountingHex: "6B5CD8"),
        soft: Color(accountingHex: "F0EDFF"),
        defaultOptions: [
            .init(id: "nutrition.vitaminD", title: "维生素D", systemImage: "sun.max.fill"),
            .init(id: "nutrition.calcium", title: "钙片", systemImage: "circle.hexagongrid.fill"),
            .init(id: "nutrition.iron", title: "铁剂", systemImage: "circle.fill"),
            .init(id: "nutrition.protein", title: "蛋白质", systemImage: "drop.circle.fill"),
            .init(id: "nutrition.dha", title: "DHA", systemImage: "fish.fill"),
        ],
        sections: [
            .init(
                id: "nutrition.more",
                title: "更多",
                options: [
                    .init(id: "nutrition.probiotics", title: "益生菌", systemImage: "sparkles"),
                    .init(id: "nutrition.folic", title: "叶酸", systemImage: "leaf.circle.fill"),
                    .init(id: "nutrition.magnesium", title: "镁", systemImage: "moon.fill"),
                    .init(id: "nutrition.b6", title: "B6", systemImage: "bolt.fill"),
                    .init(id: "nutrition.omega3", title: "Omega-3", systemImage: "drop.fill"),
                ]
            ),
        ]
    )

    private static let healthHabits = HealthRecordOutline(
        id: "healthHabits",
        title: "健康小忌",
        subtitle: "可能影响今天恢复的行为",
        systemImage: "exclamationmark.triangle.fill",
        color: Color(accountingHex: "D87918"),
        soft: Color(accountingHex: "FFF1DE"),
        defaultOptions: [
            .init(id: "habit.lateNight", title: "熬夜", systemImage: "moon.fill"),
            .init(id: "habit.moodWave", title: "情绪波动", systemImage: "cloud.sun.rain.fill"),
            .init(id: "habit.coldFood", title: "生冷饮食", systemImage: "snowflake"),
            .init(id: "habit.sitting", title: "久坐", systemImage: "chair.fill"),
            .init(id: "habit.overExercise", title: "过度运动", systemImage: "dumbbell.fill"),
        ],
        sections: [
            .init(
                id: "habit.more",
                title: "更多提醒",
                options: [
                    .init(id: "habit.binge", title: "暴饮暴食", systemImage: "fork.knife"),
                    .init(id: "habit.sweet", title: "甜食", systemImage: "birthday.cake.fill"),
                    .init(id: "habit.spicy", title: "辛辣", systemImage: "flame.fill"),
                    .init(id: "habit.alcohol", title: "喝酒", systemImage: "wineglass.fill"),
                    .init(id: "habit.smoking", title: "吸烟", systemImage: "smoke.fill"),
                    .init(id: "habit.coldBelly", title: "腹部受凉", systemImage: "wind"),
                    .init(id: "habit.overClean", title: "过度清洁", systemImage: "shower.fill"),
                ]
            ),
        ]
    )

    private static let skin = HealthRecordOutline(
        id: "skin",
        title: "皮肤",
        subtitle: "油、干、痘、水肿和敏感",
        systemImage: "camera.macro",
        color: Color(accountingHex: "D65086"),
        soft: Color(accountingHex: "FDEAF2"),
        defaultOptions: [
            .init(id: "skin.normal", title: "一切正常", systemImage: "checkmark.circle.fill"),
            .init(id: "skin.acne", title: "痘痘", systemImage: "circle.grid.2x2.fill"),
            .init(id: "skin.oily", title: "出油", systemImage: "drop.fill"),
            .init(id: "skin.swollen", title: "水肿", systemImage: "drop.circle.fill"),
            .init(id: "skin.dry", title: "皮肤干燥", systemImage: "sun.min.fill"),
        ],
        sections: [
            .init(
                id: "skin.more",
                title: "更多",
                options: [
                    .init(id: "skin.blackhead", title: "黑头", systemImage: "circle.fill"),
                    .init(id: "skin.dull", title: "暗沉", systemImage: "moon.fill"),
                    .init(id: "skin.red", title: "泛红", systemImage: "flame.fill"),
                    .init(id: "skin.peeling", title: "脱皮", systemImage: "leaf.fill"),
                    .init(id: "skin.allergy", title: "过敏", systemImage: "allergens.fill"),
                    .init(id: "skin.itch", title: "瘙痒", systemImage: "hand.raised.fill"),
                    .init(id: "skin.sting", title: "刺痛", systemImage: "bolt.fill"),
                ]
            ),
        ]
    )

    private static let intimacy = HealthRecordOutline(
        id: "intimacy",
        title: "爱爱",
        subtitle: "是否发生、措施和时间",
        systemImage: "heart.fill",
        color: Color(accountingHex: "B95FD8"),
        soft: Color(accountingHex: "F9EAFE"),
        defaultOptions: [
            .init(id: "intimacy.none", title: "无性行为", systemImage: "heart.slash.fill"),
            .init(id: "intimacy.condom", title: "避孕套", systemImage: "shield.fill"),
            .init(id: "intimacy.shortPill", title: "短效避孕药", systemImage: "pills.fill"),
            .init(id: "intimacy.longPill", title: "长效避孕药", systemImage: "calendar.circle.fill"),
            .init(id: "intimacy.emergencyPill", title: "紧急避孕药", systemImage: "bolt.circle.fill"),
        ],
        sections: [
            .init(
                id: "intimacy.more",
                title: "更多",
                options: [
                    .init(id: "intimacy.noMeasure", title: "无措施", systemImage: "exclamationmark.triangle.fill"),
                    .init(id: "intimacy.withdrawal", title: "体外排精", systemImage: "arrow.uturn.backward.circle.fill"),
                    .init(id: "intimacy.noEjaculation", title: "未射精", systemImage: "minus.circle.fill"),
                    .init(id: "intimacy.iud", title: "节育环", systemImage: "circle.hexagongrid.fill"),
                    .init(id: "intimacy.other", title: "其他措施", systemImage: "ellipsis.circle.fill"),
                ]
            ),
        ]
    )
}

private enum ManualMediaAction: String, CaseIterable, Identifiable {
    case photo
    case camera
    case voice

    var id: String { rawValue }

    var title: String {
        switch self {
        case .photo: return "图片"
        case .camera: return "拍照"
        case .voice: return "语音"
        }
    }

    var systemImage: String {
        switch self {
        case .photo: return "photo"
        case .camera: return "camera"
        case .voice: return "mic"
        }
    }
}

private struct AccountingQuickField: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String

    static let defaults = [
        AccountingQuickField(systemImage: "calendar", title: "今天 5/25"),
        AccountingQuickField(systemImage: "waveform.path.ecg", title: "D18 黄体期"),
        AccountingQuickField(systemImage: "clock", title: "现在"),
        AccountingQuickField(systemImage: "sparkles", title: "给 Vitora"),
    ]
}

private struct AccountingAIParseResult: Equatable {
    let type: String
    let category: String
    let amount: String
    let note: String
}

private enum AccountingAIParser {
    static func parse(_ text: String) -> AccountingAIParseResult {
        if text.localizedCaseInsensitiveContains("B6") || text.contains("镁") {
            var items: [String] = []
            var details: [String] = []
            if text.localizedCaseInsensitiveContains("B6") {
                items.append("B6")
                details.append("10mg")
            }
            if text.contains("镁") {
                items.append("镁")
                details.append(firstNumber(in: text).map { "\($0)mg" } ?? "200mg")
            }
            return AccountingAIParseResult(type: "营养", category: items.joined(separator: " + "), amount: details.joined(separator: " / "), note: text)
        }

        if text.contains("月经") || text.contains("经期") || text.contains("姨妈") {
            return AccountingAIParseResult(type: "经期", category: "月经变化", amount: "待确认", note: text)
        }

        if text.contains("低落") || text.contains("焦虑") || text.contains("烦躁") || text.contains("开心") || text.contains("平静") {
            let mood = ["低落", "焦虑", "烦躁", "开心", "平静"].first { text.contains($0) } ?? "情绪"
            return AccountingAIParseResult(type: "情绪", category: mood, amount: "已标记", note: text)
        }

        let category: String
        if text.contains("小腹") {
            category = "小腹坠胀"
        } else if text.contains("腰酸") {
            category = "腰酸"
        } else if text.contains("眩晕") {
            category = "眩晕"
        } else {
            category = "头痛"
        }
        let severity = text.contains("严重") ? "重" : (text.contains("中度") || text.contains("明显") ? "中" : "轻")
        return AccountingAIParseResult(type: "症状", category: category, amount: severity, note: text)
    }

    private static func firstNumber(in text: String) -> String? {
        guard let range = text.range(of: #"(\d+)(\.\d+)?"#, options: .regularExpression) else {
            return nil
        }
        return String(text[range])
    }
}

private enum AccountingPalette {
    static let aiAccent = Color(accountingHex: "D65086")
    static let aiDeep = Color(accountingHex: "A93461")
    static let aiSoft = Color(accountingHex: "FDEAF2")
}

private struct FlowWrapLayout<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        if #available(iOS 16.0, *) {
            FlowLayout(spacing: spacing) {
                content
            }
        } else {
            HStack(spacing: spacing) {
                content
            }
        }
    }
}

@available(iOS 16.0, *)
private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 320
        let rows = arrange(subviews: subviews, maxWidth: maxWidth)
        let height = rows.reduce(CGFloat.zero) { partial, row in
            partial + row.height
        } + CGFloat(max(0, rows.count - 1)) * spacing
        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrange(subviews: subviews, maxWidth: bounds.width)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(item.size)
                )
                x += item.size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private func arrange(subviews: Subviews, maxWidth: CGFloat) -> [FlowRow] {
        var rows: [FlowRow] = []
        var currentItems: [FlowItem] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let itemWidth = size.width
            let projectedWidth = currentItems.isEmpty ? itemWidth : currentWidth + spacing + itemWidth

            if projectedWidth > maxWidth, !currentItems.isEmpty {
                rows.append(FlowRow(items: currentItems, height: currentHeight))
                currentItems = [FlowItem(index: index, size: size)]
                currentWidth = itemWidth
                currentHeight = size.height
            } else {
                currentItems.append(FlowItem(index: index, size: size))
                currentWidth = projectedWidth
                currentHeight = max(currentHeight, size.height)
            }
        }

        if !currentItems.isEmpty {
            rows.append(FlowRow(items: currentItems, height: currentHeight))
        }

        return rows
    }

    private struct FlowRow {
        let items: [FlowItem]
        let height: CGFloat
    }

    private struct FlowItem {
        let index: Int
        let size: CGSize
    }
}

private extension Color {
    init(accountingHex hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }

        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

// MARK: - Legacy Health Parser Contracts

enum VitoraRecordCategory: String, CaseIterable, Identifiable {
    case symptom
    case mood
    case period
    case nutrition
    case more

    var id: String { rawValue }

    var title: String {
        switch self {
        case .symptom: return "症状"
        case .mood: return "情绪"
        case .period: return "月经"
        case .nutrition: return "营养"
        case .more: return "更多"
        }
    }

    var palette: VitoraRecordPalette {
        switch self {
        case .symptom:
            return .init(
                background: Color(red: 238 / 255, green: 247 / 255, blue: 255 / 255),
                soft: Color(red: 223 / 255, green: 239 / 255, blue: 252 / 255),
                optionFill: Color(red: 225 / 255, green: 241 / 255, blue: 254 / 255),
                selectedFill: Color(red: 205 / 255, green: 229 / 255, blue: 248 / 255),
                accent: Color(red: 32 / 255, green: 102 / 255, blue: 176 / 255),
                deepAccent: Color(red: 18 / 255, green: 80 / 255, blue: 144 / 255)
            )
        case .mood:
            return .init(
                background: Color(red: 255 / 255, green: 249 / 255, blue: 235 / 255),
                soft: Color(red: 251 / 255, green: 238 / 255, blue: 206 / 255),
                optionFill: Color(red: 252 / 255, green: 239 / 255, blue: 212 / 255),
                selectedFill: Color(red: 246 / 255, green: 224 / 255, blue: 181 / 255),
                accent: Color(red: 153 / 255, green: 92 / 255, blue: 19 / 255),
                deepAccent: Color(red: 126 / 255, green: 70 / 255, blue: 12 / 255)
            )
        case .period:
            return .init(
                background: Color(red: 255 / 255, green: 244 / 255, blue: 248 / 255),
                soft: Color(red: 250 / 255, green: 226 / 255, blue: 235 / 255),
                optionFill: Color(red: 248 / 255, green: 231 / 255, blue: 238 / 255),
                selectedFill: Color(red: 247 / 255, green: 214 / 255, blue: 228 / 255),
                accent: Color(red: 211 / 255, green: 82 / 255, blue: 130 / 255),
                deepAccent: Color(red: 169 / 255, green: 52 / 255, blue: 97 / 255)
            )
        case .nutrition:
            return .init(
                background: Color(red: 247 / 255, green: 246 / 255, blue: 255 / 255),
                soft: Color(red: 233 / 255, green: 230 / 255, blue: 255 / 255),
                optionFill: Color(red: 235 / 255, green: 232 / 255, blue: 255 / 255),
                selectedFill: Color(red: 219 / 255, green: 214 / 255, blue: 251 / 255),
                accent: Color(red: 83 / 255, green: 71 / 255, blue: 157 / 255),
                deepAccent: Color(red: 64 / 255, green: 53 / 255, blue: 132 / 255)
            )
        case .more:
            return .init(
                background: Color(red: 248 / 255, green: 248 / 255, blue: 244 / 255),
                soft: Color(red: 239 / 255, green: 238 / 255, blue: 230 / 255),
                optionFill: Color(red: 244 / 255, green: 243 / 255, blue: 237 / 255),
                selectedFill: Color(red: 229 / 255, green: 227 / 255, blue: 218 / 255),
                accent: Color(red: 108 / 255, green: 101 / 255, blue: 89 / 255),
                deepAccent: Color(red: 77 / 255, green: 70 / 255, blue: 60 / 255)
            )
        }
    }
}

struct VitoraRecordPalette {
    let background: Color
    let soft: Color
    let optionFill: Color
    let selectedFill: Color
    let accent: Color
    let deepAccent: Color
}

struct VitoraRecordOption: Identifiable, Hashable {
    let id: String
    let title: String
    let systemImage: String
    let category: VitoraRecordCategory

    static let catalog: [VitoraRecordOption] = [
        .init(id: "headache", title: "头痛", systemImage: "bandage.fill", category: .symptom),
        .init(id: "dizzy", title: "眩晕", systemImage: "arrow.clockwise", category: .symptom),
        .init(id: "waist_soreness", title: "腰酸", systemImage: "figure.strengthtraining.traditional", category: .symptom),
        .init(id: "abdominal_heaviness", title: "小腹坠胀", systemImage: "dot.circle", category: .symptom),
        .init(id: "breast_tenderness", title: "乳房胀痛", systemImage: "heart", category: .symptom),
        .init(id: "low_appetite", title: "食欲不振", systemImage: "face.dashed", category: .symptom),
        .init(id: "diarrhea", title: "腹泻", systemImage: "drop", category: .symptom),
        .init(id: "constipation", title: "便秘", systemImage: "xmark.circle", category: .symptom),
        .init(id: "calm", title: "平静", systemImage: "circle", category: .mood),
        .init(id: "happy", title: "开心", systemImage: "face.smiling", category: .mood),
        .init(id: "excited", title: "兴奋", systemImage: "sparkles", category: .mood),
        .init(id: "grateful", title: "感恩", systemImage: "heart", category: .mood),
        .init(id: "anxious", title: "焦虑", systemImage: "cloud", category: .mood),
        .init(id: "irritable", title: "烦躁", systemImage: "flame", category: .mood),
        .init(id: "low", title: "低落", systemImage: "face.dashed", category: .mood),
        .init(id: "tired", title: "疲惫", systemImage: "zzz", category: .mood),
        .init(id: "magnesium", title: "镁", systemImage: "pills.fill", category: .nutrition),
        .init(id: "b6", title: "B6", systemImage: "b.circle.fill", category: .nutrition),
        .init(id: "iron", title: "铁", systemImage: "aqi.medium", category: .nutrition),
        .init(id: "calcium", title: "钙", systemImage: "bone.fill", category: .nutrition),
        .init(id: "vitamin_d", title: "维生素D", systemImage: "sun.max", category: .nutrition),
        .init(id: "omega3", title: "Omega-3", systemImage: "fish", category: .nutrition),
        .init(id: "folate", title: "叶酸", systemImage: "leaf", category: .nutrition),
        .init(id: "probiotic", title: "益生菌", systemImage: "circle.grid.2x2", category: .nutrition),
    ]
}

enum VitoraRecordSeverity: String, CaseIterable, Identifiable {
    case light
    case medium
    case heavy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light: return "轻"
        case .medium: return "中"
        case .heavy: return "重"
        }
    }
}

struct VitoraRecordParsedItem: Identifiable, Equatable {
    let id = UUID()
    let category: VitoraRecordCategory
    let subtype: String
    let displaySubtype: String
    let severity: String?
    let doseMG: Int?
    let confidence: Double
    let needsConfirmation: Bool

    var displayTitle: String {
        if let severity {
            return "\(displaySubtype) · \(severity)"
        }
        if let doseMG {
            return "\(displaySubtype) \(doseMG)mg"
        }
        return displaySubtype
    }

    var detailText: String {
        let confidenceText = "置信度 \(Int((confidence * 100).rounded()))%"
        if needsConfirmation {
            return "\(confidenceText) · 需要确认"
        }
        return confidenceText
    }

    static func == (lhs: VitoraRecordParsedItem, rhs: VitoraRecordParsedItem) -> Bool {
        lhs.category == rhs.category &&
            lhs.subtype == rhs.subtype &&
            lhs.displaySubtype == rhs.displaySubtype &&
            lhs.severity == rhs.severity &&
            lhs.doseMG == rhs.doseMG &&
            lhs.confidence == rhs.confidence &&
            lhs.needsConfirmation == rhs.needsConfirmation
    }
}

struct VitoraRecordParsePreview: Equatable {
    let rawInput: String
    let items: [VitoraRecordParsedItem]
    let vitoraFeedback: String?
}

struct VitoraQuickRecordParser {
    func parse(rawInput: String, cycleDay: Int = 18, phase: String = "luteal_mid", time: String = "10:00") -> VitoraRecordParsePreview {
        let normalized = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
        var items: [VitoraRecordParsedItem] = []

        if containsHeadache(in: normalized) {
            let severity = inferredSeverity(from: normalized)
            let needsConfirmation = severity.wasDefaulted
            items.append(
                VitoraRecordParsedItem(
                    category: .symptom,
                    subtype: "headache",
                    displaySubtype: "头痛",
                    severity: severity.value,
                    doseMG: nil,
                    confidence: needsConfirmation ? 0.78 : 0.85,
                    needsConfirmation: needsConfirmation
                )
            )
        }

        if normalized.localizedCaseInsensitiveContains("B6") || normalized.contains("维生素B6") {
            items.append(
                VitoraRecordParsedItem(
                    category: .nutrition,
                    subtype: "B6",
                    displaySubtype: "B6",
                    severity: nil,
                    doseMG: 10,
                    confidence: 0.78,
                    needsConfirmation: false
                )
            )
        }

        if normalized.contains("镁") {
            items.append(
                VitoraRecordParsedItem(
                    category: .nutrition,
                    subtype: "magnesium",
                    displaySubtype: "镁",
                    severity: nil,
                    doseMG: 200,
                    confidence: 0.80,
                    needsConfirmation: false
                )
            )
        }

        return VitoraRecordParsePreview(rawInput: normalized, items: items, vitoraFeedback: nil)
    }

    private func containsHeadache(in text: String) -> Bool {
        text.contains("头痛") || text.contains("头疼") || text.contains("头有点痛")
    }

    private func inferredSeverity(from text: String) -> (value: String, wasDefaulted: Bool) {
        if text.contains("严重") {
            return ("重", false)
        }
        if text.contains("中度") || text.contains("明显") {
            return ("中", false)
        }
        if text.contains("有点") || text.contains("轻微") || text.contains("头有点痛") {
            return ("轻", false)
        }
        return ("中", true)
    }
}
