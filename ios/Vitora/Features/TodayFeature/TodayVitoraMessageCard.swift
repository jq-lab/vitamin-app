import SwiftUI

// TodayVitoraMessageCard removed — replaced by VitoraChatBubble

/// Vitora chat bubble — avatar + name + message bubble + optional disclaimer.
/// Shared across State A and State B for consistent chat-style messaging.
struct VitoraChatBubble: View {
    var message: String
    var disclaimer: String? = nil
    var timestamp: String? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VitoraAvatarGlow(size: 34)

            VStack(alignment: .leading, spacing: 4) {
                Text("Vitora")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

                Text(message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .lineSpacing(3)
                    .padding(14)
                    .background(Color(red: 242 / 255, green: 242 / 255, blue: 247 / 255), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .frame(maxWidth: 240, alignment: .leading)

                if let disclaimer {
                    Text(disclaimer)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                }

                if let timestamp {
                    Text(timestamp)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                }
            }
        }
    }
}

struct TodayRecordFeedbackCard: View {
    let feedback: RecentRecordFeedback?
    let fallbackMessage: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VitoraAvatarGlow(size: 34)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text("Vitora")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)

                    if let feedback {
                        Text("刚刚记录")
                            .font(.system(size: 10.5, weight: .heavy))
                            .foregroundStyle(Color(red: 180 / 255, green: 103 / 255, blue: 36 / 255))
                            .padding(.horizontal, 8)
                            .frame(height: 22)
                            .background(Color(red: 255 / 255, green: 238 / 255, blue: 209 / 255), in: Capsule())
                            .accessibilityHidden(true)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    if let feedback {
                        HStack(spacing: 7) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundStyle(Color(red: 60 / 255, green: 151 / 255, blue: 112 / 255))
                            Text(feedback.summary)
                                .font(.system(size: 12.5, weight: .heavy))
                                .foregroundStyle(Color.black.opacity(0.68))
                                .lineLimit(1)
                                .minimumScaleFactor(0.74)
                        }
                    }

                    Text(feedback?.message ?? fallbackMessage)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: 265, alignment: .leading)
                .background(Color(red: 242 / 255, green: 242 / 255, blue: 247 / 255), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .accessibilityIdentifier("today.record.feedback")

                Text("本内容仅供生活方式参考，不构成医疗建议")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
            }
        }
    }
}

/// Vitora avatar — rounded square with warm bottom glow + pixel egg.
/// Matches the reference: cream/white bg, soft shadow, warm light source underneath.
struct VitoraAvatarGlow: View {
    var size: CGFloat = 42

    var body: some View {
        ZStack {
            // Warm glow underneath
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 255 / 255, green: 220 / 255, blue: 180 / 255).opacity(0.5),
                            Color(red: 255 / 255, green: 235 / 255, blue: 210 / 255).opacity(0.2),
                            Color.clear,
                        ],
                        center: .bottom,
                        startRadius: 0,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size, height: size)

            // White/cream card background
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color(red: 252 / 255, green: 248 / 255, blue: 242 / 255),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.88, height: size * 0.88)
                .shadow(color: Color(red: 240 / 255, green: 190 / 255, blue: 140 / 255).opacity(0.35), radius: 6, x: 0, y: 4)
                .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)

            // Pixel egg
            PixelEggView(
                size: size * 0.52,
                expression: .sleepyBlush,
                materialStyle: .blueCrystal
            )
        }
        .frame(width: size, height: size)
    }
}
