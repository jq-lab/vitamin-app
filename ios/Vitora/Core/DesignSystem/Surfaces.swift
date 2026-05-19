import SwiftUI

enum AuraBackgroundMood {
    case today
    case vitora
    case cycle
    case support
}

enum VoiceToneMood: String, Equatable {
    case calm
    case low
    case bright
    case urgent

    var label: String {
        switch self {
        case .calm:
            return "语调平稳"
        case .low:
            return "语调偏低"
        case .bright:
            return "语调偏亮"
        case .urgent:
            return "语速偏快"
        }
    }
}

struct VoiceMoodSignal: Equatable {
    var volume: Double
    var pitch: Double
    var speechRate: Double
    var pauseLevel: Double
    var tone: VoiceToneMood

    static let idle = VoiceMoodSignal(volume: 0.10, pitch: 0.46, speechRate: 0.20, pauseLevel: 0.72, tone: .calm)
    static let listeningPreview = VoiceMoodSignal(volume: 0.56, pitch: 0.58, speechRate: 0.46, pauseLevel: 0.20, tone: .calm)
    static let strongPreview = VoiceMoodSignal(volume: 0.88, pitch: 0.64, speechRate: 0.62, pauseLevel: 0.10, tone: .bright)

    func sampled(at time: TimeInterval, active: Bool) -> VoiceMoodSignal {
        guard active else {
            return .idle
        }

        let volumeWave = (sin(time * 2.1) + 1) * 0.5
        let pitchWave = (sin(time * 1.3 + 0.8) + 1) * 0.5
        let rateWave = (sin(time * 1.7 + 1.6) + 1) * 0.5

        return VoiceMoodSignal(
            volume: min(1, max(0, volume * 0.72 + volumeWave * 0.32)),
            pitch: min(1, max(0, pitch * 0.78 + pitchWave * 0.22)),
            speechRate: min(1, max(0, speechRate * 0.74 + rateWave * 0.24)),
            pauseLevel: pauseLevel,
            tone: tone
        )
    }
}

enum PremiumAuraScene: String {
    case today
    case vitora
    case cycle
    case sheet
    case onboarding
    case support

    var baseColor: Color {
        switch self {
        case .today:
            return VitoraTheme.ColorToken.paperWarmBase
        case .vitora:
            return Color(red: 249 / 255, green: 247 / 255, blue: 245 / 255)
        case .cycle:
            return VitoraTheme.ColorToken.paperWarmBase
        case .sheet:
            return Color(red: 250 / 255, green: 248 / 255, blue: 245 / 255)
        case .onboarding:
            return Color(red: 250 / 255, green: 247 / 255, blue: 244 / 255)
        case .support:
            return Color(red: 250 / 255, green: 248 / 255, blue: 246 / 255)
        }
    }

    var primaryMist: Color {
        switch self {
        case .today:
            return Color(red: 154 / 255, green: 224 / 255, blue: 221 / 255)
        case .vitora:
            return Color(red: 162 / 255, green: 224 / 255, blue: 232 / 255)
        case .cycle:
            return Color(red: 162 / 255, green: 224 / 255, blue: 220 / 255)
        case .sheet:
            return Color(red: 196 / 255, green: 232 / 255, blue: 235 / 255)
        case .onboarding:
            return Color(red: 190 / 255, green: 229 / 255, blue: 232 / 255)
        case .support:
            return Color(red: 210 / 255, green: 228 / 255, blue: 232 / 255)
        }
    }

    var secondaryMist: Color {
        switch self {
        case .today:
            return Color(red: 255 / 255, green: 220 / 255, blue: 208 / 255)
        case .vitora:
            return Color(red: 255 / 255, green: 218 / 255, blue: 208 / 255)
        case .cycle:
            return Color(red: 255 / 255, green: 225 / 255, blue: 211 / 255)
        case .sheet:
            return Color(red: 249 / 255, green: 232 / 255, blue: 232 / 255)
        case .onboarding:
            return Color(red: 255 / 255, green: 223 / 255, blue: 229 / 255)
        case .support:
            return Color(red: 248 / 255, green: 235 / 255, blue: 233 / 255)
        }
    }

    var tertiaryMist: Color {
        switch self {
        case .today, .sheet, .support:
            return Color(red: 224 / 255, green: 233 / 255, blue: 231 / 255)
        case .vitora:
            return Color(red: 224 / 255, green: 233 / 255, blue: 232 / 255)
        case .cycle:
            return Color(red: 228 / 255, green: 239 / 255, blue: 225 / 255)
        case .onboarding:
            return Color(red: 232 / 255, green: 225 / 255, blue: 241 / 255)
        }
    }

    var mistOpacity: Double {
        switch self {
        case .sheet:
            return 0.24
        case .support:
            return 0.18
        case .vitora:
            return 0.24
        case .onboarding:
            return 0.30
        default:
            return 0.30
        }
    }

    var bottomFogOpacity: Double {
        switch self {
        case .sheet, .support:
            return 0.24
        case .vitora:
            return 0.20
        default:
            return 0.22
        }
    }
}

