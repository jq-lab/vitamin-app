import SwiftUI

enum PixelVitoraState {
    case idle
    case listening
    case thinking
    case confirming
    case sleeping
    case energetic
    case questioning
}

enum PixelVitoraAccessory {
    case none
    case clipboard
    case pencil
    case voice
}

enum PixelVitoraMaterialStyle {
    case standard
    case heroCompanion
    case tabFace
    case ambientBackground
}

private struct SoftVitoraBlobShape: InsettableShape {
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
        }

        var path = Path()
        path.move(to: point(0.50, 0.01))
        path.addCurve(to: point(0.82, 0.22), control1: point(0.67, -0.01), control2: point(0.80, 0.08))
        path.addCurve(to: point(0.91, 0.41), control1: point(0.89, 0.24), control2: point(0.94, 0.33))
        path.addCurve(to: point(0.99, 0.54), control1: point(1.02, 0.42), control2: point(1.05, 0.50))
        path.addCurve(to: point(0.89, 0.68), control1: point(1.03, 0.63), control2: point(0.96, 0.70))
        path.addCurve(to: point(0.70, 0.91), control1: point(0.86, 0.82), control2: point(0.79, 0.90))
        path.addCurve(to: point(0.29, 0.91), control1: point(0.57, 0.98), control2: point(0.38, 0.98))
        path.addCurve(to: point(0.16, 0.72), control1: point(0.20, 0.90), control2: point(0.14, 0.82))
        path.addCurve(to: point(0.02, 0.58), control1: point(0.07, 0.72), control2: point(-0.02, 0.66))
        path.addCurve(to: point(0.12, 0.43), control1: point(-0.04, 0.49), control2: point(0.03, 0.42))
        path.addCurve(to: point(0.24, 0.20), control1: point(0.10, 0.30), control2: point(0.16, 0.21))
        path.addCurve(to: point(0.50, 0.01), control1: point(0.29, 0.06), control2: point(0.40, 0.01))
        path.closeSubpath()
        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}

private struct BlobColorClouds: View {
    var size: CGFloat
    var style: PixelVitoraMaterialStyle = .standard

    var body: some View {
        ZStack {
            cloud(
                color: Color(red: 255 / 255, green: 84 / 255, blue: 144 / 255),
                width: 0.74,
                height: 0.72,
                x: -0.13,
                y: -0.07,
                opacity: style.cloudOpacity(0.86)
            )
            cloud(
                color: Color(red: 255 / 255, green: 121 / 255, blue: 51 / 255),
                width: 0.72,
                height: 0.62,
                x: 0.14,
                y: 0.10,
                opacity: style.cloudOpacity(0.82)
            )
            cloud(
                color: Color(red: 255 / 255, green: 232 / 255, blue: 103 / 255),
                width: 0.50,
                height: 0.42,
                x: 0.16,
                y: 0.25,
                opacity: style.cloudOpacity(0.74)
            )
            cloud(
                color: Color(red: 88 / 255, green: 220 / 255, blue: 242 / 255),
                width: 0.42,
                height: 0.38,
                x: 0.32,
                y: 0.36,
                opacity: style.edgeOpacity(0.42)
            )
            cloud(
                color: Color(red: 153 / 255, green: 141 / 255, blue: 246 / 255),
                width: 0.48,
                height: 0.52,
                x: -0.30,
                y: 0.30,
                opacity: style.edgeOpacity(0.28)
            )
            cloud(
                color: Color.white,
                width: 0.58,
                height: 0.40,
                x: -0.04,
                y: -0.35,
                opacity: style.whiteCloudOpacity
            )
        }
        .frame(width: size * 1.05, height: size * 0.98)
        .blur(radius: max(6, size * 0.085))
    }

    private func cloud(color: Color, width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat, opacity: Double) -> some View {
        Ellipse()
            .fill(color.opacity(opacity))
            .frame(width: size * width, height: size * height)
            .offset(x: size * x, y: size * y)
    }
}

private extension PixelVitoraMaterialStyle {
    func cloudOpacity(_ base: Double) -> Double {
        switch self {
        case .standard:
            return base * 0.72
        case .heroCompanion:
            return base * 0.30
        case .tabFace:
            return base * 0.62
        case .ambientBackground:
            return base * 0.38
        }
    }

    func edgeOpacity(_ base: Double) -> Double {
        switch self {
        case .standard:
            return base * 0.66
        case .heroCompanion:
            return base * 0.24
        case .tabFace:
            return base * 0.54
        case .ambientBackground:
            return base * 0.32
        }
    }

