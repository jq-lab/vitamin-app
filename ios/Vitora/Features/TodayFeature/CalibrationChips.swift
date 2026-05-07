import SwiftUI

struct CalibrationChips: View {
    let onSelect: (String) -> Void

    private let chips = ["告诉 Vitora", "睡得浅", "压力大"]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(chips, id: \.self) { chip in
                Button {
                    onSelect(chip)
                } label: {
                    Text(chip)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(chip == "告诉 Vitora" ? VitoraTheme.ColorToken.paper : VitoraTheme.ColorToken.actionPrimaryDeep)
                        .padding(.horizontal, 14)
                        .frame(height: 36)
                        .background(chip == "告诉 Vitora" ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.72))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("today.calibration.\(chip == "告诉 Vitora" ? "tell" : chip)")
            }
        }
    }
}
