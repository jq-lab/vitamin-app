import SwiftUI
import UIKit

enum VitoraInputDockStyle: Equatable {
    case sheetLocal
    case assistantFloating
}

struct VitoraInputDock: View {
    @Binding var text: String
    var placeholder = "今日想问什么？"
    var style: VitoraInputDockStyle = .sheetLocal
    var isVoiceRecording = false
    var voiceSignal: VoiceMoodSignal = .idle
    var isProcessing = false
    var focusTrigger = 0
    var exposesAccessibility = true
    let onVoice: () -> Void
    let onSend: () -> Void
    @State private var localFocusTrigger = 0

    var body: some View {
        Group {
            if isProcessing {
                VitoraProcessingStatusRail(style: style)
            } else {
                inputControls
            }
        }
        .padding(style == .assistantFloating ? 7 : 8)
        .background(inputBarBackground)
        .clipShape(Capsule(style: .continuous))
        .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(style == .assistantFloating ? 0.72 : 0.62), lineWidth: 0.75))
        .shadow(color: style == .assistantFloating ? VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.12) : .clear, radius: 16, x: 0, y: 8)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(exposesAccessibility ? "vitora.input.dock" : "vitora.input.dock.hidden")
        .accessibilityHidden(!exposesAccessibility)
        .animation(.easeOut(duration: 0.22), value: isVoiceRecording)
        .animation(.easeOut(duration: 0.20), value: isProcessing)
    }

    private var inputControls: some View {
        HStack(spacing: 8) {
            Button(action: {
                let shouldFocusKeyboard = isVoiceRecording
                onVoice()
                if shouldFocusKeyboard {
                    localFocusTrigger += 1
                }
            }) {
                dockCircleButton(
                    systemImage: isVoiceRecording ? "keyboard" : "mic",
                    foreground: isVoiceRecording ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.strongText,
                    background: VitoraTheme.ColorToken.surfacePearlMain.opacity(0.62)
                )
            }
            .buttonStyle(.plain)
            .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
            .contentShape(Circle())
            .accessibilityLabel(isVoiceRecording ? "键盘输入" : "语音记录")
            .accessibilityHint(isVoiceRecording ? "结束语音记录并返回键盘输入" : "语音会先转写并由 Vitora 理解，确认后才保存")
            .accessibilityIdentifier(exposesAccessibility ? "vitora.input.voice" : "vitora.input.voice.hidden")

            HStack(spacing: 8) {
                if isVoiceRecording {
                    VoiceRecordingInlineStatus(signal: voiceSignal)
                        .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
                        .accessibilityIdentifier(exposesAccessibility ? "vitora.input.voice.status" : "vitora.input.voice.status.hidden")
                } else {
                    if style == .assistantFloating {
                        PixelInputIdentityBadge()
                            .frame(width: 28, height: 28)
                            .accessibilityHidden(true)
                    }

                    FocusableVitoraTextField(
                        text: $text,
                        placeholder: placeholder,
                        focusTrigger: focusTrigger + localFocusTrigger,
                        exposesAccessibility: exposesAccessibility,
                        onSubmit: onSend
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
                }
            }
            .padding(.leading, isVoiceRecording ? 10 : 14)
            .padding(.trailing, style == .assistantFloating ? 12 : 14)
            .frame(minHeight: VitoraTheme.Size.touchTargetMin)
            .background(inputCapsuleBackground)
            .shadow(color: Color.white.opacity(0.46), radius: 8, x: -2, y: -2)
            .contentShape(Capsule(style: .continuous))
            .onTapGesture {
                guard !isVoiceRecording else {
                    return
                }
                localFocusTrigger += 1
            }

            inlineSendButton
        }
    }

    private var hasSendContent: Bool {
        !isProcessing && (!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isVoiceRecording)
    }

    private var inlineSendButton: some View {
        Button(action: onSend) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(hasSendContent ? VitoraTheme.ColorToken.paper : VitoraTheme.ColorToken.secondaryText.opacity(0.60))
                .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                .background(sendButtonBackground)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
        .contentShape(Circle())
        .disabled(!hasSendContent || isProcessing)
        .accessibilityLabel("发送给 Vitora")
        .accessibilityHint("发送后先显示 Vitora 的理解确认")
        .accessibilityIdentifier(exposesAccessibility ? "vitora.input.send" : "vitora.input.send.hidden")
    }

    private var sendButtonBackground: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: hasSendContent ? [
                        VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.92),
                        Color(red: 100 / 255, green: 214 / 255, blue: 230 / 255).opacity(0.82),
                    ] : [
                        VitoraTheme.ColorToken.surfacePearlMain.opacity(0.34),
                        Color(red: 226 / 255, green: 245 / 255, blue: 250 / 255).opacity(0.24),
                        Color(red: 255 / 255, green: 224 / 255, blue: 234 / 255).opacity(0.18),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(hasSendContent ? 0.78 : 0.48), lineWidth: 0.85)
            )
            .shadow(
                color: (hasSendContent ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.paper).opacity(hasSendContent ? 0.28 : 0.10),
                radius: hasSendContent ? 8 : 4,
                x: 0,
                y: hasSendContent ? 4 : 2
            )
    }

    private var inputCapsuleBackground: some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .overlay {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                VitoraTheme.ColorToken.surfacePearlMain.opacity(0.68),
                                Color(red: 255 / 255, green: 237 / 255, blue: 242 / 255).opacity(0.22),
                                Color(red: 230 / 255, green: 247 / 255, blue: 251 / 255).opacity(0.30),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay(Capsule().stroke(Color.white.opacity(0.88), lineWidth: 0.7))
    }

    private var inputBarBackground: some View {
        Capsule(style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 222 / 255, green: 245 / 255, blue: 250 / 255).opacity(0.42),
                                VitoraTheme.ColorToken.surfacePearlMain.opacity(0.30),
                                Color(red: 255 / 255, green: 224 / 255, blue: 234 / 255).opacity(0.36),
                                Color(red: 227 / 255, green: 220 / 255, blue: 255 / 255).opacity(0.22),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.66),
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.30),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .blendMode(.screen)
            )
    }

    private func dockCircleButton(systemImage: String, foreground: Color, background: Color) -> some View {
        Color.clear
            .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
            .overlay {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(foreground)
                    .accessibilityHidden(true)
            }
            .background(background)
            .overlay {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.56),
                                Color(red: 230 / 255, green: 247 / 255, blue: 251 / 255).opacity(0.24),
                                Color(red: 255 / 255, green: 224 / 255, blue: 234 / 255).opacity(0.18),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .clipShape(Circle())
            .overlay(Circle().stroke(VitoraTheme.ColorToken.paper.opacity(0.84), lineWidth: 0.8))
    }
}