    var paperOpacity: Double {
        switch self {
        case .standard:
            return 0.78
        case .heroCompanion:
            return 0.92
        case .tabFace:
            return 0.80
        case .ambientBackground:
            return 0.72
        }
    }

    var glowMultiplier: Double {
        switch self {
        case .standard:
            return 0.74
        case .heroCompanion:
            return 0.34
        case .tabFace:
            return 0.66
        case .ambientBackground:
            return 0.34
        }
    }

    var whiteCloudOpacity: Double {
        switch self {
        case .standard:
            return 0.48
        case .heroCompanion:
            return 0.70
        case .tabFace:
            return 0.50
        case .ambientBackground:
            return 0.42
        }
    }
}

private struct FrostedVitoraSkin: View {
    var size: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<16, id: \.self) { index in
                let x = CGFloat((index * 37) % 100) / 100 - 0.50
                let y = CGFloat((index * 53) % 100) / 100 - 0.48
                let scale = CGFloat(18 + (index * 11) % 34) / 100
                Circle()
                    .fill(
                        index.isMultiple(of: 3)
                            ? VitoraTheme.ColorToken.paper.opacity(0.13)
                            : Color(red: 214 / 255, green: 222 / 255, blue: 236 / 255).opacity(0.09)
                    )
                    .frame(width: size * scale, height: size * scale * 0.74)
                    .blur(radius: size * 0.045)
                    .offset(x: size * x, y: size * y)
            }
        }
        .blendMode(.screen)
    }
}

struct PixelVitoraView: View {
    var state: PixelVitoraState = .idle
    var size: CGFloat = 96
    var showsGlow: Bool = true
    var materialStyle: PixelVitoraMaterialStyle = .standard
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathes = false
    @State private var blinks = false

