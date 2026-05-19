import SwiftUI

struct HomeTabGlyph: View {
    var isSelected = false

    var body: some View {
        Image(systemName: isSelected ? "house.fill" : "house")
            .font(.system(size: 16, weight: .semibold))
            .symbolRenderingMode(.hierarchical)
            .accessibilityHidden(true)
    }
}

struct FlowerCycleGlyph: View {
    var isSelected = false

    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                Capsule()
                    .fill(isSelected ? VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.88) : VitoraTheme.ColorToken.secondaryText.opacity(0.58))
                    .frame(width: 7, height: 13)
                    .offset(y: -7)
                    .rotationEffect(.degrees(Double(index) * 72))
            }

            Circle()
                .fill(isSelected ? Color.white.opacity(0.90) : VitoraTheme.ColorToken.secondaryText.opacity(0.35))
                .frame(width: 6, height: 6)
        }
        .frame(width: 24, height: 24)
        .accessibilityHidden(true)
    }
}
