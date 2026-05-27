import SwiftUI

struct EnergyOrbFullView: View {
    let isFullVersion: Bool
    let onComplete: () -> Void

    @State private var startDate: Date?
    @State private var showAnalysisCard = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let ringDiameter: CGFloat = 220

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if let startDate, !showAnalysisCard {
                TimelineView(.animation) { timeline in
                    let elapsed = timeline.date.timeIntervalSince(startDate)
                    orbScene(elapsed: elapsed)
                        .onChange(of: elapsed > OrbTimeline.totalDuration(isFullVersion: isFullVersion) - 1.0) { _, shouldShowCard in
                            if shouldShowCard && !showAnalysisCard {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    showAnalysisCard = true
                                }
                            }
                        }
                }
            }

            // Confetti continues after orb fades
            if let startDate {
                let confettiStart = isFullVersion ? 12.0 : 4.5
                TimelineView(.animation) { timeline in
                    let elapsed = timeline.date.timeIntervalSince(startDate)
                    OrbConfettiView(
                        isActive: elapsed >= confettiStart,
                        elapsed: max(0, elapsed - confettiStart)
                    )
                }
                .allowsHitTesting(false)
            }

            // Analysis card (stage 7)
            if showAnalysisCard {
                BodyAnalysisCard(onClose: onComplete)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .onAppear {
            if reduceMotion {
                showAnalysisCard = true
            } else {
                startDate = Date()
            }
        }
    }

    @ViewBuilder
    private func orbScene(elapsed: Double) -> some View {
        let currentStage = OrbTimeline.stage(at: elapsed, isFullVersion: isFullVersion)
        let fadeOut = currentStage == .cardReveal
        let sceneOpacity = fadeOut ? max(0, 1 - OrbTimeline.stageProgress(at: elapsed, stage: .cardReveal, isFullVersion: isFullVersion) * 2) : 1.0

        ZStack {
            // Top text area
            VStack(spacing: 0) {
                topText(elapsed: elapsed, stage: currentStage)
                    .frame(height: 60)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .padding(.top, 120)

            // Center: ring + inner content
            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    // Ring
                    OrbRingView(
                        diameter: ringDiameter,
                        segment1Progress: segmentProgress(segment: 1, elapsed: elapsed),
                        segment2Progress: segmentProgress(segment: 2, elapsed: elapsed),
                        segment3Progress: segmentProgress(segment: 3, elapsed: elapsed),
                        compositeProgress: compositeBlend(elapsed: elapsed),
                        ringScale: ringScale(elapsed: elapsed)
                    )

                    // Glow pulse (stage 6)
                    if OrbTimeline.hasReached(stage: .confetti, at: elapsed, isFullVersion: isFullVersion) {
                        let confettiProgress = OrbTimeline.stageProgress(at: elapsed, stage: .confetti, isFullVersion: isFullVersion)
                        if confettiProgress < 0.3 {
                            OrbRingGlowPulse(diameter: ringDiameter, progress: confettiProgress / 0.3)
                        }
                    }

                    // Inner content (numbers)
                    innerContent(elapsed: elapsed, stage: currentStage)
                }

                Spacer()

                // Data bubbles (stage 5+)
                if OrbTimeline.hasReached(stage: .composite, at: elapsed, isFullVersion: isFullVersion) {
                    dataBubbles(elapsed: elapsed)
                        .padding(.bottom, 40)
                }
            }
        }
        .opacity(sceneOpacity)
    }

    // MARK: - Top Text

    @ViewBuilder
    private func topText(elapsed: Double, stage: OrbStage) -> some View {
        switch stage {
        case .opening:
            TypewriterText(
                fullText: "发现……",
                charDuration: 0.08,
                startDelay: 0.5,
                fontSize: 14,
                color: Color(red: 184 / 255, green: 184 / 255, blue: 194 / 255)
            )

        case .sleep:
            TypewriterText(
                fullText: "昨晚的睡眠很给力，7.2 小时深睡到位",
                charDuration: 0.05,
                startDelay: 0,
                fontSize: 13,
                color: Color(red: 26 / 255, green: 26 / 255, blue: 31 / 255)
            )
            .id("sleep-text")

        case .heartRate:
            TypewriterText(
                fullText: "午后 94bpm 心率，那趟楼梯让你心跳加速了",
                charDuration: 0.05,
                startDelay: 0,
                fontSize: 13,
                color: Color(red: 26 / 255, green: 26 / 255, blue: 31 / 255)
            )
            .id("hr-text")

        case .hrv:
            TypewriterText(
                fullText: "HRV 48ms 比昨天低了 8%，神经还紧绷",
                charDuration: 0.05,
                startDelay: 0,
                fontSize: 13,
                color: Color(red: 26 / 255, green: 26 / 255, blue: 31 / 255)
            )
            .id("hrv-text")

        default:
            EmptyView()
        }
    }

    // MARK: - Inner Content (center of ring)

    @ViewBuilder
    private func innerContent(elapsed: Double, stage: OrbStage) -> some View {
        switch stage {
        case .opening:
            EmptyView()

        case .sleep:
            VStack(spacing: 2) {
                RollingNumberView(
                    target: 7.2, duration: 0.8, elapsed: elapsed,
                    startTime: 2.4, decimals: 1, fontSize: 28,
                    fontDesign: .serif, color: .black, suffix: "h"
                )
                Text("深睡 +12%")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(red: 40 / 255, green: 205 / 255, blue: 150 / 255))
            }
            .transition(.asymmetric(insertion: .offset(y: 30).combined(with: .opacity), removal: .offset(y: -30).combined(with: .opacity)))

        case .heartRate:
            VStack(spacing: 2) {
                RollingNumberView(
                    target: 94, duration: 0.8, elapsed: elapsed,
                    startTime: 4.9, decimals: 0, fontSize: 28,
                    fontDesign: .serif, color: .black, suffix: "bpm"
                )
                Text("心率峰值")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            }
            .transition(.asymmetric(insertion: .offset(y: 30).combined(with: .opacity), removal: .offset(y: -30).combined(with: .opacity)))

        case .hrv:
            VStack(spacing: 2) {
                RollingNumberView(
                    target: 48, duration: 0.8, elapsed: elapsed,
                    startTime: 7.4, decimals: 0, fontSize: 28,
                    fontDesign: .serif, color: .black, suffix: "ms"
                )
                Text("HRV ↓8%")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(red: 240 / 255, green: 139 / 255, blue: 82 / 255))
            }
            .transition(.asymmetric(insertion: .offset(y: 30).combined(with: .opacity), removal: .offset(y: -30).combined(with: .opacity)))

        case .composite, .confetti, .cardReveal:
            VStack(spacing: 4) {
                RollingNumberView(
                    target: 68, duration: 1.0, elapsed: elapsed,
                    startTime: 9.6, decimals: 0, fontSize: 56,
                    fontDesign: .serif, color: .black, suffix: "%"
                )
                Text("综合能量 · 充足")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(red: 90 / 255, green: 200 / 255, blue: 250 / 255))
                    .opacity(elapsed >= 10.0 ? 1 : 0)
                Text("身体年龄 25.3 ↓-1.2")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(red: 40 / 255, green: 205 / 255, blue: 150 / 255))
                    .opacity(elapsed >= 10.4 ? 1 : 0)
            }
            .transition(.scale(scale: 0.8).combined(with: .opacity))

        default:
            EmptyView()
        }
    }

    // MARK: - Data Bubbles (stage 5)

    private func dataBubbles(elapsed: Double) -> some View {
        let bubbleStart = isFullVersion ? 10.8 : 3.0
        let bubbles = OrbBubbleData.defaults

        return HStack(spacing: 8) {
            ForEach(Array(bubbles.enumerated()), id: \.offset) { index, bubble in
                let delay = Double(bubble.delayMs) / 1000.0
                let bubbleElapsed = elapsed - bubbleStart - delay
                let isVisible = bubbleElapsed > 0

                OrbDataBubble(
                    title: bubble.title,
                    value: bubble.value,
                    delta: bubble.delta,
                    accent: bubble.accent,
                    isPositive: bubble.isPositive
                )
                .opacity(isVisible ? 1 : 0)
                .offset(x: isVisible ? 0 : (bubble.entryEdge == .leading ? -60 : 60))
                .floatingMotion(isActive: bubbleElapsed > 0.6)
                .animation(.spring(response: 0.6, dampingFraction: 0.72), value: isVisible)
            }
        }
    }

    // MARK: - Ring Progress Calculations

    private func ringScale(elapsed: Double) -> Double {
        guard elapsed >= 1.0 else { return 0 }
        let t = min((elapsed - 1.0) / 0.5, 1.0)
        return springBounce(t)
    }

    private func segmentProgress(segment: Int, elapsed: Double) -> Double {
        guard isFullVersion else {
            // Brief: all segments fill instantly in composite
            return OrbTimeline.hasReached(stage: .composite, at: elapsed, isFullVersion: false) ? 1 : 0
        }

        switch segment {
        case 1: // 0°-120°, fills during sleep stage (T=2.4s, 600ms)
            let t = (elapsed - 2.4) / 0.6
            return min(max(t, 0), 1)
        case 2: // 120°-240°, fills during heartRate stage (T=4.9s, 600ms)
            let t = (elapsed - 4.9) / 0.6
            return min(max(t, 0), 1)
        case 3: // 240°-360°, fills during hrv stage (T=7.4s, 600ms)
            let t = (elapsed - 7.4) / 0.6
            return min(max(t, 0), 1)
        default:
            return 0
        }
    }

    private func compositeBlend(elapsed: Double) -> Double {
        let compositeStart = isFullVersion ? 9.0 : 1.5
        let t = (elapsed - compositeStart) / 0.6
        return min(max(t, 0), 1)
    }
}
