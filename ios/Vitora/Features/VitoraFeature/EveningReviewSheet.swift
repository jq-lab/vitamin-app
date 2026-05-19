import SwiftUI

struct EveningReviewSheet: View {
    let review: EveningReview
    let learningSignal: VitoraLearningSignal?
    let sleepSeed: SleepSeedCard?
    let onSubmit: (EveningReviewFeedback, String?) -> Void
    let onSelectSeed: (SleepSeedKind) -> Void
    let onTellVitora: () -> Void
    let onClose: () -> Void

    @State private var selectedFeedback: EveningReviewFeedback?
    @State private var selectedSeedKind: SleepSeedKind?
    @State private var note = ""

    var body: some View {
        ZStack {
            WaterAuraReferenceBackground(scene: .sheet, intensity: 0.82)
            VitoraTheme.ColorToken.paper.opacity(0.24)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    reviewCard
                    feedbackBlock
                    if hasFeedback {
                        seedSelectionBlock
                    }
                    if review.status == .submitted {
                        savedState
                    }
                    tellVitoraBlock
                }
                .padding(.horizontal, VitoraTheme.Spacing.screenMargin)
                .padding(.top, VitoraTheme.Spacing.md)
                .padding(.bottom, VitoraTheme.Spacing.xxl)
            }
        }
        .accessibilityIdentifier("vitora.review.sheet")
    }

    private var header: some View {
        FrostedSheetHeader(
            title: "今晚复盘",
            subtitle: "回看今天前后的变化",
            closeAccessibilityID: "vitora.review.close",
            onClose: onClose
        )
    }

    private var reviewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("今天 Vitora 给过这个建议：")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            Text("13:30 前加一小份蛋白，下午轻走 10 分钟")
                .font(.title3.weight(.semibold))
                .lineSpacing(3)
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            HStack(alignment: .center, spacing: 18) {
                energyBubble(title: "早上", value: "68%", subtitle: "能量平稳")

                VStack(spacing: 8) {
                    Image(systemName: "arrow.right")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    Text("同一天")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }

                energyBubble(title: "晚间感受", value: selectedFeedback?.displayText ?? "待确认", subtitle: "由你决定")
            }
            .frame(maxWidth: .infinity)

            Text(review.beforeSummary)
                .font(.footnote)
                .lineSpacing(3)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
        }
        .padding(18)
        .background(GlassSurface(cornerRadius: 26, opacity: 0.72, shadowStrength: 0.28, variant: .cleanElevated))
    }

    private func energyBubble(title: String, value: String, subtitle: String) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                VitoraTheme.ColorToken.paper.opacity(0.96),
                                VitoraTheme.ColorToken.auraCyan.opacity(0.52),
                                VitoraTheme.ColorToken.auraBlue.opacity(0.58),
                            ],
                            center: .topLeading,
                            startRadius: 1,
                            endRadius: 58
                        )
                    )
                    .frame(width: 76, height: 76)
                    .shadow(color: VitoraTheme.ColorToken.auraBlue.opacity(0.18), radius: 16, x: 0, y: 6)

                Text(value)
                    .font(.headline.weight(.semibold))
                    .minimumScaleFactor(0.72)
                    .lineLimit(1)
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .padding(.horizontal, 6)
            }

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.primaryText)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var feedbackBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("后来感觉如何？")
                .font(.headline.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            HStack(spacing: 10) {
                feedbackButton(.helpful)
                feedbackButton(.neutral)
                feedbackButton(.notSuitable)
            }

            TextField("有什么想补充？可留空", text: $note)
                .textFieldStyle(.plain)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .frame(minHeight: 48)
                .background(InputDockSurface())
                .accessibilityIdentifier("vitora.review.note")
        }
        .padding(18)
        .background(GlassSurface(cornerRadius: 24, opacity: 0.68, shadowStrength: 0.28, variant: .cleanResting))
    }

    private var hasFeedback: Bool {
        selectedFeedback != nil || review.status == .submitted
    }

    private func feedbackButton(_ feedback: EveningReviewFeedback) -> some View {
        Button {
            selectedFeedback = feedback
            onSubmit(feedback, note.isEmpty ? nil : note)
        } label: {
            Text(feedback.displayText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(selectedFeedback == feedback ? Color.white : VitoraTheme.ColorToken.actionPrimaryDeep)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    Capsule(style: .continuous)
                        .fill(selectedFeedback == feedback ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.paper.opacity(0.50))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(VitoraTheme.ColorToken.paper.opacity(0.84), lineWidth: 0.7)
                )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("vitora.review.feedback.\(feedback.rawValue)")
    }

    private var savedState: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                PixelVitoraView(state: .confirming, size: 34, showsGlow: false)
                Text("Vitora 已记住这条反馈")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }

            Text("更新后的学习信号")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)

            Text(learningSignal?.summary ?? "后续建议会更注意今天的反馈，优先保持低负担。")
                .font(.footnote)
                .lineSpacing(3)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
        }
        .padding(18)
        .background(GlassSurface(cornerRadius: 24, opacity: 0.70, shadowStrength: 0.34, variant: .cleanElevated))
        .accessibilityIdentifier("vitora.review.saved")
    }

    private var seedSelectionBlock: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .center, spacing: 10) {
                SleepSeedPixelView(
                    kind: selectedSeedKind ?? sleepSeed?.kind ?? .reserve,
                    state: selectedSeedKind == nil ? .seed : .halfOpen,
                    size: 44
                )
                .frame(width: 48, height: 48)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    Text("选择今晚种子")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)

                    Text("选择一颗种子，让 Vitora 明早看看它长成什么样。")
                        .font(.footnote)
                        .lineSpacing(2)
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }
            }

            VStack(spacing: 8) {
                ForEach(SleepSeedKind.allCases) { kind in
                    seedButton(kind)
                }
            }

            if let selectedSeedKind {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.success)

                    Text("\(selectedSeedKind.title)已保存，明早会结合休息情况观察。")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .lineLimit(2)
                }
                .padding(.horizontal, 12)
                .frame(minHeight: 36)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(VitoraTheme.ColorToken.paper.opacity(0.46), in: Capsule())
            }
        }
        .padding(18)
        .background(GlassSurface(cornerRadius: 24, opacity: 0.70, shadowStrength: 0.30, variant: .cleanElevated))
    }

    private func seedButton(_ kind: SleepSeedKind) -> some View {
        let isSelected = selectedSeedKind == kind || (selectedSeedKind == nil && sleepSeed?.kind == kind && sleepSeed?.growthState == .seed)

        return Button {
            selectedSeedKind = kind
            onSelectSeed(kind)
        } label: {
            HStack(spacing: 12) {
                SleepSeedPixelView(kind: kind, state: isSelected ? .halfOpen : .seed, size: 34)
                    .frame(width: 38, height: 38)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    Text(kind.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)

                    Text(kind.subtitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(isSelected ? VitoraTheme.ColorToken.success : VitoraTheme.ColorToken.secondaryText.opacity(0.62))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? VitoraTheme.ColorToken.paper.opacity(0.78) : VitoraTheme.ColorToken.paper.opacity(0.44))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(isSelected ? 0.88 : 0.54), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("vitora.review.seed.\(kind.rawValue)")
    }

    private var tellVitoraBlock: some View {
        Button(action: onTellVitora) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                Text("告诉 Vitora 更多细节")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 48)
            .background(GlassSurface(cornerRadius: 18, opacity: 0.64, shadowStrength: 0.24, variant: .cleanResting))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("vitora.review.tell")
    }
}
