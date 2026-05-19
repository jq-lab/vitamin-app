import SwiftUI

struct ShareCardPreviewSheet: View {
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color(red: 248 / 255, green: 246 / 255, blue: 242 / 255).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Vitora✦")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)

                        HStack(spacing: 6) {
                            Text("✦").font(.caption)
                            Text("🌸").font(.caption)
                            Text("Vitora 分享卡片预览")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                            Text("🌸").font(.caption)
                            Text("✦").font(.caption)
                        }

                        Text("记录能量 · 洞察节律 · 温柔成长")
                            .font(.caption)
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }
                    .padding(.top, 16)

                    // Two cards side by side
                    HStack(alignment: .top, spacing: 12) {
                        morningCard
                        eveningCard
                    }
                    .padding(.horizontal, 4)

                    // Share bottom
                    shareFooter

                    // Close
                    Button("关闭预览", action: onClose)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Morning Card

    private var morningCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Vitora✦")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                Spacer()
                HStack(spacing: 3) {
                    Text("☀️").font(.caption2)
                    Text("早安花卡").font(.caption2.weight(.medium)).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }
            }

            VStack(spacing: 4) {
                Text("早安 ☀️")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text("愿你今天从容有余")
                    .font(.caption)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            // Pixel garden image
            Image("PixelGarden")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(spacing: 4) {
                Text("留白花 · 半开")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                HStack(spacing: 2) {
                    Text("✦").font(.caption2).foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    Text("花语").font(.caption2.weight(.bold)).foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    Text("✦").font(.caption2).foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                }

                Text("给自己留一点呼吸的空间，\n也是在照顾明天。")
                    .font(.caption2)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 12) {
                Label("今日 72%", systemImage: "heart.fill")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                Label("黄体期 D19", systemImage: "clock")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            Text("Vitora✦")
                .font(.caption2.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.88))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        )
    }

    // MARK: - Evening Card

    private var eveningCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Vitora✦")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                Spacer()
                HStack(spacing: 3) {
                    Text("🌙").font(.caption2)
                    Text("晚安复盘卡").font(.caption2.weight(.medium)).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                }
            }

            VStack(spacing: 4) {
                Text("今晚复盘 🌙")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text("回看今天前后的变化")
                    .font(.caption)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            // Energy comparison
            HStack(spacing: 8) {
                VStack(spacing: 4) {
                    Text("早上").font(.caption2.weight(.medium)).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .padding(.horizontal, 8).padding(.vertical, 2)
                        .background(Color.gray.opacity(0.10), in: Capsule())
                    Text("68").font(.title2.weight(.bold)).foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Text("分").font(.caption2).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    Text("半开").font(.caption2.weight(.medium)).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    Text("🌸").font(.system(size: 28))
                }

                Image(systemName: "arrow.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)

                VStack(spacing: 4) {
                    Text("晚上").font(.caption2.weight(.medium)).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .padding(.horizontal, 8).padding(.vertical, 2)
                        .background(Color.gray.opacity(0.10), in: Capsule())
                    Text("有帮助")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(VitoraTheme.ColorToken.actionPrimaryDeep, in: Capsule())
                    Text("更舒展").font(.caption2.weight(.medium)).foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    Text("🌺").font(.system(size: 28))
                }
            }

            Text("今天你保留了下午的恢复时间，\nVitora 又更懂你一点。")
                .font(.caption2)
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .multilineTextAlignment(.center)

            HStack(spacing: 4) {
                Text("🪴").font(.caption)
                Text("今晚种下一颗种子")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                Text("✦").font(.caption2).foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(
                Capsule().fill(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.08))
                    .overlay(Capsule().stroke(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.22), lineWidth: 0.8))
            )

            Text("Vitora✦")
                .font(.caption2.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.88))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        )
    }

    // MARK: - Share Footer

    private var shareFooter: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(
                    LinearGradient(colors: [Color(red: 0.72, green: 0.82, blue: 0.95), Color(red: 0.82, green: 0.72, blue: 0.92)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 48, height: 48)
                .overlay(Text("🌿").font(.title3))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("分享你的能量花园").font(.subheadline.weight(.bold)).foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Text("🌱").font(.caption)
                }
                Text("长按保存图片，分享给你的朋友\n一起温柔记录每一天的自己")
                    .font(.caption2)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }

            Spacer()

            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.12))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: "qrcode")
                            .font(.system(size: 28))
                            .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                    )
                Text("扫码下载 Vitora")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.82))
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.58), lineWidth: 0.7))
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        )
    }
}