struct PremiumAuraBackground: View {
    var scene: PremiumAuraScene = .today
    var signal: VoiceMoodSignal = .idle
    var isListening = false
    var intensity: Double = 1

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        TimelineView(.animation) { timeline in
            let active = isListening && !reduceMotion
            let phase = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            let sampledSignal = signal.sampled(at: phase, active: active)

            ZStack {
                scene.baseColor

                PearlAmbientWash(
                    scene: scene,
                    intensity: intensity,
                    reduceTransparency: reduceTransparency
                )

                PremiumAuraMistField(
                    scene: scene,
                    phase: phase,
                    signal: sampledSignal,
                    isListening: active,
                    intensity: intensity,
                    reduceTransparency: reduceTransparency
                )

                LinearGradient(
                    stops: [
                        .init(color: scene.secondaryMist.opacity(reduceTransparency ? 0.20 : 0.10 * intensity), location: 0.0),
                        .init(color: VitoraTheme.ColorToken.surfacePearlMain.opacity(reduceTransparency ? 0.56 : 0.38), location: 0.28),
                        .init(color: VitoraTheme.ColorToken.paperWarmLift.opacity(reduceTransparency ? 0.52 : 0.34), location: 0.58),
                        .init(color: VitoraTheme.ColorToken.surfacePearlMain.opacity(reduceTransparency ? 0.34 : 0.24), location: 0.78),
                        .init(color: scene.primaryMist.opacity(reduceTransparency ? 0.14 : 0.075 * intensity), location: 0.96),
                        .init(color: Color(red: 226 / 255, green: 230 / 255, blue: 228 / 255).opacity(reduceTransparency ? 0.18 : 0.08), location: 1.0),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                PremiumAuraTexture(scene: scene, reduceTransparency: reduceTransparency)
                    .opacity(reduceTransparency ? 0.10 : 0.24)

                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(reduceTransparency ? 0.22 : 0.045)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .black.opacity(0.18), location: 0.62),
                                .init(color: .black, location: 1.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                if reduceTransparency {
                    VitoraTheme.ColorToken.paperWarmLift.opacity(0.46)
                }

                PremiumAuraAccessibilityMarker(identifier: "premium.aura.background.\(scene.rawValue)")
            }
        }
        .ignoresSafeArea()
        .accessibilityElement(children: .contain)
    }
}

private struct PearlAmbientWash: View {
    let scene: PremiumAuraScene
    let intensity: Double
    let reduceTransparency: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: scene.secondaryMist.opacity(0.17 * intensity), location: 0.0),
                    .init(color: VitoraTheme.ColorToken.surfacePearlMain.opacity(0.48 * intensity), location: 0.30),
                    .init(color: VitoraTheme.ColorToken.paperWarmLift.opacity(0.42 * intensity), location: 0.62),
                    .init(color: scene.primaryMist.opacity(cyanOpacity * 0.55), location: 1.0),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color(red: 255 / 255, green: 214 / 255, blue: 198 / 255).opacity(warmOpacity * 1.12),
                    Color(red: 255 / 255, green: 229 / 255, blue: 186 / 255).opacity(warmOpacity * 0.52),
                    Color(red: 255 / 255, green: 236 / 255, blue: 239 / 255).opacity(warmOpacity * 0.42),
                    .clear,
                ],
                center: UnitPoint(x: 0.20, y: 0.03),
                startRadius: 1,
                endRadius: 380
            )

            RadialGradient(
                colors: [
                    Color(red: 165 / 255, green: 227 / 255, blue: 225 / 255).opacity(cyanOpacity * 0.86),
                    Color(red: 213 / 255, green: 240 / 255, blue: 232 / 255).opacity(cyanOpacity * 0.52),
                    Color(red: 222 / 255, green: 229 / 255, blue: 227 / 255).opacity(cyanOpacity * 0.26),
                    .clear,
                ],
                center: UnitPoint(x: 0.88, y: 0.98),
                startRadius: 1,
                endRadius: 340
            )

            RadialGradient(
                colors: [
                    VitoraTheme.ColorToken.surfacePearlMain.opacity(reduceTransparency ? 0.40 : 0.34 * intensity),
                    VitoraTheme.ColorToken.paperWarmLift.opacity(reduceTransparency ? 0.22 : 0.16 * intensity),
                    .clear,
                ],
                center: UnitPoint(x: 0.04, y: 0.96),
                startRadius: 1,
                endRadius: 310
            )

            RadialGradient(
                colors: [
                    VitoraTheme.ColorToken.surfacePearlMain.opacity(reduceTransparency ? 0.34 : 0.28 * intensity),
                    VitoraTheme.ColorToken.surfacePearlMain.opacity(reduceTransparency ? 0.18 : 0.12 * intensity),
                    .clear,
                ],
                center: .topLeading,
                startRadius: 1,
                endRadius: 300
            )

            RadialGradient(
                colors: [
                    VitoraTheme.ColorToken.surfacePearlMain.opacity(reduceTransparency ? 0.28 : 0.18 * intensity),
                    VitoraTheme.ColorToken.paperWarmLift.opacity(reduceTransparency ? 0.18 : 0.10 * intensity),
                    .clear,
                ],
                center: .bottomTrailing,
                startRadius: 1,
                endRadius: 330
            )

            RadialGradient(
                colors: [
                    VitoraTheme.ColorToken.surfacePearlMain.opacity(reduceTransparency ? 0.18 : 0.16 * intensity),
                    VitoraTheme.ColorToken.paperWarmLift.opacity(reduceTransparency ? 0.12 : 0.10 * intensity),
                    .clear,
                ],
                center: .center,
                startRadius: 1,
                endRadius: 260
            )
        }
        .allowsHitTesting(false)
    }

    private var warmOpacity: Double {
        let base: Double
        switch scene {
        case .onboarding:
            base = 0.28
        case .vitora:
            base = 0.10
        case .sheet:
            base = 0.12
        case .cycle:
            base = 0.13
        case .today:
            base = 0.13
        case .support:
            base = 0.09
        }
        return (reduceTransparency ? base * 0.45 : base) * intensity
    }

    private var cyanOpacity: Double {
        let base: Double
        switch scene {
        case .sheet:
            base = 0.13
        case .onboarding:
            base = 0.15
        case .today, .cycle:
            base = 0.14
        default:
            base = 0.10
        }
        return (reduceTransparency ? base * 0.55 : base) * intensity
    }
}

private struct PremiumAuraAccessibilityMarker: View {
    let identifier: String

    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.001))
            .frame(width: 1, height: 1)
            .accessibilityLabel("Vitora 浅霜背景")
            .accessibilityIdentifier(identifier)
            .allowsHitTesting(false)
    }
}

private struct PremiumAuraMistField: View {
    let scene: PremiumAuraScene
    let phase: TimeInterval
    let signal: VoiceMoodSignal
    let isListening: Bool
    let intensity: Double
    let reduceTransparency: Bool

    var body: some View {
        Canvas { context, size in
            let voiceLift = isListening ? min(1, max(0, signal.volume)) * 0.18 : 0
            drawMistRibbon(
                in: &context,
                size: size,
                y: size.height * 0.17,
                amplitude: size.height * 0.10,
                color: scene.secondaryMist,
                opacity: (scene.mistOpacity * 0.78 + voiceLift) * intensity,
                blur: 44,
                width: size.height * 0.17,
                phaseOffset: phase * 0.08
            )
            drawMistRibbon(
                in: &context,
                size: size,
                y: size.height * 0.43,
                amplitude: size.height * 0.075,
                color: scene.primaryMist,
                opacity: (scene.mistOpacity * 0.44 + voiceLift * 0.42) * intensity,
                blur: 54,
                width: size.height * 0.20,
                phaseOffset: phase * -0.06 + 1.2
            )
            drawMistRibbon(
                in: &context,
                size: size,
                y: size.height * 0.84,
                amplitude: size.height * 0.06,
                color: scene.tertiaryMist,
                opacity: (scene.mistOpacity * 0.28) * intensity,
                blur: 68,
                width: size.height * 0.18,
                phaseOffset: phase * 0.045 + 2.1
            )

            guard isListening else {
                return
            }

            for index in 0..<3 {
                drawVoiceRipple(
                    in: &context,
                    size: size,
                    color: scene.primaryMist,
                    strength: min(1, signal.volume) * (0.18 - Double(index) * 0.035),
                    phaseOffset: phase * 0.34 + Double(index) * 0.55
                )
            }
        }
        .blendMode(.softLight)
        .opacity(reduceTransparency ? 0.38 : 1)
        .allowsHitTesting(false)
    }

    private func drawMistRibbon(
        in context: inout GraphicsContext,
        size: CGSize,
        y: CGFloat,
        amplitude: CGFloat,
        color: Color,
        opacity: Double,
        blur: CGFloat,
        width: CGFloat,
        phaseOffset: Double
    ) {
        var path = Path()
        let start = CGPoint(x: -size.width * 0.18, y: y + sin(phaseOffset) * amplitude)
        let c1 = CGPoint(x: size.width * 0.24, y: y - amplitude * 1.15 + CGFloat(sin(phaseOffset + 0.8)) * amplitude * 0.32)
        let c2 = CGPoint(x: size.width * 0.60, y: y + amplitude * 1.08 + CGFloat(cos(phaseOffset + 0.4)) * amplitude * 0.28)
        let end = CGPoint(x: size.width * 1.18, y: y + CGFloat(cos(phaseOffset)) * amplitude)
        path.move(to: start)
        path.addCurve(to: end, control1: c1, control2: c2)

        var soft = context
        soft.addFilter(.blur(radius: blur))
        soft.stroke(path, with: .color(color.opacity(opacity)), style: StrokeStyle(lineWidth: width, lineCap: .round))

        var rim = context
        rim.addFilter(.blur(radius: max(12, blur * 0.28)))
        rim.stroke(path, with: .color(Color.white.opacity(opacity * 0.32)), style: StrokeStyle(lineWidth: max(18, width * 0.18), lineCap: .round))
    }

