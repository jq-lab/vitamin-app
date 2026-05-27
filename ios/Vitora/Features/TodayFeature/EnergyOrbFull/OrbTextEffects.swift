import SwiftUI

// MARK: - Typewriter Text

struct TypewriterText: View {
    let fullText: String
    let charDuration: Double
    let startDelay: Double
    let fontSize: CGFloat
    let color: Color

    @State private var visibleCount: Int = 0
    @State private var timer: Timer?

    var body: some View {
        Text(String(fullText.prefix(visibleCount)))
            .font(.system(size: fontSize, weight: .medium))
            .foregroundStyle(color)
            .lineSpacing(3)
            .onAppear { startTyping() }
            .onDisappear { timer?.invalidate() }
    }

    private func startTyping() {
        visibleCount = 0
        let totalChars = fullText.count
        guard totalChars > 0 else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
            timer = Timer.scheduledTimer(withTimeInterval: charDuration, repeats: true) { t in
                if visibleCount < totalChars {
                    visibleCount += 1
                } else {
                    t.invalidate()
                }
            }
        }
    }
}

// MARK: - Rolling Number (driven by elapsed time)

struct RollingNumberView: View {
    let target: Double
    let duration: Double
    let elapsed: Double
    let startTime: Double
    let decimals: Int
    let fontSize: CGFloat
    let fontDesign: Font.Design
    let color: Color
    let suffix: String

    init(
        target: Double,
        duration: Double = 0.8,
        elapsed: Double,
        startTime: Double,
        decimals: Int = 1,
        fontSize: CGFloat = 28,
        fontDesign: Font.Design = .serif,
        color: Color = .black,
        suffix: String = ""
    ) {
        self.target = target
        self.duration = duration
        self.elapsed = elapsed
        self.startTime = startTime
        self.decimals = decimals
        self.fontSize = fontSize
        self.fontDesign = fontDesign
        self.color = color
        self.suffix = suffix
    }

    private var currentValue: Double {
        let t = elapsed - startTime
        guard t > 0 else { return 0 }
        let progress = min(t / duration, 1.0)
        return target * easeOut(progress)
    }

    var body: some View {
        Text(formatted)
            .font(.system(size: fontSize, weight: .bold, design: fontDesign))
            .foregroundStyle(color)
            .monospacedDigit()
            .contentTransition(.numericText())
    }

    private var formatted: String {
        if decimals == 0 {
            return "\(Int(currentValue))\(suffix)"
        }
        return String(format: "%.\(decimals)f\(suffix)", currentValue)
    }
}

// MARK: - Fade-slide text transition helpers

struct SlideInText: View {
    let text: String
    let fontSize: CGFloat
    let color: Color
    let isVisible: Bool
    let fromDirection: Edge

    var body: some View {
        if isVisible {
            Text(text)
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundStyle(color)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: fromDirection == .bottom ? .bottom : .top).combined(with: .opacity),
                        removal: .opacity
                    )
                )
        }
    }
}
