import SwiftUI

struct SeedPlantingSheet: View {
    let onClose: () -> Void
    let onPlant: (SeedType) -> Void

    @State private var selectedSeed: SeedType = .lavender

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
            PixelFlowerView(seed: selectedSeed, size: 72)

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

                PixelFlowerView(seed: seed, size: 44)

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
            PixelFlowerView(seed: selectedSeed, size: 48)
                .opacity(score == "68分" ? 0.6 : (score == "80分" ? 0.85 : 1.0))
                .scaleEffect(score == "68分" ? 0.8 : (score == "80分" ? 0.9 : 1.0))
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
    case lavender
    case rose
    case camellia
    case bellflower
    case hydrangea
    case iris
    case sunflower
    case tulip

    var id: String { rawValue }

    var name: String {
        switch self {
        case .lavender: return "薰衣草"
        case .rose: return "玫瑰"
        case .camellia: return "山茶花"
        case .bellflower: return "桔梗"
        case .hydrangea: return "绣球花"
        case .iris: return "鸢尾花"
        case .sunflower: return "向日葵"
        case .tulip: return "郁金香"
        }
    }

    var shortLabel: String {
        switch self {
        case .lavender: return "安神舒缓"
        case .rose: return "温柔绽放"
        case .camellia: return "热情满满"
        case .bellflower: return "静心守候"
        case .hydrangea: return "安心恢复"
        case .iris: return "清爽一点"
        case .sunflower: return "重新启动"
        case .tulip: return "保留余量"
        }
    }

    var description: String {
        switch self {
        case .lavender: return "让紫色的宁静帮你放松紧绷的神经，安然入眠。"
        case .rose: return "像玫瑰一样温柔绽放，对自己多一点耐心。"
        case .camellia: return "红色的热情给身体注入力量，明天会更好。"
        case .bellflower: return "安静等待也是一种力量，给恢复留出空间。"
        case .hydrangea: return "一簇簇小花聚在一起，恢复从点滴开始。"
        case .iris: return "做一件让心情变清爽的小事，刷新今天的感受。"
        case .sunflower: return "向着阳光的方向，一小段晨间活动唤醒身体。"
        case .tulip: return "给自己留一点呼吸的空间，也是在照顾明天。"
        }
    }

    var flowerColors: (primary: Color, secondary: Color, accent: Color) {
        switch self {
        case .lavender: return (Color(red: 0.62, green: 0.48, blue: 0.88), Color(red: 0.72, green: 0.58, blue: 0.92), Color(red: 0.82, green: 0.70, blue: 0.96))
        case .rose: return (Color(red: 0.92, green: 0.52, blue: 0.68), Color(red: 0.96, green: 0.68, blue: 0.78), Color(red: 0.98, green: 0.82, blue: 0.88))
        case .camellia: return (Color(red: 0.88, green: 0.22, blue: 0.28), Color(red: 0.95, green: 0.38, blue: 0.38), Color(red: 0.98, green: 0.62, blue: 0.52))
        case .bellflower: return (Color(red: 0.58, green: 0.48, blue: 0.88), Color(red: 0.72, green: 0.62, blue: 0.95), Color(red: 0.85, green: 0.78, blue: 0.98))
        case .hydrangea: return (Color(red: 0.42, green: 0.68, blue: 0.92), Color(red: 0.55, green: 0.78, blue: 0.95), Color(red: 0.72, green: 0.88, blue: 0.98))
        case .iris: return (Color(red: 0.38, green: 0.42, blue: 0.88), Color(red: 0.52, green: 0.55, blue: 0.95), Color(red: 0.68, green: 0.72, blue: 0.98))
        case .sunflower: return (Color(red: 0.95, green: 0.82, blue: 0.18), Color(red: 0.98, green: 0.88, blue: 0.42), Color(red: 0.72, green: 0.52, blue: 0.22))
        case .tulip: return (Color(red: 0.92, green: 0.48, blue: 0.58), Color(red: 0.96, green: 0.62, blue: 0.68), Color(red: 0.98, green: 0.78, blue: 0.82))
        }
    }
}

// MARK: - Pixel Flower View (Canvas-drawn with grass base)

struct PixelFlowerView: View {
    let seed: SeedType
    let size: CGFloat

