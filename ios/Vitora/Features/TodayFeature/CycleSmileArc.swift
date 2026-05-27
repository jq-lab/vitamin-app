import SwiftUI

/// Curved arc cycle phase indicator with heart icon at current position.
struct CycleSmileArc: View {
    let cycleDay: Int
    let cyclePhase: String

    private let greenPhase = Color(red: 112 / 255, green: 218 / 255, blue: 168 / 255)
    private let yellowGreen = Color(red: 179 / 255, green: 203 / 255, blue: 98 / 255)
    private let amberPhase = Color(red: 242 / 255, green: 171 / 255, blue: 48 / 255)
    private let amberLight = Color(red: 245 / 255, green: 198 / 255, blue: 116 / 255)
    private let pinkPhase = Color(red: 244 / 255, green: 176 / 255, blue: 197 / 255)
    private let pinkFade = Color(red: 236 / 255, green: 206 / 255, blue: 216 / 255)

    var body: some View {
        VStack(spacing: 8) {
            // Arc + heart
            Canvas { context, size in
                let w = size.width
                let arcY: CGFloat = 22

                // Gradient arc path
                var arc = Path()
                arc.move(to: CGPoint(x: 16, y: arcY))
                arc.addQuadCurve(
                    to: CGPoint(x: w - 16, y: arcY),
                    control: CGPoint(x: w / 2, y: arcY + 28)
                )

                context.stroke(
                    arc,
                    with: .linearGradient(
                        Gradient(colors: [
                            greenPhase,
                            yellowGreen,
                            amberPhase,
                            amberLight,
                            pinkFade,
                            pinkPhase,
                        ]),
                        startPoint: CGPoint(x: 16, y: arcY),
                        endPoint: CGPoint(x: w - 16, y: arcY)
                    ),
                    style: StrokeStyle(lineWidth: 4.5, lineCap: .round)
                )

                // Heart circle at current phase position (~68% for D18 luteal)
                let progress: CGFloat = 0.62
                let heartX = 16 + (w - 32) * progress
                // Y on the arc at this X position (quadratic bezier interpolation)
                let t = progress
                let startY = arcY
                let controlY = arcY + 28
                let endY = arcY
                let heartY = (1 - t) * (1 - t) * startY + 2 * (1 - t) * t * controlY + t * t * endY

                // White circle background
                context.fill(
                    Path(ellipseIn: CGRect(x: heartX - 16, y: heartY - 16, width: 32, height: 32)),
                    with: .color(Color.white)
                )
                context.stroke(
                    Path(ellipseIn: CGRect(x: heartX - 16, y: heartY - 16, width: 32, height: 32)),
                    with: .color(Color.white.opacity(0.9)),
                    lineWidth: 1.5
                )

                // Heart emoji
                context.draw(
                    Text("♥")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(amberPhase),
                    at: CGPoint(x: heartX, y: heartY),
                    anchor: .center
                )
            }
            .frame(height: 46)

            // Phase labels with colored dots
            HStack(spacing: 16) {
                phaseDot(color: greenPhase, label: "月经期", isActive: false)
                Spacer()
                phaseDot(color: amberPhase, label: "排卵期", isActive: false)
                Spacer()
                phaseDot(color: pinkPhase, label: "黄体期 D\(cycleDay)", isActive: true)
            }
            .padding(.horizontal, 12)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("周期进度：\(cyclePhase) Day \(cycleDay)")
        .accessibilityIdentifier("today.cycle.smile.arc")
    }

    private func phaseDot(color: Color, label: String, isActive: Bool) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(label)
                .font(.system(size: isActive ? 14 : 12, weight: isActive ? .bold : .semibold))
                .foregroundStyle(isActive
                    ? Color(red: 44 / 255, green: 44 / 255, blue: 42 / 255)
                    : Color(red: 136 / 255, green: 135 / 255, blue: 128 / 255))
        }
    }
}
