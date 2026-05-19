import SwiftUI

struct SeedPlantingSheet: View {
    let onClose: () -> Void
    let onPlant: (SeedType) -> Void

    @State private var selectedSeed: SeedType = .blank

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.gray.opacity(0.35))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 14)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    selectedSeedCard
                    seedSelector
                    growthExplanation
                    tipCard
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 24)
            }

            bottomButtons
        }
        .background(Color(red: 250 / 255, green: 248 / 255, blue: 245 / 255))
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text("✦")
                        .font(.title3)
                    Text("今晚种下一颗种子")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                }

                Text("明早 Vitora 会告诉你它长成了什么样")
                    .font(.subheadline)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .frame(width: 32, height: 32)
                    .background(Color.gray.opacity(0.10), in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Selected Seed Card

    private var selectedSeedCard: some View {
        HStack(spacing: 14) {
            Text(selectedSeed.emoji)
                .font(.system(size: 44))
                .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 6) {
                Text(selectedSeed.name)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                Text(selectedSeed.description)
                    .font(.subheadline)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.32), lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        )
        .accessibilityIdentifier("seed.selected.card")
    }

    // MARK: - Seed Selector (horizontal scroll)

    private var seedSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(SeedType.allCases) { seed in
                    seedCell(seed)
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 4)
        }
    }

    private func seedCell(_ seed: SeedType) -> some View {
        let isSelected = selectedSeed == seed

        return Button {
            withAnimation(.easeOut(duration: 0.18)) {
                selectedSeed = seed
            }
        } label: {
            VStack(spacing: 6) {
                Text(seed.name)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                Text(seed.emoji)
                    .font(.system(size: 36))
                    .frame(height: 44)

                Text(seed.shortLabel)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }
            .frame(width: 90)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(isSelected ? 0.95 : 0.62))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.42) : Color.clear, lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(isSelected ? 0.06 : 0.02), radius: 6, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("seed.option.\(seed.rawValue)")
    }

    // MARK: - Growth Explanation

    private var growthExplanation: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 4) {
                Text("✦")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                Text("不同能量，种子会长成不同的花朵")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }

            // Three flower stages
            HStack(spacing: 0) {
                flowerStage(score: "68分", label: "半开", emoji: "🌸")
                Spacer()
                flowerStage(score: "80分", label: "盛开", emoji: "🌺")
                Spacer()
                flowerStage(score: "100分", label: "盛开 + 露水", emoji: "💐")
            }

            // Progress bar
            GeometryReader { proxy in
                let w = proxy.size.width
                ZStack(alignment: .leading) {
                    // Track
                    Capsule().fill(Color.gray.opacity(0.15)).frame(height: 6)

                    // Filled portion (68%)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.6),
                                    Color(red: 0.90, green: 0.52, blue: 0.62),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: w * 0.68, height: 6)

                    // Dashed remaining
                    Capsule()
                        .stroke(Color(red: 0.90, green: 0.52, blue: 0.62).opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                        .frame(height: 6)
                        .offset(x: w * 0.68)
                        .frame(width: w * 0.32)

                    // Dots
                    Circle().fill(VitoraTheme.ColorToken.actionPrimaryDeep).frame(width: 10, height: 10).position(x: 0, y: 3)
                    Circle().fill(Color(red: 0.90, green: 0.52, blue: 0.62)).frame(width: 10, height: 10).position(x: w * 0.68, y: 3)
                    Circle().fill(Color(red: 0.90, green: 0.52, blue: 0.62).opacity(0.5)).frame(width: 10, height: 10).position(x: w, y: 3)

                    // Arrow
                    Image(systemName: "arrowtriangle.right.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(Color(red: 0.90, green: 0.52, blue: 0.62).opacity(0.4))
                        .position(x: w + 6, y: 3)
                }
            }
            .frame(height: 10)
            .padding(.horizontal, 8)
        }
    }

    private func flowerStage(score: String, label: String, emoji: String) -> some View {
        VStack(spacing: 4) {
            Text(score)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
            Text(label)
                .font(.caption2)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            Text(emoji)
                .font(.system(size: 36))
        }
    }

    // MARK: - Tip Card

    private var tipCard: some View {
        HStack(spacing: 12) {
            Text("💧")
                .font(.system(size: 28))

            Text("能量充盈，花朵会更饱满、颜色更亮，也会给你带来更好的体验。")
                .font(.caption)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.78))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.62), lineWidth: 0.8))
        )
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        HStack(spacing: 12) {
            Button {
                onPlant(selectedSeed)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("种下这颗种子")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(VitoraTheme.ColorToken.strongText)
                        .shadow(color: VitoraTheme.ColorToken.strongText.opacity(0.22), radius: 14, x: 0, y: 6)
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("seed.plant.button")

            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    let others = SeedType.allCases.filter { $0 != selectedSeed }
                    if let random = others.randomElement() {
                        selectedSeed = random
                    }
                }
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 18, weight: .semibold))
                    Text("换一个")
                        .font(.caption2.weight(.medium))
                }
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .frame(width: 62, height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.78))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.gray.opacity(0.18), lineWidth: 1))
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("seed.shuffle.button")
        }
        .padding(.horizontal, 22)
        .padding(.top, 10)
        .padding(.bottom, 16)
        .background(
            Color(red: 250 / 255, green: 248 / 255, blue: 245 / 255)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: -4)
        )
    }
}

// MARK: - Seed Types

enum SeedType: String, CaseIterable, Identifiable {
    case blank
    case dawn
    case stretch
    case rest
    case blue

    var id: String { rawValue }

    var name: String {
        switch self {
        case .blank: return "留白种子"
        case .dawn: return "晨光种子"
        case .stretch: return "舒展种子"
        case .rest: return "小憩种子"
        case .blue: return "晴蓝种子"
        }
    }

    var shortLabel: String {
        switch self {
        case .blank: return "保留余量"
        case .dawn: return "重新启动"
        case .stretch: return "慢慢舒展"
        case .rest: return "安心恢复"
        case .blue: return "清爽一点"
        }
    }

    var description: String {
        switch self {
        case .blank: return "给自己留一点呼吸的空间，也是在照顾明天。"
        case .dawn: return "一小段晨间活动，帮助身体慢慢苏醒过来。"
        case .stretch: return "轻柔拉伸放松紧绷的肌肉，让身体回到舒适。"
        case .rest: return "允许自己安静休息一会儿，恢复比努力更重要。"
        case .blue: return "做一件让心情变清爽的小事，刷新今天的感受。"
        }
    }

    var emoji: String {
        switch self {
        case .blank: return "🌰"
        case .dawn: return "🌅"
        case .stretch: return "🌿"
        case .rest: return "🍃"
        case .blue: return "🦋"
        }
    }
}
