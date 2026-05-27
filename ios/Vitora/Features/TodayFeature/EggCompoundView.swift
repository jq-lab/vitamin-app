import SwiftUI

/// 区块 1 · 蛋复合组件（凝视区）
/// 包含：花朵能量组件 + 侧弧 dial（chip 栈 + tick 弧线）
/// chip 切换只影响 dial 高亮和下方信息卡，不再在主视觉下方重复展示分数。
struct EggCompoundView: View {
    @Binding var activeDimension: DimensionType
    let cycleDay: Int
    let cyclePhase: String
    @State private var growthPulseID = 0

    var body: some View {
        GeometryReader { proxy in
            let flowerWidth = max(proxy.size.width + 150, 520)
            let flowerHeight: CGFloat = 280

            ZStack(alignment: .topTrailing) {
                Button {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.72)) {
                        growthPulseID += 1
                    }
                } label: {
                    FlowerEnergyBloomView(
                        size: CGSize(width: flowerWidth, height: flowerHeight),
                        energyProgress: qaEnergyProgress,
                        growthThreshold: 0.80,
                        phaseLabel: cyclePhase,
                        sameSpeciesPair: qaShowsSameSpeciesPair,
                        accent: activeDimension.accent,
                        pulseID: growthPulseID
                    )
                    .offset(x: -80)
                }
                .buttonStyle(.plain)
                .frame(width: proxy.size.width, height: flowerHeight, alignment: .leading)
                .contentShape(Rectangle())
                .accessibilityIdentifier("egg.compound.mascot")
                .accessibilityHint("点击让今日能量花轻微生长")

                // Right dimension chips are intentionally outside the flower canvas so
                // the active capsule never covers the bucket readout.
                ScrollableChipDial(
                    activeDimension: $activeDimension,
                    cycleDay: cycleDay,
                    accent: activeDimension.accent
                )
                .frame(width: 104)
                .frame(height: 126)
                .padding(.top, 8)
                .offset(x: 18)
            }
        }
        .frame(height: 286)
        .padding(.horizontal, 0)
        .padding(.vertical, 2)
        .accessibilityIdentifier("egg.compound.view")
    }

    private var qaEnergyProgress: CGFloat {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-vitoraUITestFlowerSymbiosis") {
            return 1.0
        }
        if arguments.contains("-vitoraUITestFlowerEnergy80") {
            return 0.80
        }
        return 0.68
    }

    private var qaShowsSameSpeciesPair: Bool {
        ProcessInfo.processInfo.arguments.contains("-vitoraUITestFlowerSymbiosis")
    }
}

// MARK: - Flower Energy Bloom