    private func drawVoiceRipple(
        in context: inout GraphicsContext,
        size: CGSize,
        color: Color,
        strength: Double,
        phaseOffset: Double
    ) {
        var path = Path()
        let y = size.height * (0.27 + CGFloat(sin(phaseOffset)) * 0.035)
        path.move(to: CGPoint(x: size.width * 0.08, y: y))
        path.addCurve(
            to: CGPoint(x: size.width * 0.92, y: y + CGFloat(cos(phaseOffset)) * 18),
            control1: CGPoint(x: size.width * 0.30, y: y - 30),
            control2: CGPoint(x: size.width * 0.67, y: y + 34)
        )

        var ripple = context
        ripple.addFilter(.blur(radius: 5))
        ripple.stroke(path, with: .color(color.opacity(strength)), style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
    }
}

private struct PremiumAuraTexture: View {
    let scene: PremiumAuraScene
    let reduceTransparency: Bool

    var body: some View {
        Canvas { context, size in
            guard !reduceTransparency else {
                return
            }

            for index in 0..<110 {
                let seed = Double(index + 1)
                let x = abs((sin(seed * 12.9898) * 43758.5453).truncatingRemainder(dividingBy: 1))
                let y = abs((sin(seed * 78.233) * 12438.234).truncatingRemainder(dividingBy: 1))
                let length = CGFloat(0.9 + (seed.truncatingRemainder(dividingBy: 4)) * 0.24)
                let opacity = 0.010 + (seed.truncatingRemainder(dividingBy: 5)) * 0.002
                let rect = CGRect(
                    x: CGFloat(x) * size.width,
                    y: CGFloat(y) * size.height,
                    width: length,
                    height: 0.55
                )
                context.fill(Path(roundedRect: rect, cornerRadius: 0.3), with: .color(scene.primaryMist.opacity(opacity)))
                context.fill(Path(roundedRect: rect.offsetBy(dx: 0.4, dy: 0.4), cornerRadius: 0.3), with: .color(Color.white.opacity(opacity * 1.6)))
            }
        }
        .blendMode(.softLight)
        .allowsHitTesting(false)
    }
}

struct WaterAuraReferenceBackground: View {
    var scene: PremiumAuraScene = .today
    var signal: VoiceMoodSignal = .idle
    var isListening = false
    var intensity: Double = 1

    var body: some View {
        PremiumAuraBackground(
            scene: scene,
            signal: signal,
            isListening: isListening,
            intensity: intensity
        )
    }
}

private struct WaterAuraVoiceInteractionLayer: View {
    var signal: VoiceMoodSignal
    var phase: TimeInterval
    var isListening: Bool

    var body: some View {
        Canvas { context, size in
            let rect = circleRect(in: size)
            let volume = min(1, max(0, signal.volume))
            let path = waterOvalPath(in: rect, phase: phase, volume: volume, layer: 0)

            var soft = context
            soft.addFilter(.blur(radius: isListening ? 4.0 : 3.0))
            soft.stroke(
                path,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 128 / 255, green: 146 / 255, blue: 148 / 255).opacity(0.38),
                        Color.white.opacity(0.92),
                        Color(red: 174 / 255, green: 190 / 255, blue: 190 / 255).opacity(0.60),
                        Color.white.opacity(0.78),
                    ]),
                    startPoint: CGPoint(x: rect.minX, y: rect.minY),
                    endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
                ),
                lineWidth: isListening ? 7.2 + volume * 2.0 : 5.4
            )

            context.stroke(
                path,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.96),
                        Color(red: 154 / 255, green: 172 / 255, blue: 173 / 255).opacity(0.72),
                        Color.white.opacity(0.90),
                        Color(red: 132 / 255, green: 154 / 255, blue: 155 / 255).opacity(0.34),
                    ]),
                    startPoint: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.minY),
                    endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
                ),
                lineWidth: isListening ? 2.2 : 1.55
            )

            guard isListening else {
                return
            }

            let rippleOpacity = 0.11 + volume * 0.18
            for index in 1...3 {
                let rippleRect = rect.insetBy(
                    dx: -CGFloat(index) * rect.width * (0.018 + CGFloat(volume) * 0.010),
                    dy: -CGFloat(index) * rect.height * (0.020 + CGFloat(volume) * 0.012)
                )
                let ripple = waterOvalPath(in: rippleRect, phase: phase + Double(index) * 0.38, volume: volume, layer: index)
                var rippleContext = context
                rippleContext.addFilter(.blur(radius: CGFloat(index) * 1.6))
                rippleContext.stroke(
                    ripple,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(rippleOpacity * (1.0 - Double(index) * 0.16)),
                            Color(red: 154 / 255, green: 222 / 255, blue: 218 / 255).opacity(rippleOpacity * 0.74),
                            Color.white.opacity(0.0),
                        ]),
                        startPoint: CGPoint(x: rippleRect.minX, y: rippleRect.minY),
                        endPoint: CGPoint(x: rippleRect.maxX, y: rippleRect.maxY)
                    ),
                    lineWidth: CGFloat(1.2 + volume * 2.2 - Double(index) * 0.16)
                )
            }

            let strong = min(1, max(0, (volume - 0.70) / 0.25))
            if strong > 0 {
                drawStrongVoiceRibbons(in: &context, size: size, rect: rect, phase: phase, strength: strong)
            }
        }
        .blendMode(.plusLighter)
        .opacity(0.98)
    }

    private func circleRect(in size: CGSize) -> CGRect {
        CGRect(
            x: -size.width * 0.18,
            y: size.height * 0.035,
            width: size.width * 1.36,
            height: size.height * 0.52
        )
    }

    private func waterOvalPath(in rect: CGRect, phase: TimeInterval, volume: Double, layer: Int) -> Path {
        var path = Path()
        let steps = 64
        let energy = isListening ? (0.78 + volume * 1.05) : 0.18
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let rx = rect.width * 0.50
        let ry = rect.height * 0.48

        for index in 0...steps {
            let t = Double(index) / Double(steps) * .pi * 2
            let ripple = sin(t * (5.0 + Double(layer) * 0.4) + phase * 0.62) * 0.012 * energy
                + sin(t * 11.0 - phase * 0.48) * 0.006 * energy
            let x = center.x + CGFloat(cos(t)) * rx * CGFloat(1 + ripple)
            let y = center.y + CGFloat(sin(t)) * ry * CGFloat(1 + ripple * 1.35)
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        path.closeSubpath()
        return path
    }

    private func drawStrongVoiceRibbons(
        in context: inout GraphicsContext,
        size: CGSize,
        rect: CGRect,
        phase: TimeInterval,
        strength: Double
    ) {
        for index in 0..<3 {
            let y = rect.midY + rect.height * CGFloat(-0.18 + Double(index) * 0.15)
                + CGFloat(sin(phase * 0.74 + Double(index))) * rect.height * 0.018 * CGFloat(strength)
            let amplitude = rect.height * CGFloat(0.028 + strength * 0.020)
            var path = Path()
            path.move(to: CGPoint(x: size.width * -0.08, y: y))
            path.addCurve(
                to: CGPoint(x: size.width * 0.36, y: y + amplitude * 0.42),
                control1: CGPoint(x: size.width * 0.10, y: y - amplitude),
                control2: CGPoint(x: size.width * 0.22, y: y + amplitude)
            )
            path.addCurve(
                to: CGPoint(x: size.width * 0.74, y: y - amplitude * 0.32),
                control1: CGPoint(x: size.width * 0.50, y: y - amplitude * 0.92),
                control2: CGPoint(x: size.width * 0.62, y: y + amplitude * 0.72)
            )
            path.addCurve(
                to: CGPoint(x: size.width * 1.08, y: y + amplitude * 0.18),
                control1: CGPoint(x: size.width * 0.86, y: y - amplitude * 0.80),
                control2: CGPoint(x: size.width * 0.96, y: y + amplitude * 0.72)
            )

            var ribbon = context
            ribbon.addFilter(.blur(radius: 2.4))
            ribbon.stroke(
                path,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.0),
                        Color.white.opacity(0.18 * strength),
                        Color(red: 151 / 255, green: 224 / 255, blue: 219 / 255).opacity(0.16 * strength),
                        Color.white.opacity(0.0),
                    ]),
                    startPoint: CGPoint(x: 0, y: y),
                    endPoint: CGPoint(x: size.width, y: y)
                ),
                lineWidth: CGFloat(2.0 + strength * 3.0)
            )
        }
    }
}

