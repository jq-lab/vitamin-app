import SwiftUI

enum VitoraHeaderMode: Equatable {
    case expanded
    case docked
    case fullChat

    var isCompact: Bool {
        self != .expanded
    }
}

private struct VitoraHeaderLayoutMetrics {
    let stackSpacing: CGFloat
    let heroTopPadding: CGFloat
    let heroSpaceHeight: CGFloat
    let heroOpacity: Double

    static func metrics(for mode: VitoraHeaderMode) -> VitoraHeaderLayoutMetrics {
        switch mode {
        case .expanded:
            return VitoraHeaderLayoutMetrics(
                stackSpacing: 11,
                heroTopPadding: 38,
                heroSpaceHeight: 254,
                heroOpacity: 1
            )
        case .docked:
            return VitoraHeaderLayoutMetrics(
                stackSpacing: 6,
                heroTopPadding: 12,
                heroSpaceHeight: 184,
                heroOpacity: 0.98
            )
        case .fullChat:
            return VitoraHeaderLayoutMetrics(
                stackSpacing: 7,
                heroTopPadding: 10,
                heroSpaceHeight: 156,
                heroOpacity: 0.46
            )
        }
    }
}

struct VitoraCompressedHeader: View {
    var mode: VitoraHeaderMode = .expanded
    var isListening = false
    var isMuted = false
    var onBack: () -> Void = {}
    var onToggleMute: () -> Void = {}
    var onOpenSupport: () -> Void = {}
    var onOpenCalendar: () -> Void = {}
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var entered = false
    private var metrics: VitoraHeaderLayoutMetrics {
        .metrics(for: mode)
    }

    var body: some View {
        VStack(spacing: metrics.stackSpacing) {
            topControls
                .zIndex(3)
            heroSpace
                .zIndex(1)
        }
        .onAppear {
            guard !reduceMotion else {
                entered = true
                return
            }
            withAnimation(.easeOut(duration: 0.32)) {
                entered = true
            }
        }
    }

    private var topControls: some View {
        HStack {
            circularHeaderButton(systemName: "chevron.left", isSelected: false, action: onBack)
                .accessibilityLabel("返回")
                .accessibilityIdentifier("vitora.header.back")

            Spacer()

            circularHeaderButton(systemName: isMuted ? "speaker.slash" : "speaker.wave.2", isSelected: isMuted, action: onToggleMute)
                .accessibilityLabel(isMuted ? "取消静音" : "静音")
                .accessibilityValue(isMuted ? "已静音" : "未静音")
                .accessibilityIdentifier("vitora.header.mute")

            circularHeaderButton(systemName: "ellipsis", isSelected: false, action: onOpenSupport)
                .accessibilityLabel("打开 Vitora 设置")
                .accessibilityIdentifier("vitora.support.open")
        }
    }

    private var heroSpace: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Vitora 知道卡片")
                .accessibilityIdentifier("vitora.hero")
                .allowsHitTesting(false)

            Button(action: onOpenCalendar) {
                VitoraKnowledgeHeroCard(mode: mode, isListening: isListening)
                    .padding(.top, metrics.heroTopPadding)
                    .opacity(metrics.heroOpacity)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("打开今日 5月5日周期日历")
            .accessibilityIdentifier("vitora.date.context.openCalendar")
        }
        .frame(height: metrics.heroSpaceHeight)
    }

    private func circularHeaderButton(systemName: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(isSelected ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.strongText)
                .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                .background(GlassSurface(cornerRadius: VitoraTheme.Size.touchTargetMin / 2, opacity: isSelected ? 0.48 : 0.34, shadowStrength: 0.34))
                .overlay(
                    Circle()
                        .stroke(isSelected ? VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.42) : Color.white.opacity(0.62), lineWidth: isSelected ? 1.1 : 0.7)
                )
                .clipShape(Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
        .contentShape(Circle())
    }

}

private struct VitoraKnowledgeHeroCard: View {
    let mode: VitoraHeaderMode
    let isListening: Bool

    private var compressed: Bool { mode.isCompact }
    private var fullChat: Bool { mode == .fullChat }
    private var foregroundTop: CGFloat { compressed ? 54 : 70 }
    private var shelfDepth: CGFloat { compressed ? 15 : 19 }
    private var cornerRadius: CGFloat { compressed ? 26 : 30 }
    private var cardHeight: CGFloat { fullChat ? 138 : (compressed ? 158 : 192) }
    private var backplateHeight: CGFloat { fullChat ? 74 : (compressed ? 88 : 112) }
    private var rightPaneWidth: CGFloat { fullChat ? 108 : (compressed ? 126 : 132) }
    private var companionSize: CGFloat { fullChat ? 62 : (compressed ? 76 : 108) }

