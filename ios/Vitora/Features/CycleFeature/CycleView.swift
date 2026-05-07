import SwiftUI

struct CycleView: View {
    @ObservedObject var environment: AppEnvironment
    @State private var sheet: CycleSheet?

    var body: some View {
        ZStack {
            AuraBackground(intensity: 1.0)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 17) {
                    header

                    AskableTipHint()
                        .padding(.leading, 2)

                    CurrentPhaseRelationCard(
                        onOpenDetail: { sheet = .phase },
                        onAskVitora: { openVitora(source: "周期阶段", summary: "黄体期 Day 18") }
                    )

                    EnergyDynamicsCard(
                        onOpenDetail: { sheet = .energy },
                        onAskVitora: { openVitora(source: "能量动态", summary: "本周平均 62% · 周三后恢复变慢") }
                    )
                }
                .padding(.horizontal, VitoraTheme.Spacing.screenMargin)
                .padding(.top, 16)
                .padding(.bottom, VitoraTheme.Size.tabBarHeight + 40)
            }
        }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .phase:
                CurrentPhaseDetailSheet(
                    onClose: { self.sheet = nil },
                    onAskVitora: { openVitora(source: "当前周期阶段", summary: "用户想校准日期或感受") }
                )
            case .energy:
                EnergyDynamicsDetailSheet(
                    onClose: { self.sheet = nil },
                    onAskVitora: { openVitora(source: "能量动态", summary: "解释趋势或某个低点") }
                )
            case .settings:
                SettingsPanel(onClose: { self.sheet = nil })
            }
        }
        .accessibilityIdentifier("cycle.pivot.surface")
    }

    private var header: some View {
        HStack {
            Text("周期")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)

            Spacer()

            Button {
                sheet = .settings
            } label: {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 23, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                    .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .frame(width: VitoraTheme.Size.touchTargetMin, height: VitoraTheme.Size.touchTargetMin)
            .accessibilityLabel("打开我的与设置")
            .accessibilityIdentifier("cycle.settings.open")
        }
    }

    private func openVitora(source: String, summary: String) {
        environment.openVitoraContext(
            sourceTitle: source,
            sourceSummary: summary,
            prompt: "Vitora 会带着这个长期节律上下文来解释或校准。"
        )
        sheet = nil
    }
}

private enum CycleSheet: Identifiable {
    case phase
    case energy
    case settings

    var id: String {
        switch self {
        case .phase:
            return "phase"
        case .energy:
            return "energy"
        case .settings:
            return "settings"
        }
    }
}