struct VoiceReactiveAuraBackground: View {
    var signal: VoiceMoodSignal = .idle
    var isListening = false
    var intensity: Double = 1

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        TimelineView(.animation) { timeline in
            let sampledSignal = signal.sampled(at: timeline.date.timeIntervalSinceReferenceDate, active: isListening && !reduceMotion)
            let phase = isListening && !reduceMotion ? timeline.date.timeIntervalSinceReferenceDate : 0

            ZStack {
                Color(red: 246 / 255, green: 248 / 255, blue: 246 / 255)

                GeometryReader { proxy in
                    ZStack(alignment: .top) {
                        VoiceWaterSkyLayer(isListening: isListening)
                            .frame(height: proxy.size.height * 0.60)

                        VoiceWaterCircleLayer(signal: sampledSignal, phase: phase, isListening: isListening)
                            .frame(height: proxy.size.height * 0.60)

                        VoiceWaterRippleLayer(signal: sampledSignal, phase: phase, isListening: isListening)
                            .frame(height: proxy.size.height * 0.60)

                        VoiceMiddleMistLayer(isListening: isListening)
                            .frame(height: proxy.size.height)

                        VoiceBottomFrostLayer(isListening: isListening, reduceTransparency: reduceTransparency)
                            .frame(height: proxy.size.height)
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }

                VitoraTheme.ColorToken.paper
                    .opacity(reduceTransparency ? 0.30 : (isListening ? 0.025 : 0.10) * intensity)
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .accessibilityIdentifier(isListening ? "voice.reactive.aura.listening" : "voice.reactive.aura.idle")
    }
}

private struct VoiceWaterSkyLayer: View {
    var isListening: Bool

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color(red: 249 / 255, green: 249 / 255, blue: 246 / 255).opacity(0.96), location: 0.0),
                .init(color: Color(red: 235 / 255, green: 247 / 255, blue: 244 / 255).opacity(isListening ? 0.78 : 0.58), location: 0.26),
                .init(color: Color(red: 190 / 255, green: 235 / 255, blue: 234 / 255).opacity(isListening ? 0.32 : 0.18), location: 0.54),
                .init(color: Color(red: 250 / 255, green: 250 / 255, blue: 247 / 255).opacity(0.78), location: 1.0),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .blur(radius: isListening ? 20 : 28)
        .opacity(isListening ? 0.92 : 0.72)
        .blendMode(.screen)
    }
}

private struct VoiceWaterCircleLayer: View {
    var signal: VoiceMoodSignal
    var phase: TimeInterval
    var isListening: Bool