    var body: some View {
        ZStack(alignment: .topLeading) {
            unifiedComponentHalo

            folderShell

            interLayerCompanion

            titleMark

            dataContextPill
                .padding(.top, compressed ? 12 : 14)
                .padding(.trailing, compressed ? 18 : 24)
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .allowsHitTesting(false)

            foregroundKnowledgeCard
                .padding(.top, foregroundTop)
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .compositingGroup()
        .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.14), radius: compressed ? 18 : 24, x: 0, y: compressed ? 12 : 15)
        .shadow(color: Color(red: 244 / 255, green: 132 / 255, blue: 174 / 255).opacity(0.13), radius: compressed ? 18 : 24, x: -4, y: compressed ? 8 : 10)
        .shadow(color: VitoraTheme.ColorToken.paper.opacity(0.60), radius: compressed ? 9 : 12, x: -2, y: -3)
    }

    private var titleMark: some View {
        Text("Vitora 知道")
        .font((compressed ? Font.body : Font.title3).weight(.heavy))
        .multilineTextAlignment(.leading)
        .foregroundStyle(VitoraTheme.ColorToken.paper.opacity(fullChat ? 0.38 : 0.68))
        .shadow(color: Color(red: 240 / 255, green: 116 / 255, blue: 156 / 255).opacity(0.12), radius: 8, x: 0, y: 3)
        .padding(.top, compressed ? 13 : 15)
        .padding(.leading, compressed ? 28 : 34)
        .allowsHitTesting(false)
    }

    private var interLayerCompanion: some View {
        PixelVitoraScene(
            state: isListening ? .listening : .questioning,
            size: companionSize,
            accessory: .none,
            showsSparkles: !compressed,
            showsBaseShadow: false,
            materialStyle: .heroCompanion
        )
        .opacity(isListening ? (compressed ? 0.34 : 0.42) : (compressed ? 0.28 : 0.36))
        .blur(radius: compressed ? 0.7 : 1.0)
        .shadow(color: Color(red: 255 / 255, green: 161 / 255, blue: 108 / 255).opacity(compressed ? 0.10 : 0.14), radius: compressed ? 13 : 17, x: 0, y: 4)
        .offset(
            x: fullChat ? 238 : (compressed ? 246 : 255),
            y: fullChat ? 50 : (compressed ? 66 : 82)
        )
        .allowsHitTesting(false)
    }

    private var unifiedComponentHalo: some View {
        RoundedRectangle(cornerRadius: compressed ? 28 : 32, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        VitoraTheme.ColorToken.paper.opacity(0.36),
                        Color(red: 255 / 255, green: 225 / 255, blue: 238 / 255).opacity(0.30),
                        VitoraTheme.ColorToken.paper.opacity(0.20),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blur(radius: compressed ? 14 : 18)
            .padding(.horizontal, compressed ? 16 : 12)
            .frame(height: cardHeight - 12)
            .offset(y: compressed ? 6 : 8)
            .blendMode(.screen)
    }

    private var folderShell: some View {
        let shell = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return ZStack(alignment: .topLeading) {
            shell
                .fill(.ultraThinMaterial)
                .overlay {
                    shell.fill(
                        LinearGradient(
                            colors: [
                                VitoraTheme.ColorToken.paper.opacity(0.48),
                                Color(red: 248 / 255, green: 224 / 255, blue: 255 / 255).opacity(0.28),
                                Color(red: 255 / 255, green: 222 / 255, blue: 236 / 255).opacity(0.20),
                                VitoraTheme.ColorToken.paper.opacity(0.42),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }

            LinearGradient(
                colors: [
                    Color(red: 244 / 255, green: 220 / 255, blue: 255 / 255).opacity(0.48),
                    Color(red: 255 / 255, green: 116 / 255, blue: 158 / 255).opacity(0.44),
                    Color(red: 255 / 255, green: 176 / 255, blue: 96 / 255).opacity(0.34),
                    Color(red: 222 / 255, green: 238 / 255, blue: 255 / 255).opacity(0.24),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: backplateHeight)
            .clipShape(shell)
            .blur(radius: 0.4)

            VitoraFolderForegroundShape(shelfDepth: shelfDepth, cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .overlay {
                    VitoraFolderForegroundShape(shelfDepth: shelfDepth, cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    VitoraTheme.ColorToken.paper.opacity(compressed ? 0.62 : 0.66),
                                    Color(red: 255 / 255, green: 250 / 255, blue: 252 / 255).opacity(0.46),
                                    VitoraTheme.ColorToken.paper.opacity(0.34),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .padding(.top, foregroundTop)
                .padding(.horizontal, 4)

            VitoraFolderSeamShape(foregroundTop: foregroundTop, shelfDepth: shelfDepth)
                .stroke(
                    LinearGradient(
                        colors: [
                            VitoraTheme.ColorToken.paper.opacity(0.80),
                            VitoraTheme.ColorToken.paper.opacity(0.32),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round)
                )
                .padding(.horizontal, 4)
                .blendMode(.screen)

            shell
                .stroke(
                    LinearGradient(
                        colors: [
                            VitoraTheme.ColorToken.paper.opacity(0.92),
                            Color(red: 225 / 255, green: 232 / 255, blue: 242 / 255).opacity(0.62),
                            VitoraTheme.ColorToken.paper.opacity(0.72),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.05
                )
        }
        .padding(.horizontal, 4)
    }

    private var folderBackplate: some View {
        RoundedRectangle(cornerRadius: compressed ? 26 : 30, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: compressed ? 26 : 30, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                VitoraTheme.ColorToken.paper.opacity(0.46),
                                Color(red: 242 / 255, green: 214 / 255, blue: 255 / 255).opacity(0.42),
                                Color(red: 255 / 255, green: 128 / 255, blue: 165 / 255).opacity(0.48),
                                Color(red: 255 / 255, green: 177 / 255, blue: 104 / 255).opacity(0.42),
                                Color(red: 221 / 255, green: 238 / 255, blue: 255 / 255).opacity(0.30),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .blur(radius: 0.2)
            }
            .overlay {
                RoundedRectangle(cornerRadius: compressed ? 26 : 30, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                VitoraTheme.ColorToken.paper.opacity(0.46),
                                Color(red: 232 / 255, green: 220 / 255, blue: 235 / 255).opacity(0.30),
                                VitoraTheme.ColorToken.paper.opacity(0.28),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(VitoraTheme.ColorToken.paper.opacity(0.22))
                    .frame(height: 16)
                    .blur(radius: 10)
                    .offset(y: 8)
            }
            .padding(.horizontal, 4)
            .frame(height: compressed ? 98 : 116)
    }

    private var foregroundKnowledgeCard: some View {
        HStack(spacing: 0) {
            vitalsBlock
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(2)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            VitoraTheme.ColorToken.paper.opacity(0.14),
                            VitoraTheme.ColorToken.paper.opacity(0.72),
                            VitoraTheme.ColorToken.paper.opacity(0.18),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1, height: compressed ? 76 : 88)
                .padding(.leading, compressed ? 10 : 12)
                .padding(.trailing, compressed ? 8 : 10)

            energySummaryBlock
                .frame(width: rightPaneWidth, alignment: .trailing)
        }
        .padding(.horizontal, compressed ? 17 : 22)
        .padding(.vertical, compressed ? 13 : 15)
        .padding(.horizontal, 4)
    }

    private var vitalsBlock: some View {
        VStack(alignment: .leading, spacing: compressed ? 8 : 10) {
            knownRow(icon: "timer", text: "黄体期 Day18")
            knownRow(icon: "moon.fill", text: "睡眠 7.2h · 略低")
            knownRow(icon: "waveform.path.ecg", text: "HRV ↓8%", highlightsSuffix: true)
        }
    }

    private var energySummaryBlock: some View {
        ZStack(alignment: .trailing) {
            VStack(alignment: .trailing, spacing: compressed ? 4 : 5) {
                Text("今日能量")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText.opacity(0.74))

                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("68")
                        .font(.system(size: compressed ? 25 : 31, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 255 / 255, green: 150 / 255, blue: 94 / 255),
                                    Color(red: 72 / 255, green: 153 / 255, blue: 242 / 255),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .lineLimit(1)

                    Text("%")
                        .font(.system(size: compressed ? 12 : 15, weight: .heavy, design: .rounded))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.76))
                }
                .shadow(color: Color(red: 255 / 255, green: 174 / 255, blue: 98 / 255).opacity(0.16), radius: 10, x: 0, y: 4)
            }
            .padding(.trailing, compressed ? 2 : 4)
            .padding(.top, compressed ? 42 : 58)
        }
        .frame(maxHeight: .infinity, alignment: .topTrailing)
    }

    private var dataContextPill: some View {
        HStack(spacing: compressed ? 4 : 6) {
            Image(systemName: "calendar")
                .font(.system(size: compressed ? 9 : 10, weight: .bold))

            Text("今日")
                .font(.system(size: compressed ? 11 : 12, weight: .heavy))
                .foregroundStyle(VitoraTheme.ColorToken.strongText.opacity(0.84))

            Text("5月5日 周二")
                .font(.system(size: compressed ? 11 : 12, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text("黄体期")
                .font(.system(size: compressed ? 11 : 12, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Image(systemName: "chevron.right")
                .font(.system(size: compressed ? 8 : 9, weight: .heavy))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.72))
        }
        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
        .padding(.leading, compressed ? 9 : 11)
        .padding(.trailing, compressed ? 7 : 9)
        .frame(height: compressed ? 25 : 28)
        .background(VitoraTheme.ColorToken.paper.opacity(compressed ? 0.46 : 0.54), in: Capsule())
        .background(.ultraThinMaterial.opacity(0.20), in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.58), lineWidth: 0.65))
        .shadow(color: VitoraTheme.ColorToken.actionPrimaryDeep.opacity(0.08), radius: 7, x: 0, y: 3)
    }

    private var folderForegroundSurface: some View {
        let shape = VitoraFolderForegroundShape(shelfDepth: compressed ? 16 : 22, cornerRadius: compressed ? 25 : 30)
        return shape
            .fill(.ultraThinMaterial)
            .overlay {
                shape.fill(
                    LinearGradient(
                        colors: [
                            VitoraTheme.ColorToken.paper.opacity(compressed ? 0.46 : 0.50),
                            Color(red: 255 / 255, green: 244 / 255, blue: 248 / 255).opacity(compressed ? 0.26 : 0.30),
                            VitoraTheme.ColorToken.paper.opacity(compressed ? 0.22 : 0.26),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .overlay {
                shape.stroke(
                    LinearGradient(
                        colors: [
                            VitoraTheme.ColorToken.paper.opacity(0.72),
                            Color(red: 214 / 255, green: 230 / 255, blue: 235 / 255).opacity(0.52),
                            VitoraTheme.ColorToken.paper.opacity(0.42),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.1
                )
            }
            .overlay(alignment: .topLeading) {
                shape
                    .fill(
                        LinearGradient(
                            colors: [
                                VitoraTheme.ColorToken.paper.opacity(0.38),
                                .clear,
                            ],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .blendMode(.screen)
            }
    }

    private func knownRow(icon: String, text: String, highlightsSuffix: Bool = false) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: compressed ? 11 : 12, weight: .semibold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .frame(width: compressed ? 24 : 26, height: compressed ? 24 : 26)
                .background(VitoraTheme.ColorToken.paper.opacity(0.62), in: Circle())
                .overlay(Circle().stroke(VitoraTheme.ColorToken.paper.opacity(0.78), lineWidth: 0.75))

            Text(text)
                .font((compressed ? Font.subheadline : Font.body).weight(.semibold))
                .foregroundStyle(highlightsSuffix ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
    }
}

private struct VitoraFolderForegroundShape: Shape {
    var shelfDepth: CGFloat
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let r = min(cornerRadius, rect.width * 0.10, rect.height * 0.24)
        let shelfStart = rect.minX + rect.width * 0.43
        let shelfEnd = rect.minX + rect.width * 0.53
        let rightTop = rect.minY + shelfDepth
        let bottom = rect.maxY

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + r, y: rect.minY))
        path.addLine(to: CGPoint(x: shelfStart, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: shelfEnd, y: rightTop),
            control1: CGPoint(x: shelfStart + rect.width * 0.035, y: rect.minY),
            control2: CGPoint(x: shelfEnd - rect.width * 0.035, y: rightTop)
        )
        path.addLine(to: CGPoint(x: rect.maxX - r, y: rightTop))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rightTop + r), control: CGPoint(x: rect.maxX, y: rightTop))
        path.addLine(to: CGPoint(x: rect.maxX, y: bottom - r))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - r, y: bottom), control: CGPoint(x: rect.maxX, y: bottom))
        path.addLine(to: CGPoint(x: rect.minX + r, y: bottom))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: bottom - r), control: CGPoint(x: rect.minX, y: bottom))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        path.addQuadCurve(to: CGPoint(x: rect.minX + r, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

private struct VitoraFolderSeamShape: Shape {
    var foregroundTop: CGFloat
    var shelfDepth: CGFloat

    func path(in rect: CGRect) -> Path {
        let shelfStart = rect.minX + rect.width * 0.43
        let shelfEnd = rect.minX + rect.width * 0.53
        let rightTop = rect.minY + foregroundTop + shelfDepth

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 28, y: rect.minY + foregroundTop))
        path.addLine(to: CGPoint(x: shelfStart, y: rect.minY + foregroundTop))
        path.addCurve(
            to: CGPoint(x: shelfEnd, y: rightTop),
            control1: CGPoint(x: shelfStart + rect.width * 0.035, y: rect.minY + foregroundTop),
            control2: CGPoint(x: shelfEnd - rect.width * 0.035, y: rightTop)
        )
        path.addLine(to: CGPoint(x: rect.maxX - 28, y: rightTop))
        return path
    }
}
