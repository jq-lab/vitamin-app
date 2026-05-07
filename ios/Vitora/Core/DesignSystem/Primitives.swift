import SwiftUI

struct VitoraPrimaryButton: View {
    let title: LocalizedStringKey
    var isLoading: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                }
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, minHeight: VitoraTheme.Size.touchTargetMin)
        }
        .buttonStyle(.borderedProminent)
        .tint(VitoraTheme.ColorToken.actionPrimary)
        .disabled(isLoading)
    }
}

struct VitoraChip: View {
    let title: LocalizedStringKey
    var isSelected: Bool

    var body: some View {
        Text(title)
            .font(.callout)
            .padding(.horizontal, VitoraTheme.Spacing.md)
            .frame(minHeight: VitoraTheme.Size.touchTargetMin)
            .background(isSelected ? VitoraTheme.ColorToken.actionPrimary.opacity(0.18) : VitoraTheme.ColorToken.softSurface)
            .clipShape(Capsule())
            .foregroundStyle(isSelected ? VitoraTheme.ColorToken.actionPrimaryDeep : VitoraTheme.ColorToken.primaryText)
    }
}

struct VitoraTextField: View {
    let title: LocalizedStringKey
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .textFieldStyle(.plain)
            .padding(.horizontal, VitoraTheme.Spacing.md)
            .frame(minHeight: VitoraTheme.Size.touchTargetMin)
            .background(VitoraTheme.ColorToken.softSurface)
            .clipShape(RoundedRectangle(cornerRadius: VitoraTheme.Radius.md, style: .continuous))
    }
}

struct VitoraProgressBar: View {
    var progress: Double

    var body: some View {
        ProgressView(value: min(max(progress, 0), 1))
            .tint(VitoraTheme.ColorToken.actionPrimary)
    }
}

enum ComplianceLabelKind: String {
    case defaultLifestyle
    case vitora
    case lowData
    case nutrition
    case dataControl
    case aiUnavailable

    var text: String {
        switch self {
        case .defaultLifestyle:
            "本内容仅供生活方式参考，不替代专业意见。"
        case .vitora:
            "Vitora 的理解来自你提供的数据和记录，可作为生活方式参考。"
        case .lowData:
            "当前可用信息较少，你可以继续手动记录，或稍后连接 HealthKit。"
        case .nutrition:
            "Vitora 只记录你已经在使用的内容，不引导你新增或购买。"
        case .dataControl:
            "你可以导出个人数据，也可以移除账号和本地数据。"
        case .aiUnavailable:
            "Vitora 暂时无法生成新回复，你仍可以保存记录。"
        }
    }

    var accessibilityID: String {
        "compliance.\(rawValue)"
    }
}

struct ComplianceLabel: View {
    private let localizedText: LocalizedStringKey?
    private let literalText: String?
    private let identifier: String

    init(text: LocalizedStringKey) {
        localizedText = text
        literalText = nil
        identifier = "compliance.label"
    }

    init(_ kind: ComplianceLabelKind) {
        localizedText = nil
        literalText = kind.text
        identifier = kind.accessibilityID
    }

    var body: some View {
        Group {
            if let literalText {
                Text(literalText)
            } else if let localizedText {
                Text(localizedText)
            }
        }
        .font(.footnote)
        .lineSpacing(2)
        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
        .accessibilityIdentifier(identifier)
    }
}
