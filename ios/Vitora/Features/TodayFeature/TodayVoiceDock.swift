import SwiftUI

struct TodayVoiceDock: View {
    @State private var inputText = ""

    var body: some View {
        HStack(spacing: 10) {
            TextField("和 Vitora 聊聊吧...", text: $inputText)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .padding(.leading, 6)

            Spacer(minLength: 0)

            Button(action: {}) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(
                        inputText.isEmpty
                            ? VitoraTheme.ColorToken.secondaryText.opacity(0.28)
                            : VitoraTheme.ColorToken.actionPrimaryDeep,
                        in: Circle()
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.82))
                .overlay(Capsule().stroke(Color.black.opacity(0.06), lineWidth: 0.6))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .accessibilityIdentifier("today.voice.dock")
    }
}
