import SwiftUI

func cycleDetailContainer<Content: View>(
    title: String,
    onClose: @escaping () -> Void,
    @ViewBuilder content: () -> Content
) -> some View {
    ZStack {
        AuraBackground(intensity: 0.90)
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button("关闭", action: onClose)
                        .font(.callout.weight(.semibold))
                    Spacer()
                    Text(title)
                        .font(.headline.weight(.bold))
                    Spacer()
                    Color.clear.frame(width: 44, height: 1)
                }
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

                content()
            }
            .padding(20)
            .padding(.bottom, 32)
        }
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
    .background(GlassSurface(cornerRadius: 20, opacity: 0.38))
}
