import AVFoundation
import SwiftUI
import UIKit

enum DynamicAuraVariant: String, CaseIterable, Equatable {
    case base
    case menstrual
    case follicular
    case ovulation
    case luteal

    static func cycleVariant(for day: Int?) -> DynamicAuraVariant {
        guard let day else {
            return .base
        }

        switch day {
        case 1...5:
            return .menstrual
        case 6...13:
            return .follicular
        case 14...16:
            return .ovulation
        default:
            return .luteal
        }
    }

    var phaseLabel: String {
        switch self {
        case .base:
            return "低数据"
        case .menstrual:
            return "月经期"
        case .follicular:
            return "卵泡期"
        case .ovulation:
            return "排卵期"
        case .luteal:
            return "黄体期"
        }
    }

    var assetName: String {
        switch self {
        case .base:
            return "default"
        case .menstrual:
            return "menstrual"
        case .follicular:
            return "follicular"
        case .ovulation:
            return "ovulation"
        case .luteal:
            return "luteal"
        }
    }

    var readabilityWash: Double {
        switch self {
        case .ovulation:
            return 0.32
        case .luteal:
            return 0.36
        case .menstrual:
            return 0.34
        default:
            return 0.30
        }
    }

    var softTint: Color {
        switch self {
        case .base:
            return Color(red: 154 / 255, green: 221 / 255, blue: 252 / 255)
        case .menstrual:
            return Color(red: 244 / 255, green: 198 / 255, blue: 218 / 255)
        case .follicular:
            return Color(red: 118 / 255, green: 220 / 255, blue: 228 / 255)
        case .ovulation:
            return Color(red: 123 / 255, green: 225 / 255, blue: 176 / 255)
        case .luteal:
            return Color(red: 245 / 255, green: 214 / 255, blue: 128 / 255)
        }
    }

    var videoURL: URL? {
        Bundle.main.url(
            forResource: "dynamic-aura-\(assetName)",
            withExtension: "mp4",
            subdirectory: "DynamicAura"
        ) ?? Bundle.main.url(forResource: "dynamic-aura-\(assetName)", withExtension: "mp4")
    }

    var posterURL: URL? {
        Bundle.main.url(
            forResource: "dynamic-aura-\(assetName)-poster",
            withExtension: "png",
            subdirectory: "DynamicAura"
        ) ?? Bundle.main.url(forResource: "dynamic-aura-\(assetName)-poster", withExtension: "png")
    }
}

struct DynamicAuraVideoBackground: View {
    var variant: DynamicAuraVariant = .base
    var intensity: Double = 1
    var motionEnabled = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        ZStack {
            if shouldPlayVideo, let videoURL = variant.videoURL {
                LoopingAuraVideoView(url: videoURL)
                    .id(videoURL)
                    .transition(.opacity)
            } else if let posterURL = variant.posterURL, let image = UIImage(contentsOfFile: posterURL.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            } else {
                PremiumAuraBackground(scene: premiumScene, intensity: intensity)
            }

            VitoraTheme.ColorToken.paperWarmLift
                .opacity(reduceTransparency ? 0.64 : variant.readabilityWash * 0.72 * intensity)

            variant.softTint
                .opacity(reduceTransparency ? 0.04 : 0.08 * intensity)
                .blendMode(.softLight)

            LinearGradient(
                colors: [
                    VitoraTheme.ColorToken.paperWarmLift.opacity(0.22),
                    VitoraTheme.ColorToken.paperWarmBase.opacity(0.08),
                    VitoraTheme.ColorToken.paperWarmCyanMist.opacity(0.10),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.softLight)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.32), value: variant)
        .accessibilityHidden(true)
        .accessibilityIdentifier("dynamic.aura.background.\(variant.assetName)")
    }

    private var shouldPlayVideo: Bool {
        motionEnabled && !reduceMotion
    }

    private var premiumScene: PremiumAuraScene {
        switch variant {
        case .base, .follicular, .ovulation, .menstrual:
            return .today
        case .luteal:
            return .cycle
        }
    }
}

private struct LoopingAuraVideoView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> LoopingAuraVideoUIView {
        LoopingAuraVideoUIView(url: url)
    }

    func updateUIView(_ uiView: LoopingAuraVideoUIView, context: Context) {
        uiView.configure(url: url)
    }
}

private final class LoopingAuraVideoUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var currentURL: URL?

    init(url: URL) {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        layer.addSublayer(playerLayer)
        playerLayer.videoGravity = .resizeAspectFill
        configure(url: url)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    func configure(url: URL) {
        guard currentURL != url else {
            player?.play()
            return
        }

        currentURL = url
        let item = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer()
        queuePlayer.isMuted = true
        queuePlayer.actionAtItemEnd = .none
        playerLayer.player = queuePlayer
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        player = queuePlayer
        queuePlayer.play()
    }
}