private struct FlowerEnergyBloomView: View {
    let size: CGSize
    let energyProgress: CGFloat
    let growthThreshold: CGFloat
    let phaseLabel: String
    let sameSpeciesPair: Bool
    let accent: Color
    let pulseID: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var tapBloom: CGFloat = 0
    private var clampedProgress: CGFloat { min(max(energyProgress, 0), 1) }
    private var growthState: FlowerGrowthState {
        clampedProgress >= growthThreshold ? .flower : .seedling
    }
    private var progressText: String {
        "\(Int((clampedProgress * 100).rounded()))%"
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let sway = reduceMotion ? 0 : CGFloat(sin(time * (.pi * 2 / 6.6))) * 1.2
            let wavePhase = reduceMotion ? 0 : time * (.pi * 2 / 4.6)

            ZStack {
                Canvas { context, canvasSize in
                    drawEnergyBloom(in: canvasSize, context: &context, swayDegrees: sway, wavePhase: wavePhase)
                }

                if tapBloom > 0 {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 255 / 255, green: 203 / 255, blue: 75 / 255).opacity(0.26 * tapBloom),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 4,
                                endRadius: 86
                            )
                        )
                        .frame(width: 152, height: 152)
                        .position(x: size.width * 0.50, y: size.height * 0.56)
                        .scaleEffect(0.92 + tapBloom * 0.08)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: size.width, height: size.height)
        }
        .onChange(of: pulseID) { _, _ in
            guard !reduceMotion else {
                tapBloom = 0.55
                withAnimation(.easeOut(duration: 0.24)) { tapBloom = 0 }
                return
            }
            tapBloom = 1
            withAnimation(.spring(response: 0.52, dampingFraction: 0.78)) {
                tapBloom = 0
            }
        }
        .accessibilityLabel("今日能量花")
    }

    private func drawEnergyBloom(in size: CGSize, context: inout GraphicsContext, swayDegrees: CGFloat, wavePhase: TimeInterval) {
        let w = size.width
        let h = size.height
        let baselineY = h * 0.58
        let todayX = w * 0.55
        let bowlHalfWidth = min(90, w * 0.17)
        let bowlLeftX = todayX - bowlHalfWidth
        let bowlRightX = todayX + bowlHalfWidth
        let bowlTopY = baselineY
        let bowlBottomY = min(h - 24, baselineY + 78)

        drawStraightTimeline(in: size, context: &context, bowlLeftX: bowlLeftX, bowlRightX: bowlRightX, baselineY: baselineY)
        drawEnergyBowl(context: &context, centerX: todayX, topY: bowlTopY, bottomY: bowlBottomY, leftX: bowlLeftX, rightX: bowlRightX, wavePhase: wavePhase)
        drawTodayGrowthState(context: &context, base: CGPoint(x: todayX, y: baselineY - 13), swayDegrees: swayDegrees)
        drawHistoryNodes(in: size, context: &context, baselineY: baselineY)
        drawTodayNode(context: &context, center: CGPoint(x: todayX, y: baselineY))
        drawThresholdHint(context: &context, centerX: todayX, baselineY: baselineY)
        drawOptionalSymbiosis(context: &context, centerX: todayX, baselineY: baselineY)
        drawReadout(context: &context, centerX: todayX, topY: bowlTopY, bottomY: bowlBottomY)
    }

    private func drawStraightTimeline(in size: CGSize, context: inout GraphicsContext, bowlLeftX: CGFloat, bowlRightX: CGFloat, baselineY: CGFloat) {
        var leftTrack = Path()
        leftTrack.move(to: CGPoint(x: 16, y: baselineY))
        leftTrack.addLine(to: CGPoint(x: bowlLeftX - 6, y: baselineY))
        context.stroke(
            leftTrack,
            with: .linearGradient(
                Gradient(colors: [Color(red: 31 / 255, green: 183 / 255, blue: 118 / 255), Color(red: 82 / 255, green: 203 / 255, blue: 148 / 255)]),
                startPoint: CGPoint(x: 16, y: baselineY),
                endPoint: CGPoint(x: bowlLeftX, y: baselineY)
            ),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [7, 8])
        )

        var bowlLine = Path()
        bowlLine.move(to: CGPoint(x: bowlLeftX, y: baselineY))
        bowlLine.addLine(to: CGPoint(x: bowlRightX, y: baselineY))
        context.stroke(
            bowlLine,
            with: .linearGradient(
                Gradient(colors: [Color(red: 255 / 255, green: 173 / 255, blue: 4 / 255), Color(red: 240 / 255, green: 142 / 255, blue: 0)]),
                startPoint: CGPoint(x: bowlLeftX, y: baselineY),
                endPoint: CGPoint(x: bowlRightX, y: baselineY)
            ),
            style: StrokeStyle(lineWidth: 4, lineCap: .round)
        )

        var rightTrack = Path()
        rightTrack.move(to: CGPoint(x: bowlRightX + 6, y: baselineY))
        rightTrack.addLine(to: CGPoint(x: size.width - 18, y: baselineY))
        context.stroke(
            rightTrack,
            with: .linearGradient(
                Gradient(colors: [Color(red: 255 / 255, green: 153 / 255, blue: 167 / 255), Color(red: 238 / 255, green: 103 / 255, blue: 136 / 255)]),
                startPoint: CGPoint(x: bowlRightX, y: baselineY),
                endPoint: CGPoint(x: size.width - 18, y: baselineY)
            ),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [7, 8])
        )
    }

    private func drawEnergyBowl(context: inout GraphicsContext, centerX: CGFloat, topY: CGFloat, bottomY: CGFloat, leftX: CGFloat, rightX: CGFloat, wavePhase: TimeInterval) {
        var bowl = Path()
        bowl.move(to: CGPoint(x: leftX, y: topY))
        bowl.addLine(to: CGPoint(x: rightX, y: topY))
        bowl.addQuadCurve(to: CGPoint(x: leftX, y: topY), control: CGPoint(x: centerX, y: bottomY + 54))
        bowl.addLine(to: CGPoint(x: leftX, y: topY))
        bowl.closeSubpath()

        context.fill(
            bowl,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 255 / 255, green: 249 / 255, blue: 229 / 255).opacity(0.26),
                    Color(red: 255 / 255, green: 226 / 255, blue: 130 / 255).opacity(0.18),
                    Color.white.opacity(0.10)
                ]),
                startPoint: CGPoint(x: centerX, y: topY),
                endPoint: CGPoint(x: centerX, y: bottomY)
            )
        )

        let fillTop = bottomY - (bottomY - topY) * clampedProgress

        var fillContext = context
        fillContext.clip(to: bowl)
        fillContext.fill(
            Path(CGRect(x: leftX - 2, y: fillTop, width: rightX - leftX + 4, height: bottomY - fillTop + 26)),
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 255 / 255, green: 238 / 255, blue: 157 / 255).opacity(0.80),
                    Color(red: 255 / 255, green: 194 / 255, blue: 49 / 255).opacity(0.72),
                    Color(red: 255 / 255, green: 166 / 255, blue: 8 / 255).opacity(0.58)
                ]),
                startPoint: CGPoint(x: centerX, y: fillTop),
                endPoint: CGPoint(x: centerX, y: bottomY)
            )
        )

        context.stroke(
            bowl,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 255 / 255, green: 170 / 255, blue: 5 / 255),
                    Color(red: 241 / 255, green: 143 / 255, blue: 0)
                ]),
                startPoint: CGPoint(x: leftX, y: topY),
                endPoint: CGPoint(x: rightX, y: bottomY)
            ),
            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
        )

        var glowContext = context
        glowContext.addFilter(.blur(radius: 12))
        glowContext.fill(
            Path(ellipseIn: CGRect(x: leftX + 8, y: bottomY - 10, width: rightX - leftX - 16, height: 22)),
            with: .color(Color(red: 255 / 255, green: 173 / 255, blue: 20 / 255).opacity(0.20))
        )

        var wavePath = Path()
        wavePath.move(to: CGPoint(x: leftX + 10, y: fillTop + 6))
        let waveCount = 5
        for index in 0...waveCount {
            let x = leftX + 10 + (rightX - leftX - 20) * CGFloat(index) / CGFloat(waveCount)
            let y = fillTop + 5 + CGFloat(sin(wavePhase + Double(index) * 0.78)) * 1.2
            if index == 0 {
                wavePath.move(to: CGPoint(x: x, y: y))
            } else {
                wavePath.addLine(to: CGPoint(x: x, y: y))
            }
        }
        context.stroke(
            wavePath,
            with: .linearGradient(
                Gradient(colors: [Color.white.opacity(0.86), Color(red: 255 / 255, green: 244 / 255, blue: 186 / 255).opacity(0.52)]),
                startPoint: CGPoint(x: leftX, y: fillTop),
                endPoint: CGPoint(x: rightX, y: fillTop)
            ),
            style: StrokeStyle(lineWidth: 1.1, lineCap: .round, lineJoin: .round)
        )

        for index in 0..<10 {
            let x = leftX + 14 + CGFloat((index * 23) % 72)
            let y = fillTop + 9 + CGFloat((index * 17) % 26)
            context.stroke(
                Path(ellipseIn: CGRect(x: x, y: y, width: 3.2, height: 3.2)),
                with: .color(Color.white.opacity(0.58)),
                lineWidth: 0.7
            )
        }
    }

    private func drawTodayGrowthState(context: inout GraphicsContext, base: CGPoint, swayDegrees: CGFloat) {
        var layer = context
        layer.translateBy(x: base.x, y: base.y)
        layer.rotate(by: .degrees(swayDegrees))
        layer.translateBy(x: -base.x, y: -base.y)

        switch growthState {
        case .seedling:
            drawSeedling(context: &layer, base: base)
        case .flower:
            drawSunflowerPlant(context: &layer, base: base)
        }
    }

    private func drawThresholdHint(context: inout GraphicsContext, centerX: CGFloat, baselineY: CGFloat) {
        guard growthState == .seedling else { return }

        context.draw(
            Text("达到 80% 时\n将成长为向日葵")
                .font(.system(size: 10.5, weight: .bold))
                .foregroundColor(Color(red: 239 / 255, green: 141 / 255, blue: 3 / 255)),
            at: CGPoint(x: centerX, y: baselineY - 126),
            anchor: .center
        )

        let bubbleRect = CGRect(x: centerX - 24, y: baselineY - 109, width: 48, height: 40)
        context.stroke(
            Path(ellipseIn: bubbleRect),
            with: .color(Color(red: 246 / 255, green: 151 / 255, blue: 0).opacity(0.54)),
            style: StrokeStyle(lineWidth: 1.1, lineCap: .round, dash: [4, 4])
        )
        drawTinySunflower(context: &context, center: CGPoint(x: centerX, y: baselineY - 89), scale: 0.48)

        var arrow = Path()
        arrow.move(to: CGPoint(x: centerX, y: baselineY - 65))
        arrow.addLine(to: CGPoint(x: centerX, y: baselineY - 37))
        context.stroke(
            arrow,
            with: .color(Color(red: 246 / 255, green: 151 / 255, blue: 0).opacity(0.56)),
            style: StrokeStyle(lineWidth: 1.3, lineCap: .round, dash: [3, 4])
        )
    }

    private func drawOptionalSymbiosis(context: inout GraphicsContext, centerX: CGFloat, baselineY: CGFloat) {
        guard clampedProgress >= 1, sameSpeciesPair else { return }

        let bubbleRect = CGRect(x: centerX - 46, y: baselineY - 118, width: 92, height: 58)
        context.stroke(
            Path(ellipseIn: bubbleRect),
            with: .color(Color(red: 246 / 255, green: 151 / 255, blue: 0).opacity(0.74)),
            style: StrokeStyle(lineWidth: 1.2, lineCap: .round, dash: [4, 4])
        )
        context.draw(
            Text("100% 同品种\n双朵共生")
                .font(.system(size: 8.6, weight: .semibold))
                .foregroundColor(Color(red: 225 / 255, green: 130 / 255, blue: 0)),
            at: CGPoint(x: centerX, y: baselineY - 105),
            anchor: .center
        )
        drawTinySunflower(context: &context, center: CGPoint(x: centerX - 13, y: baselineY - 82), scale: 0.46)
        drawTinySunflower(context: &context, center: CGPoint(x: centerX + 13, y: baselineY - 82), scale: 0.46)

        var arrow = Path()
        arrow.move(to: CGPoint(x: centerX, y: baselineY - 58))
        arrow.addLine(to: CGPoint(x: centerX, y: baselineY - 47))
        context.stroke(
            arrow,
            with: .color(Color(red: 246 / 255, green: 151 / 255, blue: 0).opacity(0.64)),
            style: StrokeStyle(lineWidth: 1.25, lineCap: .round, dash: [3, 4])
        )
    }

    private func drawReadout(context: inout GraphicsContext, centerX: CGFloat, topY: CGFloat, bottomY: CGFloat) {
        let scoreY = topY + (bottomY - topY) * 0.64
        let scoreRect = CGRect(x: centerX - 34, y: scoreY - 14, width: 68, height: 28)
        context.fill(Path(roundedRect: scoreRect, cornerRadius: 14), with: .color(Color.white.opacity(0.30)))
        context.draw(
            Text(progressText)
                .font(.system(size: 23, weight: .heavy, design: .rounded))
                .foregroundColor(Color(red: 239 / 255, green: 141 / 255, blue: 3 / 255)),
            at: CGPoint(x: centerX, y: scoreRect.midY),
            anchor: .center
        )

        let phaseRect = CGRect(x: centerX - 29, y: scoreRect.maxY + 4, width: 58, height: 18)
        context.fill(Path(roundedRect: phaseRect, cornerRadius: 10), with: .color(Color.white.opacity(0.64)))
        context.draw(
            Text(phaseLabel)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(red: 239 / 255, green: 141 / 255, blue: 3 / 255)),
            at: CGPoint(x: centerX, y: phaseRect.midY),
            anchor: .center
        )
    }

    private func drawSeedling(context: inout GraphicsContext, base: CGPoint) {
        var stem = Path()
        stem.move(to: CGPoint(x: base.x, y: base.y + 2))
        stem.addLine(to: CGPoint(x: base.x, y: base.y - 25))
        context.stroke(stem, with: .color(Color(red: 77 / 255, green: 176 / 255, blue: 72 / 255)), style: StrokeStyle(lineWidth: 3, lineCap: .round))

        drawLeaf(context: &context, center: CGPoint(x: base.x - 5, y: base.y - 16), angle: -0.82, color: Color(red: 92 / 255, green: 191 / 255, blue: 79 / 255), scale: 0.58)
        drawLeaf(context: &context, center: CGPoint(x: base.x + 7, y: base.y - 20), angle: 0.82, color: Color(red: 111 / 255, green: 202 / 255, blue: 88 / 255), scale: 0.58)
    }

    private func drawSunflowerPlant(context: inout GraphicsContext, base: CGPoint) {
        var stem = Path()
        stem.move(to: CGPoint(x: base.x, y: base.y + 2))
        stem.addLine(to: CGPoint(x: base.x, y: base.y - 54))
        context.stroke(stem, with: .color(Color(red: 77 / 255, green: 176 / 255, blue: 72 / 255)), style: StrokeStyle(lineWidth: 3, lineCap: .round))

        drawLeaf(context: &context, center: CGPoint(x: base.x - 16, y: base.y - 22), angle: -0.72, color: Color(red: 92 / 255, green: 191 / 255, blue: 79 / 255), scale: 0.78)
        drawLeaf(context: &context, center: CGPoint(x: base.x + 18, y: base.y - 29), angle: 0.76, color: Color(red: 111 / 255, green: 202 / 255, blue: 88 / 255), scale: 0.78)

        drawFlower(context: &context, center: CGPoint(x: base.x, y: base.y - 66), scale: 0.78)
    }

    private func drawLeaf(context: inout GraphicsContext, center: CGPoint, angle: CGFloat, color: Color, scale: CGFloat = 1) {
        var leaf = Path()
        leaf.move(to: CGPoint(x: 0, y: 0))
        leaf.addCurve(to: CGPoint(x: 23, y: -7), control1: CGPoint(x: 7, y: -16), control2: CGPoint(x: 19, y: -15))
        leaf.addCurve(to: CGPoint(x: 0, y: 0), control1: CGPoint(x: 18, y: 8), control2: CGPoint(x: 7, y: 10))

        var layer = context
        layer.translateBy(x: center.x, y: center.y)
        layer.rotate(by: .radians(angle))
        layer.scaleBy(x: scale, y: scale)
        layer.fill(
            leaf,
            with: .linearGradient(
                Gradient(colors: [color.opacity(0.98), color.opacity(0.68)]),
                startPoint: CGPoint(x: 0, y: -10),
                endPoint: CGPoint(x: 22, y: 8)
            )
        )
    }

    private func drawFlower(context: inout GraphicsContext, center: CGPoint, scale: CGFloat = 1) {
        var flowerContext = context
        flowerContext.translateBy(x: center.x, y: center.y)
        flowerContext.scaleBy(x: scale, y: scale)

        for index in 0..<18 {
            let angle = CGFloat(index) / 18 * .pi * 2
            var petalContext = flowerContext
            petalContext.rotate(by: .radians(angle))
            let petal = Path(roundedRect: CGRect(x: -4.3, y: -25, width: 8.6, height: 22), cornerRadius: 4)
            petalContext.fill(
                petal,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 255 / 255, green: 218 / 255, blue: 87 / 255),
                        Color(red: 255 / 255, green: 161 / 255, blue: 32 / 255)
                    ]),
                    startPoint: CGPoint(x: 0, y: -28),
                    endPoint: CGPoint(x: 0, y: -7)
                )
            )
        }

        flowerContext.fill(Path(ellipseIn: CGRect(x: -11, y: -11, width: 22, height: 22)), with: .color(Color(red: 220 / 255, green: 113 / 255, blue: 12 / 255)))
        flowerContext.fill(Path(ellipseIn: CGRect(x: -6, y: -7, width: 12, height: 12)), with: .color(Color(red: 247 / 255, green: 151 / 255, blue: 25 / 255)))
    }

    private func drawTinySunflower(context: inout GraphicsContext, center: CGPoint, scale: CGFloat) {
        var layer = context
        layer.translateBy(x: center.x, y: center.y)
        layer.scaleBy(x: scale, y: scale)
        for index in 0..<10 {
            let angle = CGFloat(index) / 10 * .pi * 2
            var petalContext = layer
            petalContext.rotate(by: .radians(angle))
            petalContext.fill(
                Path(roundedRect: CGRect(x: -2, y: -10, width: 4, height: 9), cornerRadius: 2),
                with: .color(Color(red: 255 / 255, green: 183 / 255, blue: 39 / 255))
            )
        }
        layer.fill(Path(ellipseIn: CGRect(x: -4, y: -4, width: 8, height: 8)), with: .color(Color(red: 212 / 255, green: 111 / 255, blue: 10 / 255)))
    }

    private func drawHistoryNodes(in size: CGSize, context: inout GraphicsContext, baselineY: CGFloat) {
        let nodes: [(String, CGPoint, FlowerNodeState)] = [
            ("前天", CGPoint(x: size.width * 0.20, y: baselineY), .flower(.pink)),
            ("昨天", CGPoint(x: size.width * 0.36, y: baselineY), .flower(.sunflower))
        ]

        for node in nodes {
            let nodeSize: CGFloat = 14
            context.fill(Path(ellipseIn: CGRect(x: node.1.x - 10, y: node.1.y - 10, width: 20, height: 20)), with: .color(Color.white.opacity(0.68)))
            context.fill(Path(ellipseIn: CGRect(x: node.1.x - nodeSize / 2, y: node.1.y - nodeSize / 2, width: nodeSize, height: nodeSize)), with: .color(Color.white.opacity(0.95)))
            context.stroke(Path(ellipseIn: CGRect(x: node.1.x - nodeSize / 2, y: node.1.y - nodeSize / 2, width: nodeSize, height: nodeSize)), with: .color(Color.black.opacity(0.22)), lineWidth: 1.5)

            var miniStem = Path()
            miniStem.move(to: CGPoint(x: node.1.x, y: node.1.y - nodeSize / 2))
            miniStem.addLine(to: CGPoint(x: node.1.x, y: node.1.y - 30))
            context.stroke(miniStem, with: .color(Color(red: 86 / 255, green: 184 / 255, blue: 78 / 255)), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))

            switch node.2 {
            case .flower(.sunflower):
                let center = CGPoint(x: node.1.x, y: node.1.y - 36)
                for petal in 0..<8 {
                    let angle = CGFloat(petal) / 8 * .pi * 2
                    var petalContext = context
                    petalContext.translateBy(x: center.x, y: center.y)
                    petalContext.rotate(by: .radians(angle))
                    petalContext.fill(Path(ellipseIn: CGRect(x: -1.8, y: -8, width: 3.6, height: 8)), with: .color(Color(red: 255 / 255, green: 178 / 255, blue: 43 / 255)))
                }
                context.fill(Path(ellipseIn: CGRect(x: center.x - 3, y: center.y - 3, width: 6, height: 6)), with: .color(Color(red: 222 / 255, green: 119 / 255, blue: 19 / 255)))
            case .flower(.pink):
                let center = CGPoint(x: node.1.x, y: node.1.y - 36)
                for petal in 0..<6 {
                    let angle = CGFloat(petal) / 6 * .pi * 2
                    var petalContext = context
                    petalContext.translateBy(x: center.x, y: center.y)
                    petalContext.rotate(by: .radians(angle))
                    petalContext.fill(Path(ellipseIn: CGRect(x: -2.3, y: -8, width: 4.6, height: 8)), with: .color(Color(red: 255 / 255, green: 107 / 255, blue: 157 / 255)))
                }
                context.fill(Path(ellipseIn: CGRect(x: center.x - 2.6, y: center.y - 2.6, width: 5.2, height: 5.2)), with: .color(Color(red: 255 / 255, green: 194 / 255, blue: 55 / 255)))
            case .sprout:
                break
            case .today:
                break
            }

            context.draw(
                Text(node.0)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 86 / 255, green: 103 / 255, blue: 126 / 255)),
                at: CGPoint(x: node.1.x, y: node.1.y + 21),
                anchor: .center
            )
        }
    }

    private func drawTodayNode(context: inout GraphicsContext, center: CGPoint) {
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - 13, y: center.y - 13, width: 26, height: 26)),
            with: .color(Color(red: 255 / 255, green: 178 / 255, blue: 20 / 255).opacity(0.20 + tapBloom * 0.20))
        )
        context.fill(Path(ellipseIn: CGRect(x: center.x - 8, y: center.y - 8, width: 16, height: 16)), with: .color(Color.white.opacity(0.96)))
        context.stroke(Path(ellipseIn: CGRect(x: center.x - 8, y: center.y - 8, width: 16, height: 16)), with: .color(Color.black.opacity(0.22)), lineWidth: 1.5)
        context.fill(Path(ellipseIn: CGRect(x: center.x - 3, y: center.y - 3, width: 6, height: 6)), with: .color(Color(red: 255 / 255, green: 168 / 255, blue: 0).opacity(0.92)))
        context.draw(
            Text("今天")
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundColor(Color(red: 86 / 255, green: 103 / 255, blue: 126 / 255)),
            at: CGPoint(x: center.x, y: center.y + 17),
            anchor: .center
        )
    }
}

