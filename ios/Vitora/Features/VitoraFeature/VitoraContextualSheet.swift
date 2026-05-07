import SwiftUI

struct VitoraContextualSheet: View {
    let context: VitoraContextPayload
    let onClose: () -> Void
    @State private var input = ""
    @State private var isVoiceRecording = false
    @State private var showsUnderstanding = false

    private let chips = ["睡得浅", "压力大", "腹胀", "喝咖啡", "运动了", "吃得少"]

    var body: some View {
        ZStack {
            AuraBackground(intensity: 0.88)

            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Capsule()
                        .fill(VitoraTheme.ColorToken.secondaryText.opacity(0.28))
                        .frame(width: 42, height: 4)
                    Spacer()
                    Button("关闭", action: onClose)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .accessibilityIdentifier("vitora.context.close")
                }

                HStack(spacing: 10) {
                    PixelVitoraView(state: showsUnderstanding ? .confirming : .thinking, size: 54)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vitora 浮层 · 来源：\(context.sourceTitle)")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        Text(context.sourceSummary)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                        Text(context.prompt)
                            .font(.caption)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }
                }
                .padding(14)
                .background(GlassSurface(cornerRadius: 24, opacity: 0.40))

                Text("快捷补充")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    ForEach(chips, id: \.self) { chip in
                        Button(chip) {
                            input = chip
                        }
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(GlassSurface(cornerRadius: 18, opacity: 0.30))
                        .buttonStyle(.plain)
                    }
                }

                if showsUnderstanding {
                    RichResponseCard(
                        response: .init(
                            title: "Vitora 理解为",
                            body: "这件事会影响今日状态与下午低谷窗口。确认后才保存为上下文。",
                            actions: ["确认保存", "修改", "不用更新"]
                        )
                    )
                    .accessibilityIdentifier("vitora.context.confirm")
                }

                Spacer(minLength: 0)

                VitoraInputDock(
                    text: $input,
                    placeholder: "告诉 Vitora 一件事...",
                    isVoiceRecording: isVoiceRecording,
                    onPlus: { input = "我想补充：" },
                    onVoice: { isVoiceRecording.toggle() },
                    onSend: { showsUnderstanding = true }
                )
            }
            .padding(20)
        }
    }
}
