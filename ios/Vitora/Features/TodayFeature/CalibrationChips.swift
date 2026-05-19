import SwiftUI

struct CalibrationChips: View {
    let onSelect: (String) -> Void

    private let chips: [(title: String, icon: String, filled: Bool)] = [
        ("告诉 Vitora", "pencil", true),
        ("睡得浅", "moon.fill", false),
        ("压力大", "face.smiling", false),
    ]

    var body: some View {
        HStack(spacing: 7) {
            ForEach(chips, id: \.title) { chip in
                Button {
                    onSelect(chip.title)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: chip.icon)
                            .font(.caption2.weight(.bold))
                        Text(chip.title)
                            .font(.caption.weight(.semibold))
                    }
                        .foregroundStyle(chip.filled ? VitoraTheme.ColorToken.paper : VitoraTheme.ColorToken.actionPrimaryDeep)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: VitoraTheme.Size.touchTargetMin)
                        .background(chip.filled ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.paper.opacity(0.48))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(VitoraTheme.ColorToken.paper.opacity(chip.filled ? 0 : 0.82), lineWidth: 0.7)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("today.calibration.\(chip.title == "告诉 Vitora" ? "tell" : chip.title)")
            }
        }
    }
}
