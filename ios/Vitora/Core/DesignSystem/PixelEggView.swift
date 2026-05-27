import SwiftUI

// MARK: - Pixel Egg Expression System (spec §4.3)

enum PixelEggExpression: Equatable {
    case wideBright    // 卵泡期+能量≥70: 圆眼睁开+白光点
    case closedSparkle // 排卵期: 闭眼弧线+✨
    case sleepyBlush   // 黄体期+能量<70: 眯眼横线+粉腮红 (默认演示态)
    case halfOpen      // 黄体期+能量≥70: 半开眼+腮红
    case closedQuiet   // 月经期: 闭眼直线+淡腮红

    static func from(phase: String, energyScore: Int) -> PixelEggExpression {
        if phase.contains("月经") { return .closedQuiet }
        if phase.contains("排卵") { return .closedSparkle }
        if phase.contains("黄体") { return energyScore < 70 ? .sleepyBlush : .halfOpen }
        if phase.contains("卵泡") && energyScore >= 70 { return .wideBright }
        return .halfOpen
    }
}

enum PixelEggMaterialStyle {
    case amber
    case blueCrystal
}

enum EnergyCrystalTopic: Equatable {
    case energy
    case sleep
    case recovery
    case nutrition
    case activity
    case periodMood

    var accent: Color {
        switch self {
        case .energy:
            return Color(red: 255 / 255, green: 188 / 255, blue: 66 / 255)
        case .sleep:
            return Color(red: 75 / 255, green: 162 / 255, blue: 248 / 255)
        case .recovery:
            return Color(red: 154 / 255, green: 139 / 255, blue: 255 / 255)
        case .nutrition:
            return Color(red: 255 / 255, green: 157 / 255, blue: 78 / 255)
        case .activity:
            return Color(red: 98 / 255, green: 202 / 255, blue: 139 / 255)
        case .periodMood:
            return Color(red: 244 / 255, green: 126 / 255, blue: 178 / 255)
        }
    }

    var softAccent: Color {
        switch self {
        case .energy:
            return Color(red: 255 / 255, green: 224 / 255, blue: 142 / 255)
        case .sleep:
            return Color(red: 156 / 255, green: 220 / 255, blue: 255 / 255)
        case .recovery:
            return Color(red: 198 / 255, green: 190 / 255, blue: 255 / 255)
        case .nutrition:
            return Color(red: 255 / 255, green: 213 / 255, blue: 150 / 255)
        case .activity:
            return Color(red: 170 / 255, green: 232 / 255, blue: 190 / 255)
        case .periodMood:
            return Color(red: 255 / 255, green: 191 / 255, blue: 218 / 255)
        }
    }
}

// MARK: - Pixel Frosted Glass Egg

struct PixelFrostedGlassEgg: View {
    var size: CGSize = CGSize(width: 260, height: 340)
    var fillProgress: Double = 0.6
    var expression: PixelEggExpression? = .sleepyBlush
    var highlightTopic: EnergyCrystalTopic = .energy
    var growthPulseID: Int = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var tapDate = Date.distantPast
    @State private var growthDate = Date.distantPast

    private var clampedFillProgress: Double {
        min(max(fillProgress, 0), 1)
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let tapAge = timeline.date.timeIntervalSince(tapDate)
            let tapPulse = reduceMotion ? 0 : max(0, 1 - tapAge / 0.64)
            let growthAge = timeline.date.timeIntervalSince(growthDate)
            let growthProgress = min(max(growthAge / 1.35, 0), 1)
            let growthActive = growthAge < 1.35 ? 1.0 : 0.0
            let breath = reduceMotion ? 0 : sin(time * .pi * 2 / 3.4) * 0.011

            ZStack {
                PixelFrostedBackShell(time: time)
                PixelFrostedInnerParticles(
                    fillProgress: clampedFillProgress,
                    highlightTopic: highlightTopic,
                    time: reduceMotion ? 0 : time,
                    tapPulse: tapPulse,
                    growthProgress: reduceMotion && growthActive > 0 ? 0.45 : growthProgress,
                    growthActive: growthActive,
                    reduceMotion: reduceMotion
                )
                PixelFrostedFrostVolume(time: reduceMotion ? 0 : time)
                PixelFrostedFrontGlassShell(time: reduceMotion ? 0 : time)
                PixelFrostedPixelVoxelRim(time: reduceMotion ? 0 : time)
                PixelFrostedPixelStars()
                PixelFrostedShineSweep(time: reduceMotion ? 0 : time, reduceMotion: reduceMotion)
                PixelFrostedBottomGlow(highlightTopic: highlightTopic, time: reduceMotion ? 0 : time)
            }
            .frame(width: size.width, height: size.height)
            .mask(PixelFrostedEggShape())
            .overlay {
                if let expression {
                    PixelFrostedExpressionLayer(expression: expression)
                }
            }
            .scaleEffect(1 + breath + tapPulse * 0.042)
            .shadow(color: PixelFrostedGlassEggPalette.shellBlue.opacity(0.26), radius: 22, x: 0, y: 14)
            .shadow(color: Color.white.opacity(0.62), radius: 12, x: -4, y: -7)
            .animation(reduceMotion ? nil : .spring(response: 0.22, dampingFraction: 0.58), value: tapDate)
        }
        .frame(width: size.width, height: size.height)
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                tapDate = Date()
                growthDate = Date()
            }
        )
        .onChange(of: growthPulseID) {
            growthDate = Date()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("霜态玻璃像素蛋，内部能量晶体填充约 \(Int(clampedFillProgress * 100))%")
        .accessibilityIdentifier("pixel.frostedGlassEgg")
    }
}

private enum PixelFrostedGlassEggPalette {
    static let shellBlue = Color(red: 146 / 255, green: 211 / 255, blue: 255 / 255)
    static let rimBlue = Color(red: 70 / 255, green: 158 / 255, blue: 236 / 255)
    static let deepBlue = Color(red: 31 / 255, green: 111 / 255, blue: 220 / 255)
    static let frost = Color(red: 238 / 255, green: 249 / 255, blue: 255 / 255)
    static let aqua = Color(red: 87 / 255, green: 229 / 255, blue: 238 / 255)
    static let lavender = Color(red: 174 / 255, green: 170 / 255, blue: 255 / 255)
}

private enum PixelFrostedEggGeometry {
    static func eggPath(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.015))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.045, y: rect.minY + rect.height * 0.58),
            control1: CGPoint(x: rect.minX + rect.width * 0.26, y: rect.minY - rect.height * 0.01),
            control2: CGPoint(x: rect.minX + rect.width * 0.035, y: rect.minY + rect.height * 0.30)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.004),
            control1: CGPoint(x: rect.minX + rect.width * 0.035, y: rect.minY + rect.height * 0.86),
            control2: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.maxY)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX - rect.width * 0.045, y: rect.minY + rect.height * 0.58),
            control1: CGPoint(x: rect.maxX - rect.width * 0.25, y: rect.maxY),
            control2: CGPoint(x: rect.maxX - rect.width * 0.035, y: rect.minY + rect.height * 0.86)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.015),
            control1: CGPoint(x: rect.maxX - rect.width * 0.035, y: rect.minY + rect.height * 0.30),
            control2: CGPoint(x: rect.maxX - rect.width * 0.26, y: rect.minY - rect.height * 0.01)
        )
        path.closeSubpath()
        return path
    }

    static func innerRect(in size: CGSize) -> CGRect {
        let sideMargin = size.width * 0.115
        return CGRect(
            x: sideMargin,
            y: size.height * 0.055,
            width: size.width - sideMargin * 2,
            height: size.height * 0.835
        )
    }

    static func outlineSample(rect: CGRect, progress: CGFloat) -> (point: CGPoint, tangent: CGVector) {
        let p = progress.truncatingRemainder(dividingBy: 1)
        let segment = min(3, max(0, Int(floor(p * 4))))
        let localT = p * 4 - CGFloat(segment)
        let curves = cubicSegments(rect: rect)
        let curve = curves[segment]
        let point = cubicPoint(curve.0, curve.1, curve.2, curve.3, t: localT)
        let tangent = cubicDerivative(curve.0, curve.1, curve.2, curve.3, t: localT)
        return (point, tangent)
    }

    private static func cubicSegments(rect: CGRect) -> [(CGPoint, CGPoint, CGPoint, CGPoint)] {
        let top = CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.015)
        let left = CGPoint(x: rect.minX + rect.width * 0.045, y: rect.minY + rect.height * 0.58)
        let bottom = CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.004)
        let right = CGPoint(x: rect.maxX - rect.width * 0.045, y: rect.minY + rect.height * 0.58)
        return [
            (
                top,
                CGPoint(x: rect.minX + rect.width * 0.26, y: rect.minY - rect.height * 0.01),
                CGPoint(x: rect.minX + rect.width * 0.035, y: rect.minY + rect.height * 0.30),
                left
            ),
            (
                left,
                CGPoint(x: rect.minX + rect.width * 0.035, y: rect.minY + rect.height * 0.86),
                CGPoint(x: rect.minX + rect.width * 0.25, y: rect.maxY),
                bottom
            ),
            (
                bottom,
                CGPoint(x: rect.maxX - rect.width * 0.25, y: rect.maxY),
                CGPoint(x: rect.maxX - rect.width * 0.035, y: rect.minY + rect.height * 0.86),
                right
            ),
            (
                right,
                CGPoint(x: rect.maxX - rect.width * 0.035, y: rect.minY + rect.height * 0.30),
                CGPoint(x: rect.maxX - rect.width * 0.26, y: rect.minY - rect.height * 0.01),
                top
            )
        ]
    }

    private static func cubicPoint(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint, t: CGFloat) -> CGPoint {
        let u = 1 - t
        let x = u * u * u * p0.x + 3 * u * u * t * p1.x + 3 * u * t * t * p2.x + t * t * t * p3.x
        let y = u * u * u * p0.y + 3 * u * u * t * p1.y + 3 * u * t * t * p2.y + t * t * t * p3.y
        return CGPoint(x: x, y: y)
    }

    private static func cubicDerivative(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint, t: CGFloat) -> CGVector {
        let u = 1 - t
        let x = 3 * u * u * (p1.x - p0.x) + 6 * u * t * (p2.x - p1.x) + 3 * t * t * (p3.x - p2.x)
        let y = 3 * u * u * (p1.y - p0.y) + 6 * u * t * (p2.y - p1.y) + 3 * t * t * (p3.y - p2.y)
        return CGVector(dx: x, dy: y)
    }
}

private struct PixelFrostedEggShape: Shape {
    func path(in rect: CGRect) -> Path {
        PixelFrostedEggGeometry.eggPath(in: PixelFrostedEggGeometry.innerRect(in: rect.size))
    }
}

private struct PixelFrostedBackShell: View {
    let time: TimeInterval

    var body: some View {
        Canvas { context, size in
            let rect = PixelFrostedEggGeometry.innerRect(in: size)
            let backRect = rect.insetBy(dx: rect.width * 0.035, dy: rect.height * 0.025).offsetBy(dx: 0, dy: rect.height * 0.018)
            let backPath = PixelFrostedEggGeometry.eggPath(in: backRect)
            let eggPath = PixelFrostedEggGeometry.eggPath(in: rect)

            context.drawLayer { layer in
                layer.clip(to: eggPath)
                layer.addFilter(.blur(radius: max(2.0, size.width * 0.012)))
                layer.fill(
                    backPath,
                    with: .linearGradient(
                        Gradient(colors: [
                            PixelFrostedGlassEggPalette.deepBlue.opacity(0.16),
                            PixelFrostedGlassEggPalette.shellBlue.opacity(0.10),
                            Color.white.opacity(0.22),
                            PixelFrostedGlassEggPalette.deepBlue.opacity(0.08)
                        ]),
                        startPoint: CGPoint(x: backRect.minX, y: backRect.minY),
                        endPoint: CGPoint(x: backRect.maxX, y: backRect.maxY)
                    )
                )
                layer.stroke(backPath, with: .color(PixelFrostedGlassEggPalette.deepBlue.opacity(0.12)), lineWidth: max(7, size.width * 0.038))
            }
        }
    }
}

