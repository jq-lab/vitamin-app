import SwiftUI

struct VitoraCompressedHeader: View {
    var compressed = false
    var onOpenSupport: () -> Void = {}

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "speaker.slash")
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Button(action: onOpenSupport) {
                    Image(systemName: "ellipsis")
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("vitora.support.open")
            }

            HStack(alignment: .center, spacing: compressed ? 10 : 14) {
                PixelVitoraView(state: .idle, size: compressed ? 52 : 92)
                    .frame(width: compressed ? 72 : 126, height: compressed ? 72 : 126)

                VStack(alignment: .leading, spacing: 7) {
                    Text("Vitora 知道")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)

                    knownRow("今日 68%")
                    knownRow("黄体期 Day 18")
                    knownRow("睡眠 7.2h · 略低")
                    knownRow("HRV ↓8%")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(GlassSurface(cornerRadius: 28, opacity: 0.36))
            .accessibilityIdentifier("vitora.hero")

            HStack {
                Text("今天 5月5日（周二）")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("Day18 · 黄体期 ›")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
            }
            .padding(.horizontal, 4)
            .foregroundStyle(VitoraTheme.ColorToken.strongText)
            .accessibilityIdentifier("vitora.date.context")
        }
        .accessibilityIdentifier("vitora.compressed.header")
    }

    private func knownRow(_ text: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(VitoraTheme.ColorToken.auraBlue)
                .frame(width: 5, height: 5)
            Text(text)
                .font(.footnote.weight(.medium))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
        }
    }
}
