import SwiftUI

@MainActor
func cycleDetailContainer<Content: View>(
    title: String,
    subtitle: String? = nil,
    onClose: @escaping () -> Void,
    @ViewBuilder content: () -> Content
) -> some View {
    FrostedSheetShell(
        title: title,
        subtitle: subtitle,
        closeAccessibilityID: "cycle.detail.close",
        onClose: onClose
    ) {
        content()
    }
}

func cycleInfoBlock(title: String, lines: [String]) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title)
            .font(.headline.weight(.bold))
            .foregroundStyle(VitoraTheme.ColorToken.strongText)
        ForEach(lines, id: \.self) { line in
            Text(line)
                .font(.subheadline)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
        }
    }
    .padding(15)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(GlassSurface(cornerRadius: 20, opacity: 0.68, shadowStrength: 0.26, variant: .cleanResting))
}