private struct PixelFrostedInnerParticles: View {
    let fillProgress: Double
    let highlightTopic: EnergyCrystalTopic
    let time: TimeInterval
    let tapPulse: Double
    let growthProgress: Double
    let growthActive: Double
    let reduceMotion: Bool

    private struct Crystal {
        let topic: EnergyCrystalTopic
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let seed: Int
        let depth: CGFloat
    }

    private let crystals: [Crystal] = [
        .init(topic: .sleep, x: 0.24, y: 0.47, size: 1.06, seed: 11, depth: 0.20),
        .init(topic: .recovery, x: 0.38, y: 0.48, size: 0.95, seed: 19, depth: 0.35),
        .init(topic: .nutrition, x: 0.55, y: 0.49, size: 0.98, seed: 23, depth: 0.55),
        .init(topic: .sleep, x: 0.70, y: 0.50, size: 0.90, seed: 31, depth: 0.26),
        .init(topic: .periodMood, x: 0.31, y: 0.58, size: 0.88, seed: 37, depth: 0.60),
        .init(topic: .activity, x: 0.47, y: 0.59, size: 1.12, seed: 41, depth: 0.44),
        .init(topic: .energy, x: 0.64, y: 0.60, size: 1.02, seed: 47, depth: 0.66),
        .init(topic: .recovery, x: 0.76, y: 0.62, size: 0.82, seed: 53, depth: 0.24),
        .init(topic: .sleep, x: 0.24, y: 0.70, size: 1.28, seed: 59, depth: 0.72),
        .init(topic: .nutrition, x: 0.41, y: 0.70, size: 1.10, seed: 61, depth: 0.58),
        .init(topic: .sleep, x: 0.56, y: 0.71, size: 1.26, seed: 67, depth: 0.76),
        .init(topic: .periodMood, x: 0.70, y: 0.72, size: 1.00, seed: 71, depth: 0.46),
        .init(topic: .activity, x: 0.33, y: 0.79, size: 1.12, seed: 79, depth: 0.52),
        .init(topic: .recovery, x: 0.49, y: 0.80, size: 1.34, seed: 83, depth: 0.84),
        .init(topic: .nutrition, x: 0.64, y: 0.80, size: 1.16, seed: 89, depth: 0.62),
        .init(topic: .energy, x: 0.77, y: 0.81, size: 1.04, seed: 97, depth: 0.44),
        .init(topic: .periodMood, x: 0.25, y: 0.88, size: 0.92, seed: 101, depth: 0.48),
        .init(topic: .sleep, x: 0.40, y: 0.89, size: 1.08, seed: 103, depth: 0.70),
        .init(topic: .recovery, x: 0.56, y: 0.89, size: 1.06, seed: 107, depth: 0.58),
        .init(topic: .nutrition, x: 0.72, y: 0.89, size: 0.96, seed: 109, depth: 0.42)
    ]

    var body: some View {
        Canvas { context, size in
            let rect = PixelFrostedEggGeometry.innerRect(in: size)
            let eggPath = PixelFrostedEggGeometry.eggPath(in: rect)
            let grid = max(4.5, size.width * 0.026)
            let visibleFill = min(1, max(0, fillProgress + growthActive * 0.018 * (1 - growthProgress)))
            let fillTop = rect.maxY - rect.height * CGFloat(visibleFill)

            context.drawLayer { layer in
                layer.clip(to: eggPath)
                drawDepthVolume(in: &layer, rect: rect, fillTop: fillTop)
                drawWaterline(in: &layer, rect: rect, fillTop: fillTop, grid: grid)
                drawGaugeLines(in: &layer, rect: rect, grid: grid)

                for crystal in crystals.sorted(by: { $0.depth < $1.depth }) {
                    let drift = reduceMotion ? 0 : sin(time * (0.85 + Double(crystal.depth) * 0.5) + Double(crystal.seed) * 0.51) * Double(grid) * 0.22
                    let spread = CGFloat(tapPulse) * (unitRandom(crystal.seed * 17) - 0.5) * grid * 3.6
                    let point = CGPoint(
                        x: rect.minX + rect.width * crystal.x + spread,
                        y: rect.minY + rect.height * crystal.y + CGFloat(drift) + CGFloat(tapPulse) * grid * 0.7
                    )
                    guard point.y >= fillTop - grid * 1.2, eggPath.contains(point) else { continue }

                    let highlighted = crystal.topic == highlightTopic || (highlightTopic == .energy && crystal.topic == .recovery)
                    drawCrystal(
                        in: &layer,
                        center: point,
                        block: grid * crystal.size * (1.02 + crystal.depth * 0.46),
                        topic: crystal.topic,
                        highlighted: highlighted,
                        depth: crystal.depth,
                        seed: crystal.seed,
                        opacity: 1
                    )
                }

                drawCenterGrowth(
                    in: &layer,
                    eggPath: eggPath,
                    rect: rect,
                    grid: grid,
                    highlightTopic: highlightTopic,
                    progress: CGFloat(growthProgress),
                    active: growthActive,
                    reduceMotion: reduceMotion
                )
            }
        }
    }

    private func drawDepthVolume(in context: inout GraphicsContext, rect: CGRect, fillTop: CGFloat) {
        let volume = CGRect(x: rect.minX + rect.width * 0.06, y: fillTop, width: rect.width * 0.88, height: rect.maxY - fillTop + rect.height * 0.02)
        context.fill(
            Path(ellipseIn: CGRect(x: volume.minX, y: fillTop - rect.height * 0.04, width: volume.width, height: rect.height * 0.18)),
            with: .radialGradient(
                Gradient(colors: [
                    Color.white.opacity(0.40),
                    PixelFrostedGlassEggPalette.aqua.opacity(0.20),
                    PixelFrostedGlassEggPalette.deepBlue.opacity(0.08),
                    Color.white.opacity(0)
                ]),
                center: CGPoint(x: volume.midX, y: fillTop + rect.height * 0.03),
                startRadius: 1,
                endRadius: rect.width * 0.46
            )
        )
        context.fill(
            Path(volume),
            with: .linearGradient(
                Gradient(colors: [
                    Color.white.opacity(0.05),
                    PixelFrostedGlassEggPalette.aqua.opacity(0.18),
                    PixelFrostedGlassEggPalette.shellBlue.opacity(0.32),
                    PixelFrostedGlassEggPalette.deepBlue.opacity(0.20)
                ]),
                startPoint: CGPoint(x: volume.midX, y: volume.minY),
                endPoint: CGPoint(x: volume.midX, y: volume.maxY)
            )
        )
    }

    private func drawWaterline(in context: inout GraphicsContext, rect: CGRect, fillTop: CGFloat, grid: CGFloat) {
        let width = rect.width * 0.66
        let line = CGRect(x: rect.midX - width / 2, y: fillTop - grid * 0.16, width: width, height: max(1, grid * 0.16))
        context.fill(
            Path(roundedRect: line, cornerRadius: line.height / 2),
            with: .linearGradient(
                Gradient(colors: [
                    Color.white.opacity(0),
                    Color.white.opacity(0.58),
                    PixelFrostedGlassEggPalette.aqua.opacity(0.36),
                    Color.white.opacity(0)
                ]),
                startPoint: CGPoint(x: line.minX, y: line.midY),
                endPoint: CGPoint(x: line.maxX, y: line.midY)
            )
        )

        let columns = 19
        for index in 0..<columns {
            let seed = unitRandom(index * 31 + 9)
            let x = rect.minX + rect.width * (0.17 + CGFloat(index) / CGFloat(columns - 1) * 0.66)
            let y = fillTop + (seed - 0.5) * grid * 1.3
            let block = CGRect(x: x, y: y, width: grid * 0.76, height: grid * 0.48)
            context.fill(Path(roundedRect: block, cornerRadius: grid * 0.06), with: .color(Color.white.opacity(0.16 + Double(seed) * 0.18)))
        }
    }

    private func drawGaugeLines(in context: inout GraphicsContext, rect: CGRect, grid: CGFloat) {
        for marker in [CGFloat(0.25), CGFloat(0.50), CGFloat(0.75)] {
            let y = rect.maxY - rect.height * marker
            let width = rect.width * (marker == 0.50 ? 0.40 : 0.28)
            let line = CGRect(x: rect.midX - width / 2, y: y, width: width, height: max(0.7, grid * 0.10))
            context.fill(Path(roundedRect: line, cornerRadius: line.height / 2), with: .color(Color.white.opacity(marker == 0.50 ? 0.13 : 0.08)))
        }
    }

    private func drawCenterGrowth(
        in context: inout GraphicsContext,
        eggPath: Path,
        rect: CGRect,
        grid: CGFloat,
        highlightTopic: EnergyCrystalTopic,
        progress: CGFloat,
        active: Double,
        reduceMotion: Bool
    ) {
        guard active > 0 else { return }
        let center = CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.58)
        let glowStrength = max(0, 1 - abs(progress - 0.22) / 0.25)
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - rect.width * 0.22, y: center.y - rect.height * 0.12, width: rect.width * 0.44, height: rect.height * 0.24)),
            with: .radialGradient(
                Gradient(colors: [
                    highlightTopic.softAccent.opacity(Double(glowStrength) * 0.50),
                    Color.white.opacity(Double(glowStrength) * 0.28),
                    Color.white.opacity(0)
                ]),
                center: center,
                startRadius: grid,
                endRadius: rect.width * 0.28
            )
        )

        let topics: [EnergyCrystalTopic] = [highlightTopic, .sleep, .recovery, .nutrition, .activity, .periodMood]
        for index in 0..<6 {
            let angle = CGFloat(index) / 6 * .pi * 2 + unitRandom(index * 29 + 3) * 0.8
            let distance = reduceMotion ? grid * 1.3 : grid * (1.4 + progress * 7.4)
            let settle = reduceMotion ? 0 : grid * progress * progress * 6.2
            let point = CGPoint(
                x: center.x + cos(angle) * distance * (0.75 + unitRandom(index * 11 + 7) * 0.45),
                y: center.y + sin(angle) * distance * 0.52 + settle
            )
            guard eggPath.contains(point) else { continue }
            drawCrystal(
                in: &context,
                center: point,
                block: grid * (0.66 + unitRandom(index * 17 + 5) * 0.22),
                topic: topics[index],
                highlighted: true,
                depth: 0.82,
                seed: 400 + index,
                opacity: 1 - Double(progress) * 0.12
            )
        }
    }

    private func drawCrystal(
        in context: inout GraphicsContext,
        center: CGPoint,
        block: CGFloat,
        topic: EnergyCrystalTopic,
        highlighted: Bool,
        depth: CGFloat,
        seed: Int,
        opacity: Double
    ) {
        let accent = topic.accent
        let soft = topic.softAccent
        let b = block * (highlighted ? 1.10 : 0.98)
        let baseOpacity = opacity * (highlighted ? 0.86 : 0.50 + Double(depth) * 0.18)
        let offsets: [(CGFloat, CGFloat, CGFloat, Double)] = [
            (0, 0, 1.08, baseOpacity),
            (-0.78, 0.02, 0.76, baseOpacity * 0.82),
            (0.78, -0.02, 0.76, baseOpacity * 0.78),
            (0, -0.78, 0.70, baseOpacity * 0.70),
            (0, 0.78, 0.80, baseOpacity * 0.66),
            (-0.52, -0.54, 0.50, baseOpacity * 0.50),
            (0.55, 0.54, 0.48, baseOpacity * 0.46)
        ]

        var crystalContext = context
        crystalContext.addFilter(.shadow(color: accent.opacity((highlighted ? 0.48 : 0.20) * opacity), radius: b * (0.75 + depth * 0.30), x: 0, y: 0))

        for (index, item) in offsets.enumerated() {
            if index > 4 && unitRandom(seed * 13 + index) < 0.30 { continue }
            let rect = CGRect(
                x: center.x + item.0 * b - b * item.2 / 2,
                y: center.y + item.1 * b - b * item.2 / 2,
                width: b * item.2,
                height: b * item.2
            )
            let color = index == 0 ? soft : accent
            crystalContext.fill(Path(roundedRect: rect, cornerRadius: max(0.5, b * 0.075)), with: .color(color.opacity(item.3)))
            if index == 0 {
                let spark = CGRect(x: rect.midX - b * 0.11, y: rect.midY - b * 0.11, width: b * 0.22, height: b * 0.22)
                context.fill(Path(spark), with: .color(Color.white.opacity(0.55 * opacity)))
            }
        }
    }

    private func unitRandom(_ seed: Int) -> CGFloat {
        let value = sin(Double(seed) * 12.9898) * 43758.5453123
        return CGFloat(value - floor(value))
    }
}

