import SwiftUI

struct AuraBackground: View {
    var intensity: Double = 1

    var body: some View {
        ZStack {
            VitoraTheme.ColorToken.auraCanvas
            Circle()
                .fill(VitoraTheme.ColorToken.auraCyan.opacity(0.34 * intensity))
                .frame(width: 310, height: 310)
                .blur(radius: 48)
                .offset(x: 140, y: -230)
            Circle()
                .fill(VitoraTheme.ColorToken.auraBlue.opacity(0.24 * intensity))
                .frame(width: 270, height: 270)
                .blur(radius: 62)
                .offset(x: -145, y: 20)
            Circle()
                .fill(VitoraTheme.ColorToken.auraLavender.opacity(0.16 * intensity))
                .frame(width: 250, height: 250)
                .blur(radius: 58)
                .offset(x: 125, y: 250)
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("aura.background")
    }
}

struct GlassSurface: View {
    var cornerRadius: CGFloat = VitoraTheme.Radius.card
    var opacity: Double = 0.50

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(VitoraTheme.ColorToken.paper.opacity(opacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(VitoraTheme.ColorToken.paper.opacity(0.78), lineWidth: 0.8)
            )
            .shadow(color: VitoraTheme.ColorToken.auraBlue.opacity(0.12), radius: 18, x: 0, y: 9)
            .accessibilityIdentifier("glass.surface")
    }
}

struct SupportGlassSurface: View {
    var body: some View {
        GlassSurface(cornerRadius: VitoraTheme.Radius.card, opacity: 0.72)
    }
}

struct InputDockSurface: View {
    var body: some View {
        Capsule(style: .continuous)
            .fill(.ultraThinMaterial)
            .background(Capsule(style: .continuous).fill(VitoraTheme.ColorToken.paper.opacity(0.62)))
            .overlay(Capsule(style: .continuous).stroke(VitoraTheme.ColorToken.paper.opacity(0.86), lineWidth: 0.8))
            .shadow(color: VitoraTheme.ColorToken.auraBlue.opacity(0.14), radius: 18, x: 0, y: 8)
            .accessibilityIdentifier("input.dock.surface")
    }
}

struct VitoraCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(VitoraTheme.Spacing.md)
            .background(VitoraTheme.ColorToken.paper)
            .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.card, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 8)
    }
}

struct VitoraSheetSurface<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: VitoraTheme.Spacing.md) {
            Capsule()
                .fill(VitoraTheme.ColorToken.secondaryText.opacity(0.35))
                .frame(width: 42, height: 4)

            content
        }
        .padding(VitoraTheme.Spacing.lg)
        .background(VitoraTheme.ColorToken.paper)
        .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.sheet, style: .continuous))
    }
}