    var body: some View {
        Canvas { context, size in
            let rect = membraneRect(in: size)
            let edgeEnergy = CGFloat(isListening ? 0.95 + normalized(signal.volume) * 0.62 + normalized(signal.speechRate) * 0.18 : 0.64)
            let membranePath = waterMembranePath(in: rect, phase: phase, energy: edgeEnergy)

            var glowContext = context
            glowContext.addFilter(.blur(radius: isListening ? 18 : 24))
            glowContext.fill(
                membranePath,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 248 / 255, green: 250 / 255, blue: 247 / 255).opacity(0.0),
                        Color(red: 190 / 255, green: 235 / 255, blue: 234 / 255).opacity(isListening ? 0.58 : 0.42),
                        Color(red: 214 / 255, green: 246 / 255, blue: 241 / 255).opacity(isListening ? 0.34 : 0.26),
                        Color(red: 248 / 255, green: 250 / 255, blue: 247 / 255).opacity(0.0),
                    ]),
                    startPoint: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.22),
                    endPoint: CGPoint(x: rect.midX, y: rect.maxY + rect.height * 0.28)
                )
            )

            context.fill(
                membranePath,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 236 / 255, green: 249 / 255, blue: 246 / 255).opacity(0.72),
                        Color(red: 190 / 255, green: 235 / 255, blue: 234 / 255).opacity(isListening ? 0.82 : 0.68),
                        Color(red: 211 / 255, green: 245 / 255, blue: 240 / 255).opacity(0.70),
                        Color(red: 249 / 255, green: 250 / 255, blue: 247 / 255).opacity(0.58),
                    ]),
                    startPoint: CGPoint(x: rect.midX, y: rect.minY),
                    endPoint: CGPoint(x: rect.midX, y: rect.maxY)
                )
            )

            var innerLightContext = context
            innerLightContext.addFilter(.blur(radius: 26))
            innerLightContext.fill(
                Path(ellipseIn: CGRect(x: rect.minX + rect.width * 0.16, y: rect.minY + rect.height * 0.26, width: rect.width * 0.56, height: rect.height * 0.42)),
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.26),
                        Color(red: 216 / 255, green: 246 / 255, blue: 241 / 255).opacity(0.30),
                        Color.clear,
                    ]),
                    startPoint: CGPoint(x: rect.minX + rect.width * 0.22, y: rect.minY + rect.height * 0.20),
                    endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
                )
            )

            drawSilverRim(in: &context, path: membranePath, rect: rect, isListening: isListening)
            drawGlassHighlights(in: &context, rect: rect, phase: phase, isListening: isListening)
            drawRightWaterTrace(in: &context, rect: rect, phase: phase, isListening: isListening)
        }
        .blendMode(.normal)
    }

    private func drawSilverRim(
        in context: inout GraphicsContext,
        path: Path,
        rect: CGRect,
        isListening: Bool
    ) {
        var outer = context
        outer.addFilter(.blur(radius: 2.8))
        outer.stroke(
            path,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 138 / 255, green: 156 / 255, blue: 156 / 255).opacity(0.42),
                    Color.white.opacity(0.88),
                    Color(red: 184 / 255, green: 203 / 255, blue: 201 / 255).opacity(0.46),
                    Color.white.opacity(0.78),
                ]),
                startPoint: CGPoint(x: rect.minX, y: rect.minY),
                endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
            ),
            lineWidth: isListening ? 7.6 : 6.2
        )

        context.stroke(
            path,
            with: .linearGradient(
                Gradient(colors: [
                    Color.white.opacity(0.96),
                    Color(red: 210 / 255, green: 221 / 255, blue: 220 / 255).opacity(0.82),
                    Color(red: 184 / 255, green: 238 / 255, blue: 235 / 255).opacity(0.34),
                    Color.white.opacity(0.86),
                ]),
                startPoint: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.minY),
                endPoint: CGPoint(x: rect.maxX - rect.width * 0.06, y: rect.maxY)
            ),
            lineWidth: isListening ? 2.2 : 1.8
        )

        context.stroke(
            path,
            with: .color(Color(red: 248 / 255, green: 250 / 255, blue: 247 / 255).opacity(0.56)),
            lineWidth: 0.8
        )
    }

    private func drawGlassHighlights(
        in context: inout GraphicsContext,
        rect: CGRect,
        phase: TimeInterval,
        isListening: Bool
    ) {
        var ovalContext = context
        ovalContext.addFilter(.blur(radius: 5))
        let oval = Path(ellipseIn: CGRect(x: rect.midX - rect.width * 0.13, y: rect.minY + rect.height * 0.08 + CGFloat(sin(phase * 0.7)) * 2, width: rect.width * 0.24, height: rect.height * 0.050))
        ovalContext.fill(oval, with: .color(Color.white.opacity(isListening ? 0.34 : 0.26)))
    }

    private func drawRightWaterTrace(
        in context: inout GraphicsContext,
        rect: CGRect,
        phase: TimeInterval,
        isListening: Bool
    ) {
        var trace = Path()
        let x = rect.maxX - rect.width * 0.18
        trace.move(to: CGPoint(x: x, y: rect.minY + rect.height * 0.12))
        trace.addCurve(
            to: CGPoint(x: x + rect.width * 0.012, y: rect.midY),
            control1: CGPoint(x: x + rect.width * 0.045, y: rect.minY + rect.height * 0.24),
            control2: CGPoint(x: x - rect.width * 0.040, y: rect.minY + rect.height * 0.42 + CGFloat(sin(phase)) * 4)
        )
        trace.addCurve(
            to: CGPoint(x: x - rect.width * 0.010, y: rect.maxY - rect.height * 0.08),
            control1: CGPoint(x: x + rect.width * 0.052, y: rect.midY + rect.height * 0.10),
            control2: CGPoint(x: x - rect.width * 0.044, y: rect.maxY - rect.height * 0.25)
        )

        var blurContext = context
        blurContext.addFilter(.blur(radius: 1.6))
        blurContext.stroke(
            trace,
            with: .linearGradient(
                Gradient(colors: [
                    Color.white.opacity(0.08),
                    Color(red: 143 / 255, green: 159 / 255, blue: 158 / 255).opacity(isListening ? 0.46 : 0.28),
                    Color.white.opacity(0.56),
                    Color(red: 133 / 255, green: 153 / 255, blue: 152 / 255).opacity(0.24),
                ]),
                startPoint: CGPoint(x: x, y: rect.minY),
                endPoint: CGPoint(x: x, y: rect.maxY)
            ),
            lineWidth: isListening ? 2.1 : 1.3
        )
    }

    private func membraneRect(in size: CGSize) -> CGRect {
        CGRect(
            x: -size.width * 0.10,
            y: size.height * 0.13,
            width: size.width * 1.20,
            height: size.height * 0.62
        )
    }

    private func waterMembranePath(in rect: CGRect, phase: TimeInterval, energy: CGFloat) -> Path {
        var path = Path()
        let steps = 22
        let topBase = rect.minY + rect.height * 0.08
        let bottomBase = rect.maxY - rect.height * 0.10
        let topAmplitude = rect.height * 0.026 * energy
        let bottomAmplitude = rect.height * 0.022 * energy

        path.move(to: CGPoint(x: rect.minX, y: topBase + topAmplitude * 0.5))

        for index in 1...steps {
            let progress = CGFloat(index) / CGFloat(steps)
            let previous = CGFloat(index - 1) / CGFloat(steps)
            let x0 = rect.minX + rect.width * previous
            let x1 = rect.minX + rect.width * progress
            let wave = sin(Double(progress) * .pi * 4.8 + phase * 0.85) * Double(topAmplitude)
                + sin(Double(progress) * .pi * 11.0 - phase * 0.42) * Double(topAmplitude) * 0.26
            let y1 = topBase + CGFloat(wave)
            path.addCurve(
                to: CGPoint(x: x1, y: y1),
                control1: CGPoint(x: x0 + rect.width / CGFloat(steps) * 0.38, y: topBase - topAmplitude * 0.95),
                control2: CGPoint(x: x1 - rect.width / CGFloat(steps) * 0.28, y: y1 + topAmplitude * 0.82)
            )
        }

        path.addLine(to: CGPoint(x: rect.maxX, y: bottomBase + bottomAmplitude * 0.35))

        for index in stride(from: steps, through: 0, by: -1) {
            let progress = CGFloat(index) / CGFloat(steps)
            let previous = CGFloat(index + 1) / CGFloat(steps)
            let x0 = rect.minX + rect.width * min(1, previous)
            let x1 = rect.minX + rect.width * progress
            let wave = sin(Double(progress) * .pi * 5.2 - phase * 0.72) * Double(bottomAmplitude)
                + sin(Double(progress) * .pi * 13.0 + phase * 0.52) * Double(bottomAmplitude) * 0.34
            let y1 = bottomBase + CGFloat(wave)
            path.addCurve(
                to: CGPoint(x: x1, y: y1),
                control1: CGPoint(x: x0 - rect.width / CGFloat(steps) * 0.42, y: bottomBase + bottomAmplitude * 1.10),
                control2: CGPoint(x: x1 + rect.width / CGFloat(steps) * 0.30, y: y1 - bottomAmplitude * 0.70)
            )
        }

        path.closeSubpath()
        return path
    }

    private func normalized(_ value: Double) -> Double {
        min(1, max(0, value))
    }
}

private struct VoiceWaterRippleLayer: View {
    var signal: VoiceMoodSignal
    var phase: TimeInterval
    var isListening: Bool

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(x: -size.width * 0.10, y: size.height * 0.13, width: size.width * 1.20, height: size.height * 0.62)
            let volume = normalized(signal.volume)
            let energy = isListening ? max(0.16, volume) : 0.05
            let strong = strongVoiceLevel(volume)

            drawMembraneEdgeRipples(in: &context, rect: rect, energy: energy, phase: phase, isListening: isListening)

