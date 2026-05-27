import SwiftUI

struct OnboardingAboutYouView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            registrationHero

            VStack(spacing: 12) {
                RegistrationProviderButton(
                    title: "用 Apple 继续",
                    systemImage: "apple.logo",
                    style: .apple,
                    isEnabled: true
                ) {
                    viewModel.startRegistration(provider: .apple)
                }
                .accessibilityIdentifier("onboarding.signIn.apple")

                RegistrationProviderButton(
                    title: "用微信继续",
                    systemImage: "message.fill",
                    style: .wechat,
                    isEnabled: true
                ) {
                    viewModel.startRegistration(provider: .wechat)
                }
                .accessibilityIdentifier("onboarding.signIn.wechat")

                RegistrationProviderButton(
                    title: "用 QQ 继续",
                    systemImage: "bubble.left.and.bubble.right.fill",
                    style: .outline,
                    isEnabled: true
                ) {
                    viewModel.startRegistration(provider: .qq)
                }
                .accessibilityIdentifier("onboarding.signIn.qq")

                Button {
                    viewModel.startRegistration(provider: .local)
                } label: {
                    Text("先本地体验")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.50))
                                .overlay(Capsule().stroke(Color.white.opacity(0.74), lineWidth: 0.8))
                        )
                }
                .accessibilityIdentifier("onboarding.signIn.local")
            }

            agreementRow
        }
        .padding(.top, 8)
        .padding(.bottom, 28)
        .accessibilityIdentifier("onboarding.page.1")
    }

    private var registrationHero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.74),
                            VitoraTheme.ColorToken.surfacePearlMain.opacity(0.58),
                            Color(red: 245 / 255, green: 253 / 255, blue: 249 / 255).opacity(0.32),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 418)
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.white.opacity(0.76), lineWidth: 0.9)
                )
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.12), radius: 24, x: 0, y: 14)
                .overlay(alignment: .topTrailing) {
                    SupportGlyph()
                        .padding(.top, 16)
                        .padding(.trailing, 14)
                }

            OnboardingOrganicBlob(color: Color(red: 207 / 255, green: 246 / 255, blue: 139 / 255), rotation: -8)
                .frame(width: 168, height: 136)
                .offset(x: 122, y: 74)
                .opacity(0.28)

            OnboardingOrganicBlob(color: Color(red: 255 / 255, green: 250 / 255, blue: 149 / 255), rotation: -34)
                .frame(width: 142, height: 118)
                .offset(x: -138, y: 72)
                .opacity(0.22)

            PixelSparkle(color: Color(red: 78 / 255, green: 195 / 255, blue: 231 / 255), size: 22)
                .offset(x: 104, y: -118)
                .opacity(0.58)

            PixelSparkle(color: Color(red: 255 / 255, green: 173 / 255, blue: 63 / 255), size: 20)
                .offset(x: 136, y: -86)
                .opacity(0.48)

            VStack(spacing: 18) {
                Text("Hi，我是 Vitora")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.72))
                            .overlay(Capsule().stroke(Color.white.opacity(0.86), lineWidth: 0.8))
                            .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.08), radius: 12, x: 0, y: 6)
                    )
                    .padding(.top, 34)

                RegistrationSoftVitoraMascot(reduceMotion: reduceMotion)
                    .frame(width: 206, height: 176)
                    .accessibilityIdentifier("onboarding.pixelVitora.login")

                VStack(spacing: 10) {
                    Text("先让 Vitora\n认识你一点点")
                        .font(.system(size: 31, weight: .bold, design: .rounded))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .overlay(alignment: .bottom) {
                            Capsule()
                                .fill(VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.72))
                                .frame(width: 138, height: 7)
                                .offset(y: 4)
                        }

                    Text("选择一种进入方式，稍后 Vitora 会像聊天一样补充最小上下文。")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 286, alignment: .center)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity)
    }

    private var agreementRow: some View {
        Button {
            viewModel.toggleAgreements()
        } label: {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: viewModel.acceptedAgreements ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(viewModel.acceptedAgreements ? Color(red: 103 / 255, green: 216 / 255, blue: 82 / 255) : VitoraTheme.ColorToken.secondaryText)

                Text("我已阅读并同意《隐私政策》和《用户协议》")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(viewModel.agreementRequiresAttention ? Color(red: 255 / 255, green: 236 / 255, blue: 218 / 255).opacity(0.92) : Color.clear)
        )
        .overlay(
            Capsule()
                .stroke(viewModel.agreementRequiresAttention ? Color(red: 255 / 255, green: 151 / 255, blue: 79 / 255).opacity(0.62) : .clear, lineWidth: 1)
        )
        .accessibilityIdentifier("onboarding.agreement.toggle")
    }
}

