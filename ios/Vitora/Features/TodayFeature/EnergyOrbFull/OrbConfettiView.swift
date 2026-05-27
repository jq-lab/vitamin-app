import SwiftUI

struct OrbConfettiView: View {
    let isActive: Bool
    let elapsed: Double // seconds since confetti trigger
    let duration: Double = 2.5

    private let particleCount = 30
    private let gravity: Double = 280 // px/s²

    private let colors: [Color] = [
        Color(red: 255 / 255, green: 143 / 255, blue: 176 / 255), // pink
        Color(red: 255 / 255, green: 186 / 255, blue: 100 / 255), // orange
        Color(red: 100 / 255, green: 210 / 255, blue: 140 / 255), // green
        Color(red: 90 / 255, green: 200 / 255, blue: 250 / 255),  // blue
        Color(red: 151 / 255, green: 135 / 255, blue: 255 / 255), // purple
        Color(red: 255 / 255, green: 220 / 255, blue: 100 / 255), // yellow
    ]

    var body: some View {
        if isActive && elapsed < duration + 1.5 {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let t = min(elapsed, duration)

                    for i in 0..<particleCount {
                        let seed = Double(i)
                        let angle = (seed / Double(particleCount)) * 2 * .pi + pseudoRandom(seed: seed) * 0.3
                        let speed = 180 + pseudoRandom(seed: seed + 100) * 160 // 180-340 px/s
                        let spinRate = (pseudoRandom(seed: seed + 200) - 0.5) * 8 // rad/s

                        let vx = cos(angle) * speed
                        let vy = sin(angle) * speed - 120 // bias upward initially

                        let x = center.x + vx * t * decayFactor(t)
                        let y = center.y + vy * t * decayFactor(t) + 0.5 * gravity * t * t
                        let rotation = Angle(radians: spinRate * t)

                        let opacity = max(0, 1 - t / duration)
                        let particleSize: CGFloat = 4 + CGFloat(pseudoRandom(seed: seed + 300)) * 4

                        let color = colors[i % colors.count]
                        let shape = i % 3 // 0=circle, 1=square, 2=capsule

                        var particlePath = Path()
                        switch shape {
                        case 0:
                            particlePath.addEllipse(in: CGRect(x: -particleSize / 2, y: -particleSize / 2,
                                                               width: particleSize, height: particleSize))
                        case 1:
                            particlePath.addRoundedRect(in: CGRect(x: -particleSize / 2, y: -particleSize / 2,
                                                                   width: particleSize, height: particleSize),
                                                       cornerSize: CGSize(width: 1, height: 1))
                        default:
                            particlePath.addRoundedRect(in: CGRect(x: -particleSize / 3, y: -particleSize / 2,
                                                                   width: particleSize * 0.66, height: particleSize),
                                                       cornerSize: CGSize(width: particleSize / 3, height: particleSize / 3))
                        }

                        var transform = CGAffineTransform.identity
                        transform = transform.translatedBy(x: x, y: y)
                        transform = transform.rotated(by: rotation.radians)
                        let transformedPath = particlePath.applying(transform)

                        context.fill(transformedPath, with: .color(color.opacity(opacity)))
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }

    private func decayFactor(_ t: Double) -> Double {
        max(0, 1 - t * 0.3)
    }

    private func pseudoRandom(seed: Double) -> Double {
        let x = sin(seed * 12.9898 + 78.233) * 43758.5453
        return x - floor(x)
    }
}