            if strong > 0 {
                drawStrongWaterBands(in: &context, size: size, rect: rect, strength: strong, phase: phase)
            }
        }
        .blendMode(.screen)
        .opacity(isListening ? 1 : 0.58)
    }

    private func drawMembraneEdgeRipples(
        in context: inout GraphicsContext,
        rect: CGRect,
        energy: Double,
        phase: TimeInterval,
        isListening: Bool
    ) {
        let rippleCount = isListening ? 4 : 1

        for index in 0..<rippleCount {
            let inset = CGFloat(index) * rect.height * 0.052
            let opacity = (isListening ? 0.22 : 0.08) * (1.0 - Double(index) * 0.18) * (0.40 + energy * 0.48)
            let lineWidth = CGFloat(isListening ? 0.9 + energy * 0.9 : 0.55)
            var path = Path()
            let y = rect.minY + rect.height * (0.08 + CGFloat(index) * 0.080)
            path.move(to: CGPoint(x: rect.minX + rect.width * 0.05, y: y))
            path.addCurve(
                to: CGPoint(x: rect.maxX - rect.width * 0.05, y: y + CGFloat(sin(phase * 0.50 + Double(index))) * rect.height * 0.006),
                control1: CGPoint(x: rect.minX + rect.width * 0.30, y: y - inset - rect.height * 0.026),
                control2: CGPoint(x: rect.minX + rect.width * 0.68, y: y + inset + rect.height * 0.020)
            )
            context.stroke(
                path,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.0),
                        Color.white.opacity(opacity * 1.4),
                        Color(red: 197 / 255, green: 237 / 255, blue: 235 / 255).opacity(opacity),
                        Color.white.opacity(0.0),
                    ]),
                    startPoint: CGPoint(x: rect.minX, y: y),
                    endPoint: CGPoint(x: rect.maxX, y: y)
                ),
                lineWidth: lineWidth
            )
        }
    }

    private func drawStrongWaterBands(
        in context: inout GraphicsContext,
        size: CGSize,
        rect: CGRect,
        strength: Double,
        phase: TimeInterval
    ) {
        let bandCount = 4
        var blurred = context
        blurred.addFilter(.blur(radius: 1.8))

        for index in 0..<bandCount {
            let y = rect.minY + rect.height * (0.11 + CGFloat(index) * 0.115)
                + CGFloat(sin(phase * 0.72 + Double(index) * 0.64)) * rect.height * 0.010 * CGFloat(strength)
            let waveHeight = rect.height * CGFloat(0.018 + strength * 0.025)
            let ribbonHeight = CGFloat(5.5 + strength * 5.0)
            let phaseOffset = phase * (0.52 + Double(index) * 0.04)

            var upper = Path()
            upper.move(to: CGPoint(x: size.width * -0.08, y: y))
            upper.addCurve(
                to: CGPoint(x: size.width * 0.34, y: y + waveHeight * CGFloat(sin(phaseOffset + 0.7))),
                control1: CGPoint(x: size.width * 0.08, y: y - waveHeight * 0.80),
                control2: CGPoint(x: size.width * 0.22, y: y + waveHeight * 0.70)
            )
            upper.addCurve(
                to: CGPoint(x: size.width * 0.68, y: y + waveHeight * CGFloat(sin(phaseOffset + 1.8))),
                control1: CGPoint(x: size.width * 0.45, y: y - waveHeight * 0.72),
                control2: CGPoint(x: size.width * 0.56, y: y + waveHeight * 0.72)
            )
            upper.addCurve(
                to: CGPoint(x: size.width * 1.08, y: y + waveHeight * CGFloat(sin(phaseOffset + 2.7))),
                control1: CGPoint(x: size.width * 0.80, y: y - waveHeight * 0.70),
                control2: CGPoint(x: size.width * 0.92, y: y + waveHeight * 0.64)
            )

            var ribbon = upper
            ribbon.addLine(to: CGPoint(x: size.width * 1.08, y: y + ribbonHeight))
            ribbon.addCurve(
                to: CGPoint(x: size.width * 0.66, y: y + ribbonHeight + waveHeight * 0.30),
                control1: CGPoint(x: size.width * 0.94, y: y + ribbonHeight + waveHeight * 0.32),
                control2: CGPoint(x: size.width * 0.80, y: y + ribbonHeight - waveHeight * 0.20)
            )
            ribbon.addCurve(
                to: CGPoint(x: size.width * 0.28, y: y + ribbonHeight - waveHeight * 0.20),
                control1: CGPoint(x: size.width * 0.52, y: y + ribbonHeight + waveHeight * 0.48),
                control2: CGPoint(x: size.width * 0.40, y: y + ribbonHeight - waveHeight * 0.36)
            )
            ribbon.addLine(to: CGPoint(x: size.width * -0.08, y: y + ribbonHeight))
            ribbon.closeSubpath()

            let fillOpacity = strength * (0.090 - Double(index) * 0.008)
            blurred.fill(
                ribbon,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.0),
                        Color.white.opacity(fillOpacity * 1.5),
                        Color(red: 190 / 255, green: 235 / 255, blue: 234 / 255).opacity(fillOpacity),
                        Color.white.opacity(0.0),
                    ]),
                    startPoint: CGPoint(x: 0, y: y),
                    endPoint: CGPoint(x: size.width, y: y)
                )
            )

            let strokeOpacity = strength * (0.16 - Double(index) * 0.018)
            blurred.stroke(
                upper,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.0),
                        Color.white.opacity(strokeOpacity * 1.2),
                        Color(red: 182 / 255, green: 213 / 255, blue: 211 / 255).opacity(strokeOpacity),
                        Color.white.opacity(0.0),
                    ]),
                    startPoint: CGPoint(x: 0, y: y),
                    endPoint: CGPoint(x: size.width, y: y)
                ),
                lineWidth: CGFloat(0.8 + strength * 1.2)
            )
        }
    }

    private func normalized(_ value: Double) -> Double {
        min(1, max(0, value))
    }

    private func strongVoiceLevel(_ volume: Double) -> Double {
        min(1, max(0, (volume - 0.70) / 0.25))
    }
}

private struct VoiceMiddleMistLayer: View {
    var isListening: Bool

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0.20),
                .init(color: Color(red: 247 / 255, green: 249 / 255, blue: 246 / 255).opacity(isListening ? 0.30 : 0.42), location: 0.42),
                .init(color: Color(red: 250 / 255, green: 250 / 255, blue: 247 / 255).opacity(0.78), location: 0.58),
                .init(color: Color(red: 224 / 255, green: 243 / 255, blue: 239 / 255).opacity(0.34), location: 0.78),
                .init(color: .clear, location: 1.0),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .blendMode(.screen)
    }
}

private struct VoiceBottomFrostLayer: View {
    var isListening: Bool
    var reduceTransparency: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.42),
                            .init(color: .black.opacity(0.52), location: 0.63),
                            .init(color: .black, location: 1.0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.34),
                    .init(color: Color(red: 250 / 255, green: 250 / 255, blue: 247 / 255).opacity(reduceTransparency ? 0.86 : 0.62), location: 0.52),
                    .init(color: Color(red: 220 / 255, green: 243 / 255, blue: 239 / 255).opacity(isListening ? 0.42 : 0.32), location: 0.70),
                    .init(color: Color(red: 181 / 255, green: 226 / 255, blue: 224 / 255).opacity(isListening ? 0.30 : 0.22), location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VoiceFrostEdgeLayer(isListening: isListening)
                .opacity(reduceTransparency ? 0.18 : 0.38)
        }
    }
}

