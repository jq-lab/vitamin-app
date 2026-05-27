import SwiftUI

/// Collapsed header showing mini flower-pot energy state + score + menu button.
/// Displayed when user scrolls up into chat mode.
struct TodayCollapsedHeader: View {
    let selectedTopic: TodayInsightTopic
    let cyclePhase: String
    let onOpenDetail: () -> Void
    let onMenu: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onOpenDetail) {
                CollapsedFlowerPotGlyph(progress: 0.68)
                    .frame(width: 44, height: 44)
                    .shadow(color: Color(red: 255 / 255, green: 167 / 255, blue: 28 / 255).opacity(0.18), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("today.collapsed.flowerPot")

            // Score
            Button(action: onOpenDetail) {
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text("68")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 218 / 255, green: 130 / 255, blue: 9 / 255))
                        .monospacedDigit()
                    Text("/100")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("today.collapsed.score")

            Spacer(minLength: 0)

            // Camera button
            Button(action: { }) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.72), in: Circle())
                    .overlay(Circle().stroke(Color.black.opacity(0.06), lineWidth: 0.6))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("today.collapsed.camera")

            // Menu button
            Button(action: onMenu) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.72), in: Circle())
                    .overlay(Circle().stroke(Color.black.opacity(0.06), lineWidth: 0.6))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("today.collapsed.menu")
        }
        .padding(.horizontal, 4)
        .frame(height: 56)
        .accessibilityIdentifier("today.collapsed.header")
    }
}

private struct CollapsedFlowerPotGlyph: View {
    let progress: CGFloat

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let centerX = w * 0.5
            let rimY = h * 0.57
            let leftX = w * 0.16
            let rightX = w * 0.84
            let bottomY = h * 0.88
            let clamped = min(max(progress, 0), 1)

            context.fill(
                Path(ellipseIn: CGRect(x: w * 0.18, y: h * 0.78, width: w * 0.64, height: h * 0.17)),
                with: .color(Color(red: 255 / 255, green: 186 / 255, blue: 42 / 255).opacity(0.12))
            )

            var stem = Path()
            stem.move(to: CGPoint(x: centerX, y: rimY + 2))
            stem.addLine(to: CGPoint(x: centerX, y: h * 0.22))
            context.stroke(stem, with: .color(Color(red: 76 / 255, green: 178 / 255, blue: 76 / 255)), style: StrokeStyle(lineWidth: 2.4, lineCap: .round))

            let leafColor = Color(red: 104 / 255, green: 204 / 255, blue: 90 / 255)
            context.fill(Path(ellipseIn: CGRect(x: centerX - 15, y: h * 0.35, width: 12, height: 18)), with: .color(leafColor.opacity(0.9)))
            context.fill(Path(ellipseIn: CGRect(x: centerX + 4, y: h * 0.39, width: 16, height: 10)), with: .color(leafColor.opacity(0.86)))

            var bowl = Path()
            bowl.move(to: CGPoint(x: leftX, y: rimY))
            bowl.addLine(to: CGPoint(x: rightX, y: rimY))
            bowl.addQuadCurve(to: CGPoint(x: leftX, y: rimY), control: CGPoint(x: centerX, y: bottomY + 12))
            bowl.closeSubpath()

            let fillTop = bottomY - (bottomY - rimY) * clamped
            var fillContext = context
            fillContext.clip(to: bowl)
            fillContext.fill(
                Path(CGRect(x: leftX - 2, y: fillTop, width: rightX - leftX + 4, height: bottomY - fillTop + 8)),
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 255 / 255, green: 240 / 255, blue: 164 / 255).opacity(0.82),
                        Color(red: 255 / 255, green: 174 / 255, blue: 20 / 255).opacity(0.68)
                    ]),
                    startPoint: CGPoint(x: centerX, y: fillTop),
                    endPoint: CGPoint(x: centerX, y: bottomY)
                )
            )

            context.fill(
                bowl,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.42),
                        Color(red: 255 / 255, green: 226 / 255, blue: 137 / 255).opacity(0.16)
                    ]),
                    startPoint: CGPoint(x: centerX, y: rimY),
                    endPoint: CGPoint(x: centerX, y: bottomY)
                )
            )
            context.stroke(
                bowl,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 255 / 255, green: 176 / 255, blue: 19 / 255),
                        Color(red: 230 / 255, green: 136 / 255, blue: 0)
                    ]),
                    startPoint: CGPoint(x: leftX, y: rimY),
                    endPoint: CGPoint(x: rightX, y: bottomY)
                ),
                style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round)
            )

            let node = Path(ellipseIn: CGRect(x: centerX - 4.5, y: rimY - 4.5, width: 9, height: 9))
            context.fill(node, with: .color(Color.white.opacity(0.94)))
            context.stroke(node, with: .color(Color(red: 246 / 255, green: 155 / 255, blue: 0)), style: StrokeStyle(lineWidth: 1.7))
        }
    }
}
