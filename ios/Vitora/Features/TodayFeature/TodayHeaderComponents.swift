import SwiftUI

struct DateCycleContextStrip: View {
    let cycleText: String
    let isLowData: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "calendar")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                .frame(width: 24, height: 34)

            DateChip(day: "17", isSelected: false, isFaded: false)

            DateChip(day: "18", isSelected: true, isFaded: false)

            DateChip(day: "19", isSelected: false, isFaded: true)

            Text(cycleText)
                .font(.caption2.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimary)
                .padding(.horizontal, 10)
                .frame(height: 20)
                .background(VitoraTheme.ColorToken.actionPrimary.opacity(isLowData ? 0.08 : 0.12))
                .clipShape(Capsule())

            Spacer()
        }
        .frame(height: 48)
        .accessibilityIdentifier("today.cycleContext")
    }
}

private struct DateChip: View {
    let day: String
    let isSelected: Bool
    let isFaded: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text(day)
                .font(isSelected ? .subheadline.weight(.semibold) : .caption2)
                .foregroundStyle(VitoraTheme.ColorToken.primaryText.opacity(isFaded ? 0.30 : (isSelected ? 1 : 0.52)))
                .frame(height: isSelected ? 18 : 14)

            Circle()
                .fill(VitoraTheme.ColorToken.actionPrimary.opacity(isFaded ? 0.28 : 1))
                .frame(width: isSelected ? 7 : 4, height: isSelected ? 7 : 4)
                .shadow(color: VitoraTheme.ColorToken.actionPrimary.opacity(isSelected ? 0.40 : 0), radius: 6)
        }
        .frame(width: isSelected ? 34 : 24, height: isSelected ? 34 : 22)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(VitoraTheme.ColorToken.actionPrimary.opacity(0.12))
            }
        }
    }
}

struct TodayStateOrb: View {
    let summary: EnergySummary
    let isLowData: Bool

    private var progress: Double {
        Double(summary.scorePercent ?? 24) / 100
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(VitoraTheme.ColorToken.actionPrimary.opacity(isLowData ? 0.06 : 0.12))
                .blur(radius: 52)
                .frame(width: 300, height: 300)

            ForEach(0..<64, id: \.self) { index in
                Capsule()
                    .fill(tickColor(index: index))
                    .frame(width: 2, height: isLongTick(index: index) ? 21 : 17)
                    .offset(y: -106)
                    .rotationEffect(.degrees(Double(index) * 360 / 64))
            }

            Circle()
                .fill(VitoraTheme.ColorToken.actionPrimary.opacity(isLowData ? 0.55 : 1))
                .frame(width: 19, height: 19)
                .overlay(
                    Circle()
                        .fill(VitoraTheme.ColorToken.actionPrimary.opacity(0.14))
                        .frame(width: 30, height: 30)
                )
                .offset(x: -96, y: 41)

            Circle()
                .fill(VitoraTheme.ColorToken.paper.opacity(0.88))
                .overlay(
                    Circle()
                        .stroke(VitoraTheme.ColorToken.paper.opacity(0.96), lineWidth: 0.8)
                )
                .shadow(color: .black.opacity(0.14), radius: 16, x: 0, y: 8)
                .frame(width: 164, height: 164)

            VStack(spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(scoreText)
                        .font(.system(size: summary.scorePercent == nil ? 46 : 58, weight: .regular, design: .serif))
                        .italic()
                        .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                        .accessibilityIdentifier("today.energy.score")

                    if summary.scorePercent != nil {
                        Text("%")
                            .font(.system(size: 24, weight: .regular, design: .default))
                            .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                    }
                }

                Text(summary.displayBand)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimary)
            }
        }
        .frame(width: 246, height: 246)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var scoreText: String {
        summary.scorePercent.map(String.init) ?? "--"
    }

    private func tickColor(index: Int) -> Color {
        let activeTicks = Int((progress * 64).rounded())
        if index <= activeTicks {
            return VitoraTheme.ColorToken.actionPrimary.opacity(isLowData ? 0.45 : 1)
        }
        return VitoraTheme.ColorToken.actionPrimary.opacity(0.05)
    }

    private func isLongTick(index: Int) -> Bool {
        index % 2 == 0
    }
}