private struct PixelInputIdentityBadge: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            VitoraTheme.ColorToken.surfacePearlMain.opacity(0.92),
                            Color(red: 226 / 255, green: 246 / 255, blue: 250 / 255).opacity(0.54),
                            Color(red: 255 / 255, green: 226 / 255, blue: 237 / 255).opacity(0.46),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.white.opacity(0.84), lineWidth: 0.7)
                )

            VStack(spacing: 3) {
                HStack(spacing: 4) {
                    pixelEye
                    pixelEye
                }

                HStack(spacing: 2) {
                    Rectangle()
                        .fill(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.34))
                        .frame(width: 3, height: 3)
                    Rectangle()
                        .fill(VitoraTheme.ColorToken.auraCyan.opacity(0.42))
                        .frame(width: 3, height: 3)
                }
            }
        }
        .shadow(color: VitoraTheme.ColorToken.auraCyan.opacity(0.16), radius: 6, x: 0, y: 2)
    }

    private var pixelEye: some View {
        VStack(spacing: 1) {
            ForEach(0..<3, id: \.self) { _ in
                Rectangle()
                    .fill(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.74))
                    .frame(width: 3, height: 2)
            }
        }
    }
}

private struct VitoraProcessingStatusRail: View {
    var style: VitoraInputDockStyle
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate

            HStack(spacing: 10) {
                PixelInputIdentityBadge()
                    .frame(width: 32, height: 32)
                    .overlay(alignment: .bottomTrailing) {
                        Circle()
                            .fill(VitoraTheme.ColorToken.auraCyan.opacity(0.84))
                            .frame(width: 7, height: 7)
                            .offset(x: 1, y: 1)
                    }
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Vitora 正在整理...")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineLimit(1)

                    PixelProcessingBlocks(phase: phase)
                        .frame(width: style == .assistantFloating ? 124 : 104, height: 8)
                        .accessibilityHidden(true)
                }

                Spacer(minLength: 0)

                Text("分析中")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(VitoraTheme.ColorToken.paper.opacity(0.54), in: Capsule())
            }
            .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
            .padding(.horizontal, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.64))
                    .background(.ultraThinMaterial.opacity(0.46), in: Capsule(style: .continuous))
                    .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(0.82), lineWidth: 0.7))
            )
        }
        .accessibilityLabel("Vitora 正在整理")
        .accessibilityIdentifier("vitora.input.processing")
    }
}

private struct PixelProcessingBlocks: View {
    var phase: TimeInterval

    private let blockCount = 12

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<blockCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(color(for: index))
                    .frame(width: 7, height: height(for: index))
            }
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }

    private func height(for index: Int) -> CGFloat {
        let wave = sin(phase * 3.2 + Double(index) * 0.62)
        return 4 + CGFloat((wave + 1) * 0.5) * 4
    }

    private func color(for index: Int) -> Color {
        let wave = sin(phase * 2.4 + Double(index) * 0.48)
        let opacity = 0.34 + (wave + 1) * 0.22
        return index.isMultiple(of: 3)
            ? VitoraTheme.ColorToken.auraCyan.opacity(opacity)
            : VitoraTheme.ColorToken.actionPrimaryDeep.opacity(opacity)
    }
}