private enum FlowerKind: Equatable {
    case sunflower
    case pink
}

private enum FlowerGrowthState: Equatable {
    case seedling
    case flower
}

private enum FlowerNodeState: Equatable {
    case sprout
    case flower(FlowerKind)
    case today
}

// MARK: - Scrollable Chip + Dial (right side, combined)

/// Combined scrollable capsule chips + clock-face tick dial.
/// Chips and ticks scroll together. Snaps to nearest dimension on release.
/// Reference: 小红书 scroll-dial interaction.
struct ScrollableChipDial: View {
    @Binding var activeDimension: DimensionType
    let cycleDay: Int
    let accent: Color

    private let dims = DimensionType.allCases
    private let radius: CGFloat = 200
    private let arcSpan: CGFloat = 0.72  // visible arc in radians
    private var chipSpacing: CGFloat { arcSpan / CGFloat(dims.count - 1) }

    @State private var dragOffset: CGFloat = 0
    @State private var committedOffset: CGFloat = 0

    private var activeIndex: Int { dims.firstIndex(of: activeDimension) ?? 0 }

    var body: some View {
        ZStack(alignment: .trailing) {
            // ── Tick marks (background layer, receives drag) ──
            tickCanvas
                .contentShape(Rectangle())
                .gesture(dragGesture)

            // ── Capsule chips (foreground, tappable buttons) ──
            chipOverlay
        }
        .simultaneousGesture(dragGesture)
        .onAppear {
            committedOffset = CGFloat(activeIndex) * chipSpacing
        }
        .accessibilityIdentifier("egg.compound.view")
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                dragOffset = -value.translation.height / (radius * 1.0)
            }
            .onEnded { _ in
                let raw = committedOffset + dragOffset
                let snappedIndex = round(raw / chipSpacing)
                let clamped = min(max(snappedIndex, 0), CGFloat(dims.count - 1))
                let snappedOffset = clamped * chipSpacing

                withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                    committedOffset = snappedOffset
                    dragOffset = 0
                }