private struct RegistrationProviderButton: View {
    enum Style {
        case apple
        case wechat
        case outline
    }

    let title: String
    let systemImage: String
    let style: Style
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(borderColor, lineWidth: 0.9)
            )
            .shadow(color: shadowColor, radius: 14, x: 0, y: 7)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.46)
    }

    private var foreground: Color {
        switch style {
        case .apple, .wechat:
            return style == .apple ? .white : VitoraTheme.ColorToken.strongText
        case .outline:
            return VitoraTheme.ColorToken.strongText
        }
    }

    private var background: some ShapeStyle {
        switch style {
        case .apple:
            return AnyShapeStyle(VitoraTheme.ColorToken.strongText)
        case .wechat:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.78),
                        Color(red: 231 / 255, green: 250 / 255, blue: 222 / 255).opacity(0.72),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .outline:
            return AnyShapeStyle(Color.white.opacity(0.64))
        }
    }

    private var borderColor: Color {
        switch style {
        case .apple:
            return Color.white.opacity(0.10)
        case .wechat:
            return Color(red: 145 / 255, green: 218 / 255, blue: 118 / 255).opacity(0.42)
        case .outline:
            return VitoraTheme.ColorToken.secondaryText.opacity(0.22)
        }
    }

    private var shadowColor: Color {
        switch style {
        case .apple:
            return VitoraTheme.ColorToken.strongText.opacity(0.14)
        case .wechat, .outline:
            return VitoraTheme.ColorToken.paperLiftShadow.opacity(0.08)
        }
    }
}

private struct RegistrationSoftVitoraMascot: View {
    let reduceMotion: Bool

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let floatY = reduceMotion ? 0 : sin(time * .pi * 2 / 4.8) * 3.5
            let shimmer = reduceMotion ? 0 : (sin(time * .pi * 2 / 5.6) + 1) / 2

            ZStack {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 255 / 255, green: 180 / 255, blue: 130 / 255).opacity(0.34),
                                Color(red: 116 / 255, green: 203 / 255, blue: 250 / 255).opacity(0.12),
                                .clear,
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: 95
                        )
                    )
                    .frame(width: 180, height: 42)
                    .offset(y: 78)
                    .blur(radius: 8)

                RegistrationMascotBlobShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.50),
                                Color(red: 243 / 255, green: 199 / 255, blue: 255 / 255).opacity(0.55),
                                Color(red: 255 / 255, green: 114 / 255, blue: 177 / 255).opacity(0.74),
                                Color(red: 255 / 255, green: 129 / 255, blue: 45 / 255).opacity(0.82),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RegistrationMascotBlobShape()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 255 / 255, green: 232 / 255, blue: 79 / 255).opacity(0.40),
                                        Color.clear,
                                    ],
                                    center: UnitPoint(x: 0.58, y: 0.66),
                                    startRadius: 0,
                                    endRadius: 78
                                )
                            )
                    }
                    .overlay {
                        RegistrationMascotBlobShape()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 106 / 255, green: 170 / 255, blue: 255 / 255).opacity(0.28),
                                        Color.clear,
                                    ],
                                    center: UnitPoint(x: 0.08, y: 0.70),
                                    startRadius: 0,
                                    endRadius: 86
                                )
                            )
                    }
                    .overlay {
                        RegistrationMascotBlobShape()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.72),
                                        Color.white.opacity(0.18),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.1
                            )
                    }
                    .shadow(color: Color(red: 255 / 255, green: 130 / 255, blue: 97 / 255).opacity(0.18), radius: 18, x: 8, y: 12)
                    .shadow(color: Color(red: 110 / 255, green: 160 / 255, blue: 255 / 255).opacity(0.14), radius: 14, x: -8, y: 10)
                    .frame(width: 188, height: 140)
                    .offset(y: floatY)
                    .overlay(alignment: .topLeading) {
                        RegistrationMascotHighlight()
                            .frame(width: 74, height: 44)
                            .offset(x: 38, y: 14 + floatY)
                            .opacity(0.38 + shimmer * 0.16)
                    }
                    .overlay {
                        HStack(spacing: 22) {
                            PixelEyeCurve()
                            PixelEyeCurve()
                        }
                        .offset(x: 22, y: 8 + floatY)
                    }

                PixelSparkle(color: Color(red: 255 / 255, green: 151 / 255, blue: 205 / 255), size: 18)
                    .offset(x: 64, y: -70 + floatY * 0.35)
                    .opacity(0.72)

                PixelSparkle(color: Color(red: 87 / 255, green: 200 / 255, blue: 240 / 255), size: 15)
                    .offset(x: 92, y: -45 + floatY * 0.2)
                    .opacity(0.58)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityLabel("Vitora 玻璃像素伙伴")
        }
    }
}