private struct VoiceFrostEdgeLayer: View {
    var isListening: Bool

    var body: some View {
        Canvas { context, size in
            let top = size.height * 0.56
            let amplitude = size.height * (isListening ? 0.014 : 0.009)

            var path = Path()
            path.move(to: CGPoint(x: 0, y: top))

            for index in stride(from: 0, through: Int(size.width), by: 12) {
                let x = CGFloat(index)
                let wave = sin(Double(index) * 0.042) * amplitude + sin(Double(index) * 0.119) * amplitude * 0.35
                path.addLine(to: CGPoint(x: x, y: top + wave))
            }

            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.closeSubpath()

            var blurContext = context
            blurContext.addFilter(.blur(radius: 14))
            blurContext.fill(
                path,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.36),
                        Color(red: 205 / 255, green: 234 / 255, blue: 231 / 255).opacity(0.32),
                        Color(red: 156 / 255, green: 205 / 255, blue: 202 / 255).opacity(0.22),
                    ]),
                    startPoint: CGPoint(x: size.width * 0.5, y: top),
                    endPoint: CGPoint(x: size.width * 0.5, y: size.height)
                )
            )
        }
        .blendMode(.screen)
    }
}
enum GlassSurfaceVariant {
    case standard
    case active
    case resting
    case whiteResting
    case whiteActive
    case cleanResting
    case cleanElevated
    case cleanInset
}

struct GlassSurface: View {
    var cornerRadius: CGFloat = VitoraTheme.Radius.card
    var opacity: Double = 0.50
    var shadowStrength: Double = 1
    var variant: GlassSurfaceVariant = .standard

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .opacity(materialOpacity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                topFillColor.opacity(topFillOpacity),
                                bottomFillColor.opacity(bottomFillOpacity),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                VitoraTheme.ColorToken.surfacePearlMain.opacity(borderPrimaryOpacity),
                                Color(red: 207 / 255, green: 220 / 255, blue: 215 / 255).opacity(borderSecondaryOpacity),
                                Color.white.opacity(borderTertiaryOpacity),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.05
                    )
            )
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(highlightOpacity),
                                .clear,
                            ],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .blendMode(.screen)
            }
            .overlay(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color(red: 170 / 255, green: 189 / 255, blue: 184 / 255).opacity(coolEdgeOpacity), lineWidth: 2.0)
                    .blur(radius: 2.2)
                    .blendMode(.softLight)
            }
            .shadow(color: shadowColor.opacity(shadowOpacity * shadowStrength), radius: 15 * shadowStrength, x: 0, y: 7 * shadowStrength)
            .accessibilityIdentifier("glass.surface")
    }

    private var topFillColor: Color {
        switch variant {
        case .cleanInset:
            return VitoraTheme.ColorToken.surfacePearlInset
        case .cleanResting, .cleanElevated, .whiteResting, .whiteActive:
            return VitoraTheme.ColorToken.surfacePearlMain
        default:
            return VitoraTheme.ColorToken.paper
        }
    }

    private var bottomFillColor: Color {
        switch variant {
        case .cleanInset:
            return Color(red: 235 / 255, green: 230 / 255, blue: 224 / 255)
        case .cleanResting:
            return Color(red: 250 / 255, green: 246 / 255, blue: 239 / 255)
        case .cleanElevated, .whiteResting, .whiteActive:
            return Color(red: 255 / 255, green: 250 / 255, blue: 244 / 255)
        default:
            return VitoraTheme.ColorToken.paper
        }
    }

    private var shadowColor: Color {
        switch variant {
        case .cleanResting, .cleanElevated, .cleanInset, .whiteResting, .whiteActive:
            return VitoraTheme.ColorToken.paperLiftShadow
        default:
            return VitoraTheme.ColorToken.auraBlue
        }
    }

    private var tunedOpacity: Double {
        switch variant {
        case .standard:
            return opacity
        case .active:
            return min(0.32, max(0.18, opacity * 0.50))
        case .resting:
            return min(0.24, max(0.10, opacity * 0.36))
        case .whiteResting:
            return min(0.78, max(0.56, opacity + 0.16))
        case .whiteActive:
            return min(0.86, max(0.64, opacity + 0.22))
        case .cleanResting:
            return min(0.82, max(0.62, opacity + 0.20))
        case .cleanElevated:
            return min(0.90, max(0.70, opacity + 0.26))
        case .cleanInset:
            return min(0.70, max(0.50, opacity + 0.08))
        }
    }

    private var materialOpacity: Double {
        switch variant {
        case .standard:
            return 1
        case .active:
            return 0.58
        case .resting:
            return 0.46
        case .whiteResting:
            return 0.82
        case .whiteActive:
            return 0.88
        case .cleanResting:
            return 0.74
        case .cleanElevated:
            return 0.82
        case .cleanInset:
            return 0.60
        }
    }

    private var topFillOpacity: Double {
        switch variant {
        case .standard:
            return min(0.72, tunedOpacity + 0.10)
        case .active:
            return min(0.46, tunedOpacity + 0.08)
        case .resting:
            return min(0.34, tunedOpacity + 0.06)
        case .whiteResting:
            return min(0.92, tunedOpacity + 0.10)
        case .whiteActive:
            return min(0.96, tunedOpacity + 0.12)
        case .cleanResting:
            return min(0.94, tunedOpacity + 0.12)
        case .cleanElevated:
            return min(0.98, tunedOpacity + 0.14)
        case .cleanInset:
            return min(0.84, tunedOpacity + 0.08)
        }
    }

    private var bottomFillOpacity: Double {
        switch variant {
        case .standard:
            return max(0.30, tunedOpacity - 0.10)
        case .active:
            return max(0.16, tunedOpacity - 0.08)
        case .resting:
            return max(0.10, tunedOpacity - 0.08)
        case .whiteResting:
            return max(0.58, tunedOpacity - 0.08)
        case .whiteActive:
            return max(0.66, tunedOpacity - 0.06)
        case .cleanResting:
            return max(0.64, tunedOpacity - 0.06)
        case .cleanElevated:
            return max(0.72, tunedOpacity - 0.04)
        case .cleanInset:
            return max(0.50, tunedOpacity - 0.12)
        }
    }

    private var borderPrimaryOpacity: Double {
        switch variant {
        case .standard:
            return 0.98
        case .active:
            return 0.92
        case .resting:
            return 0.74
        case .whiteResting:
            return 0.94
        case .whiteActive:
            return 1.0
        case .cleanResting:
            return 0.92
        case .cleanElevated:
            return 1.0
        case .cleanInset:
            return 0.76
        }
    }

    private var borderSecondaryOpacity: Double {
        switch variant {
        case .standard:
            return 0.58
        case .active:
            return 0.72
        case .resting:
            return 0.46
        case .whiteResting:
            return 0.30
        case .whiteActive:
            return 0.42
        case .cleanResting:
            return 0.22
        case .cleanElevated:
            return 0.32
        case .cleanInset:
            return 0.18
        }
    }

    private var borderTertiaryOpacity: Double {
        switch variant {
        case .standard:
            return 0.64
        case .active:
            return 0.58
        case .resting:
            return 0.38
        case .whiteResting:
            return 0.72
        case .whiteActive:
            return 0.84
        case .cleanResting:
            return 0.70
        case .cleanElevated:
            return 0.82
        case .cleanInset:
            return 0.44
        }
    }

    private var highlightOpacity: Double {
        switch variant {
        case .standard:
            return 0.50
        case .active:
            return 0.36
        case .resting:
            return 0.20
        case .whiteResting:
            return 0.58
        case .whiteActive:
            return 0.68
        case .cleanResting:
            return 0.48
        case .cleanElevated:
            return 0.62
        case .cleanInset:
            return 0.28
        }
    }

    private var coolEdgeOpacity: Double {
        switch variant {
        case .standard:
            return 0.13
        case .active:
            return 0.20
        case .resting:
            return 0.11
        case .whiteResting:
            return 0.08
        case .whiteActive:
            return 0.12
        case .cleanResting:
            return 0.055
        case .cleanElevated:
            return 0.09
        case .cleanInset:
            return 0.035
        }
    }

    private var shadowOpacity: Double {
        switch variant {
        case .standard:
            return 0.09
        case .active:
            return 0.075
        case .resting:
            return 0.045
        case .whiteResting:
            return 0.045
        case .whiteActive:
            return 0.065
        case .cleanResting:
            return 0.035
        case .cleanElevated:
            return 0.060
        case .cleanInset:
            return 0.018
        }
    }
}

