import SwiftUI

struct VitoraContextualSheet: View {
    let context: VitoraContextPayload
    let onClose: () -> Void
    @State private var input = ""
    @State private var isVoiceRecording = false
    @State private var showsUnderstanding = false
    @State private var showsSaved = false

    private let chips = ["睡得浅", "压力大", "腹胀", "喝咖啡", "运动了", "吃得少"]

    var body: some View {
        ZStack {
            WaterAuraReferenceBackground(scene: .sheet, intensity: 0.82)
            VitoraTheme.ColorToken.paper.opacity(0.24)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 15) {
                        sheetHeader

                        Text("快捷补充")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                            ForEach(chips, id: \.self) { chip in
                                Button(chip) {
                                    withAnimation(.easeOut(duration: 0.14)) {
                                        input = chip
                                        showsSaved = false
                                    }
                                }
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 40)
                                .background(GlassSurface(cornerRadius: 18, opacity: input == chip ? 0.72 : 0.58, shadowStrength: input == chip ? 0.24 : 0.14, variant: input == chip ? .cleanElevated : .cleanResting))
                                .buttonStyle(.plain)
                            }
                        }

                        if showsUnderstanding {
                            understandingCard
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 14)
                }

                VitoraInputDock(
                    text: $input,
                    placeholder: "告诉 Vitora 一件事...",
                    isVoiceRecording: isVoiceRecording,
                    voiceSignal: isVoiceRecording ? .listeningPreview : .idle,
                    onVoice: { isVoiceRecording.toggle() },
                    onSend: {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
                            showsUnderstanding = true
                            showsSaved = false
                        }
                    }
                )
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)
                .background(
                    LinearGradient(
                        colors: [
                            VitoraTheme.ColorToken.paper.opacity(0),
                            VitoraTheme.ColorToken.paper.opacity(0.66),
                            VitoraTheme.ColorToken.paper.opacity(0.86),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .allowsHitTesting(false)
                )
            }
        }
    }

    private var sheetHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            FrostedSheetHeader(
                title: "告诉 Vitora",
                subtitle: "来源：\(context.sourceTitle)",
                closeAccessibilityID: "vitora.context.close",
                onClose: onClose
            )

            HStack(alignment: .top, spacing: 10) {
                PixelVitoraView(state: showsSaved ? .idle : (showsUnderstanding ? .confirming : .thinking), size: 54)
                    .frame(width: 56, height: 56)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 5) {
                    Text(context.sourceSummary)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(context.prompt)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GlassSurface(cornerRadius: 24, opacity: 0.70, shadowStrength: 0.28, variant: .cleanElevated))
        }
    }

    private var understandingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                PixelVitoraView(state: showsSaved ? .idle : .confirming, size: 34, showsGlow: false)

                Text(showsSaved ? "已保存给 Vitora" : "Vitora 理解为")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }

            Text(showsSaved ? "Vitora 会把这件事纳入今天的状态判断，回到来源后继续保持上下文。" : "这件事会影响今日状态与下午低谷窗口。确认后才保存为上下文。")
                .font(.subheadline)
                .lineSpacing(3)
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            VStack(spacing: 7) {
                understandingRow(title: "日期", value: "今天")
                understandingRow(title: "感受", value: input.isEmpty ? "午后状态变化" : input)
                understandingRow(title: "影响因素", value: "睡眠 + HRV + 周期")
                understandingRow(title: "置信度", value: "中等，确认后保存")
            }
            .padding(12)
            .background(VitoraTheme.ColorToken.paper.opacity(0.44), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.66), lineWidth: 0.7))

            ComplianceLabel(.vitora)

            HStack(spacing: 8) {
                if showsSaved {
                    Button("完成", action: onClose)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.paper)
                        .padding(.horizontal, 14)
                        .frame(height: 34)
                        .background(VitoraTheme.ColorToken.actionPrimaryDeep)
                        .clipShape(Capsule())
                } else {
                    Button("确认保存") {
                        withAnimation(.easeOut(duration: 0.24)) {
                            showsSaved = true
                        }
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.paper)
                    .padding(.horizontal, 14)
                    .frame(height: 34)
                    .background(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .clipShape(Capsule())

                    Button("修改") {
                        withAnimation(.easeOut(duration: 0.18)) {
                            showsUnderstanding = false
                        }
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .padding(.horizontal, 14)
                    .frame(height: 34)
                    .background(VitoraTheme.ColorToken.paper.opacity(0.46))
                    .clipShape(Capsule())

                    Button("不用更新", action: onClose)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                        .padding(.horizontal, 14)
                        .frame(height: 34)
                        .background(VitoraTheme.ColorToken.paper.opacity(0.36))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(15)
        .background(GlassSurface(cornerRadius: 22, opacity: 0.72, shadowStrength: 0.42, variant: .cleanElevated))
        .accessibilityIdentifier("vitora.context.confirm")
    }

    private func understandingRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .frame(width: 56, alignment: .leading)

            Text(value)
                .font(.caption.weight(.semibold))
                .lineSpacing(2)
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