private struct RegistrationMascotBlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.minY + rect.height * 0.53))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.50, y: rect.minY + rect.height * 0.03),
            control1: CGPoint(x: rect.minX + rect.width * 0.16, y: rect.minY + rect.height * 0.28),
            control2: CGPoint(x: rect.minX + rect.width * 0.30, y: rect.minY + rect.height * 0.02)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.94, y: rect.minY + rect.height * 0.45),
            control1: CGPoint(x: rect.minX + rect.width * 0.77, y: rect.minY + rect.height * 0.03),
            control2: CGPoint(x: rect.minX + rect.width * 0.93, y: rect.minY + rect.height * 0.25)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.62, y: rect.minY + rect.height * 0.96),
            control1: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.72),
            control2: CGPoint(x: rect.minX + rect.width * 0.84, y: rect.minY + rect.height * 0.95)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.minY + rect.height * 0.84),
            control1: CGPoint(x: rect.minX + rect.width * 0.37, y: rect.maxY),
            control2: CGPoint(x: rect.minX + rect.width * 0.11, y: rect.minY + rect.height * 0.99)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.minY + rect.height * 0.53),
            control1: CGPoint(x: rect.minX - rect.width * 0.04, y: rect.minY + rect.height * 0.68),
            control2: CGPoint(x: rect.minX + rect.width * 0.02, y: rect.minY + rect.height * 0.52)
        )
        path.closeSubpath()
        return path
    }
}

private struct RegistrationMascotHighlight: View {
    var body: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.72),
                        Color.white.opacity(0.06),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .rotationEffect(.degrees(-16))
            .blur(radius: 0.8)
            .accessibilityHidden(true)
    }
}

private struct PixelEyeCurve: View {
    var body: some View {
        Canvas { context, size in
            let unit = min(size.width, size.height) / 5
            let blocks: [(CGFloat, CGFloat)] = [
                (0, 2), (1, 1), (2, 0), (3, 1), (4, 2)
            ]

            for block in blocks {
                let rect = CGRect(
                    x: block.0 * unit,
                    y: block.1 * unit,
                    width: unit * 0.92,
                    height: unit * 0.92
                )
                context.fill(
                    Path(roundedRect: rect, cornerRadius: unit * 0.12),
                    with: .color(Color.white.opacity(0.96))
                )
            }
        }
        .frame(width: 34, height: 24)
        .accessibilityHidden(true)
    }
}

private struct OnboardingOrganicBlob: View {
    let color: Color
    let rotation: Double

    var body: some View {
        UnevenRoundedRectangle(
            topLeadingRadius: 80,
            bottomLeadingRadius: 40,
            bottomTrailingRadius: 92,
            topTrailingRadius: 68,
            style: .continuous
        )
        .fill(color.opacity(0.72))
        .rotationEffect(.degrees(rotation))
        .blur(radius: 0.2)
        .accessibilityHidden(true)
    }
}

private struct PixelSparkle: View {
    let color: Color
    let size: CGFloat

    var body: some View {
        Canvas { context, canvasSize in
            let unit = min(canvasSize.width, canvasSize.height) / 7
            func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
                context.fill(
                    Path(CGRect(x: x * unit, y: y * unit, width: w * unit, height: h * unit)),
                    with: .color(color)
                )
            }
            rect(3, 0, 1, 2)
            rect(3, 5, 1, 2)
            rect(0, 3, 2, 1)
            rect(5, 3, 2, 1)
            rect(2, 2, 3, 3)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

private struct SupportGlyph: View {
    var body: some View {
        Image(systemName: "headphones")
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(VitoraTheme.ColorToken.strongText.opacity(0.78))
            .frame(width: 42, height: 42)
            .accessibilityHidden(true)
    }
}
