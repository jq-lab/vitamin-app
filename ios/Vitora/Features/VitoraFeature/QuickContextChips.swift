import SwiftUI

struct QuickContextChips: View {
    let contexts: [String]
    let selected: String
    let onSelect: (String) -> Void

    private let icons: [String: String] = [
        "周期": "drop.fill",
        "睡眠": "moon.fill",
        "营养": "apple.logo",
        "情绪": "face.smiling.fill",
        "能量": "bolt.fill",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("快捷上下文")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.clear)
                .frame(height: 0)
                .accessibilityHidden(false)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(contexts, id: \.self) { context in
                        Button {
                            onSelect(context)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: icons[context, default: "circle"])
                                    .font(.system(size: 13, weight: .semibold))
                                Text(context)
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundStyle(selected == context ? VitoraTheme.ColorToken.strongText : VitoraTheme.ColorToken.strongText.opacity(0.84))
                            .padding(.horizontal, 10)
                            .frame(height: 32)
                            .background(folderFill(for: context), in: UnevenRoundedRectangle(topLeadingRadius: 14, bottomLeadingRadius: 6, bottomTrailingRadius: 6, topTrailingRadius: 14, style: .continuous))
                            .overlay(
                                UnevenRoundedRectangle(topLeadingRadius: 14, bottomLeadingRadius: 6, bottomTrailingRadius: 6, topTrailingRadius: 14, style: .continuous)
                                    .stroke(selected == context ? Color.white.opacity(0.96) : Color.white.opacity(0.64), lineWidth: selected == context ? 0.9 : 0.55)
                            )
                            .shadow(color: tabColor(for: context).opacity(selected == context ? 0.26 : 0.10), radius: selected == context ? 9 : 4, x: 0, y: 3)
                            .scaleEffect(selected == context ? 1.025 : 1)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("切换到\(context)上下文")
                        .accessibilityIdentifier("vitora.quick.context.\(context)")
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 7)
                .padding(.bottom, 6)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 116 / 255, green: 224 / 255, blue: 180 / 255).opacity(0.34),
                                    Color(red: 247 / 255, green: 220 / 255, blue: 85 / 255).opacity(0.25),
                                    Color(red: 251 / 255, green: 117 / 255, blue: 150 / 255).opacity(0.30),
                                    Color(red: 159 / 255, green: 129 / 255, blue: 230 / 255).opacity(0.30),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.76), lineWidth: 0.65)
                        )
                        .shadow(color: Color(red: 244 / 255, green: 90 / 255, blue: 154 / 255).opacity(0.12), radius: 12, x: 8, y: 5)
                        .shadow(color: Color(red: 103 / 255, green: 196 / 255, blue: 195 / 255).opacity(0.14), radius: 12, x: -7, y: 5)
                )
            }
        }
        .animation(.easeOut(duration: 0.18), value: selected)
    }

    private func folderFill(for context: String) -> AnyShapeStyle {
        if selected == context {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        VitoraTheme.ColorToken.paper.opacity(0.84),
                        tabColor(for: context).opacity(0.38),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        return AnyShapeStyle(VitoraTheme.ColorToken.paper.opacity(0.50))
    }

    private func tabColor(for context: String) -> Color {
        switch context {
        case "周期":
            return Color(red: 96 / 255, green: 177 / 255, blue: 238 / 255)
        case "睡眠":
            return Color(red: 128 / 255, green: 120 / 255, blue: 236 / 255)
        case "营养":
            return Color(red: 246 / 255, green: 169 / 255, blue: 74 / 255)
        case "情绪":
            return Color(red: 235 / 255, green: 119 / 255, blue: 177 / 255)
        case "能量":
            return Color(red: 96 / 255, green: 203 / 255, blue: 218 / 255)
        default:
            return Color(red: 120 / 255, green: 213 / 255, blue: 177 / 255)
        }
    }
}
