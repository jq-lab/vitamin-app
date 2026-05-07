import SwiftUI

struct RecordQuickTypeGrid: View {
    let selectedType: LunaRecordQuickType
    let onSelect: (LunaRecordQuickType) -> Void

    private let items: [(LunaRecordQuickType, String, String, Color)] = [
        (.cycle, "经期", "drop.fill", Color(red: 255 / 255, green: 229 / 255, blue: 236 / 255)),
        (.sleep, "睡眠", "moon.zzz.fill", Color(red: 232 / 255, green: 228 / 255, blue: 245 / 255)),
        (.energy, "能量", "bolt.fill", Color(red: 255 / 255, green: 243 / 255, blue: 214 / 255)),
        (.nutrition, "营养品", "pills.fill", Color(red: 242 / 255, green: 237 / 255, blue: 255 / 255)),
        (.mood, "感受", "face.smiling", Color(red: 237 / 255, green: 250 / 255, blue: 242 / 255)),
        (.freeText, "更多", "plus", VitoraTheme.ColorToken.softSurface),
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: 3), spacing: 22) {
            ForEach(items, id: \.0) { type, label, icon, color in
                Button {
                    onSelect(type)
                } label: {
                    VStack(spacing: 8) {
                        ZStack(alignment: .topTrailing) {
                            Circle()
                                .fill(color)
                                .frame(width: 64, height: 64)

                            if selectedType == type {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimary)
                                    .offset(x: 8, y: -6)
                            }

                            Image(systemName: icon)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(type == .cycle ? VitoraTheme.ColorToken.attention : VitoraTheme.ColorToken.primaryText)
                                .frame(width: 64, height: 64)
                        }

                        Text(label)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                    }
                    .frame(minHeight: 92)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("luna.record.quick.\(type.rawValue)")
            }
        }
    }
}