                let newIndex = Int(clamped)
                if newIndex >= 0 && newIndex < dims.count {
                    activeDimension = dims[newIndex]
                }
            }
    }

    // MARK: - Tick Canvas

    private var tickCanvas: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let cx = w + radius - 4
            let cy = h / 2
            let totalOffset = committedOffset + dragOffset
            let centerAngle: CGFloat = .pi
            let tickCount = 15

            for i in 0..<tickCount {
                let fraction = CGFloat(i) / CGFloat(tickCount - 1)
                let baseAngle = centerAngle - arcSpan / 2 + fraction * arcSpan
                let angle = baseAngle + (CGFloat(activeIndex) * chipSpacing - totalOffset)

                let visibleHalf = arcSpan / 2 + 0.08
                let angleFromCenter = abs(angle - centerAngle)
                guard angleFromCenter < visibleHalf else { continue }

                let edgeFade = 1 - (angleFromCenter / visibleHalf)
                let tickLen: CGFloat = 6 + edgeFade * 5
                let tickW: CGFloat = 1.2

                let outerX = cx + radius * cos(angle)
                let outerY = cy + radius * sin(angle)
                let innerX = cx + (radius - tickLen) * cos(angle)
                let innerY = cy + (radius - tickLen) * sin(angle)

                var tick = Path()
                tick.move(to: CGPoint(x: innerX, y: innerY))
                tick.addLine(to: CGPoint(x: outerX, y: outerY))

                context.stroke(
                    tick,
                    with: .color(Color.black.opacity(Double(edgeFade) * 0.15 + 0.03)),
                    style: StrokeStyle(lineWidth: tickW, lineCap: .round)
                )
            }

            // ── Active marker line ──
            let markerAngle = centerAngle
            let markerOuterX = cx + radius * cos(markerAngle)
            let markerOuterY = cy + radius * sin(markerAngle)
            let markerInnerX = cx + (radius - 20) * cos(markerAngle)
            let markerInnerY = cy + (radius - 20) * sin(markerAngle)

            var marker = Path()
            marker.move(to: CGPoint(x: markerInnerX, y: markerInnerY))
            marker.addLine(to: CGPoint(x: markerOuterX, y: markerOuterY))
            context.stroke(marker, with: .color(accent), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

            // Arrow
            let arrowTipX = markerInnerX + 1
            let arrowBackX = markerInnerX - 7
            var arrow = Path()
            arrow.move(to: CGPoint(x: arrowTipX, y: markerInnerY))
            arrow.addLine(to: CGPoint(x: arrowBackX, y: markerInnerY - 5))
            arrow.addLine(to: CGPoint(x: arrowBackX, y: markerInnerY + 5))
            arrow.closeSubpath()
            context.fill(arrow, with: .color(accent))
        }
        .frame(width: 44)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    // MARK: - Chip Overlay

    private var chipOverlay: some View {
        GeometryReader { proxy in
            let h = proxy.size.height
            let cy = h / 2
            let totalOffset = committedOffset + dragOffset
            let centerAngle: CGFloat = .pi

            ForEach(Array(dims.enumerated()), id: \.element) { index, dim in
                let dimAngle = centerAngle + (CGFloat(index) * chipSpacing - totalOffset)
                let angleFromCenter = abs(dimAngle - centerAngle)
                let visibleHalf = arcSpan / 2 + chipSpacing * 0.5

                if angleFromCenter < visibleHalf {
                    let yPos = cy + radius * sin(dimAngle)
                    let xIndent = radius * (1 - cos(dimAngle - centerAngle)) * 0.15
                    let edgeFade = max(1 - (angleFromCenter / visibleHalf), 0)
                    let isActive = dim == activeDimension && angleFromCenter < chipSpacing * 0.4

                    Button {
                        let targetOffset = CGFloat(index) * chipSpacing
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                            committedOffset = targetOffset
                            dragOffset = 0
                        }
                        activeDimension = dim
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: dim.icon)
                                .font(.system(size: 11, weight: .semibold))
                            Text(dim.rawValue)
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundStyle(isActive ? .white : VitoraTheme.ColorToken.strongText.opacity(0.7))
                        .padding(.horizontal, 12)
                        .frame(height: 32)
                        .background(
                            isActive ? dim.accent : Color(red: 0.95, green: 0.95, blue: 0.95),
                            in: Capsule()
                        )
                        .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(isActive ? 1.0 : 0.68 + edgeFade * 0.12)
                    .opacity(isActive ? 1.0 : Double(edgeFade * 0.5 + 0.15))
                    .position(x: 50 + xIndent, y: yPos)
                    .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.9), value: totalOffset)
                }
            }
        }
    }
}

// SideDialTickArc removed — replaced by ScrollableChipDial