private struct PixelFrostedFrostVolume: View {
    let time: TimeInterval

    var body: some View {
        Canvas { context, size in
            let rect = PixelFrostedEggGeometry.innerRect(in: size)
            let eggPath = PixelFrostedEggGeometry.eggPath(in: rect)
            context.drawLayer { layer in
                layer.clip(to: eggPath)
                layer.fill(
                    eggPath,
                    with: .radialGradient(
                        Gradient(colors: [
                            Color.white.opacity(0.28),
                            PixelFrostedGlassEggPalette.frost.opacity(0.16),
                            PixelFrostedGlassEggPalette.shellBlue.opacity(0.06),
                            Color.white.opacity(0.03)
                        ]),
                        center: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.30),
                        startRadius: 4,
                        endRadius: rect.width * 0.78
                    )
                )

                let upperFog = CGRect(x: rect.minX + rect.width * 0.10, y: rect.minY + rect.height * 0.04, width: rect.width * 0.80, height: rect.height * 0.46)
                layer.fill(
                    Path(ellipseIn: upperFog),
                    with: .radialGradient(
                        Gradient(colors: [
                            Color.white.opacity(0.34),
                            Color.white.opacity(0.14),
                            Color.white.opacity(0)
                        ]),
                        center: CGPoint(x: upperFog.midX, y: upperFog.minY + upperFog.height * 0.20),
                        startRadius: 1,
                        endRadius: upperFog.width * 0.56
                    )
                )

                for row in 0..<17 {
                    for col in 0..<13 {
                        let jitter = unitRandom(row * 57 + col * 31)
                        guard jitter > 0.46 else { continue }
                        let block = max(2.2, size.width * 0.012)
                        let x = rect.minX + rect.width * (0.16 + CGFloat(col) / 12 * 0.68)
                        let y = rect.minY + rect.height * (0.11 + CGFloat(row) / 16 * 0.70)
                        let point = CGPoint(x: x, y: y)
                        guard eggPath.contains(point) else { continue }
                        let opacity = 0.025 + Double(jitter) * 0.045
                        layer.fill(Path(CGRect(x: x, y: y, width: block, height: block)), with: .color(Color.white.opacity(opacity)))
                    }
                }
            }
        }
    }

    private func unitRandom(_ seed: Int) -> CGFloat {
        let value = sin(Double(seed) * 12.9898) * 43758.5453123
        return CGFloat(value - floor(value))
    }
}

private struct PixelFrostedFrontGlassShell: View {
    let time: TimeInterval

    var body: some View {
        Canvas { context, size in
            let rect = PixelFrostedEggGeometry.innerRect(in: size)
            let eggPath = PixelFrostedEggGeometry.eggPath(in: rect)
            let inner = PixelFrostedEggGeometry.eggPath(in: rect.insetBy(dx: rect.width * 0.065, dy: rect.height * 0.035))

            context.drawLayer { layer in
                layer.clip(to: eggPath)
                layer.fill(
                    eggPath,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color.white.opacity(0.34),
                            PixelFrostedGlassEggPalette.frost.opacity(0.11),
                            Color.white.opacity(0.04),
                            PixelFrostedGlassEggPalette.shellBlue.opacity(0.10)
                        ]),
                        startPoint: CGPoint(x: rect.minX, y: rect.minY),
                        endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
                    )
                )
                layer.stroke(inner, with: .color(Color.white.opacity(0.24)), lineWidth: max(1.0, size.width * 0.006))
            }

            context.stroke(eggPath, with: .color(Color.white.opacity(0.86)), lineWidth: max(1.2, size.width * 0.010))
            context.stroke(eggPath, with: .color(PixelFrostedGlassEggPalette.rimBlue.opacity(0.52)), lineWidth: max(3.2, size.width * 0.022))
            context.stroke(eggPath, with: .color(Color.white.opacity(0.30)), lineWidth: max(7.0, size.width * 0.040))

            let leftSpecular = CGRect(x: rect.minX + rect.width * 0.18, y: rect.minY + rect.height * 0.10, width: rect.width * 0.34, height: rect.height * 0.18)
            context.fill(Path(ellipseIn: leftSpecular), with: .color(Color.white.opacity(0.24)))

            let pixelHighlights = [
                CGRect(x: rect.minX + rect.width * 0.26, y: rect.minY + rect.height * 0.13, width: size.width * 0.048, height: size.width * 0.048),
                CGRect(x: rect.minX + rect.width * 0.36, y: rect.minY + rect.height * 0.12, width: size.width * 0.035, height: size.width * 0.035),
                CGRect(x: rect.minX + rect.width * 0.48, y: rect.minY + rect.height * 0.03, width: size.width * 0.090, height: size.width * 0.030),
                CGRect(x: rect.maxX - rect.width * 0.22, y: rect.minY + rect.height * 0.54, width: size.width * 0.038, height: size.width * 0.12)
            ]
            for highlight in pixelHighlights {
                context.fill(Path(roundedRect: highlight, cornerRadius: 1.2), with: .color(Color.white.opacity(0.38)))
            }
        }
    }
}

private struct PixelFrostedPixelVoxelRim: View {
    let time: TimeInterval

    var body: some View {
        Canvas { context, size in
            let rect = PixelFrostedEggGeometry.innerRect(in: size)
            let eggPath = PixelFrostedEggGeometry.eggPath(in: rect)
        let block = max(4.8, size.width * 0.032)
            context.drawLayer { layer in
                layer.clip(to: eggPath)
                for index in 0..<128 {
                    let sample = PixelFrostedEggGeometry.outlineSample(rect: rect, progress: CGFloat(index) / 128)
                    let seed = unitRandom(index * 37 + 9)
                    let inset = block * (0.30 + seed * 0.86)
                    let inward = CGVector(dx: rect.midX - sample.point.x, dy: rect.midY - sample.point.y)
                    let inwardLength = max(1, sqrt(inward.dx * inward.dx + inward.dy * inward.dy))
                    let point = CGPoint(
                        x: sample.point.x + inward.dx / inwardLength * inset,
                        y: sample.point.y + inward.dy / inwardLength * inset
                    )
                    guard eggPath.contains(point) else { continue }

                    let sizeJitter = block * (0.74 + unitRandom(index * 53 + 5) * 0.54)
                    let rectBlock = CGRect(x: point.x - sizeJitter / 2, y: point.y - sizeJitter / 2, width: sizeJitter, height: sizeJitter)
                    let color: Color
                    if seed < 0.30 {
                        color = Color.white
                    } else if seed < 0.76 {
                        color = PixelFrostedGlassEggPalette.shellBlue
                    } else {
                        color = PixelFrostedGlassEggPalette.rimBlue
                    }
                    let opacity = 0.24 + Double(seed) * 0.42
                    layer.fill(Path(roundedRect: rectBlock, cornerRadius: max(0.8, block * 0.10)), with: .color(color.opacity(opacity)))

                    let shine = CGRect(x: rectBlock.minX + rectBlock.width * 0.12, y: rectBlock.minY + rectBlock.height * 0.10, width: rectBlock.width * 0.36, height: rectBlock.height * 0.22)
                    layer.fill(Path(roundedRect: shine, cornerRadius: 0.8), with: .color(Color.white.opacity(0.18 + Double(seed) * 0.12)))

                    if index % 4 == 0 {
                        let shadow = CGRect(x: rectBlock.minX + rectBlock.width * 0.52, y: rectBlock.minY + rectBlock.height * 0.58, width: rectBlock.width * 0.36, height: rectBlock.height * 0.30)
                        layer.fill(Path(shadow), with: .color(PixelFrostedGlassEggPalette.deepBlue.opacity(0.08)))
                    }
                }
            }
        }
    }

    private func unitRandom(_ seed: Int) -> CGFloat {
        let value = sin(Double(seed) * 12.9898) * 43758.5453123
        return CGFloat(value - floor(value))
    }
}

private struct PixelFrostedPixelStars: View {
    var body: some View {
        Canvas { context, size in
            let rect = PixelFrostedEggGeometry.innerRect(in: size)
            let eggPath = PixelFrostedEggGeometry.eggPath(in: rect)
            let block = max(3.4, size.width * 0.018)
            let stars: [(CGFloat, CGFloat, CGFloat)] = [
                (0.37, 0.33, 1.00),
                (0.67, 0.46, 0.88),
                (0.28, 0.66, 1.02),
                (0.73, 0.75, 0.80),
                (0.17, 0.53, 0.72),
                (0.84, 0.59, 0.72)
            ]
            context.drawLayer { layer in
                layer.clip(to: eggPath)
                for (x, y, scale) in stars {
                    let center = CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
                    drawStar(in: &layer, center: center, block: block * scale, eggPath: eggPath)
                }
            }
        }
    }

    private func drawStar(in context: inout GraphicsContext, center: CGPoint, block: CGFloat, eggPath: Path) {
        let offsets: [(CGFloat, CGFloat, Double)] = [
            (0, -2, 0.34), (0, -1, 0.62),
            (-2, 0, 0.34), (-1, 0, 0.68), (0, 0, 0.88), (1, 0, 0.68), (2, 0, 0.34),
            (0, 1, 0.62), (0, 2, 0.34),
            (-1, -1, 0.28), (1, -1, 0.28), (-1, 1, 0.28), (1, 1, 0.28)
        ]
        for (dx, dy, opacity) in offsets {
            let rect = CGRect(x: center.x + dx * block - block / 2, y: center.y + dy * block - block / 2, width: block, height: block)
            guard eggPath.contains(CGPoint(x: rect.midX, y: rect.midY)) else { continue }
            context.fill(Path(roundedRect: rect, cornerRadius: block * 0.12), with: .color(PixelFrostedGlassEggPalette.deepBlue.opacity(opacity)))
            if dx == 0 && dy == 0 {
                context.fill(Path(CGRect(x: rect.midX - block * 0.16, y: rect.midY - block * 0.16, width: block * 0.32, height: block * 0.32)), with: .color(Color.white.opacity(0.52)))
            }
        }
    }
}

private struct PixelFrostedShineSweep: View {
    let time: TimeInterval
    let reduceMotion: Bool

