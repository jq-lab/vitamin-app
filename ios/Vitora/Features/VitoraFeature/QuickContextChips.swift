import SwiftUI

struct QuickContextChips: View {
    let contexts: [String]
    let selected: String
    let onSelect: (String) -> Void

    private let icons: [String: String] = [
        "周期": "calendar",
        "睡眠": "moon.zzz.fill",
        "营养": "takeoutbag.and.cup.and.straw.fill",
        "情绪": "sparkles",
        "能量": "waveform.path",
        "+": "plus",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("快捷上下文")
                .font(.headline.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            HStack(spacing: 11) {
                ForEach(contexts, id: \.self) { context in
                    Button {
                        onSelect(context)
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: icons[context, default: "circle"])
                                .font(.system(size: 17, weight: .semibold))
                            Text(context)
                                .font(.caption2.weight(.medium))
                        }
                        .foregroundStyle(selected == context ? VitoraTheme.ColorToken.paper : VitoraTheme.ColorToken.actionPrimaryDeep)
                        .frame(width: 49, height: 52)
                        .background(selected == context ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.paper.opacity(0.34))
                        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .stroke(VitoraTheme.ColorToken.paper.opacity(0.72), lineWidth: 0.7)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("vitora.quick.context.\(context)")
                }
            }
        }
    }
}
