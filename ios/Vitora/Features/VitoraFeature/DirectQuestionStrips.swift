import SwiftUI

struct DirectQuestionStrips: View {
    let questions: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("可以直接问")
                .font(.headline.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            ForEach(questions, id: \.self) { question in
                Button {
                    onSelect(question)
                } label: {
                    HStack {
                        Text(question)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 42)
                    .background(GlassSurface(cornerRadius: 18, opacity: 0.26))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("vitora.direct.question.\(question)")
            }
        }
    }
}