    var body: some View {
        Canvas { context, size in
            let rect = PixelFrostedEggGeometry.innerRect(in: size)
            let eggPath = PixelFrostedEggGeometry.eggPath(in: rect)
            context.drawLayer { layer in
                layer.clip(to: eggPath)
                guard !reduceMotion else { return }
                let period = 4.6
                let progress = CGFloat(time.truncatingRemainder(dividingBy: period) / period)
                let sweepX = rect.minX - rect.width * 0.46 + progress * rect.width * 1.78
                var sweep = Path()
                sweep.move(to: CGPoint(x: sweepX, y: rect.minY - rect.height * 0.06))
                sweep.addLine(to: CGPoint(x: sweepX + rect.width * 0.18, y: rect.minY - rect.height * 0.06))
                sweep.addLine(to: CGPoint(x: sweepX + rect.width * 0.58, y: rect.maxY + rect.height * 0.06))
                sweep.addLine(to: CGPoint(x: sweepX + rect.width * 0.36, y: rect.maxY + rect.height * 0.06))
                sweep.closeSubpath()
                layer.fill(
                    sweep,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.34),
                            PixelFrostedGlassEggPalette.shellBlue.opacity(0.15),
                            Color.white.opacity(0)
                        ]),
                        startPoint: CGPoint(x: sweepX, y: rect.midY),
                        endPoint: CGPoint(x: sweepX + rect.width * 0.50, y: rect.midY)
                    )
                )
            }
        }
    }
}

private struct PixelFrostedBottomGlow: View {
    let highlightTopic: EnergyCrystalTopic
    let time: TimeInterval

    var body: some View {
        Canvas { context, size in
            let rect = PixelFrostedEggGeometry.innerRect(in: size)
            let eggPath = PixelFrostedEggGeometry.eggPath(in: rect)
            let pulse = 0.84 + sin(time * .pi * 2 / 3.8) * 0.10
            context.drawLayer { layer in
                layer.clip(to: eggPath)
                let glow = CGRect(
                    x: rect.minX + rect.width * 0.14,
                    y: rect.maxY - rect.height * 0.22,
                    width: rect.width * 0.72,
                    height: rect.height * 0.20
                )
                layer.fill(
                    Path(ellipseIn: glow),
                    with: .radialGradient(
                        Gradient(colors: [
                            highlightTopic.softAccent.opacity(0.22 * pulse),
                            PixelFrostedGlassEggPalette.aqua.opacity(0.18 * pulse),
                            Color.white.opacity(0)
                        ]),
                        center: CGPoint(x: glow.midX, y: glow.midY),
                        startRadius: 1,
                        endRadius: glow.width * 0.52
                    )
                )
            }
        }
    }
}

private struct PixelFrostedExpressionLayer: View {
    let expression: PixelEggExpression

