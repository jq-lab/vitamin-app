import SwiftUI

enum PixelVitoraState {
    case idle
    case listening
    case thinking
    case confirming
}

struct PixelVitoraView: View {
    var state: PixelVitoraState = .idle
    var size: CGFloat = 96
    var showsGlow: Bool = true

    var body: some View {
        ZStack {
            if showsGlow {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                VitoraTheme.ColorToken.auraCyan.opacity(0.72),
                                VitoraTheme.ColorToken.auraLavender.opacity(0.46),
                                .clear,
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: size * 0.72
                        )
                    )
                    .frame(width: size * 1.58, height: size * 1.58)
                    .blur(radius: size * 0.08)
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            VitoraTheme.ColorToken.paper.opacity(0.92),
                            VitoraTheme.ColorToken.auraCyan.opacity(0.62),
                            VitoraTheme.ColorToken.auraBlue.opacity(0.72),
                            VitoraTheme.ColorToken.auraLavender.opacity(0.52),
                        ],
                        center: .topLeading,
                        startRadius: 1,
                        endRadius: size * 0.74
                    )
                )
                .frame(width: size, height: size)
                .overlay {
                    Circle()
                        .stroke(VitoraTheme.ColorToken.paper.opacity(0.82), lineWidth: max(1, size * 0.018))
                }
                .shadow(color: VitoraTheme.ColorToken.auraBlue.opacity(0.28), radius: size * 0.22, x: 0, y: size * 0.08)

            HStack(spacing: size * 0.13) {
                pixelEye
                pixelEye
            }
            .offset(y: -size * 0.04)
        }
        .frame(width: size * 1.42, height: size * 1.42)
        .accessibilityLabel("像素 Vitora")
        .accessibilityIdentifier("pixel.vitora")
    }

    private var pixelEye: some View {
        VStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { column in
                        RoundedRectangle(cornerRadius: 1.4, style: .continuous)
                            .fill(eyeFill(row: row, column: column))
                            .frame(width: max(3, size * 0.035), height: max(3, size * 0.035))
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func eyeFill(row: Int, column: Int) -> Color {
        let active: Set<String>
        switch state {
        case .idle:
            active = ["0-1", "1-1", "2-1", "3-1", "4-1"]
        case .listening:
            active = ["0-1", "1-0", "1-1", "1-2", "2-0", "2-2", "3-1"]
        case .thinking:
            active = ["1-0", "1-1", "1-2", "2-2", "3-1"]
        case .confirming:
            active = ["1-0", "2-1", "3-2"]
        }
        return active.contains("\(row)-\(column)") ? VitoraTheme.ColorToken.paper.opacity(0.96) : .clear
    }
}

struct VitoraFaceTabButton: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 48, height: 48)
                .overlay(Circle().stroke(VitoraTheme.ColorToken.paper.opacity(0.86), lineWidth: 2))
                .shadow(color: VitoraTheme.ColorToken.auraBlue.opacity(isSelected ? 0.34 : 0.12), radius: 12, x: 0, y: 4)

            PixelVitoraView(state: isSelected ? .listening : .idle, size: 33, showsGlow: false)
        }
        .accessibilityIdentifier("tab.vitora.face")
    }
}