struct PearlGradientSurface: View {
    var cornerRadius: CGFloat = VitoraTheme.Radius.sheet
    var warmStrength: Double = 1
    var cyanStrength: Double = 1
    var materialOpacity: Double = 0.12
    var shadowStrength: Double = 0.28

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack {
            shape
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: VitoraTheme.ColorToken.surfacePearlMain.opacity(0.98), location: 0.0),
                            .init(color: Color(red: 253 / 255, green: 249 / 255, blue: 242 / 255).opacity(0.94), location: 0.44),
                            .init(color: Color(red: 239 / 255, green: 246 / 255, blue: 242 / 255).opacity(0.84), location: 1.0),
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )

            shape
                .fill(.ultraThinMaterial)
                .opacity(materialOpacity)

            RadialGradient(
                colors: [
                    VitoraTheme.ColorToken.paperWarmPeachMist.opacity(0.22 * warmStrength),
                    Color(red: 248 / 255, green: 226 / 255, blue: 214 / 255).opacity(0.12 * warmStrength),
                    .clear,
                ],
                center: .topTrailing,
                startRadius: 1,
                endRadius: 270
            )

            RadialGradient(
                colors: [
                    VitoraTheme.ColorToken.paperWarmCyanMist.opacity(0.26 * cyanStrength),
                    Color(red: 241 / 255, green: 250 / 255, blue: 247 / 255).opacity(0.13 * cyanStrength),
                    .clear,
                ],
                center: .bottomLeading,
                startRadius: 1,
                endRadius: 300
            )

            RadialGradient(
                colors: [
                    Color.white.opacity(0.42),
                    VitoraTheme.ColorToken.surfacePearlMain.opacity(0.16),
                    .clear,
                ],
                center: .center,
                startRadius: 1,
                endRadius: 220
            )
        }
        .clipShape(shape)
        .overlay {
            shape
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.92),
                            Color(red: 216 / 255, green: 227 / 255, blue: 222 / 255).opacity(0.46),
                            VitoraTheme.ColorToken.surfacePearlMain.opacity(0.78),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.16 * shadowStrength), radius: 24 * shadowStrength, x: 0, y: 14 * shadowStrength)
        .shadow(color: Color.white.opacity(0.58 * shadowStrength), radius: 12 * shadowStrength, x: -7, y: -7)
    }
}

struct SupportGlassSurface: View {
    var body: some View {
        GlassSurface(cornerRadius: VitoraTheme.Radius.card, opacity: 0.74, shadowStrength: 0.34, variant: .cleanResting)
    }
}

struct InputDockSurface: View {
    var body: some View {
        Capsule(style: .continuous)
            .fill(.ultraThinMaterial)
            .background(Capsule(style: .continuous).fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.72)))
            .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(0.86), lineWidth: 0.8))
            .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.12), radius: 16, x: 0, y: 8)
            .accessibilityIdentifier("input.dock.surface")
    }
}

struct FrostedSheetHeader: View {
    let title: String
    var subtitle: String?
    var closeTitle = "关闭"
    var closeAccessibilityID: String?
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 7) {
            HStack(alignment: .center) {
                Button(closeTitle, action: onClose)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .frame(minWidth: 58, minHeight: VitoraTheme.Size.touchTargetMin, alignment: .leading)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier(closeAccessibilityID ?? "frosted.sheet.close")

                Spacer(minLength: 8)

                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .layoutPriority(1)

                Spacer(minLength: 8)

                Color.clear
                    .frame(width: 58, height: VitoraTheme.Size.touchTargetMin)
            }

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 4)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("frosted.sheet.header")
    }
}

struct FrostedSheetShell<Content: View>: View {
    let title: String
    var subtitle: String?
    var closeAccessibilityID: String?
    let onClose: () -> Void
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        closeAccessibilityID: String? = nil,
        onClose: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.closeAccessibilityID = closeAccessibilityID
        self.onClose = onClose
        self.content = content()
    }

    var body: some View {
        ZStack {
            PremiumAuraBackground(scene: .sheet, intensity: 0.82)

            LinearGradient(
                colors: [
                    VitoraTheme.ColorToken.paperWarmLift.opacity(0.18),
                    VitoraTheme.ColorToken.paperWarmBase.opacity(0.08),
                    VitoraTheme.ColorToken.paperWarmCyanMist.opacity(0.16),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            RadialGradient(
                colors: [
                    VitoraTheme.ColorToken.paperWarmPeachMist.opacity(0.10),
                    .clear,
                ],
                center: .topTrailing,
                startRadius: 1,
                endRadius: 300
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    FrostedSheetHeader(
                        title: title,
                        subtitle: subtitle,
                        closeAccessibilityID: closeAccessibilityID,
                        onClose: onClose
                    )

                    content
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 34)
            }
        }
        .accessibilityIdentifier("frosted.sheet.shell")
    }
}

struct VitoraCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(VitoraTheme.Spacing.md)
            .background(VitoraTheme.ColorToken.surfacePearlMain)
            .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.card, style: .continuous))
            .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.12), radius: 18, x: 0, y: 8)
    }
}

struct VitoraSheetSurface<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: VitoraTheme.Spacing.md) {
            Capsule()
                .fill(VitoraTheme.ColorToken.secondaryText.opacity(0.35))
                .frame(width: 42, height: 4)

            content
        }
        .padding(VitoraTheme.Spacing.lg)
        .background(GlassSurface(cornerRadius: VitoraTheme.Radius.sheet, opacity: 0.80, shadowStrength: 0.42, variant: .cleanElevated))
        .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.sheet, style: .continuous))
        .shadow(color: VitoraTheme.ColorToken.auraBlue.opacity(0.10), radius: 24, x: 0, y: -6)
    }
}