    var body: some View {
        Canvas { context, size in
            let rect = PixelFrostedEggGeometry.innerRect(in: size)
            let scale = min(size.width / 260, size.height / 340)
            let eyeY = rect.minY + rect.height * 0.47
            let leftX = rect.minX + rect.width * 0.34
            let rightX = rect.minX + rect.width * 0.58
            let deepBlue = PixelFrostedGlassEggPalette.deepBlue

            switch expression {
            case .wideBright, .halfOpen:
                let eyeHeight = expression == .wideBright ? 14 * scale : 9 * scale
                let left = CGRect(x: leftX, y: eyeY, width: 14 * scale, height: eyeHeight)
                let right = CGRect(x: rightX, y: eyeY, width: 14 * scale, height: eyeHeight)
                context.fill(Path(roundedRect: left, cornerRadius: 2 * scale), with: .color(deepBlue.opacity(0.76)))
                context.fill(Path(roundedRect: right, cornerRadius: 2 * scale), with: .color(deepBlue.opacity(0.76)))
                context.fill(Path(CGRect(x: left.maxX - 5 * scale, y: left.minY + 2 * scale, width: 3.5 * scale, height: 3.5 * scale)), with: .color(Color.white.opacity(0.82)))
                context.fill(Path(CGRect(x: right.maxX - 5 * scale, y: right.minY + 2 * scale, width: 3.5 * scale, height: 3.5 * scale)), with: .color(Color.white.opacity(0.82)))
            case .closedSparkle, .sleepyBlush, .closedQuiet:
                let eyeWidth = 22 * scale
                let eyeHeight = 5.5 * scale
                let left = CGRect(x: leftX, y: eyeY + 8 * scale, width: eyeWidth, height: eyeHeight)
                let right = CGRect(x: rightX, y: eyeY + 8 * scale, width: eyeWidth, height: eyeHeight)
                context.fill(Path(roundedRect: left, cornerRadius: eyeHeight / 2), with: .color(deepBlue.opacity(0.78)))
                context.fill(Path(roundedRect: right, cornerRadius: eyeHeight / 2), with: .color(deepBlue.opacity(0.78)))
                context.fill(Path(CGRect(x: left.minX + 3 * scale, y: left.minY - 1 * scale, width: 7 * scale, height: 2 * scale)), with: .color(Color.white.opacity(0.56)))
                context.fill(Path(CGRect(x: right.minX + 3 * scale, y: right.minY - 1 * scale, width: 7 * scale, height: 2 * scale)), with: .color(Color.white.opacity(0.56)))
            }

            if expression != .wideBright {
                let blush = Color(red: 241 / 255, green: 186 / 255, blue: 214 / 255)
                let blushW = 10 * scale
                let blushH = 4.5 * scale
                context.fill(Path(roundedRect: CGRect(x: rect.minX + rect.width * 0.30, y: rect.minY + rect.height * 0.58, width: blushW, height: blushH), cornerRadius: blushH / 2), with: .color(blush.opacity(0.30)))
                context.fill(Path(roundedRect: CGRect(x: rect.minX + rect.width * 0.67, y: rect.minY + rect.height * 0.58, width: blushW, height: blushH), cornerRadius: blushH / 2), with: .color(blush.opacity(0.30)))
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Pixel Glass Egg Container

struct PixelGlassEggContainer: View {
    var size: CGSize = CGSize(width: 280, height: 360)
    var fillProgress: Double = 0.6
    var expression: PixelEggExpression? = nil
    var highlightTopic: EnergyCrystalTopic = .energy
    var growthPulseID: Int = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var tapDate = Date.distantPast
    @State private var growthDate = Date.distantPast

    private var clampedFillProgress: Double {
        min(max(fillProgress, 0), 1)
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let tapAge = timeline.date.timeIntervalSince(tapDate)
            let tapPulse = reduceMotion ? 0 : max(0, 1 - tapAge / 0.62)
            let breath = reduceMotion ? 0 : sin(time * .pi * 2 / 3.2) * 0.012
            let growthAge = timeline.date.timeIntervalSince(growthDate)
            let growthActive = growthAge < 1.45 ? 1.0 : 0.0
            let growthProgress = growthActive > 0 ? min(max(growthAge / 1.45, 0), 1) : 1

            Canvas { context, canvasSize in
                PixelGlassEggRenderer.draw(
                    in: &context,
                    canvasSize: canvasSize,
                    fillProgress: clampedFillProgress,
                    expression: expression,
                    highlightTopic: highlightTopic,
                    growthProgress: reduceMotion && growthActive > 0 ? 0.55 : growthProgress,
                    growthActive: growthActive,
                    time: reduceMotion ? 0 : time,
                    tapPulse: tapPulse,
                    reduceMotion: reduceMotion
                )
            }
            .frame(width: size.width, height: size.height)
            .scaleEffect(1 + breath + tapPulse * 0.045)
            .animation(reduceMotion ? nil : .spring(response: 0.22, dampingFraction: 0.58), value: tapDate)
        }
        .frame(width: size.width, height: size.height)
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                tapDate = Date()
                growthDate = Date()
            }
        )
        .onChange(of: growthPulseID) {
            growthDate = Date()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("蓝晶像素玻璃蛋，今日恢复资源填充约 \(Int(clampedFillProgress * 100))%")
        .accessibilityIdentifier("pixel.glassEgg.container")
    }
}

private enum PixelGlassEggRenderer {
    private static let shellBlue = Color(red: 146 / 255, green: 211 / 255, blue: 255 / 255)
    private static let rimBlue = Color(red: 61 / 255, green: 155 / 255, blue: 235 / 255)
    private static let deepBlue = Color(red: 35 / 255, green: 118 / 255, blue: 221 / 255)
    private static let aqua = Color(red: 86 / 255, green: 229 / 255, blue: 238 / 255)
    private static let lavender = Color(red: 158 / 255, green: 163 / 255, blue: 255 / 255)

    private struct EnergyCrystal {
        let topic: EnergyCrystalTopic
        let xRatio: CGFloat
        let yRatio: CGFloat
        let sizeRatio: CGFloat
        let seed: Int
    }

    static func draw(
        in context: inout GraphicsContext,
        canvasSize: CGSize,
        fillProgress: Double,
        expression: PixelEggExpression?,
        highlightTopic: EnergyCrystalTopic,
        growthProgress: Double,
        growthActive: Double,
        time: TimeInterval,
        tapPulse: Double,
        reduceMotion: Bool
    ) {
        let width = canvasSize.width
        let height = canvasSize.height
        let scale = min(width / 280, height / 360)
        let eggRect = CGRect(
            x: width * 0.105,
            y: height * 0.07,
            width: width * 0.79,
            height: height * 0.79
        )
        let eggPath = eggPath(in: eggRect)
        let grid = max(3.6, 7.4 * scale)
        let visibleFill = min(1, max(0, fillProgress + growthActive * 0.012 * (1 - growthProgress)))
        let fillTop = eggRect.maxY - eggRect.height * CGFloat(visibleFill)

        drawBackground(in: &context, size: canvasSize, eggRect: eggRect, scale: scale)
        drawInterior(
            in: &context,
            eggPath: eggPath,
            eggRect: eggRect,
            fillTop: fillTop,
            grid: grid,
            highlightTopic: highlightTopic,
            growthProgress: growthProgress,
            growthActive: growthActive,
            time: time,
            tapPulse: tapPulse,
            reduceMotion: reduceMotion
        )
        drawShell(in: &context, eggPath: eggPath, eggRect: eggRect, scale: scale)
        drawPixelGrid(in: &context, eggPath: eggPath, eggRect: eggRect, grid: grid)
        drawVoxelRim(in: &context, eggPath: eggPath, eggRect: eggRect, grid: grid, scale: scale)
        drawStars(in: &context, eggPath: eggPath, eggRect: eggRect, block: max(3.6, grid * 0.74))
        drawHighlights(in: &context, eggPath: eggPath, eggRect: eggRect, scale: scale, time: time, reduceMotion: reduceMotion)

        if let expression {
            drawExpression(expression, in: &context, eggRect: eggRect, scale: scale)
        }
    }

    private static func eggPath(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.01))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.05, y: rect.minY + rect.height * 0.58),
            control1: CGPoint(x: rect.minX + rect.width * 0.28, y: rect.minY - rect.height * 0.01),
            control2: CGPoint(x: rect.minX + rect.width * 0.05, y: rect.minY + rect.height * 0.30)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.minX + rect.width * 0.04, y: rect.minY + rect.height * 0.86),
            control2: CGPoint(x: rect.minX + rect.width * 0.24, y: rect.maxY)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX - rect.width * 0.05, y: rect.minY + rect.height * 0.58),
            control1: CGPoint(x: rect.maxX - rect.width * 0.24, y: rect.maxY),
            control2: CGPoint(x: rect.maxX - rect.width * 0.04, y: rect.minY + rect.height * 0.86)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.01),
            control1: CGPoint(x: rect.maxX - rect.width * 0.05, y: rect.minY + rect.height * 0.30),
            control2: CGPoint(x: rect.maxX - rect.width * 0.28, y: rect.minY - rect.height * 0.01)
        )
        path.closeSubpath()
        return path
    }

    private static func drawBackground(in context: inout GraphicsContext, size: CGSize, eggRect: CGRect, scale: CGFloat) {
        let auraRect = eggRect.insetBy(dx: -eggRect.width * 0.26, dy: -eggRect.height * 0.18)
        context.fill(
            Path(ellipseIn: auraRect),
            with: .radialGradient(
                Gradient(colors: [
                    Color.white.opacity(0.46),
                    Color(red: 232 / 255, green: 244 / 255, blue: 255 / 255).opacity(0.24),
                    Color(red: 248 / 255, green: 252 / 255, blue: 255 / 255).opacity(0),
                ]),
                center: CGPoint(x: size.width * 0.48, y: size.height * 0.38),
                startRadius: 6 * scale,
                endRadius: max(size.width, size.height) * 0.54
            )
        )

        let glowRect = CGRect(
            x: eggRect.minX - eggRect.width * 0.10,
            y: eggRect.maxY - eggRect.height * 0.12,
            width: eggRect.width * 1.20,
            height: eggRect.height * 0.26
        )
        var glowContext = context
        glowContext.addFilter(.shadow(color: shellBlue.opacity(0.30), radius: 28 * scale, x: 0, y: 14 * scale))
        glowContext.fill(Path(ellipseIn: glowRect), with: .color(shellBlue.opacity(0.20)))
        context.fill(
            Path(ellipseIn: glowRect.insetBy(dx: glowRect.width * 0.12, dy: glowRect.height * 0.24)),
            with: .color(Color.white.opacity(0.45))
        )
    }

    private static func drawInterior(
        in context: inout GraphicsContext,
        eggPath: Path,
        eggRect: CGRect,
        fillTop: CGFloat,
        grid: CGFloat,
        highlightTopic: EnergyCrystalTopic,
        growthProgress: Double,
        growthActive: Double,
        time: TimeInterval,
        tapPulse: Double,
        reduceMotion: Bool
    ) {
        context.drawLayer { layer in
            layer.clip(to: eggPath)

            drawInteriorGaugeLines(in: &layer, eggRect: eggRect, grid: grid)

            let fillRect = CGRect(
                x: eggRect.minX - grid,
                y: fillTop,
                width: eggRect.width + grid * 2,
                height: eggRect.maxY - fillTop + grid
            )

            layer.fill(
                Path(fillRect),
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.28),
                        aqua.opacity(0.38),
                        shellBlue.opacity(0.46),
                        deepBlue.opacity(0.34),
                    ]),
                    startPoint: CGPoint(x: fillRect.midX, y: fillRect.minY),
                    endPoint: CGPoint(x: fillRect.midX, y: fillRect.maxY)
                )
            )

            drawCrystalWaterline(in: &layer, eggRect: eggRect, fillTop: fillTop, grid: grid)
            drawEnergyCrystals(
                in: &layer,
                eggPath: eggPath,
                eggRect: eggRect,
                fillTop: fillTop,
                grid: grid,
                highlightTopic: highlightTopic,
                time: time,
                tapPulse: tapPulse
            )
            drawCenterEmergence(
                in: &layer,
                eggPath: eggPath,
                eggRect: eggRect,
                grid: grid,
                highlightTopic: highlightTopic,
                growthProgress: growthProgress,
                growthActive: growthActive,
                reduceMotion: reduceMotion
            )
        }
    }

    private static func drawInteriorGaugeLines(in context: inout GraphicsContext, eggRect: CGRect, grid: CGFloat) {
        for marker in [CGFloat(0.25), CGFloat(0.50), CGFloat(0.75)] {
            let y = eggRect.maxY - eggRect.height * marker
            let lineWidth = eggRect.width * (marker == 0.50 ? 0.42 : 0.32)
            let line = CGRect(
                x: eggRect.midX - lineWidth / 2,
                y: y,
                width: lineWidth,
                height: max(0.8, grid * 0.12)
            )
            context.fill(
                Path(roundedRect: line, cornerRadius: line.height / 2),
                with: .color(Color.white.opacity(marker == 0.50 ? 0.17 : 0.11))
            )
        }
    }

    private static func drawCrystalWaterline(in context: inout GraphicsContext, eggRect: CGRect, fillTop: CGFloat, grid: CGFloat) {
        let width = eggRect.width * 0.70
        let lineRect = CGRect(
            x: eggRect.midX - width / 2,
            y: fillTop - grid * 0.18,
            width: width,
            height: max(1.0, grid * 0.18)
        )
        context.fill(
            Path(roundedRect: lineRect, cornerRadius: lineRect.height / 2),
            with: .linearGradient(
                Gradient(colors: [
                    Color.white.opacity(0.0),
                    Color.white.opacity(0.60),
                    aqua.opacity(0.38),
                    Color.white.opacity(0.0),
                ]),
                startPoint: CGPoint(x: lineRect.minX, y: lineRect.midY),
                endPoint: CGPoint(x: lineRect.maxX, y: lineRect.midY)
            )
        )

        let startColumn = Int((eggRect.minX + eggRect.width * 0.18) / grid)
        let endColumn = Int((eggRect.maxX - eggRect.width * 0.18) / grid)
        for column in startColumn...endColumn {
            let seed = unitRandom(column * 73 + 19)
            let x = CGFloat(column) * grid
            let y = fillTop + (seed - 0.5) * grid * 1.5
            let rect = CGRect(x: x, y: y, width: grid * 0.92, height: grid * 0.58)
            context.fill(Path(rect), with: .color(Color.white.opacity(0.20 + Double(seed) * 0.16)))
        }
    }

    private static func drawEnergyCrystals(
        in context: inout GraphicsContext,
        eggPath: Path,
        eggRect: CGRect,
        fillTop: CGFloat,
        grid: CGFloat,
        highlightTopic: EnergyCrystalTopic,
        time: TimeInterval,
        tapPulse: Double
    ) {
        let crystals: [EnergyCrystal] = [
            EnergyCrystal(topic: .sleep, xRatio: 0.24, yRatio: 0.40, sizeRatio: 1.18, seed: 11),
            EnergyCrystal(topic: .recovery, xRatio: 0.36, yRatio: 0.42, sizeRatio: 1.02, seed: 19),
            EnergyCrystal(topic: .nutrition, xRatio: 0.52, yRatio: 0.41, sizeRatio: 1.12, seed: 23),
            EnergyCrystal(topic: .sleep, xRatio: 0.66, yRatio: 0.45, sizeRatio: 1.05, seed: 31),
            EnergyCrystal(topic: .periodMood, xRatio: 0.42, yRatio: 0.49, sizeRatio: 0.98, seed: 37),
            EnergyCrystal(topic: .activity, xRatio: 0.57, yRatio: 0.51, sizeRatio: 1.02, seed: 41),
            EnergyCrystal(topic: .energy, xRatio: 0.73, yRatio: 0.52, sizeRatio: 1.12, seed: 47),
            EnergyCrystal(topic: .sleep, xRatio: 0.29, yRatio: 0.68, sizeRatio: 1.34, seed: 53),
            EnergyCrystal(topic: .recovery, xRatio: 0.48, yRatio: 0.69, sizeRatio: 1.22, seed: 59),
            EnergyCrystal(topic: .nutrition, xRatio: 0.63, yRatio: 0.70, sizeRatio: 1.08, seed: 61),
            EnergyCrystal(topic: .activity, xRatio: 0.38, yRatio: 0.75, sizeRatio: 1.18, seed: 67),
            EnergyCrystal(topic: .periodMood, xRatio: 0.57, yRatio: 0.76, sizeRatio: 1.30, seed: 71),
            EnergyCrystal(topic: .sleep, xRatio: 0.71, yRatio: 0.77, sizeRatio: 1.20, seed: 79),
            EnergyCrystal(topic: .energy, xRatio: 0.22, yRatio: 0.82, sizeRatio: 1.06, seed: 83),
            EnergyCrystal(topic: .recovery, xRatio: 0.34, yRatio: 0.84, sizeRatio: 1.34, seed: 89),
            EnergyCrystal(topic: .sleep, xRatio: 0.49, yRatio: 0.84, sizeRatio: 1.26, seed: 97),
            EnergyCrystal(topic: .nutrition, xRatio: 0.63, yRatio: 0.85, sizeRatio: 1.22, seed: 101),
            EnergyCrystal(topic: .activity, xRatio: 0.77, yRatio: 0.84, sizeRatio: 0.98, seed: 103),
            EnergyCrystal(topic: .periodMood, xRatio: 0.29, yRatio: 0.90, sizeRatio: 1.02, seed: 107),
            EnergyCrystal(topic: .sleep, xRatio: 0.44, yRatio: 0.91, sizeRatio: 1.16, seed: 109),
            EnergyCrystal(topic: .recovery, xRatio: 0.60, yRatio: 0.91, sizeRatio: 1.12, seed: 113),
            EnergyCrystal(topic: .nutrition, xRatio: 0.72, yRatio: 0.90, sizeRatio: 1.06, seed: 127)
        ]

        for crystal in crystals {
            let bob = sin(time * 1.2 + Double(crystal.seed) * 0.43) * Double(grid) * 0.20
            let burst = CGFloat(tapPulse) * (unitRandom(crystal.seed * 5) - 0.5) * grid * 3.2
            let center = CGPoint(
                x: eggRect.minX + eggRect.width * crystal.xRatio + burst,
                y: eggRect.minY + eggRect.height * crystal.yRatio + CGFloat(bob) + CGFloat(tapPulse) * grid * 0.8
            )

            guard center.y >= fillTop - grid * 1.4, eggPath.contains(center) else { continue }
            let isHighlighted = crystal.topic == highlightTopic || (highlightTopic == .energy && crystal.topic == .recovery)
            drawEnergyCrystalCluster(
                in: &context,
                center: center,
                block: grid * crystal.sizeRatio * 1.22,
                topic: crystal.topic,
                isHighlighted: isHighlighted,
                seed: crystal.seed
            )
        }
    }

    private static func drawCenterEmergence(
        in context: inout GraphicsContext,
        eggPath: Path,
        eggRect: CGRect,
        grid: CGFloat,
        highlightTopic: EnergyCrystalTopic,
        growthProgress: Double,
        growthActive: Double,
        reduceMotion: Bool
    ) {
        guard growthActive > 0 else { return }

        let progress = CGFloat(growthProgress)
        let center = CGPoint(x: eggRect.midX, y: eggRect.minY + eggRect.height * 0.61)
        let glowStrength = max(0, 1 - abs(Double(progress) - 0.20) / 0.28)
        if glowStrength > 0.01 {
            let glowRect = CGRect(
                x: center.x - eggRect.width * 0.30,
                y: center.y - eggRect.height * 0.16,
                width: eggRect.width * 0.60,
                height: eggRect.height * 0.32
            )
            context.fill(
                Path(ellipseIn: glowRect),
                with: .radialGradient(
                    Gradient(colors: [
                        highlightTopic.softAccent.opacity(0.42 * glowStrength),
                        Color.white.opacity(0.22 * glowStrength),
                        Color.white.opacity(0)
                    ]),
                    center: center,
                    startRadius: grid,
                    endRadius: eggRect.width * 0.33
                )
            )
        }

        let topics: [EnergyCrystalTopic] = [highlightTopic, .sleep, .recovery, .nutrition, .periodMood, .activity, .energy]
        for index in 0..<7 {
            let angle = CGFloat(index) / 7 * .pi * 2 + unitRandom(index * 19 + 5) * 0.7
            let distance = reduceMotion ? grid * 1.5 : grid * (1.8 + progress * 7.0)
            let settle = reduceMotion ? 0 : grid * progress * progress * 6.0
            let point = CGPoint(
                x: center.x + cos(angle) * distance * (0.7 + unitRandom(index * 13 + 3) * 0.6),
                y: center.y + sin(angle) * distance * 0.48 + settle
            )
            guard eggPath.contains(point) else { continue }
            let fade = max(0, 1 - Double(progress) * 0.18)
            drawEnergyCrystalCluster(
                in: &context,
                center: point,
                block: grid * (0.72 + unitRandom(index * 31 + 9) * 0.24),
                topic: topics[index],
                isHighlighted: true,
                seed: 300 + index,
                opacity: fade
            )
        }
    }

    private static func drawEnergyCrystalCluster(
        in context: inout GraphicsContext,
        center: CGPoint,
        block: CGFloat,
        topic: EnergyCrystalTopic,
        isHighlighted: Bool,
        seed: Int,
        opacity: Double = 1
    ) {
        let accent = topic.accent
        let soft = topic.softAccent
        let glow = isHighlighted ? 0.55 : 0.26
        let scale = isHighlighted ? 1.12 : 1.0
        let baseOpacity = opacity * (isHighlighted ? 0.84 : 0.58)
        let b = block * scale
        let offsets: [(CGFloat, CGFloat, CGFloat, Double)] = [
            (0, 0, 1.12, baseOpacity),
            (-0.78, 0.0, 0.82, baseOpacity * 0.82),
            (0.78, 0.0, 0.82, baseOpacity * 0.78),
            (0, -0.78, 0.78, baseOpacity * 0.72),
            (0, 0.78, 0.84, baseOpacity * 0.70),
            (-0.54, -0.58, 0.58, baseOpacity * 0.55),
            (0.56, 0.58, 0.56, baseOpacity * 0.48)
        ]

        var crystalContext = context
        crystalContext.addFilter(.shadow(color: accent.opacity(glow * opacity), radius: b * 0.95, x: 0, y: 0))

        for (index, offset) in offsets.enumerated() {
            if index > 4 && unitRandom(seed * 17 + index) < 0.34 { continue }
            let rect = CGRect(
                x: center.x + offset.0 * b - b * offset.2 / 2,
                y: center.y + offset.1 * b - b * offset.2 / 2,
                width: b * offset.2,
                height: b * offset.2
            )
            let fill = index == 0 ? soft : accent
            crystalContext.fill(
                Path(roundedRect: rect, cornerRadius: max(0.7, b * 0.08)),
                with: .color(fill.opacity(offset.3))
            )
            if index == 0 {
                let spark = CGRect(x: rect.midX - b * 0.13, y: rect.midY - b * 0.13, width: b * 0.26, height: b * 0.26)
                context.fill(Path(spark), with: .color(Color.white.opacity(0.58 * opacity)))
            }
        }
    }

    private static func drawJaggedFillSurface(in context: inout GraphicsContext, eggRect: CGRect, fillTop: CGFloat, grid: CGFloat) {
        let startColumn = Int((eggRect.minX + eggRect.width * 0.13) / grid)
        let endColumn = Int((eggRect.maxX - eggRect.width * 0.13) / grid)
        for column in startColumn...endColumn {
            let seed = unitRandom(column * 73 + 19)
            let x = CGFloat(column) * grid
            let y = fillTop + (seed - 0.5) * grid * 2.2
            let rect = CGRect(x: x, y: y, width: grid * 0.92, height: grid * 0.72)
            context.fill(Path(rect), with: .color(Color.white.opacity(0.34 + Double(seed) * 0.18)))
        }
    }

    private static func drawCrystalPixels(
        in context: inout GraphicsContext,
        eggPath: Path,
        eggRect: CGRect,
        fillTop: CGFloat,
        grid: CGFloat,
        time: TimeInterval,
        tapPulse: Double
    ) {
        let colors = [aqua, shellBlue, Color.white, lavender, deepBlue]
        let count = 96
        for index in 0..<count {
            let rx = unitRandom(index * 97 + 11)
            let ry = unitRandom(index * 53 + 31)
            let sizeSeed = unitRandom(index * 37 + 7)
            let drift = sin(time * 1.25 + Double(index) * 0.71) * Double(grid) * 0.24
            let burst = CGFloat(tapPulse) * (unitRandom(index * 131 + 5) - 0.5) * grid * 4.5
            let x = eggRect.minX + eggRect.width * (0.16 + rx * 0.68) + burst
            let y = fillTop + (eggRect.maxY - fillTop) * (0.09 + ry * 0.84) + CGFloat(drift) + CGFloat(tapPulse) * grid * 1.2
            let block = grid * (0.52 + sizeSeed * 0.78)
            let rect = CGRect(x: x, y: y, width: block, height: block)
            guard eggPath.contains(CGPoint(x: rect.midX, y: rect.midY)) else { continue }

            let color = colors[index % colors.count]
            let opacity = 0.42 + Double(unitRandom(index * 29 + 3)) * 0.36
            var crystalContext = context
            crystalContext.addFilter(.shadow(color: color.opacity(0.36), radius: block * 0.9, x: 0, y: 0))
            crystalContext.fill(Path(roundedRect: rect, cornerRadius: block * 0.16), with: .color(color.opacity(opacity)))

            if index % 4 == 0 {
                let spark = CGRect(x: rect.midX - block * 0.18, y: rect.midY - block * 0.18, width: block * 0.36, height: block * 0.36)
                context.fill(Path(spark), with: .color(Color.white.opacity(0.72)))
            }
        }
    }

    private static func drawShell(in context: inout GraphicsContext, eggPath: Path, eggRect: CGRect, scale: CGFloat) {
        context.drawLayer { layer in
            layer.clip(to: eggPath)

            let upper = CGRect(
                x: eggRect.minX - eggRect.width * 0.05,
                y: eggRect.minY - eggRect.height * 0.05,
                width: eggRect.width * 1.10,
                height: eggRect.height * 0.56
            )
            layer.fill(
                Path(upper),
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.52),
                        Color(red: 233 / 255, green: 248 / 255, blue: 255 / 255).opacity(0.24),
                        shellBlue.opacity(0.10),
                    ]),
                    startPoint: CGPoint(x: upper.minX, y: upper.minY),
                    endPoint: CGPoint(x: upper.maxX, y: upper.maxY)
                )
            )

            let lower = CGRect(
                x: eggRect.minX - eggRect.width * 0.05,
                y: eggRect.minY + eggRect.height * 0.44,
                width: eggRect.width * 1.10,
                height: eggRect.height * 0.64
            )
            layer.fill(
                Path(lower),
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.06),
                        shellBlue.opacity(0.06),
                        Color.white.opacity(0.10)
                    ]),
                    startPoint: CGPoint(x: lower.minX, y: lower.minY),
                    endPoint: CGPoint(x: lower.maxX, y: lower.maxY)
                )
            )
        }

        context.stroke(eggPath, with: .color(Color.white.opacity(0.86)), lineWidth: 2.4 * scale)
        context.stroke(eggPath, with: .color(rimBlue.opacity(0.38)), lineWidth: 6.0 * scale)
        context.stroke(eggPath, with: .color(Color.white.opacity(0.36)), lineWidth: 11.0 * scale)
    }

    private static func drawPixelGrid(in context: inout GraphicsContext, eggPath: Path, eggRect: CGRect, grid: CGFloat) {
        let columns = Int(eggRect.width / grid) + 2
        let rows = Int(eggRect.height / grid) + 2
        for row in 0..<rows {
            for column in 0..<columns {
                let x = eggRect.minX + CGFloat(column) * grid
                let y = eggRect.minY + CGFloat(row) * grid
                let rect = CGRect(x: x, y: y, width: grid * 0.78, height: grid * 0.78)
                let center = CGPoint(x: rect.midX, y: rect.midY)
                guard eggPath.contains(center) else { continue }

                let lowerWeight = center.y > eggRect.minY + eggRect.height * 0.47 ? 0.15 : 0.04
                let opacity = lowerWeight + Double(unitRandom(row * 41 + column * 17)) * 0.08
                context.fill(Path(rect), with: .color(shellBlue.opacity(opacity)))
            }
        }
    }

    private static func drawVoxelRim(
        in context: inout GraphicsContext,
        eggPath: Path,
        eggRect: CGRect,
        grid: CGFloat,
        scale: CGFloat
    ) {
        let columns = Int(eggRect.width / grid) + 3
        let rows = Int(eggRect.height / grid) + 3

        for row in -1..<rows {
            for column in -1..<columns {
                let x = eggRect.minX + CGFloat(column) * grid
                let y = eggRect.minY + CGFloat(row) * grid
                let rect = CGRect(x: x, y: y, width: grid * 0.92, height: grid * 0.92)
                let center = CGPoint(x: rect.midX, y: rect.midY)
                guard eggPath.contains(center) else { continue }

                let neighbors = [
                    CGPoint(x: center.x + grid, y: center.y),
                    CGPoint(x: center.x - grid, y: center.y),
                    CGPoint(x: center.x, y: center.y + grid),
                    CGPoint(x: center.x, y: center.y - grid)
                ]
                let isRim = neighbors.contains { !eggPath.contains($0) }
                guard isRim else { continue }

                let seed = unitRandom(row * 83 + column * 43 + 5)
                let color = seed < 0.38 ? Color.white : (seed < 0.78 ? shellBlue : rimBlue)
                let opacity = 0.30 + Double(seed) * 0.36
                var rimContext = context
                rimContext.addFilter(.shadow(color: rimBlue.opacity(0.22), radius: 2.8 * scale, x: 0, y: 1.4 * scale))
                rimContext.fill(Path(roundedRect: rect, cornerRadius: 1.1 * scale), with: .color(color.opacity(opacity)))
            }
        }
    }

    private static func drawStars(in context: inout GraphicsContext, eggPath: Path, eggRect: CGRect, block: CGFloat) {
        let stars: [(CGFloat, CGFloat, CGFloat)] = [
            (0.39, 0.34, 1.0),
            (0.67, 0.47, 0.86),
            (0.30, 0.66, 1.0),
            (0.71, 0.76, 0.78),
            (0.18, 0.52, 0.72),
            (0.83, 0.58, 0.72)
        ]

        for (xRatio, yRatio, sizeRatio) in stars {
            let center = CGPoint(
                x: eggRect.minX + eggRect.width * xRatio,
                y: eggRect.minY + eggRect.height * yRatio
            )
            drawPixelStar(in: &context, center: center, block: block * sizeRatio, eggPath: eggPath)
        }
    }

    private static func drawPixelStar(in context: inout GraphicsContext, center: CGPoint, block: CGFloat, eggPath: Path) {
        let offsets: [(CGFloat, CGFloat, Double)] = [
            (0, -2, 0.42), (0, -1, 0.68),
            (-2, 0, 0.42), (-1, 0, 0.74), (0, 0, 0.92), (1, 0, 0.74), (2, 0, 0.42),
            (0, 1, 0.68), (0, 2, 0.42),
            (-1, -1, 0.34), (1, -1, 0.34), (-1, 1, 0.34), (1, 1, 0.34)
        ]

        for (dx, dy, opacity) in offsets {
            let rect = CGRect(
                x: center.x + dx * block - block / 2,
                y: center.y + dy * block - block / 2,
                width: block,
                height: block
            )
            guard eggPath.contains(CGPoint(x: rect.midX, y: rect.midY)) else { continue }
            context.fill(Path(roundedRect: rect, cornerRadius: block * 0.12), with: .color(deepBlue.opacity(opacity)))
            if dx == 0 && dy == 0 {
                context.fill(
                    Path(CGRect(x: rect.midX - block * 0.18, y: rect.midY - block * 0.18, width: block * 0.36, height: block * 0.36)),
                    with: .color(Color.white.opacity(0.55))
                )
            }
        }
    }

    private static func drawHighlights(
        in context: inout GraphicsContext,
        eggPath: Path,
        eggRect: CGRect,
        scale: CGFloat,
        time: TimeInterval,
        reduceMotion: Bool
    ) {
        context.drawLayer { layer in
            layer.clip(to: eggPath)

            let leftHighlight = CGRect(
                x: eggRect.minX + eggRect.width * 0.22,
                y: eggRect.minY + eggRect.height * 0.10,
                width: eggRect.width * 0.34,
                height: eggRect.height * 0.18
            )
            layer.fill(Path(ellipseIn: leftHighlight), with: .color(Color.white.opacity(0.30)))

            let pixelBlocks = [
                CGRect(x: eggRect.minX + eggRect.width * 0.27, y: eggRect.minY + eggRect.height * 0.13, width: 15 * scale, height: 15 * scale),
                CGRect(x: eggRect.minX + eggRect.width * 0.36, y: eggRect.minY + eggRect.height * 0.12, width: 12 * scale, height: 12 * scale),
                CGRect(x: eggRect.minX + eggRect.width * 0.50, y: eggRect.minY + eggRect.height * 0.03, width: 26 * scale, height: 9 * scale)
            ]
            for block in pixelBlocks {
                layer.fill(Path(roundedRect: block, cornerRadius: 1.2 * scale), with: .color(Color.white.opacity(0.42)))
            }

            guard !reduceMotion else { return }
            let sweepPeriod = 4.2
            let sweepProgress = CGFloat((time.truncatingRemainder(dividingBy: sweepPeriod)) / sweepPeriod)
            let sweepX = eggRect.minX - eggRect.width * 0.45 + sweepProgress * eggRect.width * 1.75
            var sweep = Path()
            sweep.move(to: CGPoint(x: sweepX, y: eggRect.minY - eggRect.height * 0.06))
            sweep.addLine(to: CGPoint(x: sweepX + eggRect.width * 0.18, y: eggRect.minY - eggRect.height * 0.06))
            sweep.addLine(to: CGPoint(x: sweepX + eggRect.width * 0.54, y: eggRect.maxY + eggRect.height * 0.06))
            sweep.addLine(to: CGPoint(x: sweepX + eggRect.width * 0.36, y: eggRect.maxY + eggRect.height * 0.06))
            sweep.closeSubpath()
            layer.fill(
                sweep,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.30),
                        shellBlue.opacity(0.16),
                        Color.white.opacity(0)
                    ]),
                    startPoint: CGPoint(x: sweepX, y: eggRect.midY),
                    endPoint: CGPoint(x: sweepX + eggRect.width * 0.46, y: eggRect.midY)
                )
            )
        }
    }

    private static func drawExpression(
        _ expression: PixelEggExpression,
        in context: inout GraphicsContext,
        eggRect: CGRect,
        scale: CGFloat
    ) {
        let eyeY = eggRect.minY + eggRect.height * 0.48
        let leftX = eggRect.minX + eggRect.width * 0.36
        let rightX = eggRect.minX + eggRect.width * 0.58
        let eyeWidth = 22 * scale
        let eyeHeight = 6 * scale

        switch expression {
        case .wideBright, .halfOpen:
            let openHeight = expression == .wideBright ? 16 * scale : 10 * scale
            let left = CGRect(x: leftX, y: eyeY, width: 15 * scale, height: openHeight)
            let right = CGRect(x: rightX, y: eyeY, width: 15 * scale, height: openHeight)
            context.fill(Path(roundedRect: left, cornerRadius: 2 * scale), with: .color(deepBlue.opacity(0.74)))
            context.fill(Path(roundedRect: right, cornerRadius: 2 * scale), with: .color(deepBlue.opacity(0.74)))
            context.fill(Path(CGRect(x: left.maxX - 6 * scale, y: left.minY + 2 * scale, width: 4 * scale, height: 4 * scale)), with: .color(Color.white.opacity(0.86)))
            context.fill(Path(CGRect(x: right.maxX - 6 * scale, y: right.minY + 2 * scale, width: 4 * scale, height: 4 * scale)), with: .color(Color.white.opacity(0.86)))

        case .closedSparkle, .sleepyBlush, .closedQuiet:
            let left = CGRect(x: leftX, y: eyeY + 8 * scale, width: eyeWidth, height: eyeHeight)
            let right = CGRect(x: rightX, y: eyeY + 8 * scale, width: eyeWidth, height: eyeHeight)
            context.fill(Path(roundedRect: left, cornerRadius: eyeHeight / 2), with: .color(deepBlue.opacity(0.78)))
            context.fill(Path(roundedRect: right, cornerRadius: eyeHeight / 2), with: .color(deepBlue.opacity(0.78)))
            context.fill(Path(CGRect(x: left.minX + 3 * scale, y: left.minY - 1 * scale, width: 7 * scale, height: 2 * scale)), with: .color(Color.white.opacity(0.58)))
            context.fill(Path(CGRect(x: right.minX + 3 * scale, y: right.minY - 1 * scale, width: 7 * scale, height: 2 * scale)), with: .color(Color.white.opacity(0.58)))
        }

        if expression != .wideBright {
            let blush = Color(red: 241 / 255, green: 186 / 255, blue: 214 / 255)
            let blushW = 11 * scale
            let blushH = 5 * scale
            context.fill(
                Path(roundedRect: CGRect(x: eggRect.minX + eggRect.width * 0.32, y: eggRect.minY + eggRect.height * 0.58, width: blushW, height: blushH), cornerRadius: blushH / 2),
                with: .color(blush.opacity(0.36))
            )
            context.fill(
                Path(roundedRect: CGRect(x: eggRect.minX + eggRect.width * 0.66, y: eggRect.minY + eggRect.height * 0.58, width: blushW, height: blushH), cornerRadius: blushH / 2),
                with: .color(blush.opacity(0.36))
            )
        }
    }

    private static func unitRandom(_ seed: Int) -> CGFloat {
        let value = sin(Double(seed) * 12.9898) * 43758.5453123
        return CGFloat(value - floor(value))
    }
}