    var body: some View {
        ZStack {
            if showsGlow {
                SoftVitoraBlobShape()
                    .fill(
                        RadialGradient(
                            colors: [
                                VitoraTheme.ColorToken.paper.opacity(0.58),
                                Color(red: 255 / 255, green: 104 / 255, blue: 142 / 255).opacity(glowOpacity * 0.66 * materialStyle.glowMultiplier),
                                Color(red: 255 / 255, green: 173 / 255, blue: 55 / 255).opacity(glowOpacity * 0.58 * materialStyle.glowMultiplier),
                                VitoraTheme.ColorToken.auraCyan.opacity(glowOpacity * 0.22 * materialStyle.glowMultiplier),
                                .clear,
                            ],
                            center: .center,
                            startRadius: size * 0.08,
                            endRadius: size * 0.98
                        )
                    )
                    .frame(width: size * 1.86, height: size * 1.72)
                    .blur(radius: size * 0.22)
                    .opacity(reduceMotion ? 0.82 : (breathes ? 0.94 : 0.62))
                    .scaleEffect(reduceMotion ? 1 : (breathes ? 1.08 : 0.96))
            }

            SoftVitoraBlobShape()
                .fill(VitoraTheme.ColorToken.paper.opacity(materialStyle.paperOpacity))
                .frame(width: size * 1.05, height: size * 0.98)
                .overlay {
                    SoftVitoraBlobShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 253 / 255, green: 250 / 255, blue: 255 / 255).opacity(0.80),
                                    Color(red: 236 / 255, green: 234 / 255, blue: 246 / 255).opacity(0.50),
                                    Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255).opacity(0.34),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    BlobColorClouds(size: size, style: materialStyle)
                        .clipShape(SoftVitoraBlobShape())
                        .blendMode(.plusLighter)
                }
                .overlay {
                    FrostedVitoraSkin(size: size)
                        .clipShape(SoftVitoraBlobShape())
                        .opacity(0.76)
                }
                .overlay {
                    SoftVitoraBlobShape()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    VitoraTheme.ColorToken.paper.opacity(0.98),
                                    Color(red: 229 / 255, green: 224 / 255, blue: 238 / 255).opacity(0.74),
                                    Color(red: 212 / 255, green: 224 / 255, blue: 244 / 255).opacity(0.50),
                                    VitoraTheme.ColorToken.paper.opacity(0.86),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: max(1.8, size * 0.034)
                        )
                        .blur(radius: size * 0.008)
                }
                .overlay {
                    SoftVitoraBlobShape()
                        .stroke(
                            VitoraTheme.ColorToken.paper.opacity(0.36),
                            lineWidth: max(0.8, size * 0.010)
                        )
                        .padding(size * 0.045)
                        .blur(radius: size * 0.012)
                }
                .overlay(alignment: .topLeading) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    VitoraTheme.ColorToken.paper.opacity(0.44),
                                    VitoraTheme.ColorToken.paper.opacity(0.14),
                                    .clear,
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size * 0.32, height: size * 0.10)
                        .blur(radius: size * 0.022)
                        .rotationEffect(.degrees(-34))
                        .offset(x: size * 0.18, y: size * 0.12)
                        .blendMode(.screen)
                }
                .overlay(alignment: .bottomTrailing) {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    VitoraTheme.ColorToken.auraCyan.opacity(0.50),
                                    Color(red: 173 / 255, green: 214 / 255, blue: 255 / 255).opacity(0.30),
                                    .clear,
                                ],
                                center: .bottomTrailing,
                                startRadius: 1,
                                endRadius: size * 0.60
                            )
                        )
                        .frame(width: size * 0.86, height: size * 0.86)
                        .blur(radius: size * 0.055)
                        .offset(x: size * 0.02, y: size * 0.06)
                        .blendMode(.screen)
                }
                .shadow(color: VitoraTheme.ColorToken.paper.opacity(0.74), radius: size * 0.07, x: -size * 0.03, y: -size * 0.04)
                .shadow(color: Color(red: 255 / 255, green: 126 / 255, blue: 158 / 255).opacity(0.24), radius: size * 0.22, x: 0, y: 0)
                .shadow(color: VitoraTheme.ColorToken.auraBlue.opacity(0.10), radius: size * 0.24, x: 0, y: size * 0.10)
                .scaleEffect(reduceMotion ? 1 : (breathes ? breathScale.upper : breathScale.lower))

            HStack(spacing: size * 0.17) {
                pixelEye(index: 0)
                pixelEye(index: 1)
            }
            .offset(y: -size * 0.055)
        }
        .frame(width: size * 1.42, height: size * 1.38)
        .scaleEffect(stateScale)
        .offset(y: stateYOffset)
        .accessibilityLabel("像素 Vitora")
        .accessibilityIdentifier("pixel.vitora")
        .onAppear {
            guard !reduceMotion else {
                return
            }
            withAnimation(.easeInOut(duration: breathDuration).repeatForever(autoreverses: true)) {
                breathes = true
            }
        }
        .task {
            await runBlinkLoop()
        }
    }

    private func pixelEye(index: Int) -> some View {
        let pixelSize = max(3.8, size * 0.058)
        return VStack(spacing: max(0.55, size * 0.005)) {
            ForEach(0..<6, id: \.self) { row in
                HStack(spacing: max(0.55, size * 0.005)) {
                    ForEach(0..<2, id: \.self) { column in
                        let isActive = blinks ? isBlinkPixelActive(row: row, column: column) : isEyePixelActive(row: row, column: column, eyeIndex: index)
                        RoundedRectangle(cornerRadius: 1.4, style: .continuous)
                            .fill(
                                isActive
                                    ? LinearGradient(
                                        colors: [
                                            VitoraTheme.ColorToken.paper.opacity(1.0),
                                            Color(red: 255 / 255, green: 244 / 255, blue: 210 / 255).opacity(0.86),
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    : LinearGradient(colors: [.clear, .clear], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: pixelSize, height: pixelSize)
                            .shadow(color: VitoraTheme.ColorToken.paper.opacity(isActive ? 0.88 : 0), radius: size * 0.030, x: 0, y: 0)
                            .shadow(color: Color(red: 255 / 255, green: 217 / 255, blue: 150 / 255).opacity(isActive ? 0.80 : 0), radius: size * 0.055, x: 0, y: 0)
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func isEyePixelActive(row: Int, column: Int, eyeIndex: Int) -> Bool {
        let active: Set<String>
        switch state {
        case .idle:
            active = [
                "0-0", "0-1", "1-0", "1-1", "2-0", "2-1",
                "3-0", "3-1", "4-0", "4-1", "5-0", "5-1",
            ]
        case .listening:
            active = eyeIndex == 0
                ? [
                    "0-0", "0-1", "1-0", "1-1", "2-0", "2-1",
                    "3-0", "3-1", "4-0", "4-1", "5-0", "5-1",
                ]
                : [
                    "0-0", "0-1", "1-0", "1-1", "2-0", "2-1",
                    "3-0", "3-1", "4-0", "4-1", "5-0", "5-1",
                ]
        case .thinking:
            active = eyeIndex == 0
                ? ["0-0", "0-1", "1-0", "1-1", "2-0", "2-1", "3-0", "3-1", "4-0", "4-1"]
                : ["1-0", "1-1", "2-0", "2-1", "3-0", "3-1", "4-0", "4-1", "5-0", "5-1"]
        case .confirming:
            active = eyeIndex == 0
                ? [
                    "0-0", "0-1", "1-0", "1-1", "2-0", "2-1",
                    "3-0", "3-1", "4-0", "4-1", "5-0", "5-1",
                ]
                : ["2-0", "2-1", "3-0", "3-1", "4-0", "4-1"]
        case .sleeping:
            active = eyeIndex == 0
                ? ["3-0", "4-0", "4-1", "5-1"]
                : ["3-1", "4-0", "4-1", "5-0"]
        case .energetic:
            active = [
                "0-0", "0-1", "1-0", "1-1", "2-0", "2-1",
                "3-0", "3-1", "4-0", "4-1", "5-0", "5-1",
            ]
        case .questioning:
            active = eyeIndex == 0
                ? ["0-0", "0-1", "1-0", "1-1", "2-0", "2-1", "3-0", "3-1", "4-0", "4-1", "5-0", "5-1"]
                : ["1-0", "1-1", "2-0", "2-1", "3-0", "3-1", "4-0", "4-1"]
        }
        return active.contains("\(row)-\(column)")
    }

    private func isBlinkPixelActive(row: Int, column: Int) -> Bool {
        (row == 2 || row == 3) && (column == 0 || column == 1)
    }

    private var breathScale: (lower: CGFloat, upper: CGFloat) {
        switch state {
        case .listening:
            return (0.990, 1.024)
        case .thinking:
            return (0.986, 1.030)
        case .confirming:
            return (0.992, 1.018)
        case .sleeping:
            return (0.976, 1.006)
        case .energetic:
            return (0.996, 1.034)
        case .questioning:
            return (0.990, 1.026)
        case .idle:
            return (0.990, 1.020)
        }
    }

    private var glowOpacity: Double {
        switch state {
        case .listening:
            return 0.72
        case .thinking:
            return 0.78
        case .confirming:
            return 0.66
        case .sleeping:
            return 0.46
        case .energetic:
            return 0.74
        case .questioning:
            return 0.68
        case .idle:
            return 0.58
        }
    }

    private var breathDuration: Double {
        switch state {
        case .listening:
            return 2.6
        case .thinking:
            return 2.4
        case .confirming:
            return 2.9
        case .sleeping:
            return 4.2
        case .energetic:
            return 2.2
        case .questioning:
            return 2.8
        case .idle:
            return 3.4
        }
    }

    private var stateScale: CGFloat {
        switch state {
        case .sleeping:
            return 0.93
        case .energetic:
            return 1.04
        default:
            return 1.0
        }
    }

    private var stateYOffset: CGFloat {
        switch state {
        case .sleeping:
            return size * 0.045
        case .energetic:
            return -size * 0.025
        default:
            return 0
        }
    }

    private func runBlinkLoop() async {
        guard !reduceMotion else {
            return
        }

        while !Task.isCancelled {
            let wait = UInt64.random(in: 4_000_000_000...7_000_000_000)
            try? await Task.sleep(nanoseconds: wait)
            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.07)) {
                    blinks = true
                }
            }

            try? await Task.sleep(nanoseconds: 140_000_000)
            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.09)) {
                    blinks = false
                }
            }
        }
    }
}

struct PixelVitoraScene: View {
    var state: PixelVitoraState = .idle
    var size: CGFloat = 72
    var accessory: PixelVitoraAccessory = .none
    var showsSparkles = true
    var showsBaseShadow = true
    var materialStyle: PixelVitoraMaterialStyle = .standard

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var floats = false
    @State private var twinkles = false

    var body: some View {
        ZStack {
            if showsBaseShadow {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                VitoraTheme.ColorToken.auraBlue.opacity(0.26),
                                VitoraTheme.ColorToken.auraCyan.opacity(0.12),
                                .clear,
                            ],
                            center: .center,
                            startRadius: 1,
                            endRadius: size * 0.58
                        )
                    )
                    .frame(width: size * 1.34, height: size * 0.22)
                    .blur(radius: size * 0.08)
                    .offset(y: size * 0.57)
                    .opacity(reduceMotion ? 0.76 : (floats ? 0.56 : 0.82))
            }

            if showsSparkles {
                PixelVitoraSparkles(size: size, isActive: twinkles)
            }

            PixelVitoraView(state: state, size: size, showsGlow: true, materialStyle: materialStyle)
                .offset(y: reduceMotion ? 0 : (floats ? -size * 0.045 : size * 0.035))

            accessoryView
                .offset(x: size * 0.44, y: size * 0.34)
                .rotationEffect(.degrees(reduceMotion ? -8 : (floats ? -4 : -10)))
        }
        .frame(width: size * 1.86, height: size * 1.62)
        .accessibilityIdentifier("pixel.vitora.scene")
        .onAppear {
            guard !reduceMotion else {
                return
            }
            withAnimation(.easeInOut(duration: floatDuration).repeatForever(autoreverses: true)) {
                floats = true
            }
            withAnimation(.easeInOut(duration: state == .thinking ? 1.35 : 1.85).repeatForever(autoreverses: true)) {
                twinkles = true
            }
        }
    }

    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .none:
            EmptyView()
        case .clipboard:
            GlassClipboardAccessory(size: size)
        case .pencil:
            Image(systemName: "pencil")
                .font(.system(size: size * 0.28, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .padding(size * 0.10)
                .background(VitoraTheme.ColorToken.paper.opacity(0.72))
                .clipShape(Circle())
        case .voice:
            Image(systemName: "waveform")
                .font(.system(size: size * 0.26, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.auraCyan)
                .padding(size * 0.10)
                .background(VitoraTheme.ColorToken.paper.opacity(0.66))
                .clipShape(Circle())
        }
    }

    private var floatDuration: Double {
        switch state {
        case .confirming:
            return 2.9
        case .thinking:
            return 2.4
        case .listening:
            return 2.6
        case .sleeping:
            return 4.2
        case .energetic:
            return 2.2
        case .questioning:
            return 2.8
        case .idle:
            return 3.4
        }
    }
}

