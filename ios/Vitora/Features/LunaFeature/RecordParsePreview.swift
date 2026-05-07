import SwiftUI

struct RecordParsePreview: View {
    let preview: LunaRecordParsePreview
    @Binding var summary: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: VitoraTheme.Spacing.sm) {
            HStack {
                Text("Vitora 理解为")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)

                Spacer()

                Text(typeTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .padding(.horizontal, VitoraTheme.Spacing.sm)
                    .padding(.vertical, 5)
                    .background(VitoraTheme.ColorToken.actionPrimarySoft)
                    .clipShape(Capsule())
            }

            TextField("调整 Luna 的理解", text: $summary)
                .font(.subheadline)
                .foregroundStyle(VitoraTheme.ColorToken.primaryText)
                .textFieldStyle(.plain)
                .padding(VitoraTheme.Spacing.sm)
                .frame(minHeight: 58, alignment: .topLeading)
                .background(VitoraTheme.ColorToken.softSurface)
                .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.md, style: .continuous))
                .accessibilityIdentifier("luna.record.preview.summary")

            HStack(spacing: VitoraTheme.Spacing.xs) {
                ForEach(preview.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .padding(.horizontal, VitoraTheme.Spacing.xs)
                        .padding(.vertical, 5)
                        .background(VitoraTheme.ColorToken.paper)
                        .clipShape(Capsule())
                }
            }

            Text(preview.complianceLabelID == "CL-AI-UNAVAILABLE" ? "AI 暂不可用，仍可按你的确认保存。" : "Luna 只会把确认后的内容作为上下文。")
                .font(.caption)
                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)

            HStack(spacing: VitoraTheme.Spacing.sm) {
                Button("取消", action: onCancel)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
                    .background(VitoraTheme.ColorToken.softSurface)
                    .clipShape(Capsule())
                    .accessibilityIdentifier("luna.record.cancel")

                Button("保存", action: onSave)
                    .font(.callout.weight(.bold))
                    .foregroundStyle(VitoraTheme.ColorToken.paper)
                    .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
                    .background(VitoraTheme.ColorToken.shell)
                    .clipShape(Capsule())
                    .accessibilityIdentifier("luna.record.save")
            }
        }
        .padding(VitoraTheme.Spacing.md)
        .background(VitoraTheme.ColorToken.paper)
        .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.lg, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }

    private var typeTitle: String {
        switch preview.detectedType {
        case .energy:
            "能量"
        case .cycle:
            "周期"
        case .sleep:
            "睡眠"
        case .mood:
            "感受"
        case .nutrition:
            "营养补给"
        case .freeText:
            "自由备注"
        }
    }
}