// MARK: - Pixel Egg Renderer (amber palette, spec §4.2)

struct PixelEggView: View {
    var size: CGFloat = 148
    var expression: PixelEggExpression = .sleepyBlush
    var materialStyle: PixelEggMaterialStyle = .amber

    // Egg SVG viewBox 0 0 100 130, rendered at 148x192
    private var renderHeight: CGFloat { size * 130 / 100 }

    // Amber palette (spec §2)
    private let eggBase = Color(red: 250/255, green: 238/255, blue: 218/255)      // #FAEEDA
    private let pixelAmber = Color(red: 239/255, green: 159/255, blue: 39/255)     // #EF9F27
    private let highlightWhite = Color.white
    private let blushPink = Color(red: 244/255, green: 192/255, blue: 209/255)     // #F4C0D1
    private let eyeDark = Color(red: 44/255, green: 44/255, blue: 42/255)          // #2C2C2A
    private let amberDeep = Color(red: 186/255, green: 117/255, blue: 23/255)      // #BA7517

    var body: some View {
        Canvas { context, canvasSize in
            let w = canvasSize.width
            let h = canvasSize.height
            let sx = w / 100  // scale factor x
            let sy = h / 130  // scale factor y

            // 1. Egg shape path (spec: M50,12 C28,12 15,44 15,76 C15,107 30,120 50,120 C70,120 85,107 85,76 C85,44 72,12 50,12 Z)
            var eggPath = Path()
            eggPath.move(to: CGPoint(x: 50*sx, y: 12*sy))
            eggPath.addCurve(to: CGPoint(x: 15*sx, y: 76*sy),
                             control1: CGPoint(x: 28*sx, y: 12*sy),
                             control2: CGPoint(x: 15*sx, y: 44*sy))
            eggPath.addCurve(to: CGPoint(x: 50*sx, y: 120*sy),
                             control1: CGPoint(x: 15*sx, y: 107*sy),
                             control2: CGPoint(x: 30*sx, y: 120*sy))
            eggPath.addCurve(to: CGPoint(x: 85*sx, y: 76*sy),
                             control1: CGPoint(x: 70*sx, y: 120*sy),
                             control2: CGPoint(x: 85*sx, y: 107*sy))
            eggPath.addCurve(to: CGPoint(x: 50*sx, y: 12*sy),
                             control1: CGPoint(x: 85*sx, y: 44*sy),
                             control2: CGPoint(x: 72*sx, y: 12*sy))
            eggPath.closeSubpath()

            if materialStyle == .blueCrystal {
                drawBlueCrystalEgg(in: &context, eggPath: eggPath, width: w, height: h, sx: sx, sy: sy)
                return
            }

            // 2. Fill base color
            context.fill(eggPath, with: .color(eggBase))

            // 3. Pixel pattern (9x9 tile, inner 7x7 amber squares)
            context.clipToLayer { clipCtx in
                clipCtx.fill(eggPath, with: .color(.white))
            }
            let tileSize: CGFloat = 9 * sx
            let blockSize: CGFloat = 7 * sx
            let blockOffset: CGFloat = 1 * sx
            let cols = Int(w / tileSize) + 1
            let rows = Int(h / tileSize) + 1
            for row in 0..<rows {
                for col in 0..<cols {
                    let x = CGFloat(col) * tileSize + blockOffset
                    let y = CGFloat(row) * tileSize + blockOffset
                    let rect = CGRect(x: x, y: y, width: blockSize, height: blockSize)
                    let center = CGPoint(x: x + blockSize/2, y: y + blockSize/2)
                    if eggPath.contains(center) {
                        context.fill(Path(rect), with: .color(pixelAmber.opacity(0.25)))
                    }
                }
            }

            // 4. Left-top highlight (spec: (22,22) and (31,22) white blocks)
            let hl1 = CGRect(x: 22*sx, y: 22*sy, width: 7*sx, height: 7*sy)
            let hl2 = CGRect(x: 31*sx, y: 22*sy, width: 7*sx, height: 7*sy)
            context.fill(Path(hl1), with: .color(highlightWhite.opacity(0.75)))
            context.fill(Path(hl2), with: .color(highlightWhite.opacity(0.45)))

            // 5. Eyes (expression-dependent)
            drawEyes(in: &context, sx: sx, sy: sy)

            // 6. Blush (expression-dependent)
            drawBlush(in: &context, sx: sx, sy: sy)
        }
        .frame(width: size, height: renderHeight)
        .accessibilityIdentifier("pixel.egg")
    }

