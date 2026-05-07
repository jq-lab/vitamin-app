import SwiftUI

struct LunaPixelHomeCard: View {
    let state: LunaHomeState
    let onOpenRecord: () -> Void

    var body: some View {
        Button(action: onOpenRecord) {
            ZStack {
                RoundedRectangle(cornerRadius: VitoraTheme.Radius.sheet, style: .continuous)
                    .fill(VitoraTheme.ColorToken.cardGlass)
                    .overlay(
                        RoundedRectangle(cornerRadius: VitoraTheme.Radius.sheet, style: .continuous)
                            .stroke(Color(red: 191 / 255, green: 209 / 255, blue: 224 / 255).opacity(0.30), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 20, x: 0, y: 10)

                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text(state.prompt)
                            .font(.footnote)
                            .foregroundStyle(VitoraTheme.ColorToken.primaryText)

                        Spacer()

                        Text(state.isLowData ? "信息较少" : "今天有点累但还 OK")
                            .font(.caption2)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }

                    Spacer()

                    PixelLunaGlyph(block: 8)
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)

                    Spacer()

                    HStack {
                        Spacer()
                        Text("随时随心，你来说，我来记  →")
                            .font(.caption2)
                            .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                    }
                }
                .padding(.horizontal, VitoraTheme.Spacing.md)
                .padding(.vertical, VitoraTheme.Spacing.md)
            }
            .frame(maxWidth: VitoraTheme.Size.contentWidth)
            .frame(height: 184)
            .contentShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.sheet, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("luna.home.card")
    }
}

struct PixelLunaGlyph: View {
    let block: CGFloat

    var body: some View {
        HStack(spacing: block * 3.5) {
            PixelEye(block: block)
            PixelEye(block: block)
        }
    }
}

private struct PixelEye: View {
    let block: CGFloat
    private let active: Set<String> = [
        "0-1", "0-2",
        "1-0", "1-1", "1-2", "1-3",
        "2-0", "2-2", "2-3",
        "3-0", "3-1", "3-2", "3-3",
        "4-1", "4-2",
    ]

    var body: some View {
        VStack(spacing: block * 0.125) {
            ForEach(0..<5, id: \.self) { row in
                HStack(spacing: block * 0.25) {
                    ForEach(0..<4, id: \.self) { column in
                        RoundedRectangle(cornerRadius: block * 0.18, style: .continuous)
                            .fill(fill(row: row, column: column))
                            .frame(width: block, height: block)
                    }
                }
            }
        }
    }

    private func fill(row: Int, column: Int) -> Color {
        if row == 2 && column == 1 {
            return VitoraTheme.ColorToken.paper
        }
        return active.contains("\(row)-\(column)") ? VitoraTheme.ColorToken.actionPrimary : Color.clear
    }
}
