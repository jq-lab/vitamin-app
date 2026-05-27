import SwiftUI

struct OrbDataBubble: View {
    let title: String
    let value: String
    let delta: String
    let accent: Color
    let isPositive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            Text(delta)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(isPositive ? VitoraTheme.ColorToken.success : Color(red: 240 / 255, green: 139 / 255, blue: 82 / 255))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.92))
                .shadow(color: accent.opacity(0.16), radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(accent.opacity(0.22), lineWidth: 0.8)
        )
    }
}

// MARK: - Floating modifier for post-arrival micro-motion

struct FloatingModifier: ViewModifier {
    let isActive: Bool
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                guard isActive else { return }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    offset = -2
                }
            }
    }
}

extension View {
    func floatingMotion(isActive: Bool) -> some View {
        modifier(FloatingModifier(isActive: isActive))
    }
}

// MARK: - Stage 5 bubble data

struct OrbBubbleData {
    let title: String
    let value: String
    let delta: String
    let accent: Color
    let isPositive: Bool
    let entryEdge: Edge  // which side it flies in from
    let delayMs: Int     // stagger delay

    static let defaults: [OrbBubbleData] = [
        OrbBubbleData(title: "深睡", value: "7.2h", delta: "↑12%",
                      accent: VitoraTheme.ColorToken.auraBlue, isPositive: true,
                      entryEdge: .leading, delayMs: 0),
        OrbBubbleData(title: "HRV", value: "48ms", delta: "↓8%",
                      accent: VitoraTheme.ColorToken.auraLavender, isPositive: false,
                      entryEdge: .trailing, delayMs: 100),
        OrbBubbleData(title: "心率", value: "72bpm", delta: "↑5%",
                      accent: VitoraTheme.ColorToken.success, isPositive: true,
                      entryEdge: .trailing, delayMs: 200),
        OrbBubbleData(title: "周期", value: "D18", delta: "黄体期",
                      accent: VitoraTheme.ColorToken.lutealGold, isPositive: true,
                      entryEdge: .bottom, delayMs: 300),
    ]
}