    private func drawBlueCrystalEgg(
        in context: inout GraphicsContext,
        eggPath: Path,
        width: CGFloat,
        height: CGFloat,
        sx: CGFloat,
        sy: CGFloat
    ) {
        let shell = Color(red: 232 / 255, green: 247 / 255, blue: 255 / 255)
        let iceBlue = Color(red: 82 / 255, green: 169 / 255, blue: 242 / 255)
        let deepBlue = Color(red: 25 / 255, green: 116 / 255, blue: 220 / 255)
        let aqua = Color(red: 95 / 255, green: 232 / 255, blue: 238 / 255)
        let lavender = Color(red: 148 / 255, green: 151 / 255, blue: 255 / 255)

        context.fill(
            eggPath,
            with: .linearGradient(
                Gradient(colors: [
                    Color.white.opacity(0.92),
                    shell.opacity(0.86),
                    Color(red: 185 / 255, green: 229 / 255, blue: 255 / 255).opacity(0.72),
                ]),
                startPoint: CGPoint(x: width * 0.24, y: height * 0.06),
                endPoint: CGPoint(x: width * 0.78, y: height * 0.98)
            )
        )

        let tileSize: CGFloat = 8 * sx
        let blockSize: CGFloat = 6.4 * sx
        let blockOffset: CGFloat = 0.8 * sx
        let cols = Int(width / tileSize) + 2
        let rows = Int(height / tileSize) + 2

        for row in 0..<rows {
            for col in 0..<cols {
                let x = CGFloat(col) * tileSize + blockOffset
                let y = CGFloat(row) * tileSize + blockOffset
                let rect = CGRect(x: x, y: y, width: blockSize, height: blockSize)
                let center = CGPoint(x: rect.midX, y: rect.midY)
                guard eggPath.contains(center) else { continue }

                let seed = (row * 11 + col * 7) % 9
                let isLowerWater = center.y > height * 0.55
                let isRim = center.x < width * 0.24 || center.x > width * 0.76 || center.y < height * 0.22
                let opacity: Double = isLowerWater ? 0.42 : (isRim ? 0.30 : 0.16)
                let color: Color

                if isLowerWater {
                    color = seed == 0 ? lavender : (seed % 3 == 0 ? aqua : iceBlue)
                } else if isRim {
                    color = seed % 2 == 0 ? iceBlue : Color.white
                } else {
                    color = seed == 1 ? Color.white : iceBlue
                }

                context.fill(Path(rect), with: .color(color.opacity(opacity)))
            }
        }

        let particles: [(CGFloat, CGFloat, CGFloat, Color)] = [
            (31, 76, 7, aqua), (41, 82, 5, iceBlue), (53, 76, 7, Color.white),
            (63, 88, 6, lavender), (47, 96, 8, aqua), (68, 101, 5, deepBlue),
            (35, 101, 6, Color.white), (58, 108, 7, iceBlue),
        ]

        for particle in particles {
            let rect = CGRect(
                x: particle.0 * sx,
                y: particle.1 * sy,
                width: particle.2 * sx,
                height: particle.2 * sy
            )
            if eggPath.contains(CGPoint(x: rect.midX, y: rect.midY)) {
                context.fill(Path(roundedRect: rect, cornerRadius: 1.2 * sx), with: .color(particle.3.opacity(0.58)))
            }
        }

        let highlights = [
            CGRect(x: 25 * sx, y: 23 * sy, width: 9 * sx, height: 9 * sy),
            CGRect(x: 34 * sx, y: 23 * sy, width: 7 * sx, height: 7 * sy),
            CGRect(x: 57 * sx, y: 18 * sy, width: 12 * sx, height: 5 * sy),
            CGRect(x: 73 * sx, y: 47 * sy, width: 7 * sx, height: 9 * sy),
        ]

        for (index, rect) in highlights.enumerated() {
            context.fill(Path(rect), with: .color(Color.white.opacity(index == 0 ? 0.82 : 0.52)))
        }

        context.stroke(eggPath, with: .color(Color.white.opacity(0.88)), lineWidth: 1.7 * sx)
        context.stroke(eggPath, with: .color(iceBlue.opacity(0.34)), lineWidth: 3.8 * sx)

        drawBlueCrystalEyes(in: &context, sx: sx, sy: sy, deepBlue: deepBlue)
        drawBlueCrystalBlush(in: &context, sx: sx, sy: sy)
    }