private struct FocusableVitoraTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let focusTrigger: Int
    let exposesAccessibility: Bool
    let onSubmit: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = VitoraFocusableTextField(frame: .zero)
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.font = .preferredFont(forTextStyle: .callout)
        textField.adjustsFontForContentSizeCategory = true
        textField.textColor = UIColor(VitoraTheme.ColorToken.strongText)
        textField.tintColor = UIColor(VitoraTheme.ColorToken.actionPrimaryDeep)
        textField.returnKeyType = .send
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textDidChange(_:)), for: .editingChanged)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.isAccessibilityElement = exposesAccessibility
        textField.accessibilityLabel = exposesAccessibility ? "问 Vitora 或补充一件事" : nil
        textField.accessibilityIdentifier = exposesAccessibility ? "vitora.input.text" : "vitora.input.text.hidden"
        if focusTrigger > context.coordinator.lastFocusTrigger {
            context.coordinator.lastFocusTrigger = focusTrigger
            textField.requestVitoraFocus()
        }
        return textField
    }

    func updateUIView(_ textField: UITextField, context: Context) {
        context.coordinator.text = $text
        context.coordinator.onSubmit = onSubmit

        if textField.text != text {
            textField.text = text
        }

        textField.isAccessibilityElement = exposesAccessibility
        textField.accessibilityLabel = exposesAccessibility ? "问 Vitora 或补充一件事" : nil
        textField.accessibilityIdentifier = exposesAccessibility ? "vitora.input.text" : "vitora.input.text.hidden"
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(VitoraTheme.ColorToken.secondaryText.opacity(0.42)),
                .font: UIFont.preferredFont(forTextStyle: .callout),
            ]
        )

        guard focusTrigger > context.coordinator.lastFocusTrigger else {
            return
        }

        context.coordinator.lastFocusTrigger = focusTrigger
        (textField as? VitoraFocusableTextField)?.requestVitoraFocus()
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var onSubmit: () -> Void
        var lastFocusTrigger = 0

        init(text: Binding<String>, onSubmit: @escaping () -> Void) {
            self.text = text
            self.onSubmit = onSubmit
        }

        @objc
        func textDidChange(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onSubmit()
            return true
        }
    }
}

private final class VitoraFocusableTextField: UITextField {
    private var shouldFocusWhenAttached = false

    func requestVitoraFocus() {
        shouldFocusWhenAttached = true
        runFocusAttempts()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        guard window != nil, shouldFocusWhenAttached else {
            return
        }

        runFocusAttempts()
    }

    private func runFocusAttempts() {
        for index in 0..<12 {
            let delay = 0.12 * Double(index + 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self, self.window != nil else {
                    return
                }

                self.becomeFirstResponder()
            }
        }
    }
}

private struct VoiceRecordingInlineStatus: View {
    var signal: VoiceMoodSignal
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation) { timeline in
            let sampled = signal.sampled(at: timeline.date.timeIntervalSinceReferenceDate, active: !reduceMotion)

            HStack(spacing: 8) {
                VoiceSignalWaveform(signal: sampled)
                    .frame(width: 58, height: 24)

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 6) {
                        Text("正在听 · 00:12")
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            .lineLimit(1)

                        Text(sampled.tone.label)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                            .lineLimit(1)
                    }

                    Text("正在听 · 00:12")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineLimit(1)
                }
                .minimumScaleFactor(0.78)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin, alignment: .leading)
        }
    }
}

private struct VoiceSignalWaveform: View {
    var signal: VoiceMoodSignal

    private let bars = 9

    var body: some View {
        let isStrong = signal.volume >= 0.70
        HStack(alignment: .center, spacing: 3) {
            ForEach(0..<bars, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                VitoraTheme.ColorToken.paper.opacity(0.96),
                                isStrong ? Color(red: 255 / 255, green: 197 / 255, blue: 111 / 255).opacity(0.86) : VitoraTheme.ColorToken.auraCyan.opacity(0.64),
                                isStrong ? Color(red: 247 / 255, green: 94 / 255, blue: 172 / 255).opacity(0.70) : VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.42),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 4, height: barHeight(index: index))
                    .shadow(
                        color: (isStrong ? Color(red: 248 / 255, green: 116 / 255, blue: 174 / 255) : VitoraTheme.ColorToken.auraCyan).opacity(isStrong ? 0.48 : 0.24),
                        radius: isStrong ? 7 : 3,
                        x: 0,
                        y: 0
                    )
            }
        }
        .frame(maxHeight: .infinity)
        .accessibilityHidden(true)
    }

    private func barHeight(index: Int) -> CGFloat {
        let centerDistance = abs(Double(index) - Double(bars - 1) / 2)
        let falloff = max(0.28, 1 - centerDistance * 0.18)
        let pitchOffset = sin(Double(index) * 0.92 + signal.pitch * 4.2) * 0.18
        let amplitude = max(0.18, min(1, signal.volume * falloff + pitchOffset + signal.speechRate * 0.16))
        let strongBoost = signal.volume >= 0.70 ? 1.16 : 0.92
        return 7 + CGFloat(amplitude) * 18 * strongBoost
    }
}