struct PixelVitoraMessageAvatar: View {
    var size: CGFloat = 38
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var glows = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                        .fill(
                        LinearGradient(
                            colors: [
                                    VitoraTheme.ColorToken.paper.opacity(0.92),
                                    Color(red: 255 / 255, green: 252 / 255, blue: 250 / 255).opacity(0.76),
                                    Color(red: 233 / 255, green: 238 / 255, blue: 246 / 255).opacity(0.42),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    ZStack {
                        Circle()
                            .fill(Color(red: 255 / 255, green: 138 / 255, blue: 156 / 255).opacity(0.22))
                            .frame(width: size * 0.40, height: size * 0.40)
                            .offset(x: -size * 0.08, y: -size * 0.03)
                            .blur(radius: size * 0.12)
                        Circle()
                            .fill(Color(red: 255 / 255, green: 215 / 255, blue: 126 / 255).opacity(0.20))
                            .frame(width: size * 0.34, height: size * 0.34)
                            .offset(x: size * 0.12, y: size * 0.12)
                            .blur(radius: size * 0.12)
                    }
                        .clipShape(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
                        .blendMode(.plusLighter)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                        .fill(VitoraTheme.ColorToken.paper.opacity(0.26))
                        .blur(radius: size * 0.08)
                        .padding(size * 0.05)
                        .blendMode(.screen)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    VitoraTheme.ColorToken.paper.opacity(0.96),
                                    Color(red: 226 / 255, green: 224 / 255, blue: 236 / 255).opacity(0.68),
                                    VitoraTheme.ColorToken.paper.opacity(0.72),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: Color(red: 255 / 255, green: 132 / 255, blue: 162 / 255).opacity(glows ? 0.26 : 0.14), radius: glows ? 9 : 6, x: 0, y: 2)
                .shadow(color: VitoraTheme.ColorToken.paper.opacity(0.62), radius: 5, x: -2, y: -2)

            HStack(spacing: size * 0.18) {
                avatarEye
                avatarEye
            }
            .offset(y: -size * 0.03)
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Vitora 留言头像")
        .accessibilityIdentifier("pixel.vitora.message.avatar")
        .onAppear {
            guard !reduceMotion else {
                return
            }

            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                glows = true
            }
        }
    }

    private var avatarEye: some View {
        let pixel = max(2.0, size * 0.060)
        return VStack(spacing: max(0.55, size * 0.014)) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: max(0.45, size * 0.012)) {
                    ForEach(0..<2, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 0.7, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        VitoraTheme.ColorToken.paper,
                                        Color(red: 255 / 255, green: 245 / 255, blue: 216 / 255),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: pixel, height: pixel)
                            .shadow(color: VitoraTheme.ColorToken.paper.opacity(0.52), radius: size * 0.055, x: 0, y: 0)
                    }
                }
            }
        }
        .shadow(color: Color(red: 255 / 255, green: 218 / 255, blue: 150 / 255).opacity(0.28), radius: size * 0.10, x: 0, y: 0)
    }
}

