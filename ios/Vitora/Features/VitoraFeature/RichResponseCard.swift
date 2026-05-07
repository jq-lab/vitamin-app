import SwiftUI

struct RichResponseCard: View {
    let response: VitoraRichResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                PixelVitoraView(state: .confirming, size: 34, showsGlow: false)
                Text(response.title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
            }

            Text(response.body)
                .font(.subheadline)
                .lineSpacing(3)
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            ComplianceLabel(.vitora)

            HStack(spacing: 8) {
                ForEach(response.actions, id: \.self) { action in
                    Button(action) {}
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(action == "确认保存" ? VitoraTheme.ColorToken.paper : VitoraTheme.ColorToken.actionPrimaryDeep)
                        .padding(.horizontal, 11)
                        .frame(height: 32)
                        .background(action == "确认保存" ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.paper.opacity(0.4))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(15)
        .background(GlassSurface(cornerRadius: 22, opacity: 0.40))
    }
}