    var body: some View {
        Canvas { context, canvasSize in
            let s = canvasSize.width
            let colors = seed.flowerColors

            // Grass base
            let grassRect = CGRect(x: s * 0.1, y: s * 0.72, width: s * 0.8, height: s * 0.22)
            let grassPath = Path(roundedRect: grassRect, cornerRadius: s * 0.04)
            context.fill(grassPath, with: .linearGradient(
                Gradient(colors: [Color(red: 0.48, green: 0.78, blue: 0.38), Color(red: 0.38, green: 0.68, blue: 0.32)]),
                startPoint: CGPoint(x: s * 0.5, y: grassRect.minY),
                endPoint: CGPoint(x: s * 0.5, y: grassRect.maxY)
            ))

            // Small grass tufts
            for xOff in stride(from: 0.18, through: 0.78, by: 0.15) {
                let gx = s * xOff
                let gy = grassRect.minY - s * 0.02
                var blade = Path()
                blade.move(to: CGPoint(x: gx, y: gy + s * 0.04))
                blade.addLine(to: CGPoint(x: gx - s * 0.01, y: gy))
                blade.addLine(to: CGPoint(x: gx + s * 0.01, y: gy + s * 0.02))
                context.fill(blade, with: .color(Color(red: 0.52, green: 0.82, blue: 0.42)))
            }

            // Stem
            let stemTop = s * 0.32
            let stemBottom = grassRect.minY
            var stem = Path()
            stem.move(to: CGPoint(x: s * 0.5, y: stemBottom))
            stem.addLine(to: CGPoint(x: s * 0.5, y: stemTop))
            context.stroke(stem, with: .color(Color(red: 0.32, green: 0.62, blue: 0.28)), style: StrokeStyle(lineWidth: s * 0.04, lineCap: .round))

            // Leaves
            let leafY = s * 0.56
            var leftLeaf = Path()
            leftLeaf.move(to: CGPoint(x: s * 0.5, y: leafY))
            leftLeaf.addQuadCurve(to: CGPoint(x: s * 0.22, y: leafY - s * 0.06), control: CGPoint(x: s * 0.32, y: leafY - s * 0.10))
            leftLeaf.addQuadCurve(to: CGPoint(x: s * 0.5, y: leafY), control: CGPoint(x: s * 0.32, y: leafY + s * 0.06))
            context.fill(leftLeaf, with: .color(Color(red: 0.38, green: 0.72, blue: 0.32)))

            var rightLeaf = Path()
            rightLeaf.move(to: CGPoint(x: s * 0.5, y: leafY))
            rightLeaf.addQuadCurve(to: CGPoint(x: s * 0.78, y: leafY - s * 0.06), control: CGPoint(x: s * 0.68, y: leafY - s * 0.10))
            rightLeaf.addQuadCurve(to: CGPoint(x: s * 0.5, y: leafY), control: CGPoint(x: s * 0.68, y: leafY + s * 0.06))
            context.fill(rightLeaf, with: .color(Color(red: 0.42, green: 0.76, blue: 0.36)))

            // Flower head (different shapes per type)
            let center = CGPoint(x: s * 0.5, y: stemTop - s * 0.02)
            let petalR = s * 0.16

            switch seed {
            case .sunflower:
                // Large center disk
                context.fill(Path(ellipseIn: CGRect(x: center.x - petalR * 0.7, y: center.y - petalR * 0.7, width: petalR * 1.4, height: petalR * 1.4)), with: .color(colors.accent))
                // Petals around
                for i in 0..<10 {
                    let angle = Double(i) / 10.0 * .pi * 2
                    let px = center.x + cos(angle) * petalR * 1.2
                    let py = center.y + sin(angle) * petalR * 1.2
                    context.fill(Path(ellipseIn: CGRect(x: px - s * 0.04, y: py - s * 0.07, width: s * 0.08, height: s * 0.14).applying(.init(rotationAngle: angle + .pi / 2).concatenating(.init(translationX: px, y: py)))), with: .color(colors.primary))
                    // Simplified: just circles
                    context.fill(Path(ellipseIn: CGRect(x: px - s * 0.05, y: py - s * 0.05, width: s * 0.10, height: s * 0.10)), with: .color(colors.primary.opacity(0.88)))
                }
                context.fill(Path(ellipseIn: CGRect(x: center.x - petalR * 0.55, y: center.y - petalR * 0.55, width: petalR * 1.1, height: petalR * 1.1)), with: .color(colors.accent))

            case .hydrangea:
                // Cluster of small circles
                for i in 0..<12 {
                    let angle = Double(i) / 12.0 * .pi * 2
                    let dist = petalR * (0.5 + Double(i % 3) * 0.25)
                    let px = center.x + cos(angle) * dist
                    let py = center.y + sin(angle) * dist
                    let r = s * 0.05
                    context.fill(Path(ellipseIn: CGRect(x: px - r, y: py - r, width: r * 2, height: r * 2)), with: .color(i % 2 == 0 ? colors.primary : colors.secondary))
                }

            default:
                // Generic flower: 5-6 petals
                let petalCount = seed == .lavender ? 7 : (seed == .tulip ? 3 : 5)
                for i in 0..<petalCount {
                    let angle = Double(i) / Double(petalCount) * .pi * 2 - .pi / 2
                    let px = center.x + cos(angle) * petalR * 0.65
                    let py = center.y + sin(angle) * petalR * 0.65
                    let pw = s * (seed == .tulip ? 0.12 : 0.10)
                    let ph = s * (seed == .tulip ? 0.16 : 0.12)
                    context.fill(Path(ellipseIn: CGRect(x: px - pw, y: py - ph, width: pw * 2, height: ph * 2)), with: .color(i % 2 == 0 ? colors.primary : colors.secondary))
                }
                // Center
                let cr = s * 0.05
                context.fill(Path(ellipseIn: CGRect(x: center.x - cr, y: center.y - cr, width: cr * 2, height: cr * 2)), with: .color(colors.accent))
            }

            // Sparkle accents
            let sparklePositions: [(CGFloat, CGFloat)] = [(0.22, 0.18), (0.78, 0.22), (0.82, 0.52)]
            for (sx, sy) in sparklePositions {
                let sp = CGPoint(x: s * sx, y: s * sy)
                let sparkR = s * 0.012
                var sparkH = Path()
                sparkH.move(to: CGPoint(x: sp.x - sparkR * 3, y: sp.y))
                sparkH.addLine(to: CGPoint(x: sp.x + sparkR * 3, y: sp.y))
                var sparkV = Path()
                sparkV.move(to: CGPoint(x: sp.x, y: sp.y - sparkR * 3))
                sparkV.addLine(to: CGPoint(x: sp.x, y: sp.y + sparkR * 3))
                context.stroke(sparkH, with: .color(colors.primary.opacity(0.5)), style: StrokeStyle(lineWidth: sparkR, lineCap: .round))
                context.stroke(sparkV, with: .color(colors.primary.opacity(0.5)), style: StrokeStyle(lineWidth: sparkR, lineCap: .round))
            }
        }
        .frame(width: size, height: size)
    }
}