private struct PixelVitoraSparkles: View {
    var size: CGFloat
    var isActive: Bool

    var body: some View {
        ZStack {
            sparkle(x: -0.62, y: -0.18, scale: 0.050, delay: 0.0)
            sparkle(x: -0.48, y: 0.34, scale: 0.032, delay: 0.4)
            sparkle(x: 0.52, y: -0.42, scale: 0.038, delay: 0.2)
            sparkle(x: 0.72, y: 0.24, scale: 0.052, delay: 0.7)
            sparkle(x: 0.22, y: -0.66, scale: 0.028, delay: 0.1)
        }
        .frame(width: size * 1.72, height: size * 1.42)
    }

    private func sparkle(x: CGFloat, y: CGFloat, scale: CGFloat, delay: Double) -> some View {
        RoundedRectangle(cornerRadius: max(1, size * scale * 0.22), style: .continuous)
            .fill(VitoraTheme.ColorToken.paper.opacity(sparkleOpacity(delay: delay)))
            .frame(width: max(2, size * scale), height: max(2, size * scale))
            .shadow(color: VitoraTheme.ColorToken.paper.opacity(0.78), radius: size * 0.045, x: 0, y: 0)
            .rotationEffect(.degrees(45))
            .scaleEffect(isActive ? 1.14 + delay * 0.08 : 0.76 + delay * 0.05)
            .position(x: size * (0.86 + x * 0.50), y: size * (0.71 + y * 0.50))
    }

