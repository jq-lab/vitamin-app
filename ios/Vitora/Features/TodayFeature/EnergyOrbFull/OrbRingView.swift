import SwiftUI

struct OrbRingView: View {
    let diameter: CGFloat
    let segment1Progress: Double // 0→1: colors 0°-120°
    let segment2Progress: Double // 0→1: colors 120°-240°
    let segment3Progress: Double // 0→1: colors 240°-360°
    let compositeProgress: Double // 0→1: full ring gradient blend
    let ringScale: Double // 0→1: entrance scale

    private let tickCount = 48
    private let tickWidth: CGFloat = 2.5
    private let tickLength: CGFloat = 14
    private let gapFraction: CGFloat = 0.35

    private let inactiveColor = Color(red: 229 / 255, green: 229 / 255, blue: 234 / 255) // #E5E5EA
    private let activeColor = Color(red: 90 / 255, green: 200 / 255, blue: 250 / 255)   // #5AC8FA
    private let activeColorDeep = Color(red: 181 / 255, green: 229 / 255, blue: 250 / 255) // #B5E5FA

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = diameter / 2

            for i in 0..<tickCount {
                let angle = Double(i) / Double(tickCount) * 360.0
                let radians = angle * .pi / 180 - .pi / 2 // start from top

                let innerR = radius - tickLength
                let outerR = radius

                let inner = CGPoint(
                    x: center.x + innerR * cos(radians),
                    y: center.y + innerR * sin(radians)
                )
                let outer = CGPoint(
                    x: center.x + outerR * cos(radians),
                    y: center.y + outerR * sin(radians)
                )

                var path = Path()
                path.move(to: inner)
                path.addLine(to: outer)

                let tickColor = colorForTick(at: angle)
                context.stroke(
                    path,
                    with: .color(tickColor),
                    style: StrokeStyle(lineWidth: tickWidth, lineCap: .round)
                )
            }
        }
        .frame(width: diameter, height: diameter)
        .scaleEffect(ringScale)
    }

    private func colorForTick(at angle: Double) -> Color {
        // Composite mode: full ring gradient
        if compositeProgress > 0 {
            let blended = interpolateColor(from: inactiveColor, to: activeColor, progress: compositeProgress)
            return blended
        }

        // Segment coloring based on angle
        if angle < 120 {
            // Segment 1: 0°-120°
            let tickProgress = angle / 120.0
            if tickProgress <= segment1Progress {
                return activeColor
            }
        } else if angle < 240 {
            // Segment 2: 120°-240°
            let tickProgress = (angle - 120) / 120.0
            if tickProgress <= segment2Progress {
                return activeColor
            }
        } else {
            // Segment 3: 240°-360°
            let tickProgress = (angle - 240) / 120.0
            if tickProgress <= segment3Progress {
                return activeColor
            }
        }

        return inactiveColor
    }

    private func interpolateColor(from: Color, to: Color, progress: Double) -> Color {
        let p = min(max(progress, 0), 1)
        if p >= 1 { return to }
        if p <= 0 { return from }
        // Blend by mixing via opacity overlay
        return to.opacity(p)
    }
}

// MARK: - Ring glow pulse for stage 6

struct OrbRingGlowPulse: View {
    let diameter: CGFloat
    let progress: Double // 0→1 over 500ms

    var body: some View {
        Circle()
            .stroke(
                Color(red: 90 / 255, green: 200 / 255, blue: 250 / 255).opacity(0.5 * (1 - progress)),
                lineWidth: 3
            )
            .frame(width: diameter * (1 + 0.15 * progress), height: diameter * (1 + 0.15 * progress))
    }
}
