import SwiftUI

struct LunaTopBar: View {
    var body: some View {
        HStack(spacing: VitoraTheme.Spacing.md) {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                .accessibilityIdentifier("luna.lightDrawer.entry")

            Text("AI 对话")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.primaryText)

            Text("记录本")
                .font(.subheadline)
                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)

            Spacer()
        }
        .frame(maxWidth: VitoraTheme.Size.contentWidth)
    }
}

struct LunaDateContextRow: View {
    let text: String

    var body: some View {
        HStack(spacing: VitoraTheme.Spacing.sm) {
            Text("今天")
                .font(.headline.weight(.semibold))
                .foregroundStyle(VitoraTheme.ColorToken.primaryText)

            Text("5月4日（周一）  \(text)  >")
                .font(.footnote)
                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                .lineLimit(1)

            Spacer()
        }
        .frame(maxWidth: VitoraTheme.Size.contentWidth)
    }
}

struct LunaContextBubble: View {
    let state: LunaHomeState
    let onOpenRecord: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: VitoraTheme.Spacing.sm) {
            PixelLunaMiniIcon()
                .frame(width: 28, height: 28)
                .padding(.top, 2)

            Button(action: onOpenRecord) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(state.contextSummary)
                        .font(.subheadline)
                        .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                        .lineLimit(2)

                    Text(state.contextDetail)
                        .font(.caption)
                        .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                        .lineLimit(2)
                }
                .padding(.horizontal, VitoraTheme.Spacing.md)
                .padding(.vertical, VitoraTheme.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(VitoraTheme.ColorToken.softSurface)
                .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.lg, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("luna.context.bubble")
        }
        .frame(maxWidth: VitoraTheme.Size.contentWidth)
    }
}

struct LunaRecentRecordCard: View {
    let summary: String

    var body: some View {
        HStack(alignment: .top, spacing: VitoraTheme.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(VitoraTheme.ColorToken.success)
                .font(.headline)

            VStack(alignment: .leading, spacing: 3) {
                Text("已保存为 Vitora 上下文")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    .accessibilityIdentifier("luna.record.recent.title")

                Text(summary)
                    .font(.footnote)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .lineLimit(2)
                    .accessibilityIdentifier("luna.record.recent.summary")
            }

            Spacer()
        }
        .padding(VitoraTheme.Spacing.md)
        .frame(maxWidth: VitoraTheme.Size.contentWidth)
        .background(VitoraTheme.ColorToken.paper.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: VitoraTheme.Radius.card, style: .continuous)
                .stroke(VitoraTheme.ColorToken.success.opacity(0.18), lineWidth: 0.8)
        )
    }
}

struct LunaInputDock: View {
    let onOpenRecord: () -> Void
    let onOpenChat: () -> Void

    var body: some View {
        HStack(spacing: VitoraTheme.Spacing.xs) {
            Button(action: onOpenRecord) {
                Text("+")
                    .font(.title3)
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .frame(width: 38, height: 38)
                    .background(VitoraTheme.ColorToken.softSurface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("luna.record.open.plus")

            Button(action: onOpenChat) {
                Text("问 Vitora，或记录一件事...")
                    .font(.caption)
                    .foregroundStyle(Color(red: 184 / 255, green: 184 / 255, blue: 194 / 255))
                    .frame(maxWidth: .infinity, minHeight: 38, alignment: .leading)
                    .padding(.horizontal, VitoraTheme.Spacing.md)
                    .background(VitoraTheme.ColorToken.softSurface)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("luna.chat.open.input")

            Button(action: onOpenChat) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(VitoraTheme.ColorToken.paper)
                    .frame(width: 38, height: 38)
                    .background(VitoraTheme.ColorToken.shell)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("luna.chat.open.send")
        }
        .frame(maxWidth: VitoraTheme.Size.contentWidth)
        .frame(height: VitoraTheme.Size.inputDockHeight)
    }
}

private struct PixelLunaMiniIcon: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(VitoraTheme.ColorToken.actionPrimarySoft)
            .overlay {
                PixelLunaGlyph(block: 2)
            }
    }
}