    private func sparkleOpacity(delay: Double) -> Double {
        if isActive {
            return min(0.96, 0.76 + delay * 0.18)
        }
        return max(0.30, 0.52 - delay * 0.18)
    }
}

private struct GlassClipboardAccessory: View {
    var size: CGFloat

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: size * 0.10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            VitoraTheme.ColorToken.paper.opacity(0.88),
                            VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.74),
                            VitoraTheme.ColorToken.paper.opacity(0.68),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.10, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    VitoraTheme.ColorToken.paper.opacity(0.95),
                                    VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.40),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: max(1, size * 0.024)
                        )
                )

            Capsule()
                .fill(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.70))
                .frame(width: size * 0.24, height: size * 0.08)
                .offset(y: -size * 0.015)

            VStack(alignment: .leading, spacing: size * 0.050) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(
                            index == 0
                                ? VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.54)
                                : VitoraTheme.ColorToken.auraBlue.opacity(0.30)
                        )
                        .frame(width: size * (index == 0 ? 0.23 : 0.30), height: max(1.2, size * 0.018))
                }
            }
            .padding(.top, size * 0.18)
            .padding(.leading, size * 0.09)
            .frame(maxWidth: .infinity, alignment: .leading)

            Capsule()
                .fill(VitoraTheme.ColorToken.paper.opacity(0.48))
                .frame(width: size * 0.23, height: size * 0.045)
                .rotationEffect(.degrees(-28))
                .offset(x: -size * 0.08, y: size * 0.055)
                .blendMode(.screen)
        }
        .frame(width: size * 0.40, height: size * 0.50)
        .shadow(color: VitoraTheme.ColorToken.paper.opacity(0.68), radius: size * 0.04, x: -size * 0.01, y: -size * 0.02)
        .shadow(color: VitoraTheme.ColorToken.auraBlue.opacity(0.24), radius: size * 0.12, x: 0, y: size * 0.05)
        .accessibilityHidden(true)
    }
}

struct VitoraFaceTabButton: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            PixelVitoraScene(
                state: isSelected ? .listening : .idle,
                size: 34,
                accessory: .none,
                showsSparkles: false,
                showsBaseShadow: false
            )
        }
        .frame(width: 58, height: 52)
        .accessibilityIdentifier("tab.vitora.face")
    }
}
