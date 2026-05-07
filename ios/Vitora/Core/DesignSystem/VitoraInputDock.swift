import SwiftUI

struct VitoraInputDock: View {
    @Binding var text: String
    var placeholder = "问 Vitora 或补充一件事..."
    var isVoiceRecording = false
    let onPlus: () -> Void
    let onVoice: () -> Void
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 9) {
            Button(action: onPlus) {
                Color.clear
                    .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                            .accessibilityHidden(true)
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
            .contentShape(Circle())
            .accessibilityLabel("添加快捷上下文")
            .accessibilityHint("打开睡眠、周期、营养、情绪等快捷上下文")
            .accessibilityIdentifier("vitora.input.plus")

            TextField(placeholder, text: $text)
                .font(.callout)
                .textFieldStyle(.plain)
                .frame(minHeight: VitoraTheme.Size.touchTargetMin)
                .accessibilityLabel("问 Vitora 或补充一件事")
                .accessibilityIdentifier("vitora.input.text")

            Button(action: onVoice) {
                Color.clear
                    .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                    .overlay {
                        Image(systemName: isVoiceRecording ? "waveform.circle.fill" : "mic")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(isVoiceRecording ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.secondaryText)
                            .accessibilityHidden(true)
                    }
            }
            .buttonStyle(.plain)
            .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
            .contentShape(Circle())
            .accessibilityLabel(isVoiceRecording ? "停止语音记录" : "语音记录")
            .accessibilityHint("语音会先转写并由 Vitora 理解，确认后才保存")
            .accessibilityIdentifier("vitora.input.voice")

            Button(action: onSend) {
                Color.clear
                    .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                    .overlay {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(VitoraTheme.ColorToken.paper)
                            .accessibilityHidden(true)
                    }
                    .background(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
            .contentShape(Circle())
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isVoiceRecording)
            .opacity(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isVoiceRecording ? 0.72 : 1)
            .accessibilityLabel("发送给 Vitora")
            .accessibilityHint("发送后先显示 Vitora 的理解确认")
            .accessibilityIdentifier("vitora.input.send")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(InputDockSurface())
    }
}
