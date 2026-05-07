import SwiftUI

struct LegalAccountPanel: View {
    @State private var request: AccountRemovalRequest
    @State private var gateState: AppGateState?

    private let service = AccountRemovalService()

    init() {
        _request = State(initialValue: service.requestRemoval())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            supportInfoBlock(
                title: "隐私与法律",
                body: "Vitora 是生活方式辅助工具，不提供诊断或治疗。健康相关解释和建议必须保持可选、温和、非确定。",
                systemImage: "lock.shield"
            )

            ComplianceLabel(.dataControl)
                .padding(.horizontal, 4)

            supportInfoBlock(
                title: "账号移除",
                body: "移除会清理本地账号数据，并让 app 回到可解释的新开始状态。危险动作必须先确认。",
                systemImage: "trash"
            )

            removalState
        }
    }

    @ViewBuilder
    private var removalState: some View {
        switch request.state {
        case .viewing:
            actionButton(title: "开始账号移除", systemImage: "trash", identifier: "support.account.start", role: .destructive, isDestructive: true) {
                request = service.beginConfirmation(request)
            }
        case .confirming:
            supportInfoBlock(
                title: "再次确认",
                body: "这会移除本地账号数据。你可以取消并先导出数据。",
                systemImage: "exclamationmark.triangle"
            )
            actionButton(title: "确认移除本地账号数据", systemImage: "trash", identifier: "support.account.confirm", role: .destructive, isDestructive: true) {
                let persistence = InMemoryPersistenceClient()
                if let result = try? service.complete(request, persistence: persistence) {
                    request = result.request
                    gateState = result.gateState
                }
            }
        case .completed:
            supportInfoBlock(
                title: "账号移除已完成",
                body: gateState == .needsOnboarding ? "App 已回到新开始状态。" : "本地移除流程已结束。",
                systemImage: "checkmark.seal"
            )
        case .processing:
            supportInfoBlock(title: "正在移除", body: "请稍等。", systemImage: "hourglass")
        case .error:
            supportInfoBlock(title: "移除暂时失败", body: "请稍后重试。", systemImage: "exclamationmark.triangle")
        case .canceled:
            supportInfoBlock(title: "移除已取消", body: "没有清理本地账号数据。", systemImage: "xmark.circle")
        }
    }
}

@MainActor
func actionButton(
    title: String,
    systemImage: String,
    identifier: String,
    role: ButtonRole? = nil,
    isDestructive: Bool = false,
    action: @escaping () -> Void
) -> some View {
    Button(role: role, action: action) {
        Label(title, systemImage: systemImage)
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .foregroundStyle(.white)
            .background(isDestructive ? VitoraTheme.ColorToken.warm : VitoraTheme.ColorToken.actionPrimaryDeep)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier(identifier)
}