    private func drawBlueCrystalEyes(in context: inout GraphicsContext, sx: CGFloat, sy: CGFloat, deepBlue: Color) {
        let leftEyeX: CGFloat = 35 * sx
        let rightEyeX: CGFloat = 58 * sx
        let eyeY: CGFloat = 58 * sy

        switch expression {
        case .wideBright, .halfOpen:
            let eyeW: CGFloat = 9 * sx
            let eyeH: CGFloat = expression == .wideBright ? 9 * sy : 6 * sy
            let leftEye = CGRect(x: leftEyeX, y: eyeY, width: eyeW, height: eyeH)
            let rightEye = CGRect(x: rightEyeX, y: eyeY, width: eyeW, height: eyeH)
            context.fill(Path(roundedRect: leftEye, cornerRadius: 1.4 * sx), with: .color(deepBlue.opacity(0.72)))
            context.fill(Path(roundedRect: rightEye, cornerRadius: 1.4 * sx), with: .color(deepBlue.opacity(0.72)))
            context.fill(Path(CGRect(x: leftEyeX + 5 * sx, y: eyeY + 1 * sy, width: 3 * sx, height: 3 * sy)), with: .color(Color.white.opacity(0.86)))
            context.fill(Path(CGRect(x: rightEyeX + 5 * sx, y: eyeY + 1 * sy, width: 3 * sx, height: 3 * sy)), with: .color(Color.white.opacity(0.86)))

        case .closedSparkle, .sleepyBlush, .closedQuiet:
            let lineW: CGFloat = 10 * sx
            let lineH: CGFloat = 3.2 * sy
            let leftLine = CGRect(x: leftEyeX, y: eyeY + 5 * sy, width: lineW, height: lineH)
            let rightLine = CGRect(x: rightEyeX, y: eyeY + 5 * sy, width: lineW, height: lineH)
            context.fill(Path(roundedRect: leftLine, cornerRadius: 1.6 * sx), with: .color(deepBlue.opacity(0.76)))
            context.fill(Path(roundedRect: rightLine, cornerRadius: 1.6 * sx), with: .color(deepBlue.opacity(0.76)))
            context.fill(Path(CGRect(x: leftEyeX + 1.5 * sx, y: eyeY + 4.4 * sy, width: 3 * sx, height: 1.8 * sy)), with: .color(Color.white.opacity(0.62)))
            context.fill(Path(CGRect(x: rightEyeX + 1.5 * sx, y: eyeY + 4.4 * sy, width: 3 * sx, height: 1.8 * sy)), with: .color(Color.white.opacity(0.62)))
        }
    }

    private func drawBlueCrystalBlush(in context: inout GraphicsContext, sx: CGFloat, sy: CGFloat) {
        let leftBlush = CGRect(x: 31 * sx, y: 73 * sy, width: 6 * sx, height: 3.4 * sy)
        let rightBlush = CGRect(x: 64 * sx, y: 73 * sy, width: 6 * sx, height: 3.4 * sy)
        let blushColor = Color(red: 241 / 255, green: 186 / 255, blue: 214 / 255)

        context.fill(Path(roundedRect: leftBlush, cornerRadius: 1.2 * sx), with: .color(blushColor.opacity(0.42)))
        context.fill(Path(roundedRect: rightBlush, cornerRadius: 1.2 * sx), with: .color(blushColor.opacity(0.42)))
    }

    // MARK: - Eyes

    private func drawEyes(in context: inout GraphicsContext, sx: CGFloat, sy: CGFloat) {
        let leftEyeX: CGFloat = 35 * sx
        let rightEyeX: CGFloat = 58 * sx
        let eyeY: CGFloat = 58 * sy

        switch expression {
        case .wideBright:
            // Round open eyes + white sparkle dot
            let eyeSize: CGFloat = 8 * sx
            let leftEye = Path(ellipseIn: CGRect(x: leftEyeX, y: eyeY, width: eyeSize, height: eyeSize))
            let rightEye = Path(ellipseIn: CGRect(x: rightEyeX, y: eyeY, width: eyeSize, height: eyeSize))
            context.fill(leftEye, with: .color(eyeDark))
            context.fill(rightEye, with: .color(eyeDark))
            // White sparkle in top-right of each eye
            let sparkleSize: CGFloat = 3 * sx
            let ls = Path(ellipseIn: CGRect(x: leftEyeX + 5*sx, y: eyeY + 1*sy, width: sparkleSize, height: sparkleSize))
            let rs = Path(ellipseIn: CGRect(x: rightEyeX + 5*sx, y: eyeY + 1*sy, width: sparkleSize, height: sparkleSize))
            context.fill(ls, with: .color(highlightWhite))
            context.fill(rs, with: .color(highlightWhite))

        case .closedSparkle:
            // Closed arc lines (happy closed eyes)
            var leftArc = Path()
            leftArc.move(to: CGPoint(x: leftEyeX, y: eyeY + 4*sy))
            leftArc.addQuadCurve(to: CGPoint(x: leftEyeX + 8*sx, y: eyeY + 4*sy),
                                 control: CGPoint(x: leftEyeX + 4*sx, y: eyeY - 2*sy))
            var rightArc = Path()
            rightArc.move(to: CGPoint(x: rightEyeX, y: eyeY + 4*sy))
            rightArc.addQuadCurve(to: CGPoint(x: rightEyeX + 8*sx, y: eyeY + 4*sy),
                                  control: CGPoint(x: rightEyeX + 4*sx, y: eyeY - 2*sy))
            context.stroke(leftArc, with: .color(eyeDark), style: StrokeStyle(lineWidth: 2*sx, lineCap: .round))
            context.stroke(rightArc, with: .color(eyeDark), style: StrokeStyle(lineWidth: 2*sx, lineCap: .round))

        case .sleepyBlush:
            // Squinting horizontal lines (sleepy)
            let lineWidth: CGFloat = 2 * sx
            let lineLength: CGFloat = 8 * sx
            var leftLine = Path()
            leftLine.move(to: CGPoint(x: leftEyeX, y: eyeY + 4*sy))
            leftLine.addLine(to: CGPoint(x: leftEyeX + lineLength, y: eyeY + 4*sy))
            var rightLine = Path()
            rightLine.move(to: CGPoint(x: rightEyeX, y: eyeY + 4*sy))
            rightLine.addLine(to: CGPoint(x: rightEyeX + lineLength, y: eyeY + 4*sy))
            context.stroke(leftLine, with: .color(eyeDark), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            context.stroke(rightLine, with: .color(eyeDark), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

        case .halfOpen:
            // Half-open: small ovals
            let ew: CGFloat = 7 * sx
            let eh: CGFloat = 4 * sy
            let leftEye = Path(ellipseIn: CGRect(x: leftEyeX, y: eyeY + 2*sy, width: ew, height: eh))
            let rightEye = Path(ellipseIn: CGRect(x: rightEyeX, y: eyeY + 2*sy, width: ew, height: eh))
            context.fill(leftEye, with: .color(eyeDark))
            context.fill(rightEye, with: .color(eyeDark))

        case .closedQuiet:
            // Closed straight lines (quiet/resting)
            let lineWidth: CGFloat = 1.5 * sx
            let lineLength: CGFloat = 7 * sx
            var leftLine = Path()
            leftLine.move(to: CGPoint(x: leftEyeX, y: eyeY + 4*sy))
            leftLine.addLine(to: CGPoint(x: leftEyeX + lineLength, y: eyeY + 4*sy))
            var rightLine = Path()
            rightLine.move(to: CGPoint(x: rightEyeX, y: eyeY + 4*sy))
            rightLine.addLine(to: CGPoint(x: rightEyeX + lineLength, y: eyeY + 4*sy))
            context.stroke(leftLine, with: .color(eyeDark.opacity(0.7)), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            context.stroke(rightLine, with: .color(eyeDark.opacity(0.7)), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
    }

    // MARK: - Blush

    private func drawBlush(in context: inout GraphicsContext, sx: CGFloat, sy: CGFloat) {
        let hasBlush: Bool
        let blushOpacity: Double

        switch expression {
        case .wideBright: hasBlush = false; blushOpacity = 0
        case .closedSparkle: hasBlush = true; blushOpacity = 0.7
        case .sleepyBlush: hasBlush = true; blushOpacity = 0.7
        case .halfOpen: hasBlush = true; blushOpacity = 0.5
        case .closedQuiet: hasBlush = true; blushOpacity = 0.4
        }

        guard hasBlush else { return }

        // spec: (32,74) and (63,74) — 5x3 pink blocks
        let blushW: CGFloat = 5 * sx
        let blushH: CGFloat = 3 * sy
        let leftBlush = CGRect(x: 32*sx, y: 74*sy, width: blushW, height: blushH)
        let rightBlush = CGRect(x: 63*sx, y: 74*sy, width: blushW, height: blushH)

        context.fill(Path(roundedRect: leftBlush, cornerRadius: 1*sx), with: .color(blushPink.opacity(blushOpacity)))
        context.fill(Path(roundedRect: rightBlush, cornerRadius: 1*sx), with: .color(blushPink.opacity(blushOpacity)))
    }
}
